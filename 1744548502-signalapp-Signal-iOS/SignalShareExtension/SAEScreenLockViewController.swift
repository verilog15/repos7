//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

final class SAEScreenLockViewController: ScreenLockViewController {

    private var completion: ((_ didUnlock: Bool) -> Void)?

    private func invokeCompletion(didUnlock: Bool) {
        let completion = self.completion
        self.completion = nil
        completion?(didUnlock)
    }

    init(completion: @escaping (_ didUnlock: Bool) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.completion = completion
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func loadView() {
        super.loadView()
        view.backgroundColor = Theme.launchScreenBackgroundColor
        title = OWSLocalizedString("SHARE_EXTENSION_VIEW_TITLE", comment: "Title for the 'share extension' view.")
        navigationItem.leftBarButtonItem = .systemItem(.stop) { [weak self] in
            Logger.debug("tapped dismiss share button")
            self?.cancelShareExperience()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ensureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        ensureUI()

        if !hasShownAuthUIOnce {
            hasShownAuthUIOnce = true
            tryToPresentAuthUIToUnlockScreenLock()
        }
    }

    // MARK: - Lock Screen UI

    private var hasShownAuthUIOnce = false

    private var isShowingAuthUI = false

    private func ensureUI() {
        updateUIWithState(.screenLock)
    }

    private func tryToPresentAuthUIToUnlockScreenLock() {
        AssertIsOnMainThread()

        guard !isShowingAuthUI else { return }
        isShowingAuthUI = true

        ScreenLock.shared.tryToUnlockScreenLock(
            success: {
                AssertIsOnMainThread()

                Logger.info("unlock screen lock succeeded.")

                self.isShowingAuthUI = false
                self.invokeCompletion(didUnlock: true)
            },
            failure: { error in
                AssertIsOnMainThread()

                Logger.info("unlock screen lock failed.")

                self.isShowingAuthUI = false
                self.ensureUI()
                self.showScreenLockFailureAlertWithMessage(error.userErrorDescription)
            },
            unexpectedFailure: { error in
                AssertIsOnMainThread()

                Logger.info("unlock screen lock unexpectedly failed.")

                self.isShowingAuthUI = false

                // Local Authentication isn't working properly.
                // This isn't covered by the docs or the forums but in practice
                // it appears to be effective to retry again after waiting a bit.
                DispatchQueue.main.async {
                    self.ensureUI()
                }
            },
            cancel: {
                AssertIsOnMainThread()

                Logger.info("unlock screen lock cancelled.")

                self.isShowingAuthUI = false
                self.ensureUI()
            }
        )

        ensureUI()
    }

    private func showScreenLockFailureAlertWithMessage(_ message: String) {
        AssertIsOnMainThread()

        OWSActionSheets.showActionSheet(
            title: OWSLocalizedString(
                "SCREEN_LOCK_UNLOCK_FAILED",
                comment: "Title for alert indicating that screen lock could not be unlocked."
            ),
            buttonAction: { _ in
                // After the alert, update the UI.
                self.ensureUI()
            },
            fromViewController: self
        )
    }

    private func cancelShareExperience() {
        invokeCompletion(didUnlock: false)
    }
}

extension SAEScreenLockViewController: ScreenLockViewDelegate {

    func unlockButtonWasTapped() {
        AssertIsOnMainThread()

        Logger.info("unlockButtonWasTapped")

        tryToPresentAuthUIToUnlockScreenLock()
    }
}
