//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

class ProxySettingsViewController: OWSTableViewController2 {
    private var useProxy = SignalProxy.useProxy

    /// How we check that the proxy settings worked once they are enabled.
    public enum ValidationMethod {
        /// Wait for a succesful websocket connection.
        case websocket
        /// Wait for a succesful unauthenticated REST request to get a bogus registration session.
        ///
        /// What we _want_ is an way to check that we get a response from the server. Because
        /// this is used during registration, we don't have auth credentials yet so we need to do this
        /// in an unauthenticated way.
        /// In an ideal future, we could do this by establishing an unauthenticated websocket that
        /// we use for registration purposes. We don't use websockets during reg right now.
        /// Instead, we use a REST endpoint to get registration session metadata, which we feed a
        /// bogus session id and expect to get a 4xx response. Getting a 4xx means we connected; that's
        /// all we care about. (A 2xx too, is fine, though would be quite unusual)
        case restGetRegistrationSession
    }

    private let validationMethod: ValidationMethod

    public init(validationMethod: ValidationMethod = .websocket) {
        self.validationMethod = validationMethod
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = OWSLocalizedString(
            "PROXY_SETTINGS_TITLE",
            comment: "Title for the signal proxy settings"
        )

        updateTableContents()
        updateNavigationBar()
    }

    private var hasPendingChanges: Bool {
        useProxy != SignalProxy.useProxy || host != SignalProxy.host
    }

    private var host: String? {
        hostTextField.text?.nilIfEmpty
    }

    private func updateNavigationBar() {
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = .cancelButton(
                dismissingFrom: self,
                hasUnsavedChanges: { [weak self] in self?.hasPendingChanges }
            )
        }

        navigationItem.rightBarButtonItem = .systemItem(.save) { [weak self] in
            self?.didTapSave()
        }
        navigationItem.rightBarButtonItem?.isEnabled = hasPendingChanges
    }

    private lazy var hostTextField: UITextField = {
        let textField = UITextField()

        textField.text = SignalProxy.host
        textField.font = .dynamicTypeBody
        textField.backgroundColor = .clear
        textField.placeholder = OWSLocalizedString(
            "PROXY_PLACEHOLDER",
            comment: "Placeholder text for signal proxy host"
        )
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.textContentType = .URL
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        return textField
    }()

    override func themeDidChange() {
        super.themeDidChange()

        updateTableContents()
    }

    private func updateTableContents() {
        let contents = OWSTableContents()
        defer { self.contents = contents }

        let useProxy = self.useProxy

        let useProxySection = OWSTableSection()
        useProxySection.footerAttributedTitle = .composed(of: [
            OWSLocalizedString("USE_PROXY_EXPLANATION", comment: "Explanation of when you should use a signal proxy"),
            " ",
            CommonStrings.learnMore.styled(with: .link(URL(string: "https://support.signal.org/hc/en-us/articles/360056052052-Proxy-Support")!))
        ]).styled(
            with: .font(.dynamicTypeCaption1Clamped),
            .color(Theme.secondaryTextAndIconColor)
        )
        useProxySection.add(.switch(
            withText: OWSLocalizedString("USE_PROXY_BUTTON", comment: "Button to activate the signal proxy"),
            isOn: { [weak self] in
                self?.useProxy ?? false
            },
            target: self,
            selector: #selector(didToggleUseProxy)
        ))
        contents.add(useProxySection)

        let proxyAddressSection = OWSTableSection()
        proxyAddressSection.headerAttributedTitle = OWSLocalizedString("PROXY_ADDRESS", comment: "The title for the address of the signal proxy").styled(
            with: .color((Theme.isDarkThemeEnabled ? UIColor.ows_gray05 : UIColor.ows_gray90).withAlphaComponent(useProxy ? 1 : 0.25)),
            .font(UIFont.dynamicTypeBodyClamped.semibold())
        )
        proxyAddressSection.add(.init(
            customCellBlock: { [weak self] in
                let cell = OWSTableItem.newCell()
                cell.selectionStyle = .none
                guard let self = self else { return cell }

                cell.contentView.addSubview(self.hostTextField)
                self.hostTextField.autoPinEdgesToSuperviewMargins()

                if !useProxy {
                    cell.isUserInteractionEnabled = false
                    cell.contentView.alpha = 0.25
                }

                return cell
            },
            actionBlock: {}
        ))
        contents.add(proxyAddressSection)

        let shareSection = OWSTableSection()
        shareSection.add(.init(
            customCellBlock: {
                let cell = OWSTableItem.buildImageCell(image: Theme.iconImage(.buttonShare), itemName: CommonStrings.shareButton)
                cell.selectionStyle = .none

                if !useProxy {
                    cell.isUserInteractionEnabled = false
                    cell.contentView.alpha = 0.25
                }

                return cell
            },
            actionBlock: { [weak self] in
                guard let self = self else { return }
                guard !self.notifyForInvalidHostIfNecessary() else { return }
                AttachmentSharing.showShareUI(for: URL(string: "https://signal.tube/#\(self.host ?? "")")!, sender: self.view)
            }
        ))
        contents.add(shareSection)
    }

    @objc
    private func didToggleUseProxy(_ sender: UISwitch) {
        useProxy = sender.isOn
        updateTableContents()
        updateNavigationBar()
    }

    @objc
    private func textFieldDidChange() {
        updateNavigationBar()
    }

    private func notifyForInvalidHostIfNecessary() -> Bool {
        guard !SignalProxy.isValidProxyFragment(host) else { return false }

        // allow saving an empty host when the proxy is off
        if !useProxy && host == nil { return false }

        presentToast(text: OWSLocalizedString("INVALID_PROXY_HOST_ERROR", comment: "The provided proxy host address is not valid"))

        return true
    }

    private func didTapSave() {
        hostTextField.resignFirstResponder()

        guard !notifyForInvalidHostIfNecessary() else { return }

        SSKEnvironment.shared.databaseStorageRef.write { transaction in
            SignalProxy.setProxyHost(host: self.host, useProxy: self.useProxy, transaction: transaction)
        }

        guard useProxy else {
            if navigationController?.viewControllers.count == 1 {
                dismiss(animated: true)
            } else {
                updateNavigationBar()
            }
            return
        }

        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { modal in
            _ = Task(priority: .userInitiated) {
                await withTaskGroup(of: Bool.self) { group in
                    group.addTask {
                        return await self.checkConnection()
                    }
                    group.addTask {
                        // If this completes successfully or erroneously, treat that as a cancellation.
                        _ = try? await modal.wasCancelledPromise.awaitable()
                        return false
                    }
                    let connected = await group.next()!
                    group.cancelAll()

                    // We have to do this inside the TaskGroup because the modal's wasCancelledPromise is,
                    // ironically, not cancellable itself in the Swift concurrency sense. Dismissing the
                    // modal is thus required to let the task group exit.
                    modal.dismiss {
                        if connected {
                            if self.navigationController?.viewControllers.count == 1 {
                                self.presentingViewController?.presentToast(text: OWSLocalizedString("PROXY_CONNECTED_SUCCESSFULLY", comment: "The provided proxy connected successfully"))
                                self.dismiss(animated: true)
                            } else {
                                self.presentToast(text: OWSLocalizedString("PROXY_CONNECTED_SUCCESSFULLY", comment: "The provided proxy connected successfully"))
                                self.updateNavigationBar()
                            }
                        } else {
                            self.presentToast(text: OWSLocalizedString("PROXY_FAILED_TO_CONNECT", comment: "The provided proxy couldn't connect"))
                            SSKEnvironment.shared.databaseStorageRef.write { transaction in
                                SignalProxy.setProxyHost(host: self.host, useProxy: false, transaction: transaction)
                            }
                            self.updateTableContents()
                        }
                    }
                }
            }
        }
    }

    private func checkConnection() async -> Bool {
        switch validationMethod {
        case .websocket:
            return await ProxyConnectionChecker.checkConnectionAndNotify()
        case .restGetRegistrationSession:
            let request = RegistrationRequestFactory.checkProxyConnectionRequest()

            func isConnected(_ statusCode: Int) -> Bool {
                switch RegistrationServiceResponses.CheckProxyConnectionResponseCodes(rawValue: statusCode) {
                case .connected:
                    return true
                case .failure:
                    return false
                }
            }

            do {
                let response = try await SSKEnvironment.shared.networkManagerRef.asyncRequest(request, canUseWebSocket: false)
                return isConnected(response.responseStatusCode)
            } catch {
                guard
                    !error.isNetworkFailureOrTimeout,
                    let error = error as? OWSHTTPError
                else {
                    return false
                }
                return isConnected(error.responseStatusCode)
            }
        }
    }

    var shouldCancelNavigationBack: Bool {
        if hasPendingChanges {
            OWSActionSheets.showPendingChangesActionSheet { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return true
        } else {
            return false
        }
    }
}

extension ProxySettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if hasPendingChanges {
            didTapSave()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
