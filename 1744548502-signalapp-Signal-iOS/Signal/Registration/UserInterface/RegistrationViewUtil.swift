//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalServiceKit
import SignalUI

// MARK: - Strings

extension String {
    var e164FormattedAsPhoneNumberWithoutBreaks: String {
        let formatted = PhoneNumber.bestEffortLocalizedPhoneNumber(e164: self)
        return formatted.replacingOccurrences(of: " ", with: "\u{00a0}")
    }
}

// MARK: - Layout margins

extension NSDirectionalEdgeInsets {
    static func layoutMarginsForRegistration(
        _ horizontalSizeClass: UIUserInterfaceSizeClass
    ) -> NSDirectionalEdgeInsets {
        switch horizontalSizeClass {
        case .regular:
            return NSDirectionalEdgeInsets(top: 0, leading: 112, bottom: 112, trailing: 112)
        case .unspecified, .compact:
            fallthrough
        @unknown default:
            return NSDirectionalEdgeInsets(top: 0, leading: 32, bottom: 32, trailing: 32)
        }
    }

    private init(allButTop: CGFloat) {
        self.init(top: 0, leading: allButTop, bottom: allButTop, trailing: allButTop)
    }
}

// MARK: - Colors

extension UIColor {
    static var colorForRegistrationTitleLabel: UIColor { Theme.primaryTextColor }
    static var colorForRegistrationExplanationLabel: UIColor { Theme.secondaryTextAndIconColor }
}

// MARK: - Fonts

extension UIFont {
    static var fontForRegistrationExplanationLabel: UIFont { .dynamicTypeSubheadlineClamped }
}

// MARK: - Labels

extension UILabel {
    static func titleLabelForRegistration(text: String) -> UILabel {
        let result = UILabel()
        result.text = text
        result.textColor = .colorForRegistrationTitleLabel
        result.font = UIFont.dynamicTypeTitle1Clamped.semibold()
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }

    static func explanationLabelForRegistration(text: String) -> UILabel {
        let result = UILabel()
        result.textColor = .colorForRegistrationExplanationLabel
        result.font = .fontForRegistrationExplanationLabel
        result.text = text
        result.numberOfLines = 0
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        return result
    }
}

// MARK: - Buttons

extension OWSFlatButton {
    static func primaryButtonForRegistration(title: String, target: Any, selector: Selector) -> OWSFlatButton {
        let result = insetButton(
            title: title,
            font: UIFont.dynamicTypeBodyClamped.semibold(),
            titleColor: .white,
            backgroundColor: .ows_accentBlue,
            target: target,
            selector: selector
        )
        result.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 14)
        return result
    }

    static func secondaryButtonForRegistration(title: String, target: Any, selector: Selector) -> OWSFlatButton {
        let result = insetButton(
            title: title,
            font: UIFont.dynamicTypeBodyClamped.semibold(),
            titleColor: .ows_accentBlue,
            backgroundColor: .clear,
            target: target,
            selector: selector
        )
        result.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 14)
        return result
    }

    static func linkButtonForRegistration(title: String, target: Any, selector: Selector) -> OWSFlatButton {
        let button = OWSFlatButton.button(
            title: title,
            font: UIFont.dynamicTypeSubheadlineClamped,
            titleColor: Theme.accentBlueColor,
            backgroundColor: .clear,
            target: target,
            selector: selector
        )
        button.enableMultilineLabel()
        button.button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 8)
        return button
    }
}

// MARK: - Action sheets

extension ActionSheetController {
    enum RegistrationVerificationConfirmationMode {
        case sms
        case voice
    }

    static func forRegistrationVerificationConfirmation(
        mode: RegistrationVerificationConfirmationMode,
        e164: String,
        didConfirm: @escaping () -> Void,
        didRequestEdit: @escaping () -> Void
    ) -> ActionSheetController {
        let message: String
        switch mode {
        case .sms:
            message = OWSLocalizedString(
                "REGISTRATION_VIEW_PHONE_NUMBER_CONFIRMATION_ALERT_MESSAGE",
                comment: "Message for confirmation alert during phone number registration."
            )
        case .voice:
            message = OWSLocalizedString(
                "REGISTRATION_PHONE_NUMBER_VOICE_CODE_ALERT_MESSAGE",
                comment: "Message for confirmation alert when requesting a voice code during phone number registration."
            )

        }
        let result = ActionSheetController(
            title: {
                let format = OWSLocalizedString(
                    "REGISTRATION_VIEW_PHONE_NUMBER_CONFIRMATION_ALERT_TITLE_FORMAT",
                    comment: "Title for confirmation alert during phone number registration. Embeds {{phone number}}."
                )
                return String(format: format, e164.e164FormattedAsPhoneNumberWithoutBreaks)
            }(),
            message: message
        )

        let confirmButtonTitle = CommonStrings.yesButton
        result.addAction(.init(title: confirmButtonTitle) { _ in didConfirm() })

        let editButtonTitle = OWSLocalizedString(
            "REGISTRATION_VIEW_PHONE_NUMBER_CONFIRMATION_EDIT_BUTTON",
            comment: "A button allowing user to cancel registration and edit a phone number"
        )
        result.addAction(.init(title: editButtonTitle) { _ in didRequestEdit() })

        return result
    }
}

// MARK: - Alerts

extension UIAlertController {
    static func registrationAppUpdateBanner() -> UIAlertController {
        let result = UIAlertController(
            title: OWSLocalizedString(
                "REGISTRATION_CANNOT_CONTINUE_WITHOUT_UPDATING_APP_TITLE",
                comment: "During (re)registration, users may need to update their app to continue. They'll be presented with an alert if this is the case, prompting them to update. This is the title on that alert."
            ),
            message: OWSLocalizedString(
                "REGISTRATION_CANNOT_CONTINUE_WITHOUT_UPDATING_APP_DESCRIPTION",
                comment: "During (re)registration, users may need to update their app to continue. They'll be presented with an alert if this is the case, prompting them to update. This is the description text on that alert."
            ),
            preferredStyle: .alert
        )

        let updateAction = UIAlertAction(
            title: OWSLocalizedString(
                "REGISTRATION_CANNOT_CONTINUE_WITHOUT_UPDATING_APP_ACTION",
                comment: "During (re)registration, users may need to update their app to continue. They'll be presented with an alert if this is the case, prompting them to update. This is the action button on that alert."
            ),
            style: .default
        ) { _ in
            UIApplication.shared.open(TSConstants.appStoreUrl)
        }
        result.addAction(updateAction)
        result.preferredAction = updateAction

        return result
    }
}
