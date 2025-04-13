//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

class ProvisioningBaseViewController: OWSViewController, OWSNavigationChildController {

    // Unlike a delegate, we can and should retain a strong reference to the ProvisioningController.
    let provisioningController: ProvisioningController

    init(provisioningController: ProvisioningController) {
        self.provisioningController = provisioningController
        super.init()
    }

    func shouldShowBackButton() -> Bool {
        return false
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        primaryView.layoutMargins = primaryLayoutMargins

        if shouldShowBackButton() {
            let backButton = UIButton()
            backButton.setTemplateImage(UIImage(imageLiteralResourceName: "NavBarBack"), tintColor: Theme.secondaryTextAndIconColor)
            backButton.addTarget(self, action: #selector(navigateBack), for: .touchUpInside)

            view.addSubview(backButton)
            backButton.autoSetDimensions(to: CGSize(square: 40))
            backButton.autoPinEdge(toSuperviewMargin: .leading)
            backButton.autoPinEdge(toSuperviewMargin: .top)
        }
    }

    // MARK: - Factory Methods

    func createTitleLabel(text: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.textColor = Theme.primaryTextColor
        titleLabel.font = UIFont.dynamicTypeTitle1Clamped.semibold()
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        return titleLabel
    }

    func createExplanationLabel(explanationText: String) -> UILabel {
        let explanationLabel = UILabel()
        explanationLabel.textColor = Theme.secondaryTextAndIconColor
        explanationLabel.font = UIFont.dynamicTypeSubheadlineClamped
        explanationLabel.text = explanationText
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .center
        explanationLabel.lineBreakMode = .byWordWrapping
        return explanationLabel
    }

    var primaryLayoutMargins: UIEdgeInsets {
        switch traitCollection.horizontalSizeClass {
        case .unspecified, .compact:
            return UIEdgeInsets(top: 32, leading: 32, bottom: 32, trailing: 32)
        case .regular:
            return UIEdgeInsets(top: 112, leading: 112, bottom: 112, trailing: 112)
        @unknown default:
            return UIEdgeInsets(top: 32, leading: 32, bottom: 32, trailing: 32)
        }
    }

    func primaryButton(title: String, selector: Selector) -> OWSFlatButton {
        primaryButton(title: title, target: self, selector: selector)
    }

    func primaryButton(title: String, target: Any, selector: Selector) -> OWSFlatButton {
        let button = OWSFlatButton.button(
            title: title,
            font: UIFont.dynamicTypeBodyClamped.semibold(),
            titleColor: .white,
            backgroundColor: .ows_accentBlue,
            target: target,
            selector: selector)
        button.button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 14)
        return button
    }

    func primaryButton(title: String, action: UIAction) -> OWSFlatButton {
        let button = OWSFlatButton.button(
            title: title,
            font: UIFont.dynamicTypeBodyClamped.semibold(),
            titleColor: .white,
            backgroundColor: .ows_accentBlue,
            action: action)
        button.button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 14)
        return button
    }

    func linkButton(title: String, selector: Selector) -> OWSFlatButton {
        linkButton(title: title, target: self, selector: selector)
    }

    func linkButton(title: String, target: Any, selector: Selector) -> OWSFlatButton {
        let button = OWSFlatButton.button(
            title: title,
            font: UIFont.dynamicTypeSubheadlineClamped,
            titleColor: Theme.accentBlueColor,
            backgroundColor: .clear,
            target: target,
            selector: selector)
        button.enableMultilineLabel()
        button.button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 8)
        return button
    }

    class func horizontallyWrap(primaryButton: UIView) -> UIView {
        primaryButton.autoSetDimension(.width, toSize: 280)

        let buttonWrapper = UIView()
        buttonWrapper.addSubview(primaryButton)

        primaryButton.autoPinEdge(toSuperviewEdge: .top)
        primaryButton.autoPinEdge(toSuperviewEdge: .bottom)
        primaryButton.autoHCenterInSuperview()
        NSLayoutConstraint.autoSetPriority(.defaultLow) {
            primaryButton.autoPinEdge(toSuperviewEdge: .leading)
            primaryButton.autoPinEdge(toSuperviewEdge: .trailing)
        }

        return buttonWrapper
    }

    // MARK: - Overrides

    @objc
    func navigateBack() {
        navigationController?.popViewController(animated: true)
    }

    var prefersNavigationBarHidden: Bool {
        true
    }

    var shouldCancelNavigationBack: Bool {
        true
    }

    // The margins for `primaryView` will update to reflect the current traitCollection.
    // This includes handling changes to traits - e.g. when splitting an iPad or rotating
    // some iPhones.
    //
    // Subclasses should add primaryView as the single child of self.view and add any further
    // subviews to primaryView.
    //
    // If not for iOS10, we could get rid of primaryView, and manipulate the layoutMargins on
    // self.view directly, however on iOS10, UIKit VC presentation machinery resets the
    // layoutMargins *after* this method is called.
    let primaryView = UIView()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        primaryView.layoutMargins = primaryLayoutMargins
    }

    // MARK: - Orientation

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.isIPad ? .all : .portrait
    }
}
