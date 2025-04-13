//
// Copyright 2020 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import LibSignalClient
public import SignalServiceKit

public protocol BodyRangesTextViewDelegate: UITextViewDelegate {
    func textViewDidBeginTypingMention(_ textView: BodyRangesTextView)
    func textViewDidEndTypingMention(_ textView: BodyRangesTextView)

    func textViewMentionPickerParentView(_ textView: BodyRangesTextView) -> UIView?
    func textViewMentionPickerReferenceView(_ textView: BodyRangesTextView) -> UIView?
    // It doesn't matter what this key is; but when it changes cached mention names will be discarded.
    // Typically, we want this to change in new thread contexts and such.
    func textViewMentionCacheInvalidationKey(_ textView: BodyRangesTextView) -> String
    func textViewMentionPickerPossibleAddresses(_ textView: BodyRangesTextView, tx: DBReadTransaction) -> [SignalServiceAddress]

    func textViewDisplayConfiguration(_ textView: BodyRangesTextView) -> HydratedMessageBody.DisplayConfiguration
    func mentionPickerStyle(_ textView: BodyRangesTextView) -> MentionPickerStyle

    func textViewDidInsertMemoji(_ memojiGlyph: OWSAdaptiveImageGlyph)
}

extension BodyRangesTextViewDelegate {

    // Do nothing by default
    public func textViewDidInsertMemoji(_ memojiGlyph: OWSAdaptiveImageGlyph) {}
}

open class BodyRangesTextView: OWSTextView, EditableMessageBodyDelegate {

    public weak var bodyRangesDelegate: BodyRangesTextViewDelegate? {
        didSet { updateMentionState() }
    }

    public override var delegate: UITextViewDelegate? {
        didSet {
            if let delegate = delegate {
                owsAssertDebug(delegate === self)
            }
        }
    }

    private let customLayoutManager: NSLayoutManager

    public init() {
        let editableBody = EditableMessageBodyTextStorage(db: DependenciesBridge.shared.db)
        self.editableBody = editableBody
        let container = NSTextContainer()
        let layoutManager = NSLayoutManager()
        self.customLayoutManager = layoutManager
        layoutManager.textStorage = editableBody
        layoutManager.addTextContainer(container)
        container.replaceLayoutManager(layoutManager)
        super.init(frame: .zero, textContainer: container)
        updateTextContainerInset()
        delegate = self
        editableBody.editableBodyDelegate = self
        textAlignment = .natural
    }

    public override var layoutManager: NSLayoutManager {
        return customLayoutManager
    }

    deinit {
        pickerView?.removeFromSuperview()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    public func insertTypedMention(address: SignalServiceAddress) {
        guard case .typingMention(let range) = state else {
            return owsFailDebug("Can't finish typing when no mention in progress")
        }

        replaceCharacters(
            in: NSRange(
                location: range.location - Mention.prefix.count,
                length: range.length + Mention.prefix.count
            ),
            withMentionAddress: address
        )
    }

    public func replaceCharacters(
        in range: NSRange,
        withMentionAddress mentionAddress: SignalServiceAddress
    ) {
        guard let bodyRangesDelegate = bodyRangesDelegate else {
            return owsFailDebug("Can't replace characters without delegate")
        }
        guard let mentionAci = mentionAddress.aci else {
            return owsFailDebug("Can't insert a mention without an ACI")
        }

        let body = MessageBody(
            text: "@",
            ranges: MessageBodyRanges(mentions: [NSRange(location: 0, length: 1): mentionAci], styles: [])
        )
        let (hydrated, possibleAddresses) = DependenciesBridge.shared.db.read { tx in
            return (
                body.hydrating(mentionHydrator: ContactsMentionHydrator.mentionHydrator(transaction: tx)),
                bodyRangesDelegate.textViewMentionPickerPossibleAddresses(self, tx: tx)
            )
        }
        let hydratedPlaintext = hydrated.asPlaintext()

        if possibleAddresses.contains(mentionAddress) {
            editableBody.beginEditing()
            editableBody.replaceCharacters(in: range, withMentionAci: mentionAci, txProvider: DependenciesBridge.shared.db.readTxProvider)
            editableBody.endEditing()
        } else {
            // If we shouldn't resolve the mention, insert the plaintext representation.
            editableBody.beginEditing()
            editableBody.replaceCharacters(in: range, with: hydratedPlaintext, selectedRange: selectedRange)
            editableBody.endEditing()
        }
    }

    public var currentlyTypingMentionText: String? {
        guard case .typingMention(let range) = state else { return nil }
        guard (editableBody.hydratedPlaintext as NSString).length >= range.location + range.length else { return nil }
        guard range.length > 0 else { return "" }

        return (editableBody.hydratedPlaintext as NSString).substring(with: range)
    }

    public var defaultAttributes: [NSAttributedString.Key: Any] {
        var defaultAttributes = [NSAttributedString.Key: Any]()
        if let font = font { defaultAttributes[.font] = font }
        if let textColor = textColor { defaultAttributes[.foregroundColor] = textColor }
        return defaultAttributes
    }

    public var isEmpty: Bool {
        return editableBody.isEmpty
    }

    public var isWhitespaceOrEmpty: Bool {
        return editableBody.hydratedPlaintext.filterForDisplay.isEmpty
    }

    @available(*, unavailable)
    public override var text: String! {
        get {
            return textStorage.string
        }
        set {
            // Ignore setters; this is illegal
        }
    }

    @available(*, unavailable)
    public override var attributedText: NSAttributedString! {
        get {
            return textStorage.attributedString()
        }
        set {
            // Ignore setters; this is illegal
        }
    }

    public override var textColor: UIColor? {
        didSet {
            editableBody.didUpdateTheming()
        }
    }

    private let editableBody: EditableMessageBodyTextStorage

    public var messageBodyForSending: MessageBody {
        return editableBody.messageBody.filterStringForDisplay()
    }

    open func setMessageBody(_ messageBody: MessageBody?, txProvider: EditableMessageBodyTextStorage.ReadTxProvider) {
        editableBody.beginEditing()
        if messageBody == nil {
            // "unmark" text so that pending marked ranges
            // are cleared on iOS 18.1 and don't result in a
            // crash when we later set selected range to empty.
            self.unmarkText()
        }
        editableBody.setMessageBody(messageBody, txProvider: txProvider)
        editableBody.endEditing()
    }

    public func scrollToBottom() {
        let length = (editableBody.attributedString.string as NSString).length
        if length == 0 {
            return
        }
        scrollRangeToVisible(NSRange(location: length - 1, length: 1))
    }

    public func stopTypingMention() {
        state = .notTypingMention
    }

    public func reloadMentionState() {
        stopTypingMention()
        updateMentionState()
    }

    // MARK: - Mention State

    private enum State: Equatable {
        case typingMention(range: NSRange)
        case notTypingMention
    }
    private var state: State = .notTypingMention {
        didSet {
            switch state {
            case .notTypingMention:
                if oldValue != .notTypingMention { didEndTypingMention() }
            case .typingMention:
                if oldValue == .notTypingMention {
                    didBeginTypingMention()
                } else {
                    guard let currentlyTypingMentionText = currentlyTypingMentionText else {
                        return owsFailDebug("unexpectedly missing mention text while typing a mention")
                    }

                    didUpdateMentionText(currentlyTypingMentionText)
                }
            }
        }
    }

    private weak var pickerView: MentionPicker?
    private weak var pickerViewTopConstraint: NSLayoutConstraint?
    private func didBeginTypingMention() {
        guard let bodyRangesDelegate = bodyRangesDelegate else { return }

        bodyRangesDelegate.textViewDidBeginTypingMention(self)

        pickerView?.removeFromSuperview()

        let mentionableAddresses = SSKEnvironment.shared.databaseStorageRef.read { tx in
            return bodyRangesDelegate.textViewMentionPickerPossibleAddresses(self, tx: tx)
        }

        guard !mentionableAddresses.isEmpty else { return }

        guard let pickerReferenceView = bodyRangesDelegate.textViewMentionPickerReferenceView(self),
            let pickerParentView = bodyRangesDelegate.textViewMentionPickerParentView(self) else { return }

        let pickerView = MentionPicker(
            mentionableAddresses: mentionableAddresses,
            style: bodyRangesDelegate.mentionPickerStyle(self)
        ) { [weak self] selectedAddress in
            self?.insertTypedMention(address: selectedAddress)
        }
        self.pickerView = pickerView

        pickerParentView.insertSubview(pickerView, belowSubview: pickerReferenceView)
        pickerView.autoPinWidthToSuperview()
        pickerView.autoPinEdge(toSuperviewSafeArea: .top, withInset: 0, relation: .greaterThanOrEqual)

        let animationTopConstraint = pickerView.autoPinEdge(.top, to: .top, of: pickerReferenceView)

        guard let currentlyTypingMentionText = currentlyTypingMentionText,
            pickerView.mentionTextChanged(currentlyTypingMentionText) else {
                pickerView.removeFromSuperview()
                self.pickerView = nil
                state = .notTypingMention
                return
        }

        ImpactHapticFeedback.impactOccurred(style: .light)

        pickerParentView.layoutIfNeeded()

        // Slide up.
        UIView.animate(withDuration: 0.25) {
            pickerView.alpha = 1
            animationTopConstraint.isActive = false
            self.pickerViewTopConstraint = pickerView.autoPinEdge(.bottom, to: .top, of: pickerReferenceView)
            pickerParentView.layoutIfNeeded()
        }
    }

    private func didEndTypingMention() {
        bodyRangesDelegate?.textViewDidEndTypingMention(self)

        guard let pickerView = pickerView else { return }

        self.pickerView = nil

        let pickerViewTopConstraint = self.pickerViewTopConstraint
        self.pickerViewTopConstraint = nil

        guard let bodyRangesDelegate = bodyRangesDelegate,
            let pickerReferenceView = bodyRangesDelegate.textViewMentionPickerReferenceView(self),
            let pickerParentView = bodyRangesDelegate.textViewMentionPickerParentView(self) else {
                pickerView.removeFromSuperview()
                return
        }

        let style = bodyRangesDelegate.mentionPickerStyle(self)

        // Slide down.
        UIView.animate(withDuration: 0.25, animations: {
            pickerViewTopConstraint?.isActive = false
            pickerView.autoPinEdge(.top, to: .top, of: pickerReferenceView)
            pickerParentView.layoutIfNeeded()

            switch style {
            case .composingAttachment:
                pickerView.alpha = 0
            case .groupReply, .`default`:
                break
            }
        }) { _ in
            pickerView.removeFromSuperview()
        }
    }

    private func didUpdateMentionText(_ text: String) {
        if let pickerView = pickerView, !pickerView.mentionTextChanged(text) {
            state = .notTypingMention
        }
    }

    private func shouldUpdateMentionText(in range: NSRange, changedText text: String) -> Bool {
        let mentionRanges = editableBody.mentionRanges

        if range.length > 0 {
            // Locate any mentions in the edited range.
            // TODO[TextFormatting]: update styles as needed
            for mentionRange in mentionRanges {
                // Mention ranges are ordered; once we are past the range
                // we are looking for no need to look more.
                if mentionRange.location > range.upperBound {
                    break
                }
            }
        } else if
            range.location > 0,
            mentionRanges.first(where: { mentionRange in
              mentionRange.upperBound == range.location
            }) != nil {
            // If there is a mention to the left, the typing attributes will
            // be the mention's attributes. We don't want that, so we need
            // to reset them here.
            typingAttributes = defaultAttributes
        }

        return true
    }

    private func updateMentionState() {
        // If we don't yet have a delegate, we can ignore any updates.
        // We'll check again when the delegate is assigned.
        guard bodyRangesDelegate != nil else { return }

        let bodyLength = (editableBody.hydratedPlaintext as NSString).length
        guard
            selectedRange.length == 0,
            selectedRange.location > 0,
            bodyLength > 0,
            selectedRange.upperBound <= bodyLength
        else {
            state = .notTypingMention
            return
        }

        var location = selectedRange.location

        while location > 0 {
            let possiblePrefix = editableBody.hydratedPlaintext.substring(
                withRange: NSRange(location: location - Mention.prefix.count, length: Mention.prefix.count)
            )

            let mentionRanges = editableBody.mentionRanges

            // If the previous character is part of a mention, we're not typing a mention
            if mentionRanges.first(where: { $0.contains(location) }) != nil {
                state = .notTypingMention
                return
            }

            // If we find whitespace before the selected range, we're not typing a mention.
            // Mention typing breaks on whitespace.
            if possiblePrefix.unicodeScalars.allSatisfy({ NSCharacterSet.whitespacesAndNewlines.contains($0) }) {
                state = .notTypingMention
                return

            // If we find the mention prefix before the selected range, we may be typing a mention.
            } else if possiblePrefix == Mention.prefix {

                // If there's more text before the mention prefix, check if it's whitespace. Mentions
                // only start at the beginning of the string OR after a whitespace character.
                if location - Mention.prefix.count > 0 {
                    let characterPrecedingPrefix = editableBody.hydratedPlaintext.substring(
                        withRange: NSRange(location: location - Mention.prefix.count - 1, length: Mention.prefix.count)
                    )

                    // If it's not whitespace, keep looking back. Mention text can contain an "@" character,
                    // for example when trying to match a profile name that contains "@"
                    if !characterPrecedingPrefix.unicodeScalars.allSatisfy({ NSCharacterSet.whitespacesAndNewlines.contains($0) }) {
                        location -= 1
                        continue
                    }
                }

                state = .typingMention(
                    range: NSRange(location: location, length: selectedRange.location - location)
                )
                return
            } else {
                location -= 1
            }
        }

        // We checked everything, so we're not typing
        state = .notTypingMention
    }

    // MARK: - Text Formatting

    // MARK: Menu items

    private let cutUIMenuAction = #selector(cut)
    private let copyUIMenuAction = #selector(UIResponderStandardEditActions.copy(_:))
    private let pasteUIMenuAction = #selector(UIResponderStandardEditActions.paste(_:))

    private let uiMenuPromptReplaceAction = Selector(("_promptForReplace:"))
    private let uiMenuReplaceAction = Selector(("replace:"))
    private let customUIMenuPromptReplaceAction = #selector(customUIMenuPromptReplace)
    @objc
    func customUIMenuPromptReplace(_ sender: Any?) { super.perform(uiMenuPromptReplaceAction, with: sender) }

    private let uiMenuTranslateAction = Selector(("_translate:"))
    private let customUIMenuTranslateAction = #selector(customUIMenuTranslate)
    @objc
    func customUIMenuTranslate(_ sender: Any?) { super.perform(uiMenuTranslateAction, with: sender) }

    private let uiMenuLookUpAction = Selector(("_define:"))
    private let customUIMenuLookUpAction = #selector(customUIMenuLookUp)
    @objc
    func customUIMenuLookUp(_ sender: Any?) { super.perform(uiMenuLookUpAction, with: sender) }

    private let uiMenuShareAction = Selector(("_share:"))
    private let customUIMenuShareAction = #selector(customUIMenuShare)
    @objc
    func customUIMenuShare(_ sender: Any?) { super.perform(uiMenuShareAction, with: sender) }

    open override func buildMenu(with builder: UIMenuBuilder) {
        if builder.menu(for: .lookup) != nil, selectedRange.length > 0 {
            // The lookup action is special; for whatever reason it doesn't go
            // through `canPerformAction` at all, so we have to disable it here
            // or it will appear before our custom format options.
            builder.remove(menu: .lookup)
        }
        super.buildMenu(with: builder)
    }

    public func disallowsAnyPasteAction() -> Bool {
        return isShowingFormatMenu
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // We only mess with actions when there's a selection.
        guard selectedRange.length > 0 else {
            return super.canPerformAction(action, withSender: sender)
        }
        // Let our custom style actions through.
        if action == #selector(didSelectTextFormattingSubmenu) {
            return selectedRange.length > 0
        }
        if MessageBodyRanges.SingleStyle.allCases.lazy
            .map({ (style: MessageBodyRanges.SingleStyle) -> Selector in
                return self.uiMenuItemSelector(for: style)
            })
            .contains(action) {
            return isShowingFormatMenu
        }
        if action == #selector(didSelectClearStyles) {
            guard isShowingFormatMenu, selectedRange.length > 0 else {
                return false
            }
            return editableBody.hasFormatting(in: selectedRange)
        }

        switch action {
        // Cut, copy, paste are let through as they are first in the list.
        case cutUIMenuAction, copyUIMenuAction, pasteUIMenuAction:
            guard !isShowingFormatMenu else {
                return false
            }
            return super.canPerformAction(action, withSender: sender)

        // We want these actions to appear, but _after_ format. To do that, we disable
        // the system's action and use custom ones of our own that forward to the same selector.
        case customUIMenuPromptReplaceAction:
            return super.canPerformAction(uiMenuPromptReplaceAction, withSender: sender)
        case customUIMenuLookUpAction:
            return super.canPerformAction(uiMenuLookUpAction, withSender: sender)
        case customUIMenuShareAction:
            return super.canPerformAction(uiMenuShareAction, withSender: sender)
        case customUIMenuTranslateAction:
            return true

        // The second stage of replace (picking the thing to replace with) is allowed.
        case uiMenuReplaceAction:
            return super.canPerformAction(action, withSender: sender)

        // All other actions are disallowed.
        default:
            return false
        }
    }

    // When the user selects text, we show a "format" option in the menu. Tapping
    // that sets this to true, reloading the menu with styles (bold, italic, etc) and
    // omitting all other options.
    // We have to be careful to set this to false again once the menu is dismissed by
    // any means, so that when it shows again we see cut/copy/paste and "format" again.
    // There is no one callback for this dismissal, so we have to set it to false all over:
    // resign first responder, selection changed, text changed, style option tapped, etc.
    private var isShowingFormatMenu = false {
        didSet {
            if oldValue, !isShowingFormatMenu, UIMenuController.shared.isMenuVisible {
                UIMenuController.shared.hideMenu(from: self)
            }
        }
    }

    open override func resignFirstResponder() -> Bool {
        isShowingFormatMenu = false
        return super.resignFirstResponder()
    }

    fileprivate func updateUIMenuState() {
        if selectedRange.length > 0 {
            if isShowingFormatMenu {
                let orderedStyles: [MessageBodyRanges.SingleStyle] = [
                    .bold, .italic, .monospace, .strikethrough, .spoiler
                ]
                UIMenuController.shared.menuItems = orderedStyles.map { style in
                    return UIMenuItem(title: style.displayText, action: self.uiMenuItemSelector(for: style))
                } + [UIMenuItem(
                    title: OWSLocalizedString(
                        "TEXT_MENU_CLEAR_FORMATTING",
                        comment: "Option in selected text edit menu to clear all text formatting in the selected text range"
                    ),
                    action: #selector(didSelectClearStyles)
                )]
            } else {
                UIMenuController.shared.menuItems = [
                    // to get format to show up before system menu items, put our format
                    // first and then our own replacements for the system ones after.
                    UIMenuItem(
                        title: OWSLocalizedString(
                            "TEXT_MENU_FORMAT",
                            comment: "Option in selected text edit menu to view text formatting options"
                        ),
                        action: #selector(didSelectTextFormattingSubmenu)
                    ),
                    UIMenuItem(
                        title: OWSLocalizedString(
                            "TEXT_MENU_REPLACE",
                            comment: "Option in selected text edit menu to replace text with suggestions"
                        ),
                        action: #selector(customUIMenuPromptReplace)
                    ),
                    UIMenuItem(
                        title: OWSLocalizedString(
                            "TEXT_MENU_LOOK_UP",
                            comment: "Option in selected text edit menu to look up word definitions"
                        ),
                        action: #selector(customUIMenuLookUp)
                    ),
                    UIMenuItem(
                        title: OWSLocalizedString(
                            "TEXT_MENU_TRANSLATE",
                            comment: "Option in selected text edit menu to translate the word"
                        ),
                        action: #selector(customUIMenuTranslate)
                    ),
                    UIMenuItem(
                        title: OWSLocalizedString(
                            "TEXT_MENU_SHARE",
                            comment: "Option in selected text edit menu to share selected text"
                        ),
                        action: #selector(customUIMenuShare)
                    )
                ]
            }
        } else {
            UIMenuController.shared.menuItems = nil
        }
        UIMenuController.shared.update()
    }

    @objc
    private func didSelectTextFormattingSubmenu(_ sender: UIMenu) {
        isShowingFormatMenu = true
        updateUIMenuState()
        // No way to set a sub-menu in iOS 13. Have to wait for it to dismiss
        // and then show it again in the next runloop.
        DispatchQueue.main.async { [self] in
            guard let selectedTextRange, isShowingFormatMenu else {
                return
            }
            let selectionRects = selectionRects(for: selectedTextRange)
            var completeRect = CGRect.null
            for rect in selectionRects {
                if completeRect.isNull {
                    completeRect = rect.rect
                } else {
                    completeRect = rect.rect.union(completeRect)
                }
            }
            UIMenuController.shared.showMenu(from: self, rect: completeRect)
        }
    }

    private func uiMenuItemSelector(for style: MessageBodyRanges.SingleStyle) -> Selector {
        switch style {
        case .bold: return #selector(didSelectBold)
        case .italic: return #selector(didSelectItalic)
        case .spoiler: return #selector(didSelectSpoiler)
        case .strikethrough: return #selector(didSelectStrikethrough)
        case .monospace: return #selector(didSelectMonospace)
        }
    }

    @objc
    func didSelectBold() { didSelectStyle(.bold) }
    @objc
    func didSelectItalic() { didSelectStyle(.italic) }
    @objc
    func didSelectSpoiler() { didSelectStyle(.spoiler) }
    @objc
    func didSelectStrikethrough() { didSelectStyle(.strikethrough) }
    @objc
    func didSelectMonospace() { didSelectStyle(.monospace) }

    private func didSelectStyle(_ style: MessageBodyRanges.SingleStyle) {
        Logger.info("Applying style: \(style)")
        isShowingFormatMenu = false
        guard selectedRange.length > 0 else {
            return
        }
        editableBody.beginEditing()
        editableBody.toggleStyle(style, in: selectedRange)
        editableBody.endEditing()
        textViewDidChange(self)
    }

    @objc
    private func didSelectClearStyles() {
        Logger.info("Clearing styles")
        isShowingFormatMenu = false
        guard selectedRange.length > 0 else {
            return
        }
        editableBody.beginEditing()
        editableBody.clearFormatting(in: selectedRange)
        editableBody.endEditing()
        textViewDidChange(self)
    }

    // MARK: - Text Container Insets

    open var defaultTextContainerInset: UIEdgeInsets {
        UIEdgeInsets(hMargin: 7, vMargin: 7 - .hairlineWidth)
    }

    public func updateTextContainerInset() {
        var newTextContainerInset = defaultTextContainerInset

        let currentFont = font ?? UIFont.dynamicTypeBody
        let systemDefaultFont = UIFont.preferredFont(
            forTextStyle: .body,
            compatibleWith: .init(preferredContentSizeCategory: .large)
        )
        guard systemDefaultFont.pointSize > currentFont.pointSize else {
            textContainerInset = newTextContainerInset
            return
        }

        // Increase top and bottom insets so that textView has the same one-line height
        // for any content size category smaller than the default (Large).
        // Simply fixing textView at a minimum height doesn't work well because
        // smaller text will be top-aligned (and we want center).
        let insetFontAdjustment = (systemDefaultFont.ascender - systemDefaultFont.descender) - (currentFont.ascender - currentFont.descender)
        newTextContainerInset.top += insetFontAdjustment * 0.5
        newTextContainerInset.bottom = newTextContainerInset.top - 1
        textContainerInset = newTextContainerInset
    }

    // MARK: - EditableMessageBodyDelegate

    public func editableMessageBodyDidRequestNewSelectedRange(_ newSelectedRange: NSRange) {
        self.selectedRange = newSelectedRange
    }

    public func editableMessageBodyHydrator(tx: DBReadTransaction) -> MentionHydrator {
        var possibleMentionAcis = Set<Aci>()
        bodyRangesDelegate?.textViewMentionPickerPossibleAddresses(self, tx: tx).forEach {
            if let aci = $0.aci {
                possibleMentionAcis.insert(aci)
            }
        }
        let hydrator = ContactsMentionHydrator.mentionHydrator(transaction: tx)
        return { aci in
            guard possibleMentionAcis.contains(aci) else {
                return .preserveMention
            }
            return hydrator(aci)
        }
    }

    public func editableMessageBodyDisplayConfig() -> HydratedMessageBody.DisplayConfiguration {
        return bodyRangesDelegate?.textViewDisplayConfiguration(self) ?? .composing(textViewColor: self.textColor)
    }

    public func isEditableMessageBodyDarkThemeEnabled() -> Bool {
        return Theme.isDarkThemeEnabled
    }

    public func editableMessageSelectedRange() -> NSRange {
        return selectedRange
    }

    public func mentionCacheInvalidationKey() -> String {
        return bodyRangesDelegate?.textViewMentionCacheInvalidationKey(self) ?? UUID().uuidString
    }

    public func didInsertMemoji(_ memojiGlyph: OWSAdaptiveImageGlyph) {
        bodyRangesDelegate?.textViewDidInsertMemoji(memojiGlyph)
    }
}

// MARK: - Picker Keyboard Interaction

extension BodyRangesTextView {
    open override var keyCommands: [UIKeyCommand]? {
        guard pickerView != nil else { return nil }

        return [
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(upArrowPressed(_:))),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(downArrowPressed(_:))),
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(returnPressed(_:))),
            UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(tabPressed(_:)))
        ]
    }

    @objc
    func upArrowPressed(_ sender: UIKeyCommand) {
        guard let pickerView = pickerView else { return }
        pickerView.didTapUpArrow()
    }

    @objc
    func downArrowPressed(_ sender: UIKeyCommand) {
        guard let pickerView = pickerView else { return }
        pickerView.didTapDownArrow()
    }

    @objc
    func returnPressed(_ sender: UIKeyCommand) {
        guard let pickerView = pickerView else { return }
        pickerView.didTapReturn()
    }

    @objc
    func tabPressed(_ sender: UIKeyCommand) {
        guard let pickerView = pickerView else { return }
        pickerView.didTapTab()
    }
}

// MARK: - Cut/Copy/Paste

extension BodyRangesTextView {
    open override func cut(_ sender: Any?) {
        let selectedRange = self.selectedRange
        copy(sender)
        editableBody.beginEditing()
        editableBody.replaceCharacters(in: selectedRange, with: "", selectedRange: selectedRange)
        editableBody.endEditing()
        self.selectedRange = NSRange(location: selectedRange.location, length: 0)
        textViewDidChange(self)
    }

    public class func copyToPasteboard(_ text: CVTextValue) {
        let plaintext: String
        switch text {
        case .text(let text):
            plaintext = text
            UIPasteboard.general.setItems([], options: [:])
        case .attributedText(let text):
            plaintext = text.string
            UIPasteboard.general.setItems([], options: [:])
        case .messageBody(let messageBody):
            copyToPasteboard(messageBody.asMessageBodyForForwarding())
            return
        }

        let plaintextData = Data(plaintext.utf8)

        UIPasteboard.general.addItems([["public.utf8-plain-text": plaintextData]])
    }

    private class func copyToPasteboard(_ messageBody: MessageBody) {
        if messageBody.hasRanges, let encodedMessageBody = try? NSKeyedArchiver.archivedData(withRootObject: messageBody, requiringSecureCoding: true) {
            UIPasteboard.general.setItems([[Self.pasteboardType: encodedMessageBody]], options: [.localOnly: true])
        } else {
            UIPasteboard.general.setItems([], options: [:])
        }

        let plaintextData = Data(messageBody.text.utf8)

        UIPasteboard.general.addItems([["public.utf8-plain-text": plaintextData]])
    }

    public static var pasteboardType: String { SignalAttachment.bodyRangesPasteboardType }

    open override func copy(_ sender: Any?) {
        let messageBody: MessageBody
        if selectedRange.length > 0 {
            messageBody = editableBody.messageBody(forHydratedTextSubrange: selectedRange)
        } else {
            messageBody = editableBody.messageBody
        }
        Self.copyToPasteboard(messageBody)
    }

    open override func paste(_ sender: Any?) {
        if let encodedMessageBody = UIPasteboard.general.data(forPasteboardType: Self.pasteboardType),
            var messageBody = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MessageBody.self, from: encodedMessageBody) {
            editableBody.beginEditing()
            DependenciesBridge.shared.db.read { tx in
                if let possibleAddresses = bodyRangesDelegate?.textViewMentionPickerPossibleAddresses(self, tx: tx) {
                    messageBody = messageBody.forPasting(intoContextWithPossibleAddresses: possibleAddresses, transaction: tx)
                }
                editableBody.replaceCharacters(in: selectedRange, withPastedMessageBody: messageBody, txProvider: { $0(tx) })
            }
            editableBody.endEditing()
        } else if let string = UIPasteboard.general.strings?.first {
            editableBody.beginEditing()
            editableBody.replaceCharacters(in: selectedRange, with: StringSanitizer.sanitize(string), selectedRange: selectedRange)
            editableBody.endEditing()
            // Put the selection at the end of the new range.
            self.selectedRange = NSRange(location: selectedRange.location + (string as NSString).length, length: 0)
        }

        if !textStorage.isEmpty {
            // Pasting very long text generates an obscure UI error producing an UITextView where the lower
            // part contains invisible characters. The exact root of the issue is still unclear but the following
            // lines of code work as a workaround.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                if let self = self {
                    let oldRange = self.selectedRange
                    self.selectedRange = NSRange.init(location: 0, length: 0)
                    // inserting blank text into the text storage will remove the invisible characters
                    self.textStorage.insert(NSAttributedString(string: ""), at: 0)
                    // setting the range (again) will ensure scrolling to the correct position
                    self.selectedRange = oldRange
                }
            }
        }
        self.textViewDidChange(self)
    }
}

// MARK: - UITextViewDelegate

extension BodyRangesTextView: UITextViewDelegate {
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard shouldUpdateMentionText(in: range, changedText: text) else { return false }
        return bodyRangesDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }

    open func textViewDidChangeSelection(_ textView: UITextView) {
        bodyRangesDelegate?.textViewDidChangeSelection?(textView)
        updateMentionState()
        isShowingFormatMenu = false
        updateUIMenuState()
    }

    open func textViewDidChange(_ textView: UITextView) {
        isShowingFormatMenu = false
        bodyRangesDelegate?.textViewDidChange?(textView)
        if editableBody.hydratedPlaintext.isEmpty { updateMentionState() }
        self.textAlignment = editableBody.naturalTextAlignment
    }

    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return bodyRangesDelegate?.textViewShouldBeginEditing?(textView) ?? true
    }

    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        isShowingFormatMenu = false
        return bodyRangesDelegate?.textViewShouldEndEditing?(textView) ?? true
    }

    open func textViewDidBeginEditing(_ textView: UITextView) {
        bodyRangesDelegate?.textViewDidBeginEditing?(textView)
    }

    open func textViewDidEndEditing(_ textView: UITextView) {
        bodyRangesDelegate?.textViewDidEndEditing?(textView)
    }

    open func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return bodyRangesDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }

    open func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return bodyRangesDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }
}

extension MessageBodyRanges.SingleStyle {

    var displayText: String {
        switch self {
        case .bold:
            return OWSLocalizedString(
                "TEXT_MENU_BOLD",
                comment: "Option in selected text edit menu to make text bold"
            )
        case .italic:
            return OWSLocalizedString(
                "TEXT_MENU_ITALIC",
                comment: "Option in selected text edit menu to make text italic"
            )
        case .spoiler:
            return OWSLocalizedString(
                "TEXT_MENU_SPOILER",
                comment: "Option in selected text edit menu to make text spoiler"
            )
        case .strikethrough:
            return OWSLocalizedString(
                "TEXT_MENU_STRIKETHROUGH",
                comment: "Option in selected text edit menu to make text strikethrough"
            )
        case .monospace:
            return OWSLocalizedString(
                "TEXT_MENU_MONOSPACE",
                comment: "Option in selected text edit menu to make text monospace"
            )
        }
    }
}
