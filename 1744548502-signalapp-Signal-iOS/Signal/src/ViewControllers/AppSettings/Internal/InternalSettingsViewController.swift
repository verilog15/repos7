//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import AVFoundation
import SignalServiceKit
import SignalUI

class InternalSettingsViewController: OWSTableViewController2 {

    private let appReadiness: AppReadinessSetter

    init(appReadiness: AppReadinessSetter) {
        self.appReadiness = appReadiness
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Internal"

        updateTableContents()
    }

    func updateTableContents() {
        let contents = OWSTableContents()

        let debugSection = OWSTableSection()

        #if USE_DEBUG_UI
        debugSection.add(.disclosureItem(
            withText: "Debug UI",
            actionBlock: { [weak self, appReadiness] in
                guard let self = self else { return }
                DebugUITableViewController.presentDebugUI(from: self, appReadiness: appReadiness)
            }
        ))
        #endif

        if DebugFlags.audibleErrorLogging {
            debugSection.add(.disclosureItem(
                withText: OWSLocalizedString("SETTINGS_ADVANCED_VIEW_ERROR_LOG", comment: ""),
                actionBlock: { [weak self] in
                    Logger.flush()
                    let vc = LogPickerViewController(logDirUrl: DebugLogger.errorLogsDir)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            ))
        }

        debugSection.add(.disclosureItem(
            withText: "Flags",
            actionBlock: { [weak self] in
                let vc = FlagsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        ))
        debugSection.add(.disclosureItem(
            withText: "Testing",
            actionBlock: { [weak self] in
                let vc = TestingViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        ))
        debugSection.add(.actionItem(
            withText: "Export Database",
            actionBlock: { [weak self] in
                guard let self = self else {
                    return
                }
                SignalApp.showExportDatabaseUI(from: self)
            }
        ))
        debugSection.add(.actionItem(
            withText: "Query Database",
            actionBlock: { [weak self] in
                let vc = InternalSQLClientViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        ))
        debugSection.add(.actionItem(
            withText: "Run Database Integrity Checks",
            actionBlock: { [weak self] in
                guard let self = self else {
                    return
                }
                SignalApp.showDatabaseIntegrityCheckUI(from: self, databaseStorage: SSKEnvironment.shared.databaseStorageRef)
            }
        ))
        debugSection.add(.actionItem(
            withText: "Clean Orphaned Data",
            actionBlock: { [weak self] in
                guard let self else { return }
                ModalActivityIndicatorViewController.present(
                    fromViewController: self,
                    canCancel: false
                ) { modalActivityIndicator in
                    DispatchQueue.main.async {
                        OWSOrphanDataCleaner.auditAndCleanup(true) {
                            DispatchQueue.main.async { modalActivityIndicator.dismiss() }
                        }
                    }
                }
            }
        ))

        debugSection.add(.actionItem(withText: "Validate Message Backup") {
            self.validateMessageBackupProto()
        })

        debugSection.add(.actionItem(withText: "Export Message Backup proto") {
            self.exportMessageBackupProto()
        })

        contents.add(debugSection)

        let (
            contactThreadCount,
            groupThreadCount,
            messageCount,
            v2AttachmentCount,
            donationSubscriberID,
            storageServiceManifestVersion
        ) = SSKEnvironment.shared.databaseStorageRef.read { tx in
            return (
                TSThread.anyFetchAll(transaction: tx).filter { !$0.isGroupThread }.count,
                TSThread.anyFetchAll(transaction: tx).filter { $0.isGroupThread }.count,
                TSInteraction.anyCount(transaction: tx),
                try? Attachment.Record.fetchCount(tx.database),
                DonationSubscriptionManager.getSubscriberID(transaction: tx),
                SSKEnvironment.shared.storageServiceManagerRef.currentManifestVersion(tx: tx)
            )
        }

        let regSection = OWSTableSection(title: "Account")
        let localIdentifiers = DependenciesBridge.shared.tsAccountManager.localIdentifiersWithMaybeSneakyTransaction
        regSection.add(.copyableItem(label: "Phone Number", value: localIdentifiers?.phoneNumber))
        regSection.add(.copyableItem(label: "ACI", value: localIdentifiers?.aci.serviceIdString))
        regSection.add(.copyableItem(label: "PNI", value: localIdentifiers?.pni?.serviceIdString))
        regSection.add(.copyableItem(label: "Device ID", value: "\(DependenciesBridge.shared.tsAccountManager.storedDeviceIdWithMaybeTransaction)"))
        regSection.add(.copyableItem(label: "Push Token", value: SSKEnvironment.shared.preferencesRef.pushToken))
        regSection.add(.copyableItem(label: "Profile Key", value: SSKEnvironment.shared.databaseStorageRef.read(block: SSKEnvironment.shared.profileManagerRef.localUserProfile(tx:))?.profileKey?.keyData.hexadecimalString ?? "none"))
        if let donationSubscriberID {
            regSection.add(.copyableItem(label: "Donation Subscriber ID", value: donationSubscriberID.asBase64Url))
        }
        contents.add(regSection)

        let buildSection = OWSTableSection(title: "Build")
        buildSection.add(.copyableItem(label: "Environment", value: TSConstants.isUsingProductionService ? "Production" : "Staging"))
        buildSection.add(.copyableItem(label: "Variant", value: FeatureFlags.buildVariantString))
        buildSection.add(.copyableItem(label: "Current Version", value: AppVersionImpl.shared.currentAppVersion))
        buildSection.add(.copyableItem(label: "First Version", value: AppVersionImpl.shared.firstAppVersion))
        if let buildDetails = Bundle.main.object(forInfoDictionaryKey: "BuildDetails") as? [String: AnyObject] {
            if let signalCommit = (buildDetails["SignalCommit"] as? String)?.strippedOrNil?.prefix(12) {
                buildSection.add(.copyableItem(label: "Git Commit", value: String(signalCommit)))
            }
        }
        contents.add(buildSection)

        // format counts with thousands separator
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .decimal

        let byteCountFormatter = ByteCountFormatter()

        let dbSection = OWSTableSection(title: "Database")
        dbSection.add(.copyableItem(label: "DB Size", value: byteCountFormatter.string(for: SSKEnvironment.shared.databaseStorageRef.databaseFileSize)))
        dbSection.add(.copyableItem(label: "DB WAL Size", value: byteCountFormatter.string(for: SSKEnvironment.shared.databaseStorageRef.databaseWALFileSize)))
        dbSection.add(.copyableItem(label: "DB SHM Size", value: byteCountFormatter.string(for: SSKEnvironment.shared.databaseStorageRef.databaseSHMFileSize)))
        dbSection.add(.copyableItem(label: "Contact Threads", value: numberFormatter.string(for: contactThreadCount)))
        dbSection.add(.copyableItem(label: "Group Threads", value: numberFormatter.string(for: groupThreadCount)))
        dbSection.add(.copyableItem(label: "Messages", value: numberFormatter.string(for: messageCount)))
        dbSection.add(.copyableItem(label: "v2 Attachments", value: numberFormatter.string(for: v2AttachmentCount)))
        contents.add(dbSection)

        let deviceSection = OWSTableSection(title: "Device")
        deviceSection.add(.copyableItem(label: "Model", value: AppVersionImpl.shared.hardwareInfoString))
        deviceSection.add(.copyableItem(label: "iOS Version", value: AppVersionImpl.shared.iosVersionString))
        let memoryUsage = LocalDevice.currentMemoryStatus(forceUpdate: true)?.footprint
        let memoryUsageString = memoryUsage.map { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .memory) }
        deviceSection.add(.copyableItem(label: "Memory Usage", value: memoryUsageString))
        deviceSection.add(.copyableItem(label: "Locale Identifier", value: Locale.current.identifier.nilIfEmpty))
        deviceSection.add(.copyableItem(label: "Language Code", value: Locale.current.languageCode?.nilIfEmpty))
        deviceSection.add(.copyableItem(label: "Region Code", value: Locale.current.regionCode?.nilIfEmpty))
        deviceSection.add(.copyableItem(label: "Currency Code", value: Locale.current.currencyCode?.nilIfEmpty))
        contents.add(deviceSection)

        let otherSection = OWSTableSection(title: "Other")
        otherSection.add(.copyableItem(label: "Storage Service Manifest Version", value: "\(storageServiceManifestVersion)"))
        otherSection.add(.copyableItem(label: "CC?", value: SSKEnvironment.shared.signalServiceRef.isCensorshipCircumventionActive ? "Yes" : "No"))
        otherSection.add(.copyableItem(label: "Audio Category", value: AVAudioSession.sharedInstance().category.rawValue.replacingOccurrences(of: "AVAudioSessionCategory", with: "")))
        otherSection.add(.switch(
            withText: "Spinning checkmarks",
            isOn: { SpinningCheckmarks.shouldSpin },
            target: self,
            selector: #selector(spinCheckmarks(_:))))
        contents.add(otherSection)

        let paymentsSection = OWSTableSection(title: "Payments")
        paymentsSection.add(.copyableItem(label: "MobileCoin Environment", value: MobileCoinAPI.Environment.current.description))
        paymentsSection.add(.copyableItem(label: "Enabled?", value: SSKEnvironment.shared.paymentsHelperRef.arePaymentsEnabled ? "Yes" : "No"))
        if SSKEnvironment.shared.paymentsHelperRef.arePaymentsEnabled, let paymentsEntropy = SUIEnvironment.shared.paymentsSwiftRef.paymentsEntropy {
            paymentsSection.add(.copyableItem(label: "Entropy", value: paymentsEntropy.hexadecimalString))
            if let passphrase = SUIEnvironment.shared.paymentsSwiftRef.passphrase {
                paymentsSection.add(.copyableItem(label: "Mnemonic", value: passphrase.asPassphrase))
            }
            if let walletAddressBase58 = SUIEnvironment.shared.paymentsSwiftRef.walletAddressBase58() {
                paymentsSection.add(.copyableItem(label: "B58", value: walletAddressBase58))
            }
        }
        contents.add(paymentsSection)

        self.contents = contents
    }
}

// MARK: -

public enum SpinningCheckmarks {
    static var shouldSpin = false
}

private extension InternalSettingsViewController {

    @objc
    func spinCheckmarks(_ sender: Any) {
        let wasSpinning = SpinningCheckmarks.shouldSpin
        if let view = sender as? UIView {
            if wasSpinning {
                view.layer.removeAnimation(forKey: "spin")
            } else {
                let animation = CABasicAnimation(keyPath: "transform.rotation.z")
                animation.toValue = NSNumber(value: Double.pi * 2)
                animation.duration = TimeInterval.second
                animation.isCumulative = true
                animation.repeatCount = .greatestFiniteMagnitude
                view.layer.add(animation, forKey: "spin")
            }
        }
        SpinningCheckmarks.shouldSpin = !wasSpinning
    }

    func validateMessageBackupProto() {
        let messageBackupKeyMaterial = DependenciesBridge.shared.messageBackupKeyMaterial
        let messageBackupManager = DependenciesBridge.shared.messageBackupManager
        let tsAccountManager = DependenciesBridge.shared.tsAccountManager

        guard let localIdentifiers = SSKEnvironment.shared.databaseStorageRef.read(block: {tx in
            return tsAccountManager.localIdentifiers(tx: tx)
        }) else {
            return
        }
        Task {
            do {
                let backupKey = try SSKEnvironment.shared.databaseStorageRef.read { tx in
                    try messageBackupKeyMaterial.backupKey(type: .messages, tx: tx)
                }
                let metadata = try await messageBackupManager.exportEncryptedBackup(
                    localIdentifiers: localIdentifiers,
                    backupKey: backupKey,
                    backupPurpose: .remoteBackup,
                    progress: nil
                )
                try await messageBackupManager.validateEncryptedBackup(
                    fileUrl: metadata.fileUrl,
                    localIdentifiers: localIdentifiers,
                    backupKey: backupKey,
                    backupPurpose: .remoteBackup
                )
                try? FileManager.default.removeItem(at: metadata.fileUrl)
                await MainActor.run {
                    self.presentToast(text: "Passed validation")
                }
            } catch {
                await MainActor.run {
                    DependenciesBridge.shared.messageBackupErrorPresenter.presentOverTopmostViewController(completion: {
                        self.presentToast(text: "Failed validation")
                    })
                }
            }
        }
    }

    func exportMessageBackupProto() {
        ModalActivityIndicatorViewController.present(
            fromViewController: self,
            canCancel: false
        ) { modal in
            func dismissModalAndToast(_ message: String) {
                DependenciesBridge.shared.messageBackupErrorPresenter.presentOverTopmostViewController(completion: {
                    modal.dismiss {
                        self.presentToast(text: message)
                    }
                })
            }

            func exportMessageBackupProtoFile() {
                Task {
                    let result = await Result(catching: {
                        try await self.exportMessageBackupProtoFile(presentingFrom: modal)
                    })
                    await MainActor.run {
                        switch result {
                        case .success:
                            dismissModalAndToast("Success! Key copied to clipboard")
                        case .failure(let error):
                            dismissModalAndToast("Failed! \(error.localizedDescription)")
                        }
                    }
                }
            }

            guard FeatureFlags.MessageBackup.remoteExportAlpha else {
                exportMessageBackupProtoFile()
                return
            }

            DispatchQueue.main.async {
                let actionSheet = ActionSheetController(title: "Choose backup destination:")

                let localFileAction = ActionSheetAction(title: "Local device") { _ in
                    exportMessageBackupProtoFile()
                }

                let remoteFileAction = ActionSheetAction(title: "Remote server") { _ in
                    Task {
                        let result = await Result(catching: {
                            try await self.exportMessageBackupProtoRemotely()
                        })
                        await MainActor.run {
                            switch result {
                            case .success:
                                dismissModalAndToast("Done")
                            case .failure(let error):
                                dismissModalAndToast("Failed! \(error.localizedDescription)")
                            }
                        }
                    }
                }

                actionSheet.addAction(localFileAction)
                actionSheet.addAction(remoteFileAction)
                modal.presentActionSheet(actionSheet)
            }
        }
    }

    // Right now this "local" backup uses the same format and encryption scheme
    // as the remote backup. In the future, this should use the local backup
    // format and encryption scheme.
    func exportMessageBackupProtoFile(
        presentingFrom vc: UIViewController
    ) async throws {
        let messageBackupKeyMaterial = DependenciesBridge.shared.messageBackupKeyMaterial
        let messageBackupManager = DependenciesBridge.shared.messageBackupManager
        let tsAccountManager = DependenciesBridge.shared.tsAccountManager

        let (backupKey, localIdentifiers) = try SSKEnvironment.shared.databaseStorageRef.read { tx in
            (
                try messageBackupKeyMaterial.backupKey(type: .messages, tx: tx),
                tsAccountManager.localIdentifiers(tx: tx)
            )
        }

        guard let localIdentifiers else {
            return
        }

        let metadata = try await messageBackupManager.exportEncryptedBackup(
            localIdentifiers: localIdentifiers,
            backupKey: backupKey,
            backupPurpose: .remoteBackup,
            progress: nil
        )

        let messageBackupKey = try backupKey.asMessageBackupKey(for: localIdentifiers.aci)
        let keyString = "AES key: \(Data(messageBackupKey.aesKey).base64EncodedString())"
            + "\nHMAC key: \(Data(messageBackupKey.hmacKey).base64EncodedString())"

        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(
                    activityItems: [metadata.fileUrl],
                    applicationActivities: nil
                )
                activityVC.popoverPresentationController?.sourceView = self.view
                activityVC.completionWithItemsHandler = { _, _, _, _ in
                    UIPasteboard.general.string = keyString
                    continuation.resume()
                }
                vc.present(activityVC, animated: true)
            }
        }
    }

    func exportMessageBackupProtoRemotely() async throws {
        let messageBackupKeyMaterial = DependenciesBridge.shared.messageBackupKeyMaterial
        let messageBackupManager = DependenciesBridge.shared.messageBackupManager
        let tsAccountManager = DependenciesBridge.shared.tsAccountManager

        let (backupKey, localIdentifiers) = try SSKEnvironment.shared.databaseStorageRef.read { tx in
            (
                try messageBackupKeyMaterial.backupKey(type: .messages, tx: tx),
                tsAccountManager.localIdentifiers(tx: tx)
            )
        }

        guard let localIdentifiers else {
            return
        }

        let metadata = try await messageBackupManager.exportEncryptedBackup(
            localIdentifiers: localIdentifiers,
            backupKey: backupKey,
            backupPurpose: .remoteBackup,
            progress: nil
        )
        _ = try await messageBackupManager.uploadEncryptedBackup(
            metadata: metadata,
            localIdentifiers: localIdentifiers,
            auth: .implicit()
        )
    }
}
