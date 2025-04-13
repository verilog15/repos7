//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

public import SignalServiceKit

/// Manages the step-to-step state of primary device registration,
/// including re-registration and change number.
public protocol RegistrationCoordinator {

    /// Prepare to switch to secondary device linking, if allowed.
    /// If this returns true, state will have been appropriately cleared
    /// in order to proceed to seconday device linking; if not the
    /// user/device is not allowed and should stay in primary registration.
    func switchToSecondaryDeviceLinking() -> Bool

    /// Attempt to exit registration, returning true if allowed.
    ///
    /// When allowed differs by `RegistrationMode`:
    /// - registration: Never allowed (where would you go anyway?)
    /// - reRegistration: Allowed any time, but exiting preserves in-progress
    /// state which will be restored on the next attempt.
    /// - changeNumber: Allowed only before initiating the actual
    /// change number request on the server. Exiting wipes in progress state.
    func exitRegistration() -> Bool

    /// Call this method to determine which step comes next in the flow.
    /// If nothing has changed, this may be the current step, in which case
    /// no change in the UI is needed.
    ///
    /// The idea is that view controllers should be (mostly) stateless, and rely on
    /// the coordinator to update its state when actions are taken, then get the next
    /// step to know what view to push next.
    func nextStep() -> Guarantee<RegistrationStep>

    /// Continue past the splash screen (marking it as shown).
    func continueFromSplash() -> Guarantee<RegistrationStep>

    /// Mark if the user has their old device available to source registration information from.
    func setHasOldDevice(_ hasOldDevice: Bool) -> Guarantee<RegistrationStep>

    /// Show the system permissions prompts, proceeding to the next step when done.
    ///
    /// If something goes wrong, the next step will be the same as the current step
    /// but which attached metadata giving more info on the rejection.
    func requestPermissions() -> Guarantee<RegistrationStep>

    /// Submit an e164 to confirm for change number, returning the next step to take.
    /// If the e164 is rejected for any reason, the next step will be the same current step
    /// but with attached metadata giving more info on the rejection.
    func submitProspectiveChangeNumberE164(_ e164: E164) -> Guarantee<RegistrationStep>

    /// Submit an e164 to use, returning the next step to take.
    /// If the e164 is rejected for any reason, the next step will be the same current step
    /// but with attached metadata giving more info on the rejection.
    ///
    /// An e164 may already be known (e.g. re-registration); this call cements that
    /// e164. Until this is called, the e164 will not actually be used for registration.
    /// This gives the user a chance to change it before any automatic steps are taken.
    func submitE164(_ e164: E164) -> Guarantee<RegistrationStep>

    /// Wipes any previously submitted E164 so the user can enter a new one.
    ///
    /// May also blow away in progress registration steps and require redoing them;
    /// a new number is essentially a new registration.
    func requestChangeE164() -> Guarantee<RegistrationStep>

    /// Request an SMS code be sent, returning the next step to take.
    /// If requesting a code is disallowed for any reason, the next step will be the same current
    /// step but with attached metadata giving more info on the reason.
    func requestSMSCode() -> Guarantee<RegistrationStep>

    /// Request an voice code be sent, returning the next step to take.
    /// If requesting a code is disallowed for any reason, the next step will be the same current
    /// step but with attached metadata giving more info on the reason.
    func requestVoiceCode() -> Guarantee<RegistrationStep>

    /// Submit a verification code, returning the next step to take.
    /// If the code is rejected for any reason, the next step will be the same current
    /// step but with attached metadata giving more info on the rejection.
    func submitVerificationCode(_ code: String) -> Guarantee<RegistrationStep>

    /// Submit a capcha token to fulfill the captcha challenge step and go to the next step.
    /// If the token is rejected for any reason, the next step will be the same current
    /// step but with attached metadata giving more info on the rejection.
    func submitCaptcha(_ token: String) -> Guarantee<RegistrationStep>

    /// Submit a PIN code, but require confirmation in a subsequent step to proceed.
    /// That step will be provided the passed in blob, uninspected by this class.
    func setPINCodeForConfirmation(_ blob: RegistrationPinConfirmationBlob) -> Guarantee<RegistrationStep>

    /// Clear out an unconfirmed PIN code submitted via `setPINCodeForConfirmation`.
    /// Typically, will return to the initial PIN code step.
    func resetUnconfirmedPINCode() -> Guarantee<RegistrationStep>

    /// Set the PIN code, whether that be for the first time, to fetch from KBS, or
    /// to confirm the code we already know about locally.
    /// If the code is rejected for any reason, the next step will be the same current
    /// step but with attached metadata giving more info on the rejection.
    func submitPINCode(_ code: String) -> Guarantee<RegistrationStep>

    /// Skip entering the PIN code when registering for an existing account.
    /// This is only possible if reglock is disabled, and if done will wipe any KBS backups.
    /// If not allowed, an error step may be returned.
    func skipPINCode() -> Guarantee<RegistrationStep>

    /// Skip entering the existing PIN code when registering for an existing account, and instead
    /// create a new PIN (losing any backed up information).
    /// This is only possible if reglock is disabled, and if done will wipe any KBS backups.
    /// If not allowed, an error step may be returned.
    func skipAndCreateNewPINCode() -> Guarantee<RegistrationStep>

    /// When registering, the server will inform us (via an error code) if device transfer is
    /// possible from an existing device. In this case, the user must either transfer or explicitly
    /// decline transferring; this method informs the flow of the latter choice.
    func skipDeviceTransfer() -> Guarantee<RegistrationStep>

    /// Set the target restore method to be used in the next step to restore the system.
    func updateRestoreMethod(method: RegistrationRestoreMethod) -> Guarantee<RegistrationStep>

    /// Set the user-provided AEP
    func updateAccountEntropyPool(_ accountEntropyPool: AccountEntropyPool) -> Guarantee<RegistrationStep>

    /// Called after the old device sends the registration message after scanning the QR code.
    /// - parameter message: The `RegistrationProvisioningMessage` sent from the old
    ///     device containing the necessary info to reregister
    func restoreFromRegistrationMessage(message: RegistrationProvisioningMessage) -> Guarantee<RegistrationStep>

    /// Mark the users choice to skip restoring from backup and continuing to the next step.
    func skipRestoreFromBackup() -> Guarantee<RegistrationStep>

    /// Set whether the user's PNI should be discoverable by phone number.
    /// If the update is rejected for any reason, the next step will be the same current
    /// step but with attached metadata giving more info on the rejection.
    func setPhoneNumberDiscoverability(_ phoneNumberDiscoverability: PhoneNumberDiscoverability) -> Guarantee<RegistrationStep>

    /// Set the user's profile information.
    /// If the update is rejected for any reason, the next step will be the same current
    /// step but with attached metadata giving more info on the rejection.
    func setProfileInfo(
        givenName: OWSUserProfile.NameComponent,
        familyName: OWSUserProfile.NameComponent?,
        avatarData: Data?,
        phoneNumberDiscoverability: PhoneNumberDiscoverability
    ) -> Guarantee<RegistrationStep>

    /// The user has hit a reglock timeout and is acknowledging it.
    ///
    /// If they're doing initial registration, the user should get bonked back to
    /// a previous step. (Typically, the phone number entry screen)
    ///
    /// If they're already using the app (re-registration and change number), we should abort the
    /// registration process, exiting back to the main app.
    func acknowledgeReglockTimeout() -> AcknowledgeReglockResult
}

public enum AcknowledgeReglockResult {
    // Only possible during initial registration; lets the user
    // retry with a different number. Next step should be shown.
    case restartRegistration(Guarantee<RegistrationStep>)
    // Allowed to exit; the UI may go back to the main app.
    // Only sometimes possible during re-reg and change number.
    case exitRegistration
    // Unable to get anywhere; typically we are in re-registration
    // and state has already been wiped unrecoverably.
    case cannotExit
}
