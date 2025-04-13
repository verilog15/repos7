//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import UIKit

open class OWSFlatButton: UIView {

    public let button: UIButton

    private var pressedBlock: (() -> Void)?

    private var upColor: UIColor?
    private var downColor: UIColor?

    public var cornerRadius: CGFloat {
        get {
            button.layer.cornerRadius
        }
        set {
            button.layer.cornerRadius = newValue
            button.clipsToBounds = newValue > 0
        }
    }

    public override var accessibilityIdentifier: String? {
        didSet {
            guard let accessibilityIdentifier = self.accessibilityIdentifier else {
                return
            }
            button.accessibilityIdentifier = "\(accessibilityIdentifier).button"
        }
    }

    override public var backgroundColor: UIColor? {
        willSet {
            owsFailDebug("Use setBackgroundColors(upColor:) instead.")
        }
    }

    public var titleEdgeInsets: UIEdgeInsets {
        get {
            return button.ows_titleEdgeInsets
        }
        set {
            button.ows_titleEdgeInsets = newValue
        }
    }

    public var contentEdgeInsets: UIEdgeInsets {
        get {
            return button.ows_contentEdgeInsets
        }
        set {
            button.ows_contentEdgeInsets = newValue
        }
    }

    public override var tintColor: UIColor! {
        get {
            return button.tintColor
        }
        set {
            button.tintColor = newValue
        }
    }

    public init() {
        AssertIsOnMainThread()

        button = UIButton(type: .custom)

        super.init(frame: CGRect.zero)

        createContent()
    }

    @available(*, unavailable, message: "use other constructor instead.")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createContent() {
        self.addSubview(button)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.autoPinEdgesToSuperviewEdges()
    }

    public class func button(title: String,
                             font: UIFont,
                             titleColor: UIColor,
                             backgroundColor: UIColor,
                             width: CGFloat,
                             height: CGFloat,
                             target: Any,
                             selector: Selector) -> OWSFlatButton {
        let button = OWSFlatButton()
        button.setTitle(title: title,
                        font: font,
                        titleColor: titleColor )
        button.setBackgroundColors(upColor: backgroundColor)
        button.useDefaultCornerRadius()
        button.setSize(width: width, height: height)
        button.addTarget(target: target, selector: selector)
        return button
    }

    public class func button(title: String,
                             titleColor: UIColor,
                             backgroundColor: UIColor,
                             width: CGFloat,
                             height: CGFloat,
                             target: Any,
                             selector: Selector) -> OWSFlatButton {
        return OWSFlatButton.button(title: title,
                                    font: fontForHeight(height),
                                    titleColor: titleColor,
                                    backgroundColor: backgroundColor,
                                    width: width,
                                    height: height,
                                    target: target,
                                    selector: selector)
    }

    public class func insetButton(
        title: String,
        font: UIFont,
        titleColor: UIColor,
        backgroundColor: UIColor,
        target: Any,
        selector: Selector
    ) -> OWSFlatButton {
        return OWSFlatButton.button(
            title: title,
            font: font,
            titleColor: titleColor,
            backgroundColor: backgroundColor,
            target: target,
            selector: selector,
            cornerRadius: CornerStyle.inset
        )
    }

    private class func button(
        title: String,
        font: UIFont,
        titleColor: UIColor,
        backgroundColor: UIColor,
        cornerRadius: CGFloat
    ) -> OWSFlatButton {
        let button = OWSFlatButton()
        button.setTitle(title: title,
                        font: font,
                        titleColor: titleColor )
        button.setBackgroundColors(upColor: backgroundColor)
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
        return button
    }

    public class func button(
        title: String,
        font: UIFont,
        titleColor: UIColor,
        backgroundColor: UIColor,
        target: Any,
        selector: Selector,
        cornerRadius: CGFloat = CornerStyle.default
    ) -> OWSFlatButton {
        let button = button(title: title, font: font, titleColor: titleColor, backgroundColor: backgroundColor, cornerRadius: cornerRadius)
        button.addTarget(target: target, selector: selector)
        return button
    }

    public class func button(
        title: String,
        font: UIFont,
        titleColor: UIColor,
        backgroundColor: UIColor,
        action: UIAction,
        cornerRadius: CGFloat = CornerStyle.default
    ) -> OWSFlatButton {
        let button = button(title: title, font: font, titleColor: titleColor, backgroundColor: backgroundColor, cornerRadius: cornerRadius)
        button.addAction(action)
        return button
    }

    public class func fontForHeight(_ height: CGFloat) -> UIFont {
        // Cap the "button height" at 40pt or button text can look
        // excessively large.
        let fontPointSize = round(min(40, height) * 0.45)
        return UIFont.semiboldFont(ofSize: fontPointSize)
    }

    public class func heightForFont(_ font: UIFont) -> CGFloat {
        font.lineHeight * 2.5
    }

    // MARK: Methods

    public func setTitleColor(_ color: UIColor) {
        button.setTitleColor(color, for: .normal)
    }

    public func setTitle(title: String? = nil, font: UIFont? = nil, titleColor: UIColor? = nil) {
        title.map { button.setTitle($0, for: .normal) }
        font.map { button.titleLabel?.font = $0 }
        titleColor.map { setTitleColor($0) }
    }

    public func setAttributedTitle(_ title: NSAttributedString) {
        button.setAttributedTitle(title, for: .normal)
    }

    public func setImage(_ image: UIImage) {
        button.setImage(image, for: .normal)
    }

    public func setBackgroundColors(upColor: UIColor,
                                    downColor: UIColor ) {
        button.setBackgroundImage(UIImage.image(color: upColor), for: .normal)
        button.setBackgroundImage(UIImage.image(color: downColor), for: .highlighted)
    }

    public func setBackgroundColors(upColor: UIColor) {
        let downColor = upColor == .clear ? upColor : upColor.withAlphaComponent(0.7)
        setBackgroundColors(upColor: upColor, downColor: downColor)
    }

    public func setSize(width: CGFloat, height: CGFloat) {
        button.autoSetDimension(.width, toSize: width)
        button.autoSetDimension(.height, toSize: height)
    }

    public func useDefaultCornerRadius() {
        // To my eye, this radius tends to look right regardless of button size
        // (within reason) or device size. 
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
    }

    public func useInsetCornerRadius() {
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
    }

    public func setEnabled(_ isEnabled: Bool) {
        button.isEnabled = isEnabled
    }

    public func addTarget(target: Any,
                          selector: Selector) {
        button.addTarget(target, action: selector, for: .touchUpInside)
    }

    public func addAction(_ action: UIAction) {
        button.addAction(action, for: .touchUpInside)
    }

    public func setPressedBlock(_ pressedBlock: @escaping () -> Void) {
        guard self.pressedBlock == nil else { return }
        self.pressedBlock = pressedBlock
    }

    @objc
    private func buttonPressed() {
        pressedBlock?()
    }

    public func enableMultilineLabel() {
        guard let titleLabel = button.titleLabel else { return }

        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center

        button.autoPinHeight(
            toHeightOf: titleLabel,
            relation: .greaterThanOrEqual
        )
    }

    public var font: UIFont? {
        return button.titleLabel?.font
    }

    public func autoSetMinimumHeighUsingFont(extraVerticalInsets: CGFloat = 0) {
        guard let font = font else {
            owsFailDebug("Missing button font.")
            return
        }
        autoSetDimension(
            .height,
            toSize: Self.heightForFont(font) + CGFloat(extraVerticalInsets * 2.0),
            relation: .greaterThanOrEqual
        )
    }

    public func autoSetHeightUsingFont(extraVerticalInsets: CGFloat = 0) {
        guard let font = font else {
            owsFailDebug("Missing button font.")
            return
        }
        autoSetDimension(.height, toSize: Self.heightForFont(font) + CGFloat(extraVerticalInsets * 2.0))
    }

    override public var intrinsicContentSize: CGSize {
        button.intrinsicContentSize
    }

    public enum CornerStyle {
        public static let `default`: CGFloat = 5.0
        public static let inset: CGFloat = 14.0
    }
}
