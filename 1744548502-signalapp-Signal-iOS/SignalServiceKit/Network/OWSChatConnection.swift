//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient

public enum OWSChatConnectionType: Int, CaseIterable, CustomDebugStringConvertible {
    case identified = 0
    case unidentified = 1

    public var debugDescription: String {
        switch self {
        case .identified:
            return "[type: identified]"
        case .unidentified:
            return "[type: unidentified]"
        }
    }
}

// MARK: -

public enum OWSChatConnectionState: Int, CustomDebugStringConvertible {
    case closed = 0
    case connecting = 1
    case open = 2

    public var debugDescription: String {
        switch self {
        case .closed:
            return "closed"
        case .connecting:
            return "connecting"
        case .open:
            return "open"
        }
    }
}

// MARK: -
public class OWSChatConnection {
    // TODO: Should we use a higher-priority queue?
    fileprivate static let messageProcessingQueue = DispatchQueue(label: "org.signal.chat-connection.message-processing")

    public typealias RequestSuccess = (HTTPResponse) -> Void
    public typealias RequestFailure = (OWSHTTPError) -> Void
    fileprivate typealias RequestSuccessInternal = (HTTPResponse, RequestInfo) -> Void

    public static let chatConnectionStateDidChange = Notification.Name("chatConnectionStateDidChange")

    fileprivate let serialQueue: DispatchQueue

    // MARK: -

    fileprivate let type: OWSChatConnectionType
    fileprivate let appExpiry: AppExpiry
    fileprivate let  appReadiness: AppReadiness
    fileprivate let db: any DB
    fileprivate let accountManager: TSAccountManager
    fileprivate let currentCallProvider: any CurrentCallProvider
    fileprivate let registrationStateChangeManager: RegistrationStateChangeManager

    // This var must be thread-safe.
    public var currentState: OWSChatConnectionState {
        owsFailDebug("should be using a concrete subclass")
        return .closed
    }

    // This var must be thread-safe.
    public var hasEmptiedInitialQueue: Bool {
        false
    }

    // We cache this value instead of consulting [UIApplication sharedApplication].applicationState,
    // because UIKit only provides a "will resign active" notification, not a "did resign active"
    // notification.
    private let appIsActive = AtomicBool(false, lock: .sharedGlobal)

    private static let unsubmittedRequestTokenCounter = AtomicUInt(lock: .sharedGlobal)
    public typealias UnsubmittedRequestToken = UInt
    // This method is thread-safe.
    public func makeUnsubmittedRequestToken() -> UnsubmittedRequestToken {
        let token = Self.unsubmittedRequestTokenCounter.increment()
        unsubmittedRequestTokens.insert(token)
        applyDesiredSocketState()
        return token
    }
    private let unsubmittedRequestTokens = AtomicSet<UnsubmittedRequestToken>(lock: .sharedGlobal)
    // This method is thread-safe.
    fileprivate func removeUnsubmittedRequestToken(_ token: UnsubmittedRequestToken) {
        let hadToken = unsubmittedRequestTokens.remove(token)
        owsAssertDebug(hadToken)
        applyDesiredSocketState()
    }

    // MARK: - BackgroundKeepAlive

    fileprivate enum BackgroundKeepAliveRequestType {
        case didReceivePush
        case receiveMessage
        case receiveResponse

        var keepAliveDuration: TimeInterval {
            // If the app is in the background, it should keep the
            // websocket open if:
            switch self {
            case .didReceivePush:
                // Received a push notification in the last N seconds.
                return 20
            case .receiveMessage:
                // It has received a message over the socket in the last N seconds.
                return 15
            case .receiveResponse:
                // It has just received the response to a request.
                return 5
            }
            // There are many other cases as well not associated with a fixed duration,
            // such as if currentWebSocket.hasPendingRequests; see shouldSocketBeOpen().
        }
    }

    private struct BackgroundKeepAlive {
        let requestType: BackgroundKeepAliveRequestType
        let untilDate: Date
    }

    // This var should only be accessed with unfairLock acquired.
    private var _backgroundKeepAlive: BackgroundKeepAlive?
    private let unfairLock = UnfairLock()

    // This method is thread-safe.
    fileprivate func ensureBackgroundKeepAlive(_ requestType: BackgroundKeepAliveRequestType) {
        let keepAliveDuration = requestType.keepAliveDuration
        owsAssertDebug(keepAliveDuration > 0)
        let untilDate = Date().addingTimeInterval(keepAliveDuration)

        let didChange: Bool = unfairLock.withLock {
            if let oldValue = self._backgroundKeepAlive,
               oldValue.untilDate >= untilDate {
                return false
            }
            self._backgroundKeepAlive = BackgroundKeepAlive(requestType: requestType, untilDate: untilDate)
            return true
        }

        if didChange {
            var backgroundTask: OWSBackgroundTask? = OWSBackgroundTask(label: "applicationWillResignActive")
            applyDesiredSocketState {
                assertOnQueue(self.serialQueue)
                owsAssertDebug(backgroundTask != nil)
                backgroundTask = nil
            }
        }
    }

    // This var is thread-safe.
    private var hasBackgroundKeepAlive: Bool {
        unfairLock.withLock {
            guard let backgroundKeepAlive = self._backgroundKeepAlive else {
                return false
            }
            guard backgroundKeepAlive.untilDate >= Date() else {
                // Cull expired values.
                self._backgroundKeepAlive = nil
                return false
            }
            return true
        }
    }

    fileprivate var logPrefix: String {
        "[\(type)]"
    }

    // MARK: -

    public init(
        type: OWSChatConnectionType,
        accountManager: TSAccountManager,
        appExpiry: AppExpiry,
        appReadiness: AppReadiness,
        currentCallProvider: any CurrentCallProvider,
        db: any DB,
        registrationStateChangeManager: RegistrationStateChangeManager
    ) {
        AssertIsOnMainThread()

        self.serialQueue = DispatchQueue(label: "org.signal.chat-connection-\(type)")
        self.type = type
        self.appExpiry = appExpiry
        self.appReadiness = appReadiness
        self.db = db
        self.accountManager = accountManager
        self.currentCallProvider = currentCallProvider
        self.registrationStateChangeManager = registrationStateChangeManager

        appReadiness.runNowOrWhenAppDidBecomeReadySync { [weak self] in
            guard let self = self else { return }
            self.appDidBecomeReady()
            self.applyDesiredSocketState()
        }
    }

    // MARK: - Notifications

    // We want to observe these notifications lazily to avoid accessing
    // the data store in [application: didFinishLaunchingWithOptions:].
    fileprivate func appDidBecomeReady() {
        AssertIsOnMainThread()

        appIsActive.set(CurrentAppContext().isMainAppAndActive)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .OWSApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: .OWSApplicationWillResignActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(registrationStateDidChange),
                                               name: .registrationStateDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(isCensorshipCircumventionActiveDidChange),
                                               name: .isCensorshipCircumventionActiveDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(isSignalProxyReadyDidChange),
                                               name: .isSignalProxyReadyDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appExpiryDidChange),
                                               name: AppExpiryImpl.AppExpiryDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storiesEnabledStateDidChange), name: .storiesEnabledStateDidChange, object: nil)
    }

    // MARK: -

    private struct StateObservation {
        var currentState: OWSChatConnectionState
        var onOpen: [NSObject: CancellableContinuation<Void>]
    }

    /// This lock is sometimes waited on within an async context; make sure *all* uses release the lock quickly.
    private let stateObservation = AtomicValue(
        StateObservation(currentState: .closed, onOpen: [:]),
        lock: .init()
    )

    fileprivate func notifyStatusChange(newState: OWSChatConnectionState) {
        // Technically this would be safe to call from anywhere,
        // but requiring it to be on the serial queue means it's less likely
        // for a caller to check a condition that's immediately out of date (a race).
        assertOnQueue(serialQueue)

        let (oldState, continuationsToResolve): (OWSChatConnectionState, [NSObject: CancellableContinuation<Void>])
        (oldState, continuationsToResolve) = stateObservation.update {
            let oldState = $0.currentState
            if newState == oldState {
                return (oldState, [:])
            }
            $0.currentState = newState

            var continuationsToResolve: [NSObject: CancellableContinuation<Void>] = [:]
            if case .open = newState {
                continuationsToResolve = $0.onOpen
                $0.onOpen = [:]
            }

            return (oldState, continuationsToResolve)
        }
        if newState != oldState {
            Logger.info("\(logPrefix): \(oldState) -> \(newState)")
        }
        for (_, waiter) in continuationsToResolve {
            waiter.resume(with: .success(()))
        }
        NotificationCenter.default.postOnMainThread(name: Self.chatConnectionStateDidChange, object: nil)
    }

    fileprivate var cachedCurrentState: OWSChatConnectionState {
        stateObservation.get().currentState
    }

    /// Only throws on cancellation.
    func waitForOpen() async throws {
        let cancellationToken = NSObject()
        let cancellableContinuation = CancellableContinuation<Void>()
        stateObservation.update {
            if $0.currentState == .open {
                cancellableContinuation.resume(with: .success(()))
            } else {
                $0.onOpen[cancellationToken] = cancellableContinuation
            }
        }
        try await withTaskCancellationHandler(
            operation: cancellableContinuation.wait,
            onCancel: {
                // Don't cancel because CancellableContinuation does that.
                // We just clean up the state so that we don't leak memory.
                stateObservation.update { _ = $0.onOpen.removeValue(forKey: cancellationToken) }
            }
        )
    }

    // MARK: - Socket LifeCycle

    public static var canAppUseSocketsToMakeRequests: Bool {
        if !CurrentAppContext().isMainApp {
            return false
        }
        return true
    }

    // This var is thread-safe.
    public var shouldSocketBeOpen: Bool {
        desiredSocketState?.shouldSocketBeOpen ?? false
    }

    fileprivate enum DesiredSocketState: Equatable {
        case closed(reason: String)
        case open(reason: String)

        public var shouldSocketBeOpen: Bool {
            switch self {
            case .closed:
                return false
            case .open:
                return true
            }
        }
    }

    // This method is thread-safe.
    fileprivate var desiredSocketState: DesiredSocketState? {
        guard appReadiness.isAppReady else {
            return .closed(reason: "!isAppReady")
        }

        guard self.accountManager.registrationStateWithMaybeSneakyTransaction.isRegistered else {
            return .closed(reason: "!isRegisteredAndReady")
        }

        guard !appExpiry.isExpired else {
            return .closed(reason: "appExpiry.isExpired")
        }

        guard Self.canAppUseSocketsToMakeRequests else {
            return .closed(reason: "!canAppUseSocketsToMakeRequests")
        }

        if !unsubmittedRequestTokens.isEmpty {
            return .open(reason: "unsubmittedRequestTokens")
        }

        if appIsActive.get() {
            // While app is active, keep web socket alive.
            return .open(reason: "appIsActive")
        }

        if hasBackgroundKeepAlive {
            // If app is doing any work in the background, keep web socket alive.
            return .open(reason: "hasBackgroundKeepAlive")
        }

        if currentCallProvider.hasCurrentCall {
            // If the user is on a call, we need to be able to send/receive messages.
            return .open(reason: "hasCurrentCall")
        }

        return nil
    }

    // This method is thread-safe.
    public func didReceivePush() {
        owsAssertDebug(appReadiness.isAppReady)

        self.ensureBackgroundKeepAlive(.didReceivePush)
    }

    // This method aligns the socket state with the "desired" socket state.
    //
    // This method is thread-safe.
    fileprivate func applyDesiredSocketState(completion: (() -> Void)? = nil) {

        guard appReadiness.isAppReady else {
            appReadiness.runNowOrWhenAppDidBecomeReadySync { [weak self] in
                self?.applyDesiredSocketState(completion: completion)
            }
            return
        }

        serialQueue.async { [weak self] in
            guard let self = self else {
                completion?()
                return
            }

            var shouldHaveBackgroundKeepAlive = false
            if self.shouldSocketBeOpen {
                self.ensureWebsocketExists()

                // If we're keeping the webSocket open in the background,
                // ensure that the "BackgroundKeepAlive" state is active.
                shouldHaveBackgroundKeepAlive = !self.appIsActive.get()
            } else {
                self.disconnectIfNeeded()
            }

            if shouldHaveBackgroundKeepAlive {
                if nil == self.backgroundKeepAliveTimer {
                    // Start a new timer that will fire every second while the socket is open in the background.
                    // This timer will ensure we close the websocket when the time comes.
                    self.backgroundKeepAliveTimer = OffMainThreadTimer(timeInterval: 1, repeats: true) { [weak self] timer in
                        guard let self = self else {
                            timer.invalidate()
                            return
                        }
                        self.applyDesiredSocketState()
                    }
                }
                if nil == self.backgroundKeepAliveBackgroundTask {
                    self.backgroundKeepAliveBackgroundTask = OWSBackgroundTask(label: "BackgroundKeepAlive") { [weak self] (_) in
                        AssertIsOnMainThread()
                        self?.applyDesiredSocketState()
                    }
                }
            } else {
                self.backgroundKeepAliveTimer?.invalidate()
                self.backgroundKeepAliveTimer = nil
                self.backgroundKeepAliveBackgroundTask = nil
            }

            completion?()
        }
    }

    // This timer is used to check periodically whether we should
    // close the socket.
    private var backgroundKeepAliveTimer: OffMainThreadTimer?
    // This is used to manage the iOS "background task" used to
    // keep the app alive in the background.
    private var backgroundKeepAliveBackgroundTask: OWSBackgroundTask?

    // This method must be thread-safe.
    fileprivate func cycleSocket() {
        serialQueue.async {
            self.disconnectIfNeeded()
        }
        applyDesiredSocketState()
    }

    fileprivate func ensureWebsocketExists() {
        assertOnQueue(serialQueue)
        owsFailDebug("should be using a concrete subclass")
    }

    fileprivate func disconnectIfNeeded() {
        assertOnQueue(serialQueue)
        owsFailDebug("should be using a concrete subclass")
    }

    // MARK: - Notifications

    @objc
    private func applicationDidBecomeActive(_ notification: NSNotification) {
        AssertIsOnMainThread()

        appIsActive.set(true)

        applyDesiredSocketState()
    }

    @objc
    private func applicationWillResignActive(_ notification: NSNotification) {
        AssertIsOnMainThread()

        appIsActive.set(false)

        applyDesiredSocketState()
    }

    @objc
    fileprivate func registrationStateDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        applyDesiredSocketState()
    }

    @objc
    fileprivate func isCensorshipCircumventionActiveDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        cycleSocket()
    }

    @objc
    fileprivate func isSignalProxyReadyDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        guard SignalProxy.isEnabledAndReady else {
            // When we tear down the relay, everything gets canceled.
            return
        }
        // When we start the relay, we need to reconnect.
        cycleSocket()
    }

    @objc
    private func appExpiryDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        cycleSocket()
    }

    @objc
    fileprivate func storiesEnabledStateDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        cycleSocket()
    }

    // MARK: - Message Sending

    func makeRequest(_ request: TSRequest, unsubmittedRequestToken: UnsubmittedRequestToken) async throws -> HTTPResponse {
        guard !appExpiry.isExpired else {
            removeUnsubmittedRequestToken(unsubmittedRequestToken)
            throw OWSHTTPError.invalidAppState
        }

        let requestId = UInt64.random(in: .min ... .max)
        let requestDescription = "\(request) [\(requestId)]"
        do {
            Logger.info("Sending… -> \(requestDescription)")

            let (response, _) = try await withCheckedThrowingContinuation { continuation in
                self.serialQueue.async {
                    self.makeRequestInternal(
                        request,
                        requestId: requestId,
                        unsubmittedRequestToken: unsubmittedRequestToken,
                        success: { continuation.resume(returning: ($0, $1)) },
                        failure: { continuation.resume(throwing: $0) }
                    )
                }
            }

            Logger.info("HTTP \(response.responseStatusCode) <- \(requestDescription)")

            OutageDetection.shared.reportConnectionSuccess()
            return response
        } catch {
            if let statusCode = error.httpStatusCode {
                Logger.warn("HTTP \(statusCode) <- \(requestDescription)")
            } else {
                Logger.warn("Failure. <- \(requestDescription): \(error)")
            }
            throw error
        }
    }

    fileprivate func makeRequestInternal(
        _ request: TSRequest,
        requestId: UInt64,
        unsubmittedRequestToken: UnsubmittedRequestToken,
        success: @escaping RequestSuccessInternal,
        failure: @escaping RequestFailure
    ) {
        assertOnQueue(self.serialQueue)
        owsFailDebug("should be using a concrete subclass")
        failure(.invalidAppState)
    }

    // MARK: - Reconnect

    private static let socketReconnectDelaySeconds: TimeInterval = 5

    private var reconnectTimer: OffMainThreadTimer?

    fileprivate func ensureReconnectTimer() {
        assertOnQueue(serialQueue)
        if let reconnectTimer = self.reconnectTimer {
            owsAssertDebug(reconnectTimer.isValid)
        } else {
            // TODO: It'd be nice to do exponential backoff.
            self.reconnectTimer = OffMainThreadTimer(timeInterval: Self.socketReconnectDelaySeconds,
                                                     repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                self.applyDesiredSocketState()
            }
        }
    }

    fileprivate func clearReconnect() {
        assertOnQueue(serialQueue)

        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
}

public class OWSChatConnectionUsingSSKWebSocket: OWSChatConnection {

    private var _currentWebSocket = AtomicOptional<WebSocketConnection>(nil, lock: .sharedGlobal)
    fileprivate var currentWebSocket: WebSocketConnection? {
        get {
            _currentWebSocket.get()
        }
        set {
            let oldValue = _currentWebSocket.swap(newValue)

            if let oldValue, let newValue {
                owsAssertDebug(oldValue.id != newValue.id)
            }

            oldValue?.reset()

            notifyStatusChange(newState: currentState)
        }
    }

    // MARK: -

    public override var currentState: OWSChatConnectionState {
        guard let currentWebSocket = self.currentWebSocket else {
            return .closed
        }
        switch currentWebSocket.state {
        case .open:
            return .open
        case .connecting:
            return .connecting
        case .disconnected:
            return .closed
        }
    }

    // This var is thread-safe.
    public override var hasEmptiedInitialQueue: Bool {
        guard let currentWebSocket = self.currentWebSocket else {
            return false
        }
        return currentWebSocket.hasEmptiedInitialQueue.get()
    }

    fileprivate override var logPrefix: String {
        if let currentWebSocket = currentWebSocket {
            return currentWebSocket.logPrefix
        } else {
            return super.logPrefix
        }
    }

    // This method is thread-safe.
    fileprivate override var desiredSocketState: DesiredSocketState? {
        if let desire = super.desiredSocketState {
            return desire
        }
        if let currentWebSocket, currentWebSocket.hasPendingRequests {
            return .open(reason: "hasPendingRequests")
        }
        return nil
    }

    // MARK: - Message Sending

    fileprivate override func makeRequestInternal(
        _ request: TSRequest,
        requestId: UInt64,
        unsubmittedRequestToken: UnsubmittedRequestToken,
        success: @escaping RequestSuccessInternal,
        failure: @escaping RequestFailure
    ) {
        assertOnQueue(self.serialQueue)

        defer {
            removeUnsubmittedRequestToken(unsubmittedRequestToken)
        }

        guard let requestInfo = RequestInfo(
            request: request,
            requestId: requestId,
            connectionType: type,
            success: success,
            failure: failure
        ) else {
            // Failure already reported
            return
        }

        guard let currentWebSocket, currentWebSocket.state == .open else {
            Logger.warn("[\(requestId)]: Missing currentWebSocket.")
            failure(.networkFailure(.genericFailure))
            return
        }

        let requestUrl = requestInfo.requestUrl
        owsAssertDebug(requestUrl.scheme == nil)
        owsAssertDebug(requestUrl.host == nil)
        owsAssertDebug(!requestUrl.path.hasPrefix("/"))
        let requestBuilder = WebSocketProtoWebSocketRequestMessage.builder(verb: requestInfo.httpMethod,
                                                                           path: "/\(requestUrl.relativeString)",
                                                                           requestID: requestInfo.requestId)

        var httpHeaders = HttpHeaders(httpHeaders: request.allHTTPHeaderFields, overwriteOnConflict: false)
        httpHeaders.addDefaultHeaders()

        request.applyAuth(to: &httpHeaders, willSendViaWebSocket: true)

        if let existingBody = request.httpBody {
            requestBuilder.setBody(existingBody)
        } else {
            // TODO: Do we need body & headers for requests with no parameters?
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: request.parameters, options: [])
            } catch {
                owsFailDebug("[\(requestId)]: \(error)")
                requestInfo.didFailInvalidRequest()
                return
            }

            requestBuilder.setBody(jsonData)
            // If we're going to use the json serialized parameters as our body, we should overwrite
            // the Content-Type on the request.
            httpHeaders.addHeader("Content-Type",
                                  value: "application/json",
                                  overwriteOnConflict: true)
        }

        for (key, value) in httpHeaders.headers {
            requestBuilder.addHeaders("\(key):\(value)")
        }

        do {
            let requestProto = try requestBuilder.build()

            let messageBuilder = WebSocketProtoWebSocketMessage.builder()
            messageBuilder.setType(.request)
            messageBuilder.setRequest(requestProto)
            let messageData = try messageBuilder.buildSerializedData()

            guard currentWebSocket.state == .open else {
                owsFailDebug("[\(requestId)]: Socket not open.")
                requestInfo.didFailInvalidRequest()
                return
            }

            currentWebSocket.sendRequest(requestInfo: requestInfo,
                                         messageData: messageData,
                                         delegate: self)
        } catch {
            owsFailDebug("[\(requestId)]: \(error)")
            requestInfo.didFailInvalidRequest()
            return
        }
    }

    private func processWebSocketResponseMessage(_ message: WebSocketProtoWebSocketResponseMessage,
                                                 currentWebSocket: WebSocketConnection) {
        assertOnQueue(serialQueue)

        let requestId = message.requestID
        let responseStatus = message.status
        let responseData: Data? = message.hasBody ? message.body : nil

        if DebugFlags.internalLogging, message.hasMessage, let responseMessage = message.message {
            Logger.info("received WebSocket response for requestId: \(message.requestID), message: \(responseMessage)")
        }

        ensureBackgroundKeepAlive(.receiveResponse)

        var headers = HttpHeaders()
        headers.addHeaderList(message.headers, overwriteOnConflict: true)

        guard let requestInfo = currentWebSocket.popRequestInfo(forRequestId: requestId) else {
            Logger.warn("Received response to unknown request \(currentWebSocket.logPrefix)")
            return
        }
        requestInfo.complete(status: Int(responseStatus), headers: headers, data: responseData)

        // We may have been holding the websocket open, waiting for this response.
        // Check if we should close the websocket.
        applyDesiredSocketState()
    }

    // MARK: -

    fileprivate func processWebSocketRequestMessage(_ message: WebSocketProtoWebSocketRequestMessage,
                                                    currentWebSocket: WebSocketConnection) {
        assertOnQueue(self.serialQueue)

        let httpMethod = message.verb.nilIfEmpty ?? ""
        let httpPath = message.path.nilIfEmpty ?? ""
        owsAssertDebug(!httpMethod.isEmpty)
        owsAssertDebug(!httpPath.isEmpty)

        Logger.info("Got message \(currentWebSocket.logPrefix): verb: \(httpMethod), path: \(httpPath)")

        if httpMethod == "PUT",
           httpPath == "/api/v1/message" {

            // If we receive a message over the socket while the app is in the background,
            // prolong how long the socket stays open.
            //
            // TODO: NSE
            ensureBackgroundKeepAlive(.receiveMessage)

            handleIncomingMessage(message, currentWebSocket: currentWebSocket)
        } else if httpPath == "/api/v1/queue/empty" {
            // Queue is drained.
            handleEmptyQueueMessage(message, currentWebSocket: currentWebSocket)
        } else {
            Logger.warn("Unsupported WebSocket Request \(currentWebSocket.logPrefix)")

            sendWebSocketMessageAcknowledgement(message, currentWebSocket: currentWebSocket)
        }
    }

    private func handleIncomingMessage(_ message: WebSocketProtoWebSocketRequestMessage,
                                       currentWebSocket: WebSocketConnection) {
        assertOnQueue(self.serialQueue)

        var backgroundTask: OWSBackgroundTask? = OWSBackgroundTask(label: "handleIncomingMessage")

        let ackMessage = { (processingError: Error?, serverTimestamp: UInt64) in
            let ackBehavior = MessageProcessor.handleMessageProcessingOutcome(error: processingError)
            switch ackBehavior {
            case .shouldAck:
                self.sendWebSocketMessageAcknowledgement(message, currentWebSocket: currentWebSocket)
            case .shouldNotAck(let error):
                Logger.info("Skipping ack of message with serverTimestamp \(serverTimestamp) because of error: \(error)")
            }

            owsAssertDebug(backgroundTask != nil)
            backgroundTask = nil
        }

        var headers = HttpHeaders()
        headers.addHeaderList(message.headers, overwriteOnConflict: true)

        var serverDeliveryTimestamp: UInt64 = 0
        if let timestampString = headers.value(forHeader: "x-signal-timestamp") {
            if let timestamp = UInt64(timestampString) {
                serverDeliveryTimestamp = timestamp
            } else {
                owsFailDebug("Invalidly formatted timestamp: \(timestampString)")
            }
        }

        if serverDeliveryTimestamp == 0 {
            owsFailDebug("Missing server delivery timestamp")
        }

        guard let encryptedEnvelope = message.body else {
            ackMessage(OWSGenericError("Missing encrypted envelope on message \(currentWebSocket.logPrefix)"), serverDeliveryTimestamp)
            return
        }
        let envelopeSource: EnvelopeSource = {
            switch self.type {
            case .identified:
                return .websocketIdentified
            case .unidentified:
                return .websocketUnidentified
            }
        }()

        Self.messageProcessingQueue.async {
            SSKEnvironment.shared.messageProcessorRef.processReceivedEnvelopeData(
                encryptedEnvelope,
                serverDeliveryTimestamp: serverDeliveryTimestamp,
                envelopeSource: envelopeSource
            ) { error in
                self.serialQueue.async {
                    ackMessage(error, serverDeliveryTimestamp)
                }
            }
        }
    }

    private func handleEmptyQueueMessage(_ message: WebSocketProtoWebSocketRequestMessage,
                                         currentWebSocket: WebSocketConnection) {
        assertOnQueue(self.serialQueue)

        // Queue is drained.

        sendWebSocketMessageAcknowledgement(message, currentWebSocket: currentWebSocket)

        guard !currentWebSocket.hasEmptiedInitialQueue.get() else {
            owsFailDebug("Unexpected emptyQueueMessage \(currentWebSocket.logPrefix)")
            return
        }
        // We need to "flush" (i.e., "jump through") the message processing queue
        // to ensure that all received messages (see prior method) are enqueued for
        // processing before we: a) mark the queue as empty, b) notify.
        //
        // The socket might close and re-open while we're flushing the queue, so we
        // (implicitly) make sure it's still active before marking the queue as
        // empty. It's implicit because self.currentWebSocket stops referring to
        // currentWebSocket once it's no longer active.
        Self.messageProcessingQueue.async {
            self.serialQueue.async {
                if currentWebSocket.hasEmptiedInitialQueue.tryToSetFlag() {
                    self.notifyStatusChange(newState: self.currentState)
                }

                // We may have been holding the websocket open, waiting to drain the
                // queue. Check if we should close the websocket.
                self.applyDesiredSocketState()
            }
        }
    }

    private func sendWebSocketMessageAcknowledgement(_ request: WebSocketProtoWebSocketRequestMessage,
                                                     currentWebSocket: WebSocketConnection) {
        assertOnQueue(self.serialQueue)

        do {
            try currentWebSocket.sendResponse(for: request,
                                              status: 200,
                                              message: "OK")
        } catch {
            owsFailDebugUnlessNetworkFailure(error)
        }
    }

    private var webSocketAuthenticationHeaders: HttpHeaders {
        switch type {
        case .unidentified:
            return [:]
        case .identified:
            let login = accountManager.storedServerUsernameWithMaybeTransaction ?? ""
            let password = accountManager.storedServerAuthTokenWithMaybeTransaction ?? ""
            owsAssertDebug(login.nilIfEmpty != nil)
            owsAssertDebug(password.nilIfEmpty != nil)
            var result = HttpHeaders()
            result.addAuthHeader(username: login, password: password)
            return result
        }
    }

    fileprivate override func ensureWebsocketExists() {
        assertOnQueue(serialQueue)

        // Try to reuse the existing socket (if any) if it is in a valid state.
        if let currentWebSocket = self.currentWebSocket {
            switch currentWebSocket.state {
            case .open:
                self.clearReconnect()
                return
            case .connecting:
                // If we want the socket to be open and it's not open,
                // start up the reconnect timer immediately (don't wait for an error).
                // There's little harm in it and this will make us more robust to edge
                // cases.
                self.ensureReconnectTimer()
                return
            case .disconnected:
                break
            }
        }

        let signalServiceType: SignalServiceType
        switch type {
        case .identified:
            signalServiceType = .mainSignalServiceIdentified
        case .unidentified:
            signalServiceType = .mainSignalServiceUnidentified
        }

        var extraHeaders = HttpHeaders()
        extraHeaders.merge(StoryManager.buildStoryHeaders())
        extraHeaders.merge(webSocketAuthenticationHeaders)

        let request = WebSocketRequest(
            signalService: signalServiceType,
            urlPath: "v1/websocket/",
            urlQueryItems: nil,
            extraHeaders: extraHeaders
        )

        guard let webSocket = SSKEnvironment.shared.webSocketFactoryRef.buildSocket(
            request: request,
            callbackScheduler: self.serialQueue
        ) else {
            owsFailDebug("Missing webSocket.")
            return
        }
        webSocket.delegate = self
        let newWebSocket = WebSocketConnection(connectionType: type, webSocket: webSocket)
        self.currentWebSocket = newWebSocket

        // `connect` could hypothetically call a delegate method (e.g. if
        // the socket failed immediately for some reason), so we update currentWebSocket
        // _before_ calling it, not after.
        webSocket.connect()

        self.serialQueue.asyncAfter(deadline: .now() + 30) { [weak self, weak newWebSocket] in
            guard let self, let newWebSocket, self.currentWebSocket === newWebSocket else {
                return
            }

            if !newWebSocket.hasConnected.get() {
                Logger.warn("Websocket failed to connect.")
                self.cycleSocket()
            }
        }

        // If we want the socket to be open and it's not open,
        // start up the reconnect timer immediately (don't wait for an error).
        // There's little harm in it and this will make us more robust to edge
        // cases.
        self.ensureReconnectTimer()
    }

    fileprivate override func disconnectIfNeeded() {
        self.clearReconnect()
        self.currentWebSocket = nil
    }
}

// MARK: -

private class RequestInfo {

    let request: TSRequest

    let requestUrl: URL

    let httpMethod: String

    let requestId: UInt64

    let connectionType: OWSChatConnectionType

    let startDate = Date()

    var intervalSinceStartDateFormatted: String {
        startDate.formatIntervalSinceNow
    }

    // We use an enum to ensure that the completion handlers are
    // released as soon as the message completes.
    private enum Status {
        case incomplete(success: RequestSuccess, failure: RequestFailure)
        case complete
    }

    private let status: AtomicValue<Status>

    private let backgroundTask: OWSBackgroundTask

    typealias RequestSuccess = OWSChatConnection.RequestSuccessInternal
    typealias RequestFailure = OWSChatConnection.RequestFailure

    init?(
        request: TSRequest,
        requestId: UInt64 = UInt64.random(in: .min ... .max),
        connectionType: OWSChatConnectionType,
        success: @escaping RequestSuccess,
        failure: @escaping RequestFailure
    ) {
        guard let requestUrl = request.url else {
            owsFailDebug("[\(requestId)]: Missing requestUrl.")
            failure(.invalidRequest)
            return nil
        }
        guard let httpMethod = request.httpMethod.nilIfEmpty else {
            owsFailDebug("[\(requestId)]: Missing httpMethod.")
            failure(.invalidRequest)
            return nil
        }

        self.request = request
        self.requestId = requestId
        self.requestUrl = requestUrl
        self.httpMethod = httpMethod
        self.connectionType = connectionType
        self.status = AtomicValue(.incomplete(success: success, failure: failure), lock: .sharedGlobal)
        self.backgroundTask = OWSBackgroundTask(label: "ChatRequestInfo")
    }

    func complete(status: Int, headers: HttpHeaders, data: Data?) {
        if (200...299).contains(status) {
            let response = HTTPResponseImpl(requestUrl: requestUrl,
                                            status: status,
                                            headers: headers,
                                            bodyData: data)
            didSucceed(response: response)
        } else {
            let error = HTTPUtils.preprocessMainServiceHTTPError(
                request: request,
                requestUrl: requestUrl,
                responseStatus: status,
                responseHeaders: headers,
                responseData: data
            )
            didFail(error: error)
        }
    }

    private func didSucceed(response: HTTPResponse) {
        // Ensure that we only complete once.
        switch status.swap(.complete) {
        case .complete:
            return
        case .incomplete(let success, _):
            success(response, self)
        }
    }

    // Returns true if the message timed out.
    func timeoutIfNecessary() -> Bool {
        return didFail(error: .networkFailure(.genericTimeout))
    }

    func didFailInvalidRequest() {
        didFail(error: .invalidRequest)
    }

    func didFailDueToNetwork() {
        didFail(error: .networkFailure(.genericFailure))
    }

    @discardableResult
    private func didFail(error: OWSHTTPError) -> Bool {
        // Ensure that we only complete once.
        switch status.swap(.complete) {
        case .complete:
            return false
        case .incomplete(_, let failure):
            failure(error)
            return true
        }
    }
}

// MARK: -

extension OWSChatConnectionUsingSSKWebSocket: SSKWebSocketDelegate {

    public func websocketDidConnect(socket eventSocket: SSKWebSocket) {
        assertOnQueue(self.serialQueue)

        guard let currentWebSocket, currentWebSocket.webSocket === eventSocket else {
            // Ignore events from obsolete web sockets.
            return
        }

        currentWebSocket.didConnect(delegate: self)

        // If socket opens, we know we're not de-registered.
        if type == .identified {
            if accountManager.registrationStateWithMaybeSneakyTransaction.isDeregistered {
                db.write { tx in
                    registrationStateChangeManager.setIsDeregisteredOrDelinked(false, tx: tx)
                }
            }
        }

        OutageDetection.shared.reportConnectionSuccess()

        notifyStatusChange(newState: .open)
    }

    public func websocketDidDisconnectOrFail(socket eventSocket: SSKWebSocket, error: Error) {
        assertOnQueue(self.serialQueue)

        guard let currentWebSocket, currentWebSocket.webSocket === eventSocket else {
            // Ignore events from obsolete web sockets.
            return
        }

        switch error {
        case URLError.notConnectedToInternet:
            Logger.warn("\(logPrefix): notConnectedToInternet")
        default:
            Logger.warn("\(logPrefix): \(error)")
        }

        self.currentWebSocket = nil

        if type == .identified, case WebSocketError.httpError(statusCode: 403, _) = error {
            db.write { tx in
                registrationStateChangeManager.setIsDeregisteredOrDelinked(true, tx: tx)
            }
        }

        if shouldSocketBeOpen {
            // If we should retry, use `ensureReconnectTimer` to reconnect after a delay.
            ensureReconnectTimer()
        } else {
            // Otherwise clean up and align state.
            applyDesiredSocketState()
        }

        OutageDetection.shared.reportConnectionFailure()
    }

    public func websocket(_ eventSocket: SSKWebSocket, didReceiveData data: Data) {
        assertOnQueue(self.serialQueue)
        let message: WebSocketProtoWebSocketMessage
        do {
            message = try WebSocketProtoWebSocketMessage(serializedData: data)
        } catch {
            owsFailDebug("Failed to deserialize message: \(error)")
            return
        }

        guard let currentWebSocket, currentWebSocket.webSocket === eventSocket else {
            // Ignore events from obsolete web sockets.
            return
        }

        if !message.hasType {
            owsFailDebug("webSocket:didReceiveResponse: missing type.")
        } else if message.unwrappedType == .request {
            if let request = message.request {
                processWebSocketRequestMessage(request, currentWebSocket: currentWebSocket)
            } else {
                owsFailDebug("Missing request.")
            }
        } else if message.unwrappedType == .response {
            if let response = message.response {
                processWebSocketResponseMessage(response, currentWebSocket: currentWebSocket)
            } else {
                owsFailDebug("Missing response.")
            }
        } else {
            owsFailDebug("webSocket:didReceiveResponse: unknown.")
        }
    }
}

// MARK: -

extension OWSChatConnectionUsingSSKWebSocket: WebSocketConnectionDelegate {
    fileprivate func webSocketSendHeartBeat(_ webSocket: WebSocketConnection) {
        if shouldSocketBeOpen {
            webSocket.writePing()
        } else {
            Logger.warn("Closing web socket: \(logPrefix).")
            applyDesiredSocketState()
        }
    }

    fileprivate func webSocketRequestDidTimeout() {
        cycleSocket()
    }
}

// MARK: -

private protocol WebSocketConnectionDelegate: AnyObject {
    func webSocketSendHeartBeat(_ webSocket: WebSocketConnection)
    func webSocketRequestDidTimeout()
}

// MARK: -

private class WebSocketConnection {

    private let connectionType: OWSChatConnectionType

    let webSocket: SSKWebSocket

    private let unfairLock = UnfairLock()

    public var id: UInt { webSocket.id }

    public let hasEmptiedInitialQueue = AtomicBool(false, lock: .sharedGlobal)

    public var state: SSKWebSocketState { webSocket.state }

    private var requestInfoMap = AtomicDictionary<UInt64, RequestInfo>(lock: .sharedGlobal)

    public var hasPendingRequests: Bool {
        !requestInfoMap.isEmpty
    }

    public let hasConnected = AtomicBool(false, lock: .sharedGlobal)

    public var logPrefix: String {
        "[\(connectionType): \(id)]"
    }

    init(connectionType: OWSChatConnectionType, webSocket: SSKWebSocket) {
        owsAssertDebug(!CurrentAppContext().isRunningTests)

        self.connectionType = connectionType
        self.webSocket = webSocket
    }

    deinit {
        reset()
    }

    private var heartbeatTimer: OffMainThreadTimer?

    func didConnect(delegate: WebSocketConnectionDelegate) {
        hasConnected.set(true)

        startHeartbeat(delegate: delegate)
    }

    private func startHeartbeat(delegate: WebSocketConnectionDelegate) {
        let heartbeatPeriodSeconds: TimeInterval = 30
        self.heartbeatTimer = OffMainThreadTimer(timeInterval: heartbeatPeriodSeconds,
                                                 repeats: true) { [weak self, weak delegate] timer in
            guard let self = self,
                  let delegate = delegate else {
                owsFailDebug("Missing self or delegate.")
                timer.invalidate()
                return
            }
            delegate.webSocketSendHeartBeat(self)
        }
    }

    func writePing() {
        webSocket.writePing()
    }

    func reset() {
        unfairLock.withLock {
            webSocket.delegate = nil
            webSocket.disconnect(code: nil)
        }

        heartbeatTimer?.invalidate()
        self.heartbeatTimer = nil

        let requestInfos = requestInfoMap.removeAllValues()
        failPendingMessages(requestInfos: requestInfos)
    }

    private func failPendingMessages(requestInfos: [RequestInfo]) {
        guard !requestInfos.isEmpty else {
            return
        }

        Logger.info("\(logPrefix): \(requestInfos.count).")

        for requestInfo in requestInfos {
            requestInfo.didFailDueToNetwork()
        }
    }

    // This method is thread-safe.
    fileprivate func sendRequest(requestInfo: RequestInfo,
                                 messageData: Data,
                                 delegate: WebSocketConnectionDelegate) {
        requestInfoMap[requestInfo.requestId] = requestInfo

        webSocket.write(data: messageData)

        let socketTimeoutSeconds: TimeInterval = requestInfo.request.timeoutInterval
        DispatchQueue.global().asyncAfter(deadline: .now() + socketTimeoutSeconds) { [weak delegate, weak requestInfo] in
            guard let delegate = delegate,
                  let requestInfo = requestInfo else {
                return
            }

            if requestInfo.timeoutIfNecessary() {
                delegate.webSocketRequestDidTimeout()
            }
        }
    }

    fileprivate func popRequestInfo(forRequestId requestId: UInt64) -> RequestInfo? {
        requestInfoMap.removeValue(forKey: requestId)
    }

    fileprivate func sendResponse(for request: WebSocketProtoWebSocketRequestMessage,
                                  status: UInt32,
                                  message: String) throws {
        try webSocket.sendResponse(for: request, status: status, message: message)
    }
}

internal class OWSChatConnectionUsingLibSignal<Connection: ChatConnection>: OWSChatConnection, ConnectionEventsListener {
    fileprivate let libsignalNet: Net

    fileprivate enum ConnectionState {
        case closed
        case connecting(token: NSObject, task: Task<Connection?, Never>)
        case open(Connection)

        var asExternalState: OWSChatConnectionState {
            switch self {
            case .closed: .closed
            case .connecting(token: _, task: _): .connecting
            case .open(_): .open
            }
        }

        func isCurrentlyConnecting(_ token: NSObject) -> Bool {
            guard case .connecting(token: let activeToken, task: _) = self else {
                return false
            }
            return activeToken === token
        }

        func isActive(_ connection: Connection) -> Bool {
            guard case .open(let activeConnection) = self else {
                return false
            }
            return activeConnection === connection
        }

        func waitToFinishConnecting(cancel: Bool = false) async -> Connection? {
            switch self {
            case .closed:
                return nil
            case .connecting(token: _, task: let task):
                if cancel {
                    task.cancel()
                }
                return await task.value
            case .open(let connection):
                return connection
            }
        }
    }

    private var _connection: ConnectionState = .closed
    fileprivate var connection: ConnectionState {
        get {
            assertOnQueue(serialQueue)
            return _connection
        }
        set {
            assertOnQueue(serialQueue)
            _connection = newValue
            notifyStatusChange(newState: newValue.asExternalState)
        }
    }

    internal init(libsignalNet: Net, type: OWSChatConnectionType, accountManager: TSAccountManager, appExpiry: AppExpiry, appReadiness: AppReadiness, currentCallProvider: any CurrentCallProvider, db: any DB, registrationStateChangeManager: RegistrationStateChangeManager) {
        self.libsignalNet = libsignalNet
        super.init(type: type, accountManager: accountManager, appExpiry: appExpiry, appReadiness: appReadiness, currentCallProvider: currentCallProvider, db: db, registrationStateChangeManager: registrationStateChangeManager)
    }

    fileprivate func connectChatService() async throws -> Connection {
        fatalError("must be overridden by subclass")
    }

    fileprivate override func isSignalProxyReadyDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()
        // The libsignal connection needs to be recreated whether the proxy is going up,
        // changing, or going down.
        cycleSocket()
    }

    fileprivate override func ensureWebsocketExists() {
        assertOnQueue(serialQueue)

        switch connection {
        case .open(_):
            clearReconnect()
            return
        case .connecting(_, _):
            // The most recent transition was attempting to connect, and we have not yet observed a failure.
            // That's as good as we're going to get.
            return
        case .closed:
            break
        }

        // If we want the socket to be open and it's not open,
        // start up the reconnect timer immediately (don't wait for an error).
        // There's little harm in it and this will make us more robust to edge
        // cases.
        ensureReconnectTimer()

        // Unique while live.
        let token = NSObject()
        connection = .connecting(token: token, task: Task { [token] in
            func connectionAttemptCompleted(_ state: ConnectionState) async -> Connection? {
                // We're not done until self.connection has been updated.
                // (Otherwise, we might try to send requests before calling start(listener:).)
                return await withCheckedContinuation { continuation in
                    self.serialQueue.async {
                        guard self.connection.isCurrentlyConnecting(token) else {
                            // We finished connecting, but we've since been asked to disconnect
                            // (either because we should be offline, or because config has changed).
                            continuation.resume(returning: nil)
                            return
                        }

                        self.connection = state

                        if case .open(let connection) = state {
                            continuation.resume(returning: connection)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    }
                }
            }

            do {
                let chatService = try await self.connectChatService()
                if type == .identified {
                    self.didConnectIdentified()
                }
                OutageDetection.shared.reportConnectionSuccess()
                return await connectionAttemptCompleted(.open(chatService))

            } catch is CancellationError {
                // We've been asked to disconnect, no other action necessary.
                // (We could even skip updating state, since the disconnect action should have already set it to "closed",
                // but just in case it's still on "connecting" we'll continue on to execute that cleanup.)
            } catch SignalError.appExpired(_) {
                appExpiry.setHasAppExpiredAtCurrentVersion(db: db)
            } catch SignalError.deviceDeregistered(_) {
                serialQueue.async {
                    if self.connection.isCurrentlyConnecting(token) {
                        self.db.write { tx in
                            self.registrationStateChangeManager.setIsDeregisteredOrDelinked(true, tx: tx)
                        }
                    }
                }
            } catch {
                Logger.error("\(self.logPrefix): failed to connect: \(error)")
                OutageDetection.shared.reportConnectionFailure()
            }

            // Only failure cases get here.
            return await connectionAttemptCompleted(.closed)
        })
    }

    fileprivate func didConnectIdentified() {
        // Overridden by subclass.
    }

    fileprivate override func disconnectIfNeeded() {
        assertOnQueue(serialQueue)
        clearReconnect()

        let previousConnection = connection
        if case .closed = previousConnection {
            // Either we are already disconnecting,
            // or we finished disconnecting,
            // or we were never connected to begin with.
            return
        }
        connection = .closed

        // Spin off a background task to disconnect the previous connection.
        _ = Task {
            do {
                try await previousConnection.waitToFinishConnecting(cancel: true)?.disconnect()
            } catch {
                Logger.warn("\(self.logPrefix): error while disconnecting: \(error)")
            }
        }
    }

    public override var currentState: OWSChatConnectionState {
        // We update cachedCurrentState based on lifecycle events,
        // so this should be accurate (with the usual caveats about races).
        return cachedCurrentState
    }

    fileprivate override var logPrefix: String {
        "[\(type): libsignal]"
    }

    fileprivate override func makeRequestInternal(
        _ request: TSRequest,
        requestId: UInt64,
        unsubmittedRequestToken: UnsubmittedRequestToken,
        success: @escaping RequestSuccessInternal,
        failure: @escaping RequestFailure
    ) {
        var unsubmittedRequestTokenForEarlyExit: Optional = unsubmittedRequestToken
        defer {
            if let unsubmittedRequestTokenForEarlyExit {
                removeUnsubmittedRequestToken(unsubmittedRequestTokenForEarlyExit)
            }
        }

        guard let requestInfo = RequestInfo(
            request: request,
            requestId: requestId,
            connectionType: type,
            success: success,
            failure: failure
        ) else {
            // Failure already reported by the init.
            return
        }

        var httpHeaders = HttpHeaders(httpHeaders: request.allHTTPHeaderFields, overwriteOnConflict: false)
        httpHeaders.addDefaultHeaders()

        request.applyAuth(to: &httpHeaders, willSendViaWebSocket: true)

        let body: Data
        if let existingBody = request.httpBody {
            body = existingBody
        } else {
            // TODO: Do we need body & headers for requests with no parameters?
            do {
                body = try JSONSerialization.data(withJSONObject: request.parameters, options: [])
            } catch {
                owsFailDebug("[\(requestId)]: \(error).")
                requestInfo.didFailInvalidRequest()
                return
            }

            // If we're going to use the json serialized parameters as our body, we should overwrite
            // the Content-Type on the request.
            httpHeaders.addHeader("Content-Type",
                                  value: "application/json",
                                  overwriteOnConflict: true)
        }

        let requestUrl = requestInfo.requestUrl
        owsAssertDebug(requestUrl.scheme == nil)
        owsAssertDebug(requestUrl.host == nil)
        owsAssertDebug(!requestUrl.path.hasPrefix("/"))

        let libsignalRequest = ChatConnection.Request(method: requestInfo.httpMethod, pathAndQuery: "/\(requestUrl.relativeString)", headers: httpHeaders.headers, body: body, timeout: request.timeoutInterval)

        unsubmittedRequestTokenForEarlyExit = nil
        _ = Task { [self, connection] in
            var chatService: Connection?
            let connectionInfo: ConnectionInfo
            let response: ChatConnection.Response

            do {
                // LibSignalClient's ChatConnection doesn't keep track of outstanding requests,
                // so we keep the request token alive until we get the response instead.
                defer {
                    removeUnsubmittedRequestToken(unsubmittedRequestToken)
                }

                chatService = await connection.waitToFinishConnecting()
                guard let chatService else {
                    throw SignalError.chatServiceInactive("no connection to chat server")
                }

                connectionInfo = chatService.info()
                response = try await chatService.send(libsignalRequest)
            } catch {
                switch error as? SignalError {
                case .connectionTimeoutError(_), .requestTimeoutError(_):
                    if requestInfo.timeoutIfNecessary() {
                        // cycleSocket(), but only if the chatService we just used is the one that's still connected.
                        self.serialQueue.async { [weak chatService] in
                            if let chatService, self.connection.isActive(chatService) {
                                self.disconnectIfNeeded()
                            }
                        }
                        applyDesiredSocketState()
                    }
                case .webSocketError(_), .connectionFailed(_):
                    requestInfo.didFailDueToNetwork()
                default:
                    owsFailDebug("[\(requestId)] failed with an unexpected error: \(error)")
                    requestInfo.didFailDueToNetwork()
                }
                return
            }

            if DebugFlags.internalLogging {
                Logger.info("received response for requestId: \(requestId), message: \(response.message), route: \(connectionInfo)")
            }

            self.ensureBackgroundKeepAlive(.receiveResponse)

            let headers = HttpHeaders(httpHeaders: response.headers, overwriteOnConflict: false)

            requestInfo.complete(status: Int(response.status), headers: headers, data: response.body)

            // We may have been holding the websocket open, waiting for this response.
            // Check if we should close the websocket.
            self.applyDesiredSocketState()
        }
    }

    func connectionWasInterrupted(_ service: Connection, error: Error?) {
        self.serialQueue.async { [self] in
            guard connection.isActive(service) else {
                // Already done with this service.
                if let error {
                    Logger.warn("\(logPrefix) previous service was disconnected: \(error)")
                }
                return
            }

            if let error {
                Logger.error("\(logPrefix) disconnected: \(error)")
            } else {
                owsFailDebug("\(logPrefix) libsignal disconnected us without being asked")
            }

            connection = .closed

            if shouldSocketBeOpen {
                // If we should retry, use `ensureReconnectTimer` to reconnect after a delay.
                ensureReconnectTimer()
            } else {
                // Otherwise clean up and align state.
                applyDesiredSocketState()
            }

            OutageDetection.shared.reportConnectionFailure()
        }
    }
}

internal class OWSUnauthConnectionUsingLibSignal: OWSChatConnectionUsingLibSignal<UnauthenticatedChatConnection> {
    init(libsignalNet: Net, accountManager: TSAccountManager, appExpiry: AppExpiry, appReadiness: AppReadiness, currentCallProvider: any CurrentCallProvider, db: any DB, registrationStateChangeManager: RegistrationStateChangeManager) {
        super.init(libsignalNet: libsignalNet, type: .unidentified, accountManager: accountManager, appExpiry: appExpiry, appReadiness: appReadiness, currentCallProvider: currentCallProvider, db: db, registrationStateChangeManager: registrationStateChangeManager)
    }

    fileprivate override var connection: ConnectionState {
        didSet {
            if case .open(let service) = connection {
                service.start(listener: self)
            }
        }
    }

    override func connectChatService() async throws -> UnauthenticatedChatConnection {
        return try await libsignalNet.connectUnauthenticatedChat()
    }
}

internal class OWSAuthConnectionUsingLibSignal: OWSChatConnectionUsingLibSignal<AuthenticatedChatConnection>, ChatConnectionListener {
    private let _hasEmptiedInitialQueue = AtomicBool(false, lock: .sharedGlobal)
    override var hasEmptiedInitialQueue: Bool {
        _hasEmptiedInitialQueue.get()
    }

    private var _keepaliveSenderTask: Task<Void, Never>?
    private var keepaliveSenderTask: Task<Void, Never>? {
        get {
            assertOnQueue(serialQueue)
            return _keepaliveSenderTask
        }
        set {
            assertOnQueue(serialQueue)
            _keepaliveSenderTask?.cancel()
            _keepaliveSenderTask = newValue
        }
    }

    init(libsignalNet: Net, accountManager: TSAccountManager, appExpiry: AppExpiry, appReadiness: AppReadiness, currentCallProvider: any CurrentCallProvider, db: any DB, registrationStateChangeManager: RegistrationStateChangeManager) {
        super.init(libsignalNet: libsignalNet, type: .identified, accountManager: accountManager, appExpiry: appExpiry, appReadiness: appReadiness, currentCallProvider: currentCallProvider, db: db, registrationStateChangeManager: registrationStateChangeManager)
    }

    fileprivate override func connectChatService() async throws -> AuthenticatedChatConnection {
        let (username, password) = db.read { tx in
            (accountManager.storedServerUsername(tx: tx), accountManager.storedServerAuthToken(tx: tx))
        }
        // Note that we still try to connect for an unregistered user, so that we get a consistent error thrown.
        return try await libsignalNet.connectAuthenticatedChat(username: username ?? "", password: password ?? "", receiveStories: StoryManager.areStoriesEnabled)
    }

    fileprivate override var connection: ConnectionState {
        didSet {
            assertOnQueue(serialQueue)

            switch connection {
            case .connecting(token: _, task: _):
                break
            case .open(let service):
                // Note that we don't get callbacks until this point.
                service.start(listener: self)
                if accountManager.registrationStateWithMaybeSneakyTransaction.isDeregistered {
                    db.write { tx in
                        registrationStateChangeManager.setIsDeregisteredOrDelinked(false, tx: tx)
                    }
                }
                keepaliveSenderTask = makeKeepaliveTask(service)
            case .closed:
                // While _hasEmptiedInitialQueue is atomic, that's not sufficient to guarantee the
                // *order* of writes. We do that by making sure we only set it on the serial queue,
                // and then make sure libsignal's serialized callbacks result in scheduling on the
                // serial queue.
                keepaliveSenderTask = nil
                _hasEmptiedInitialQueue.set(false)
                Logger.debug("Reset _hasEmptiedInitialQueue")
            }
        }
    }

    /// Starts a task to call `/v1/keepalive` at regular intervals to allow the server to do some consistency checks.
    ///
    /// This is on top of the websocket pings libsignal already uses to keep connections alive.
    func makeKeepaliveTask(_ chat: AuthenticatedChatConnection) -> Task<Void, Never> {
        let keepaliveInterval: TimeInterval = 30
        return Task(priority: .low) { [logPrefix = self.logPrefix, weak chat] in
            while true {
                do {
                    // This does not quite send keepalives "every 30 seconds".
                    // Instead, it sends the next keepalive *at least 30 seconds* after the *response* for the previous one arrives.
                    try await Task.sleep(nanoseconds: keepaliveInterval.clampedNanoseconds)
                    guard let chat else {
                        // We've disconnected.
                        return
                    }

                    // Skip the full overhead of makeRequest(...).
                    // We don't need keepalives to count as background activity or anything like that.
                    var httpHeaders = HttpHeaders()
                    httpHeaders.addDefaultHeaders()
                    // This 30-second timeout doesn't inherently need to match the send interval above,
                    // but neither do we need an especially tight timeout here either.
                    let request = ChatConnection.Request(method: "GET", pathAndQuery: "/v1/keepalive", headers: httpHeaders.headers, body: nil, timeout: 30)
                    Logger.debug("\(logPrefix) Sending /v1/keepalive")
                    _ = try await chat.send(request)

                } catch is CancellationError,
                        SignalError.chatServiceInactive(_) {
                    // No action necessary, we're done with this service.
                    return
                } catch SignalError.rateLimitedError(retryAfter: let delay, message: _) {
                    // Not likely to happen, but best to be careful about it if it does.
                    if delay > keepaliveInterval {
                        // Wait out the part of the delay longer than 30s.
                        // Ignore cancellation here; when we get back to the top of the loop we'll check it then.
                        _ = try? await Task.sleep(nanoseconds: (delay - keepaliveInterval).clampedNanoseconds)
                    }
                } catch {
                    // Also no action necessary! Log just in case the failure has something interesting going on,
                    // but continue to rely on libsignal reporting disconnects via delegate callback.
                    // Importantly, we will continue to send keepalives until disconnected, in case this was a temporary thing.
                    Logger.info("\(logPrefix) /v1/keepalive failed: \(error)")
                }
            }
        }
    }

    func chatConnection(_ chat: AuthenticatedChatConnection, didReceiveAlerts alerts: [String]) {
        self.serialQueue.async { [self] in
            guard self.connection.isActive(chat) else {
                // We have since disconnected from the chat service instance that reported the alerts.
                return
            }

            if !alerts.isEmpty {
                Logger.warn("ignoring \(alerts.count) alerts from the server")
            }
        }
    }

    func chatConnection(_ chat: AuthenticatedChatConnection, didReceiveIncomingMessage envelope: Data, serverDeliveryTimestamp: UInt64, sendAck: @escaping () throws -> Void) {
        ensureBackgroundKeepAlive(.receiveMessage)
        let backgroundTask = OWSBackgroundTask(label: "handleIncomingMessage")

        Self.messageProcessingQueue.async {
            SSKEnvironment.shared.messageProcessorRef.processReceivedEnvelopeData(
                envelope,
                serverDeliveryTimestamp: serverDeliveryTimestamp,
                envelopeSource: .websocketIdentified
            ) { error in
                defer { backgroundTask.end() }

                let ackBehavior = MessageProcessor.handleMessageProcessingOutcome(error: error)
                switch ackBehavior {
                case .shouldAck:
                    do {
                        // Note that this does not wait for a response.
                        try sendAck()
                    } catch {
                        Logger.warn("Failed to ack message with serverTimestamp \(serverDeliveryTimestamp): \(error)")
                    }
                case .shouldNotAck(let error):
                    Logger.info("Skipping ack of message with serverTimestamp \(serverDeliveryTimestamp) because of error: \(error)")
                }
            }
        }
    }

    func chatConnectionDidReceiveQueueEmpty(_ chat: AuthenticatedChatConnection) {
        // We need to "flush" (i.e., "jump through") the message processing queue
        // to ensure that all received messages (see prior method) are enqueued for
        // processing before we: a) mark the queue as empty, b) notify.
        //
        // The socket might close and re-open while we're flushing the queue, so
        // we make sure it's still active before marking the queue as empty.
        Self.messageProcessingQueue.async {
            self.serialQueue.async {
                guard self.connection.isActive(chat) else {
                    // We have since disconnected from the chat service instance that reported the empty queue.
                    return
                }
                let alreadyEmptied = self._hasEmptiedInitialQueue.swap(true)
                Logger.debug("Initial queue emptied")

                if !alreadyEmptied {
                    // This notification is used to wake up anything waiting for hasEmptiedInitialQueue.
                    self.notifyStatusChange(newState: self.currentState)
                }

                // We may have been holding the websocket open, waiting to drain the
                // queue. Check if we should close the websocket.
                self.applyDesiredSocketState()
            }
        }
    }
}
