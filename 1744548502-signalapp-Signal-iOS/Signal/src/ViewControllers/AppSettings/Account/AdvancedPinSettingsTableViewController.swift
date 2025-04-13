//
// Copyright 2020 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

class AdvancedPinSettingsTableViewController: OWSTableViewController2 {

    private let context: ViewControllerContext

    public override init() {
        // TODO[ViewContextPiping]
        self.context = ViewControllerContext.shared
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = OWSLocalizedString("SETTINGS_ADVANCED_PIN_TITLE", comment: "The title for the advanced pin settings.")

        updateTableContents()
    }

    func updateTableContents() {
        let contents = OWSTableContents()

        let pinsSection = OWSTableSection()

        let (hasMasterKey, hasBackedUpMasterKey) = context.db.read { tx in
            return (
                context.svr.hasMasterKey(transaction: tx),
                context.svr.hasBackedUpMasterKey(transaction: tx)
            )
        }

        pinsSection.add(OWSTableItem.actionItem(
            withText: (hasMasterKey && !hasBackedUpMasterKey)
                ? OWSLocalizedString("SETTINGS_ADVANCED_PINS_ENABLE_PIN_ACTION",
                                    comment: "")
                : OWSLocalizedString("SETTINGS_ADVANCED_PINS_DISABLE_PIN_ACTION",
                                    comment: ""),
            textColor: Theme.accentBlueColor,
            accessibilityIdentifier: "advancedPinSettings.disable",
            actionBlock: { [weak self] in
                self?.enableOrDisablePin()
        }))
        contents.add(pinsSection)

        self.contents = contents
    }

    private func enableOrDisablePin() {
        let (hasMasterKey, hasBackedUpMasterKey) = context.db.read { tx in
            return (
                context.svr.hasMasterKey(transaction: tx),
                context.svr.hasBackedUpMasterKey(transaction: tx)
            )
        }
        if hasMasterKey && !hasBackedUpMasterKey {
            enablePin()
        } else {
            if SSKEnvironment.shared.paymentsHelperRef.arePaymentsEnabled,
               !PaymentsSettingsViewController.hasReviewedPassphraseWithSneakyTransaction() {
                showReviewPassphraseAlertUI()
            } else {
                disablePin()
            }
        }
    }

    private func enablePin() {
        let viewController = PinSetupViewController(
            mode: .creating,
            hideNavigationBar: false,
            completionHandler: { [weak self] _, _ in
                guard let self = self else { return }
                self.navigationController?.popToViewController(self, animated: true)
                self.updateTableContents()
            }
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func disablePin() {
        Task {
            do {
                _ = try await PinSetupViewController.disablePinWithConfirmation(fromViewController: self)
                self.updateTableContents()
            } catch {
                owsFailDebug("Error: \(error)")
            }
        }
    }

    private func showReviewPassphraseAlertUI() {
        AssertIsOnMainThread()

        let actionSheet = ActionSheetController(title: OWSLocalizedString("SETTINGS_PAYMENTS_RECORD_PASSPHRASE_DISABLE_PIN_TITLE",
                                                                         comment: "Title for the 'record payments passphrase to disable pin' UI in the app settings."),
                                                message: OWSLocalizedString("SETTINGS_PAYMENTS_RECORD_PASSPHRASE_DISABLE_PIN_DESCRIPTION",
                                                                           comment: "Description for the 'record payments passphrase to disable pin' UI in the app settings."))

        actionSheet.addAction(ActionSheetAction(title: OWSLocalizedString("SETTINGS_PAYMENTS_RECORD_PASSPHRASE_DISABLE_PIN_RECORD_PASSPHRASE",
                                                                         comment: "Label for the 'record recovery passphrase' button in the 'record payments passphrase to disable pin' UI in the app settings."),
                                                accessibilityIdentifier: "payments.settings.disable-pin.record-passphrase",
                                                style: .default) { [weak self] _ in
            self?.showRecordPaymentsPassphraseUI()
        })
        actionSheet.addAction(OWSActionSheets.cancelAction)

        presentActionSheet(actionSheet)
    }

    private func showRecordPaymentsPassphraseUI() {
        guard let passphrase = SUIEnvironment.shared.paymentsSwiftRef.passphrase else {
            owsFailDebug("Missing passphrase.")
            return
        }
        let view = PaymentsViewPassphraseSplashViewController(passphrase: passphrase,
                                                              style: .reviewed,
                                                              viewPassphraseDelegate: self)
        let navigationVC = OWSNavigationController(rootViewController: view)
        present(navigationVC, animated: true)
    }
}

// MARK: -

extension AdvancedPinSettingsTableViewController: PaymentsViewPassphraseDelegate {
    public func viewPassphraseDidComplete() {
        PaymentsSettingsViewController.setHasReviewedPassphraseWithSneakyTransaction()

        presentToast(text: OWSLocalizedString("SETTINGS_PAYMENTS_VIEW_PASSPHRASE_COMPLETE_TOAST",
                                             comment: "Message indicating that 'payments passphrase review' is complete."))
    }

    public func viewPassphraseDidCancel(viewController: PaymentsViewPassphraseSplashViewController) {
        viewController.dismiss(animated: true)
    }
}
