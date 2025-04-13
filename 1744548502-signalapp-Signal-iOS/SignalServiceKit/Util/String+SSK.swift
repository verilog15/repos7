//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import NaturalLanguage

extension NSString {
    @objc
    @available(swift, obsoleted: 1)
    internal var filterStringForDisplay: NSString {
        (self as String).filterStringForDisplay() as NSString
    }
}

// MARK: -

public extension String {
    var stripped: String {
        ows_stripped()
    }

    var strippedOrNil: String? {
        stripped.nilIfEmpty
    }

    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    var filterForDisplay: String {
        filterStringForDisplay()
    }

    func replaceCharacters(
        characterSet: CharacterSet,
        replacement: String
    ) -> String {
        let endIndex = self.endIndex
        var startIndex = self.startIndex

        // Build up a list of ranges that need to be replaced
        var ranges = [Range<String.Index>]()
        while startIndex < endIndex, let range = self.rangeOfCharacter(from: characterSet, options: [], range: startIndex..<endIndex) {
            ranges.append(range)
            startIndex = range.upperBound
        }

        // Don't do any allocation for unchanged strings
        guard ranges.count > 0 else { return self }

        // Create the result string and set up a capacity close to the final string
        var result = ""
        result.reserveCapacity(self.count)

        // Iterate through the ranges, appending the string between the last
        // match and the next, and then appending the replacement string
        var currentIndex = self.startIndex
        for range in ranges {
            result += self[currentIndex..<range.lowerBound]
            result += replacement
            currentIndex = range.upperBound
        }
        // Add the remainder of the string
        result += self[currentIndex..<endIndex]
        return result
    }

    func removeCharacters(characterSet: CharacterSet) -> String {
        return self.replaceCharacters(characterSet: characterSet, replacement: "")
    }
}

// MARK: -

extension Optional where Wrapped == String {
    public var isEmptyOrNil: Bool {
        guard let value = self else {
            return true
        }
        return value.isEmpty
    }
}

public extension String {
    /// A version of the string that only contains ASCII digits.
    ///
    /// If you want to include non-ASCII digits, see `digitsOnly`.
    ///
    /// ```
    /// "1x2x3".digitsOnly
    /// // => "123"
    /// "1️⃣23".digitsOnly
    /// // => "23"
    /// ```
    var asciiDigitsOnly: String {
        filter { $0.isASCII && $0.isNumber }
    }

    /// Is every character an ASCII digit between 0 and 9?
    ///
    /// Note that this returns `true` for the empty string.
    ///
    /// ```
    /// "123".isAsciiDigitsOnly  // => true
    /// "1x23".isAsciiDigitsOnly // => false
    /// "".isAsciiDigitsOnly     // => true
    /// "1.23".isAsciiDigitsOnly // => false
    /// ```
    var isAsciiDigitsOnly: Bool {
        allSatisfy { $0.isASCII && $0.isNumber }
    }

    /// A version of the string that only contains ASCII alphanumerics.
    ///
    /// ```swift
    /// "abc1️⃣23".asciiAlphanumericOnly
    /// // => "abc23"
    /// "ábc123".asciiAlphanumericOnly
    /// // => "bc123"
    /// ```
    var asciiAlphanumericsOnly: String {
        filter { $0.isASCII && ($0.isLetter || $0.isNumber) }
    }

    /// Is every character an ASCII alphanumeric?
    ///
    /// Not that this returns `true` for the empty string.
    ///
    /// ```swift
    /// "aBc123".isAsciiAlphanumericsOnly // => true
    /// "abc12#".isAsciiAlphanumericsOnly // => false
    /// ```
    var isAsciiAlphanumericsOnly: Bool {
        allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber) }
    }

    func substring(withRange range: NSRange) -> String {
        (self as NSString).substring(with: range)
    }

    func substring(beforeRange range: NSRange) -> String {
        (self as NSString).substring(to: range.location)
    }

    func substring(afterRange range: NSRange) -> String {
        (self as NSString).substring(from: range.location + range.length)
    }

    enum StringError: Error {
        case invalidCharacterShift
    }

    /// Converts all non arabic numerals within a string to arabic numerals
    ///
    /// For example: "Hello ١٢٣" would become "Hello 123"
    var ensureArabicNumerals: String {
        return String(map { character in
            // Check if this character is a number between 0-9, if it's not just return it and carry on
            //
            // Some languages (like Chinese) have characters that represent larger numbers (万 = 10^4)
            // These are not easily translatable into arabic numerals at a character by character level,
            // so we ignore them.
            guard let number = character.wholeNumberValue, number <= 9, number >= 0 else { return character }
            return Character("\(number)")
        })
    }

    var entireRange: NSRange {
        NSRange(location: 0, length: utf16.count)
    }

    init?(sysctlKey key: String) {
        var size: Int = 0
        sysctlbyname(key, nil, &size, nil, 0)

        guard size > 0 else { return nil }

        var value = [CChar](repeating: 0, count: size)
        sysctlbyname(key, &value, &size, nil, 0)

        self.init(cString: value)
    }

    func appendingPathComponent(_ other: String) -> String {
        return (self as NSString).appendingPathComponent(other)
    }

    var asAttributedString: NSAttributedString {
        return NSAttributedString(string: self)
    }

    func asAttributedString(attributes: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString {
        NSAttributedString(string: self, attributes: attributes)
    }
}

// MARK: - Attributed String Concatenation

public extension NSAttributedString {

    var nilIfEmpty: NSAttributedString? {
        isEmpty ? nil : self
    }

    var entireRange: NSRange {
        NSRange(location: 0, length: string.utf16.count)
    }

    func stringByAppendingString(_ string: String, attributes: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString {
        return stringByAppendingString(NSAttributedString(string: string, attributes: attributes))
    }

    func stringByAppendingString(_ string: NSAttributedString) -> NSAttributedString {
        let copy = mutableCopy() as! NSMutableAttributedString
        copy.append(string)
        return copy.copy() as! NSAttributedString
    }

    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        return lhs.stringByAppendingString(rhs)
    }

    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        return lhs.stringByAppendingString(rhs)
    }

    func ows_stripped() -> NSAttributedString {
        guard length > 0 else { return self }
        guard !string.ows_stripped().isEmpty else { return NSAttributedString() }

        let mutableString = NSMutableAttributedString(attributedString: self)
        mutableString.ows_strip()
        return NSAttributedString(attributedString: mutableString)
    }

    var isEmpty: Bool {
        length < 1
    }
}

// MARK: -

public enum ImageAttachmentHeightReference {
    case pointSize
    case lineHeight

    func height(for font: UIFont) -> CGFloat {
        switch self {
        case .pointSize: return ceil(font.pointSize)
        case .lineHeight: return ceil(font.lineHeight)
        }
    }
}

// MARK: -

public extension NSMutableAttributedString {

    /// Set a default value for the given attribute.  Preserves any existing ranges where the attribute
    /// is already defined.
    func addDefaultAttributeToEntireString(_ name: NSAttributedString.Key, value: Any) {
        enumerateAttribute(name, in: entireRange) { existing, subrange, stop in
            if existing == nil {
                addAttribute(name, value: value, range: subrange)
            }
        }
    }

    func addAttributeToEntireString(_ name: NSAttributedString.Key, value: Any) {
        addAttribute(name, value: value, range: entireRange)
    }

    func addAttributesToEntireString(_ attributes: [NSAttributedString.Key: Any] = [:]) {
        addAttributes(attributes, range: entireRange)
    }

    func setAttributes(_ attributes: [NSAttributedString.Key: Any], forSubstring substring: String) {
        guard !substring.isEmpty else {
            owsFailDebug("Invalid substring.")
            return
        }
        let str = string
        guard let range = str.range(of: substring) else {
            owsFailDebug("Substring not found.")
            return
        }
        setAttributes(attributes, range: NSRange(range, in: str))

    }

    func append(_ string: String, attributes: [NSAttributedString.Key: Any] = [:]) {
        append(NSAttributedString(string: string, attributes: attributes))
    }

    func appendTemplatedImage(named imageName: String, font: UIFont) {
        appendTemplatedImage(named: imageName, font: font, attributes: nil)
    }

    func appendTemplatedImage(named imageName: String, font: UIFont, heightReference: ImageAttachmentHeightReference) {
        appendTemplatedImage(named: imageName, font: font, attributes: nil, heightReference: heightReference)
    }

    func appendTemplatedImage(named imageName: String, font: UIFont, attributes: [NSAttributedString.Key: Any]?) {
        appendTemplatedImage(named: imageName, font: font, attributes: attributes, heightReference: .pointSize)
    }

    func appendTemplatedImage(named imageName: String, font: UIFont, attributes: [NSAttributedString.Key: Any]?, heightReference: ImageAttachmentHeightReference) {
        guard let image = UIImage(named: imageName) else {
            return owsFailDebug("missing image named \(imageName)")
        }
        appendImage(image.withRenderingMode(.alwaysTemplate), font: font, attributes: attributes, heightReference: heightReference)
    }

    func appendImage(named imageName: String, font: UIFont) {
        appendImage(named: imageName, font: font, attributes: nil)
    }

    func appendImage(named imageName: String, font: UIFont, heightReference: ImageAttachmentHeightReference) {
        appendImage(named: imageName, font: font, attributes: nil, heightReference: heightReference)
    }

    func appendImage(named imageName: String, font: UIFont, attributes: [NSAttributedString.Key: Any]?) {
        appendImage(named: imageName, font: font, attributes: attributes, heightReference: .pointSize)
    }

    func appendImage(named imageName: String, font: UIFont, attributes: [NSAttributedString.Key: Any]?, heightReference: ImageAttachmentHeightReference) {
        guard let image = UIImage(named: imageName) else {
            return owsFailDebug("missing image named \(imageName)")
        }
        appendImage(image, font: font, attributes: attributes, heightReference: heightReference)
    }

    func appendImage(_ image: UIImage, font: UIFont) {
        appendImage(image, font: font, attributes: nil)
    }

    func appendImage(_ image: UIImage, font: UIFont, heightReference: ImageAttachmentHeightReference) {
        appendImage(image, font: font, attributes: nil, heightReference: heightReference)
    }

    func appendImage(_ image: UIImage, font: UIFont, attributes: [NSAttributedString.Key: Any]?) {
        appendImage(image, font: font, attributes: attributes, heightReference: .pointSize)
    }

    func appendImage(_ image: UIImage, font: UIFont, attributes: [NSAttributedString.Key: Any]?, heightReference: ImageAttachmentHeightReference) {
        append(.with(image: image, font: font, attributes: attributes, heightReference: heightReference))
    }

    func ows_strip() {
        guard length > 0 else { return }

        let nsString = string as NSString
        let strippedString = string.ows_stripped()

        func replaceWithEmptyString() {
            replaceCharacters(in: NSRange(location: 0, length: length), with: "")
        }

        guard !strippedString.isEmpty else { return replaceWithEmptyString() }

        let remainingRange = nsString.range(of: strippedString)
        guard remainingRange.location != NSNotFound else {
            owsFailDebug("Unexpectedly missing substring after strip")
            return replaceWithEmptyString()
        }

        let newEndOfString = remainingRange.location + remainingRange.length
        if newEndOfString < mutableString.length {
            mutableString.replaceCharacters(
                in: NSRange(location: newEndOfString, length: mutableString.length - newEndOfString),
                with: ""
            )
        }

        let newStartOfString = remainingRange.location
        if newStartOfString > 0 {
            mutableString.replaceCharacters(
                in: NSRange(location: 0, length: newStartOfString),
                with: ""
            )
        }
    }
}

public extension NSAttributedString {
    /// Creates an `NSAttributedString` of the image as an `NSTextAttachment`,
    /// vertically-centered in the relative font.
    /// - Parameters:
    ///   - image: The image to use as the attachment.
    ///   - font: The font to use for sizing the image.
    ///   - attributes: A dictionary containing the attributes to add.
    ///   - centeringFont: The relative font to vertically center the image in.
    ///   If attaching this image to another attributed string of a different
    ///   font, specify that font here.
    ///   - heightReference: Which property of the font the image should be
    ///   sized relative to.
    /// - Returns: An `NSAttributedString` with the specified image as an attachment, applying `attributes`, centered vertically in `centeringFont`, sized based on the `heightReference` property of `font`.
    static func with(
        image: UIImage,
        font: UIFont,
        attributes: [NSAttributedString.Key: Any]? = nil,
        centerVerticallyRelativeTo centeringFont: UIFont? = nil,
        heightReference: ImageAttachmentHeightReference = .lineHeight
    ) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image

        let centeringFont = centeringFont ?? font

        // Match the image's height to the font's height while preserving
        // the image's aspect ratio, and vertically center.
        let imageHeight = heightReference.height(for: font)
        let imageWidth = (imageHeight / image.size.height) * image.size.width
        attachment.bounds = CGRect(
            x: 0,
            y: (centeringFont.capHeight - imageHeight) / 2,
            width: imageWidth,
            height: imageHeight
        )

        let attachmentString = NSAttributedString(attachment: attachment)

        if let attributes = attributes {
            let mutableString = NSMutableAttributedString(attributedString: attachmentString)
            mutableString.addAttributes(attributes, range: mutableString.entireRange)
            return mutableString
        } else {
            return attachmentString
        }
    }
}

// MARK: - Natural Text Alignment

public extension String {
    private var dominantLanguage: String? {
        return NLLanguageRecognizer.dominantLanguage(for: self)?.rawValue
    }

    /// The natural text alignment of a given string. This may be different
    /// than the natural alignment of the current system locale depending on
    /// the language of the string, especially for user entered text.
    var naturalTextAlignment: NSTextAlignment {
        guard let dominantLanguage = dominantLanguage else {
            // If we can't identify the strings language, use the system language's natural alignment
            return .natural
        }

        switch NSParagraphStyle.defaultWritingDirection(forLanguage: dominantLanguage) {
        case .leftToRight:
            return .left
        case .rightToLeft:
            return .right
        case .natural:
            return .natural
        @unknown default:
            return .natural
        }
    }
}

// MARK: - Selector Encoding

private let selectorOffset: UInt32 = 17

public extension String {

    func caesar(shift: UInt32) throws -> String {
        let shiftedScalars: [UnicodeScalar] = try unicodeScalars.map { c in
            guard let shiftedScalar = UnicodeScalar((c.value + shift) % 127) else {
                owsFailDebug("invalidCharacterShift")
                throw StringError.invalidCharacterShift
            }
            return shiftedScalar
        }
        return String(String.UnicodeScalarView(shiftedScalars))
    }

    var encodedForSelector: String? {
        guard let shifted = try? self.caesar(shift: selectorOffset) else {
            owsFailDebug("shifted was unexpectedly nil")
            return nil
        }

        let data = Data(shifted.utf8)

        return data.base64EncodedString()
    }

    var decodedForSelector: String? {
        guard let data = Data(base64Encoded: self) else {
            owsFailDebug("data was unexpectedly nil")
            return nil
        }

        guard let shifted = String(data: data, encoding: .utf8) else {
            owsFailDebug("shifted was unexpectedly nil")
            return nil
        }

        return try? shifted.caesar(shift: 127 - selectorOffset)
    }
}

// MARK: - Emoji

extension UnicodeScalar {
    class EmojiRange {
        // rangeStart and rangeEnd are inclusive.
        let rangeStart: UInt32
        let rangeEnd: UInt32

        // MARK: Initializers

        init(rangeStart: UInt32, rangeEnd: UInt32) {
            self.rangeStart = rangeStart
            self.rangeEnd = rangeEnd
        }
    }

    // From:
    // https://www.unicode.org/Public/emoji/
    // Current Version:
    // https://www.unicode.org/Public/emoji/6.0/emoji-data.txt
    //
    // These ranges can be code-generated using:
    //
    // * Scripts/emoji-data.txt
    // * Scripts/emoji_ranges.py
    static let kEmojiRanges = [
        // NOTE: Don't treat Pound Sign # as Jumbomoji.
        //        EmojiRange(rangeStart:0x23, rangeEnd:0x23),
        // NOTE: Don't treat Asterisk * as Jumbomoji.
        //        EmojiRange(rangeStart:0x2A, rangeEnd:0x2A),
        // NOTE: Don't treat Digits 0..9 as Jumbomoji.
        //        EmojiRange(rangeStart:0x30, rangeEnd:0x39),
        // NOTE: Don't treat Copyright Symbol © as Jumbomoji.
        //        EmojiRange(rangeStart:0xA9, rangeEnd:0xA9),
        // NOTE: Don't treat Trademark Sign ® as Jumbomoji.
        //        EmojiRange(rangeStart:0xAE, rangeEnd:0xAE),
        EmojiRange(rangeStart: 0x200D, rangeEnd: 0x200D),
        EmojiRange(rangeStart: 0x203C, rangeEnd: 0x203C),
        EmojiRange(rangeStart: 0x2049, rangeEnd: 0x2049),
        EmojiRange(rangeStart: 0x20D0, rangeEnd: 0x20FF),
        EmojiRange(rangeStart: 0x2122, rangeEnd: 0x2122),
        EmojiRange(rangeStart: 0x2139, rangeEnd: 0x2139),
        EmojiRange(rangeStart: 0x2194, rangeEnd: 0x2199),
        EmojiRange(rangeStart: 0x21A9, rangeEnd: 0x21AA),
        EmojiRange(rangeStart: 0x231A, rangeEnd: 0x231B),
        EmojiRange(rangeStart: 0x2328, rangeEnd: 0x2328),
        EmojiRange(rangeStart: 0x2388, rangeEnd: 0x2388),
        EmojiRange(rangeStart: 0x23CF, rangeEnd: 0x23CF),
        EmojiRange(rangeStart: 0x23E9, rangeEnd: 0x23F3),
        EmojiRange(rangeStart: 0x23F8, rangeEnd: 0x23FA),
        EmojiRange(rangeStart: 0x24C2, rangeEnd: 0x24C2),
        EmojiRange(rangeStart: 0x25AA, rangeEnd: 0x25AB),
        EmojiRange(rangeStart: 0x25B6, rangeEnd: 0x25B6),
        EmojiRange(rangeStart: 0x25C0, rangeEnd: 0x25C0),
        EmojiRange(rangeStart: 0x25FB, rangeEnd: 0x25FE),
        EmojiRange(rangeStart: 0x2600, rangeEnd: 0x27BF),
        EmojiRange(rangeStart: 0x2934, rangeEnd: 0x2935),
        EmojiRange(rangeStart: 0x2B05, rangeEnd: 0x2B07),
        EmojiRange(rangeStart: 0x2B1B, rangeEnd: 0x2B1C),
        EmojiRange(rangeStart: 0x2B50, rangeEnd: 0x2B50),
        EmojiRange(rangeStart: 0x2B55, rangeEnd: 0x2B55),
        EmojiRange(rangeStart: 0x3030, rangeEnd: 0x3030),
        EmojiRange(rangeStart: 0x303D, rangeEnd: 0x303D),
        EmojiRange(rangeStart: 0x3297, rangeEnd: 0x3297),
        EmojiRange(rangeStart: 0x3299, rangeEnd: 0x3299),
        EmojiRange(rangeStart: 0xFE00, rangeEnd: 0xFE0F),
        EmojiRange(rangeStart: 0x1F000, rangeEnd: 0x1F0FF),
        EmojiRange(rangeStart: 0x1F10D, rangeEnd: 0x1F10F),
        EmojiRange(rangeStart: 0x1F12F, rangeEnd: 0x1F12F),
        EmojiRange(rangeStart: 0x1F16C, rangeEnd: 0x1F171),
        EmojiRange(rangeStart: 0x1F17E, rangeEnd: 0x1F17F),
        EmojiRange(rangeStart: 0x1F18E, rangeEnd: 0x1F18E),
        EmojiRange(rangeStart: 0x1F191, rangeEnd: 0x1F19A),
        EmojiRange(rangeStart: 0x1F1AD, rangeEnd: 0x1F1FF),
        EmojiRange(rangeStart: 0x1F201, rangeEnd: 0x1F20F),
        EmojiRange(rangeStart: 0x1F21A, rangeEnd: 0x1F21A),
        EmojiRange(rangeStart: 0x1F22F, rangeEnd: 0x1F22F),
        EmojiRange(rangeStart: 0x1F232, rangeEnd: 0x1F23A),
        EmojiRange(rangeStart: 0x1F23C, rangeEnd: 0x1F23F),
        EmojiRange(rangeStart: 0x1F249, rangeEnd: 0x1F64F),
        EmojiRange(rangeStart: 0x1F680, rangeEnd: 0x1F6FF),
        EmojiRange(rangeStart: 0x1F774, rangeEnd: 0x1F77F),
        EmojiRange(rangeStart: 0x1F7D5, rangeEnd: 0x1F7FF),
        EmojiRange(rangeStart: 0x1F80C, rangeEnd: 0x1F80F),
        EmojiRange(rangeStart: 0x1F848, rangeEnd: 0x1F84F),
        EmojiRange(rangeStart: 0x1F85A, rangeEnd: 0x1F85F),
        EmojiRange(rangeStart: 0x1F888, rangeEnd: 0x1F88F),
        EmojiRange(rangeStart: 0x1F8AE, rangeEnd: 0x1FFFD),
        EmojiRange(rangeStart: 0xE0020, rangeEnd: 0xE007F)
    ]

    var isEmoji: Bool {

        // Binary search.
        var left: Int = 0
        var right = Int(UnicodeScalar.kEmojiRanges.count - 1)
        while true {
            let mid = (left + right) / 2
            let midRange = UnicodeScalar.kEmojiRanges[mid]
            if value < midRange.rangeStart {
                if mid == left {
                    return false
                }
                right = mid - 1
            } else if value > midRange.rangeEnd {
                if mid == right {
                    return false
                }
                left = mid + 1
            } else {
                return true
            }
        }
    }

    var isZeroWidthJoiner: Bool {

        return value == 8205
    }
}

extension String.UnicodeScalarView {
    public func containsOnlyEmoji() -> Bool {
        if self.isEmpty {
            return false
        }
        if self.contains(where: { !$0.isEmoji && !$0.isZeroWidthJoiner }) {
            return false
        }
        return true
    }

    public func containsOnlyEmojiIgnoringWhitespace() -> Bool {
        if self.isEmpty {
            return false
        }
        return self.allSatisfy { $0.isEmoji || $0.isZeroWidthJoiner || $0.properties.isWhitespace }
    }
}

public extension String {
    var glyphCount: Int {
        // String.count reflects the number of user-visible characters
        // the will be rendered by UILabel, UITextView, etc.
        count
    }

    var isSingleEmoji: Bool {
        glyphCount == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        unicodeScalars.contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        return self.unicodeScalars.containsOnlyEmoji()
    }

    var containsOnlyEmojiIgnoringWhitespace: Bool {
        self.unicodeScalars.containsOnlyEmojiIgnoringWhitespace()
    }

    func trimmedIfNeeded(maxGlyphCount: Int) -> String? {
        // This is O(maxGlyphCount) instead of O(self.count).
        if self.dropFirst(maxGlyphCount).isEmpty {
            return nil
        }
        return String(self.prefix(maxGlyphCount))
    }

    func trimToGlyphCount(_ maxGlyphCount: Int) -> String {
        return self.trimmedIfNeeded(maxGlyphCount: maxGlyphCount) ?? self
    }

    func trimmedIfNeeded(maxByteCount: Int) -> String? {
        var utf8Count = 0
        for index in self.indices {
            utf8Count += self[index].utf8.count
            if utf8Count > maxByteCount {
                return String(self[..<index])
            }
        }
        return nil
    }

    func trimToUtf8ByteCount(_ maxByteCount: Int) -> String {
        return self.trimmedIfNeeded(maxByteCount: maxByteCount) ?? self
    }
}

@objc
public extension NSString {
    var isSingleEmoji: Bool {
        return (self as String).isSingleEmoji
    }

    func trimToUtf8ByteCount(_ maxByteCount: Int) -> String {
        return (self as String).trimToUtf8ByteCount(maxByteCount)
    }
}

// MARK: - encodeURIComponent

public extension String {
    var encodeURIComponent: String? {
        // Match behavior of encodeURIComponent used by desktop.
        //
        // Removes any "/" in the base64. All other base64 chars are URL safe.
        // Apple's built-in `stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URL*]]`
        // doesn't offer a flavor for encoding "/".
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-_.!~*'()")
        return addingPercentEncoding(withAllowedCharacters: characterSet)
    }
}

// MARK: - Percent encoding

public extension String {
    var percentEncodedAsUrlPath: String {
        var components = URLComponents()
        components.path = self

        return components.percentEncodedPath
    }
}

// MARK: -

public extension String {
    static func formatDurationLossless(durationSeconds: UInt32) -> String {
        formatDurationLossless(durationMs: UInt64(durationSeconds) * 1000)
    }

    static func formatDurationLossless(durationMs: UInt64) -> String {
        let mSecondsPerSecond: UInt64 = 1000
        let mSecondsPerMinute: UInt64 = mSecondsPerSecond * 60
        let mSecondsPerHour: UInt64 = mSecondsPerMinute * 60
        let mSecondsPerDay: UInt64 = mSecondsPerHour * 24
        let mSecondsPerWeek: UInt64 = mSecondsPerDay * 7
        let mSecondsPerYear: UInt64 = mSecondsPerDay * 365

        let dateComponents: DateComponents = {
            var dateComponents = DateComponents()

            var remainingDuration = durationMs

            let years = remainingDuration / mSecondsPerYear
            remainingDuration -= years * mSecondsPerYear
            dateComponents.year = Int(years)

            let weeks = remainingDuration / mSecondsPerWeek
            remainingDuration -= weeks * mSecondsPerWeek
            dateComponents.weekOfYear = Int(weeks)

            let days = remainingDuration / mSecondsPerDay
            remainingDuration -= days * mSecondsPerDay
            dateComponents.day = Int(days)

            let minutes = remainingDuration / mSecondsPerMinute
            remainingDuration -= minutes * mSecondsPerMinute
            dateComponents.minute = Int(minutes)

            let seconds = remainingDuration / mSecondsPerSecond
            remainingDuration -= seconds * mSecondsPerSecond
            dateComponents.second = Int(seconds)

            return dateComponents
        }()

        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .full
        durationFormatter.allowedUnits = [.year, .weekOfMonth, .day, .hour, .minute, .second]
        guard let formattedDuration = durationFormatter.string(from: dateComponents) else {
            owsFailDebug("Could not format duration")
            return ""
        }
        return formattedDuration
    }
}

// MARK: -

@objc
public extension NSString {
    static func formatDurationLossless(durationSeconds: UInt32) -> String {
        String.formatDurationLossless(durationSeconds: durationSeconds)
    }
}

// MARK: - Filename

public extension String {
    private static let permissibleFilenameCharRegex: NSRegularExpression = {
        let pattern = "^[a-zA-Z0-9\\-_]+$"

        do {
            return try NSRegularExpression(pattern: pattern)
        } catch let error {
            owsFail("Failed to create filename char regex: \(error)")
        }
    }()

    var isPermissibleAsFilename: Bool {
        Self.permissibleFilenameCharRegex.hasMatch(input: self)
    }
}

// MARK: - Phone Numbers

public extension String {
    /// A pattern for quickly deciding if a string looks like an e164. It makes
    /// no attempt at determining whether or not a particular sequence of digits
    /// could ever be a dialable phone number.
    private static let validE164StructureRegex = try! NSRegularExpression(
        pattern: #"^\+[1-9][0-9]{0,18}$"#,
        options: []
    )

    /// Checks if the value starts with a "+" and has [1, 19] digits.
    var isStructurallyValidE164: Bool { Self.validE164StructureRegex.hasMatch(input: self) }

    var filteredAsE164: String {
        let maxLength = 256
        let length = min(maxLength, count)

        var result: [unichar] = []
        result.reserveCapacity(length)
        for uch in utf16 {
            if (0x30...0x39).contains(uch) || (result.isEmpty && uch == 0x2B) {
                result.append(uch)
                if result.count >= length {
                    break
                }
            }
        }
        return String(utf16CodeUnits: result, count: result.count)
    }
}

// MARK: - StrippedNonEmptyString

/// A String that's been fed through `strippedOrNil` and isn't `nil`.
public struct StrippedNonEmptyString: Equatable {
    public let rawValue: String
    public init?(rawValue: String) {
        guard let strippedValue = rawValue.strippedOrNil else {
            return nil
        }
        self.rawValue = strippedValue
    }
}
