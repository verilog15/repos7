//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

public struct UnsentTextAttachment {
    public let body: StyleOnlyMessageBody?
    public let textStyle: TextAttachment.TextStyle
    public let textForegroundColor: UIColor
    public let textBackgroundColor: UIColor?
    public let background: TextAttachment.Background

    public let linkPreviewDraft: OWSLinkPreviewDraft?

    public var textContent: TextAttachment.TextContent {
        return TextAttachment.textContent(body: body, textStyle: textStyle)
    }

    public init(
        body: StyleOnlyMessageBody?,
        textStyle: TextAttachment.TextStyle,
        textForegroundColor: UIColor,
        textBackgroundColor: UIColor?,
        background: TextAttachment.Background,
        linkPreviewDraft: OWSLinkPreviewDraft?
    ) {
        self.body = body
        self.textStyle = textStyle
        self.textForegroundColor = textForegroundColor
        self.textBackgroundColor = textBackgroundColor
        self.background = background
        self.linkPreviewDraft = linkPreviewDraft
    }

    public func validateAndPrepareForSending() throws -> ForSending {
        let validatedLinkPreview: LinkPreviewDataSource?
        if let linkPreview = linkPreviewDraft {
            do {
                validatedLinkPreview = try DependenciesBridge.shared.linkPreviewManager.buildDataSource(
                    from: linkPreview
                )
            } catch LinkPreviewError.featureDisabled {
                validatedLinkPreview = .init(
                    metadata: .init(
                        urlString: linkPreview.urlString,
                        title: nil,
                        previewDescription: nil,
                        date: nil
                    ),
                    imageDataSource: nil
                )
            } catch {
                Logger.error("Failed to generate link preview.")
                validatedLinkPreview = nil
            }
        } else {
            validatedLinkPreview = nil
        }

        guard validatedLinkPreview != nil || !(body?.isEmpty ?? true) else {
            throw OWSAssertionError("Empty content")
        }

        return .init(
            body: self.body,
            textStyle: self.textStyle,
            textForegroundColor: self.textForegroundColor,
            textBackgroundColor: self.textBackgroundColor,
            background: self.background,
            linkPreviewDraft: validatedLinkPreview
        )
    }

    public struct ForSending {
        public let body: StyleOnlyMessageBody?
        public let textStyle: TextAttachment.TextStyle
        public let textForegroundColor: UIColor
        public let textBackgroundColor: UIColor?
        public let background: TextAttachment.Background

        public let linkPreviewDraft: LinkPreviewDataSource?

        public var textContent: TextAttachment.TextContent {
            return TextAttachment.textContent(body: body, textStyle: textStyle)
        }

        public func buildTextAttachment(
            transaction: DBWriteTransaction
        ) -> OwnedAttachmentBuilder<TextAttachment>? {
            var linkPreviewBuilder: OwnedAttachmentBuilder<OWSLinkPreview>?
            if let linkPreview = linkPreviewDraft {
                do {
                    linkPreviewBuilder = try DependenciesBridge.shared.linkPreviewManager.buildLinkPreview(
                        from: linkPreview,
                        tx: transaction
                    )
                } catch LinkPreviewError.featureDisabled {
                    linkPreviewBuilder = .withoutFinalizer(OWSLinkPreview(urlString: linkPreview.metadata.urlString))
                } catch {
                    Logger.error("Failed to generate link preview.")
                }
            }

            guard linkPreviewBuilder != nil || !(body?.isEmpty ?? true) else {
                owsFailDebug("Empty content")
                return nil
            }

            func buildTextAttachment(linkPreview: OWSLinkPreview?) -> TextAttachment {
                return TextAttachment(
                    body: body,
                    textStyle: textStyle,
                    textForegroundColor: textForegroundColor,
                    textBackgroundColor: textBackgroundColor,
                    background: background,
                    linkPreview: linkPreview
                )
            }
            if let linkPreviewBuilder {
                return linkPreviewBuilder.wrap(buildTextAttachment(linkPreview:))
            } else {
                return .withoutFinalizer(buildTextAttachment(linkPreview: nil))
            }
        }
    }
}

public struct TextAttachment: Codable, Equatable {
    private let body: StyleOnlyMessageBody?

    private enum Constants {
        static let maxGradientPoints = 100
    }

    public enum TextStyle: Int, Codable, Equatable {
        case regular = 0
        case bold = 1
        case serif = 2
        case script = 3
        case condensed = 4
    }
    private let textStyle: TextStyle

    public enum TextContent {
        case empty
        case styled(body: String, style: TextStyle)
        case styledRanges(StyleOnlyMessageBody)
    }

    public private(set) var preview: OWSLinkPreview?

    public var textContent: TextContent {
        return Self.textContent(body: body, textStyle: textStyle)
    }

    fileprivate static func textContent(
        body: StyleOnlyMessageBody?,
        textStyle: TextStyle
    ) -> TextContent {
        guard let body, body.isEmpty.negated else {
            return .empty
        }
        switch textStyle {
        case .regular:
            if body.hasStyles {
                return .styledRanges(body)
            } else {
                return .styled(body: body.text, style: .regular)
            }
        case .bold, .serif, .script, .condensed:
            return .styled(body: body.text, style: textStyle)
        }
    }

    private let textForegroundColorHex: UInt32?
    public var textForegroundColor: UIColor? { textForegroundColorHex.map { UIColor(argbHex: $0) } }

    private let textBackgroundColorHex: UInt32?
    public var textBackgroundColor: UIColor? { textBackgroundColorHex.map { UIColor(argbHex: $0) } }

    private enum RawBackground: Codable, Equatable {
        case color(hex: UInt32)
        case gradient(raw: RawGradient)
        struct RawGradient: Codable, Equatable {
            let colors: [UInt32]
            let positions: [Float]
            let angle: UInt32

            init(colors: [UInt32], positions: [Float], angle: UInt32) {
                self.colors = colors
                self.positions = positions
                self.angle = angle
            }

            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
                self.colors = try container.decode([UInt32].self, forKey: .colors)
                self.positions = try container.decode([Float].self, forKey: .positions)
                self.angle = try container.decode(UInt32.self, forKey: .angle)
            }

            func buildProto() -> SSKProtoTextAttachmentGradient {
                let builder = SSKProtoTextAttachmentGradient.builder()
                if let startColor = colors.first {
                    builder.setStartColor(startColor)
                }
                if let endColor = colors.last {
                    builder.setEndColor(endColor)
                }
                builder.setColors(colors)
                builder.setPositions(positions)
                builder.setAngle(angle)
                return builder.buildInfallibly()
            }
        }
    }
    private let rawBackground: RawBackground

    public enum Background {
        case color(UIColor)
        case gradient(Gradient)
        public struct Gradient {
            public init(colors: [UIColor], locations: [CGFloat], angle: UInt32) {
                self.colors = colors
                self.locations = locations
                self.angle = angle
            }
            public init(colors: [UIColor]) {
                let locations: [CGFloat] = colors.enumerated().map { element in
                    return CGFloat(element.offset) / CGFloat(colors.count - 1)
                }
                self.init(colors: colors, locations: locations, angle: 180)
            }
            public let colors: [UIColor]
            public let locations: [CGFloat]
            public let angle: UInt32
        }
    }
    public var background: Background {
        switch rawBackground {
        case .color(let hex):
            return .color(.init(argbHex: hex))
        case .gradient(let rawGradient):
            return .gradient(.init(
                colors: rawGradient.colors.map { UIColor(argbHex: $0) },
                locations: rawGradient.positions.map { CGFloat($0) },
                angle: rawGradient.angle
            ))
        }
    }

    init(
        from proto: SSKProtoTextAttachment,
        bodyRanges: [SSKProtoBodyRange],
        linkPreview: OWSLinkPreview?,
        transaction: DBWriteTransaction
    ) throws {
        self.body = proto.text?.nilIfEmpty.map { StyleOnlyMessageBody(text: $0, protos: bodyRanges) }

        guard let style = proto.textStyle else {
            throw OWSAssertionError("Missing style for attachment.")
        }

        switch style {
        case .default, .regular:
            self.textStyle = .regular
        case .bold:
            self.textStyle = .bold
        case .serif:
            self.textStyle = .serif
        case .script:
            self.textStyle = .script
        case .condensed:
            self.textStyle = .condensed
        }

        if proto.hasTextForegroundColor {
            textForegroundColorHex = proto.textForegroundColor
        } else {
            textForegroundColorHex = nil
        }

        if proto.hasTextBackgroundColor {
            textBackgroundColorHex = proto.textBackgroundColor
        } else {
            textBackgroundColorHex = nil
        }

        if let gradient = proto.gradient {
            let colors: [UInt32]
            let positions: [Float]
            if !gradient.colors.isEmpty && !gradient.positions.isEmpty {
                colors = Array(gradient.colors.prefix(Constants.maxGradientPoints))
                positions = Array(gradient.positions.prefix(Constants.maxGradientPoints).map({ $0.isNaN ? 0 : $0 }))
            } else {
                colors = [ gradient.startColor, gradient.endColor ]
                positions = [ 0, 1 ]
            }
            rawBackground = .gradient(raw: .init(
                colors: colors,
                positions: positions,
                angle: gradient.angle
            ))
        } else if proto.hasColor {
            rawBackground = .color(hex: proto.color)
        } else {
            throw OWSAssertionError("Missing background for attachment.")
        }

        self.preview = linkPreview
    }

    public func buildProto(
        parentStoryMessage: StoryMessage,
        bodyRangeHandler: ([SSKProtoBodyRange]) -> Void,
        transaction: DBReadTransaction
    ) throws -> SSKProtoTextAttachment {
        let builder = SSKProtoTextAttachment.builder()

        if let body {
            builder.setText(body.text)
            bodyRangeHandler(body.toProtoBodyRanges())
        }

        let textStyle: SSKProtoTextAttachmentStyle = {
            switch self.textStyle {
            case .regular: return .regular
            case .bold: return .bold
            case .serif: return .serif
            case .script: return .script
            case .condensed: return .condensed
            }
        }()
        builder.setTextStyle(textStyle)

        if let textForegroundColorHex = textForegroundColorHex {
            builder.setTextForegroundColor(textForegroundColorHex)
        }

        if let textBackgroundColorHex = textBackgroundColorHex {
            builder.setTextBackgroundColor(textBackgroundColorHex)
        }

        switch rawBackground {
        case .color(let hex):
            builder.setColor(hex)
        case .gradient(let raw):
            builder.setGradient(raw.buildProto())
        }

        if let preview = preview {
            let previewProto = try DependenciesBridge.shared.linkPreviewManager.buildProtoForSending(
                preview,
                parentStoryMessage: parentStoryMessage,
                tx: transaction
            )
            builder.setPreview(previewProto)
        }

        return try builder.build()
    }

    public init(
        body: StyleOnlyMessageBody?,
        textStyle: TextStyle,
        textForegroundColor: UIColor,
        textBackgroundColor: UIColor?,
        background: Background,
        linkPreview: OWSLinkPreview?
    ) {
        self.body = body
        self.textStyle = textStyle
        self.textForegroundColorHex = textForegroundColor.argbHex
        self.textBackgroundColorHex = textBackgroundColor?.argbHex
        self.rawBackground = {
            switch background {
            case .color(let color):
                return .color(hex: color.argbHex)

            case .gradient(let gradient):
                return .gradient(raw: .init(colors: gradient.colors.map { $0.argbHex },
                                            positions: gradient.locations.map { Float($0) },
                                            angle: gradient.angle))
            }
        }()
        self.preview = linkPreview
    }

    /// Attempts to create a draft from the final version, so that it can be re-sent with new independent link attachment
    /// objects created. If link recreation from url fails, will omit the link.
    public func asUnsentAttachment() -> UnsentTextAttachment {
        var linkPreviewDraft: OWSLinkPreviewDraft?
        if
            let preview = preview,
            let urlString = preview.urlString,
            let url = URL(string: urlString)
        {
            linkPreviewDraft = OWSLinkPreviewDraft(url: url, title: preview.title)
        }
        return UnsentTextAttachment(
            body: body,
            textStyle: textStyle,
            textForegroundColor: textForegroundColor ?? .white,
            textBackgroundColor: textBackgroundColor,
            background: background,
            linkPreviewDraft: linkPreviewDraft
        )
    }

    public enum CodingKeys: String, CodingKey {
        // Backwards compatibility; originally this held a vanilla string.
        case body = "text"
        case textStyle
        case textForegroundColorHex
        case textBackgroundColorHex
        case rawBackground
        case preview
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            // Backwards compability; this used to contain just a raw string,
            // which we now interpret as a style-less string.
            if let rawText = try container.decodeIfPresent(String.self, forKey: .body) {
                self.body = StyleOnlyMessageBody(plaintext: rawText)
            } else {
                self.body = nil
            }
        } catch {
            self.body = try container.decodeIfPresent(StyleOnlyMessageBody.self, forKey: .body)
        }

        self.textStyle = try container.decode(TextStyle.self, forKey: .textStyle)
        self.textForegroundColorHex = try container.decodeIfPresent(UInt32.self, forKey: .textForegroundColorHex)
        self.textBackgroundColorHex = try container.decodeIfPresent(UInt32.self, forKey: .textBackgroundColorHex)
        self.rawBackground = try container.decode(RawBackground.self, forKey: .rawBackground)
        self.preview = try container.decodeIfPresent(OWSLinkPreview.self, forKey: .preview)
    }
}
