//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI
import UIKit

enum PhotoGridItemType {
    case photo
    case animated
    case video(Promise<TimeInterval>)

    var localizedString: String {
        switch self {
        case .photo:
            return CommonStrings.attachmentTypePhoto
        case .animated:
            return CommonStrings.attachmentTypeAnimated
        case .video(let promise):
            switch promise.result {
            case .failure, .none:
                return "\(CommonStrings.attachmentTypeVideo)"
            case .success(let value):
                return "\(CommonStrings.attachmentTypeVideo) \(OWSFormat.localizedDurationString(from: value))"
            }
        }
    }

    var formattedType: String {
        switch self {
        case .animated:
            return OWSLocalizedString(
                "ALL_MEDIA_THUMBNAIL_LABEL_GIF",
                comment: "Label shown over thumbnails of GIFs in the All Media view")
        case .photo:
            return OWSLocalizedString(
                "ALL_MEDIA_THUMBNAIL_LABEL_IMAGE",
                comment: "Label shown by thumbnails of images in the All Media view")
        case .video:
            return OWSLocalizedString(
                "ALL_MEDIA_THUMBNAIL_LABEL_VIDEO",
                comment: "Label shown by thumbnails of videos in the All Media view")
        }
    }
}

public struct MediaMetadata {
    var sender: String
    var abbreviatedSender: String
    var byteSize: Int
    var creationDate: Date?
}

protocol PhotoGridItem: AnyObject {
    var type: PhotoGridItemType { get }
    var isFavorite: Bool { get }
    func asyncThumbnail(completion: @escaping (UIImage?) -> Void)
    var mediaMetadata: MediaMetadata? { get }
}

class PhotoGridViewCell: UICollectionViewCell {

    static let reuseIdentifier = "PhotoGridViewCell"

    public let imageView: UIImageView

    // Contains icon and shadow.
    private var isFavoriteBadge: UIView?

    private var durationLabel: UILabel?
    private var durationLabelBackground: UIView?
    private let selectionButton = SelectionButton()

    private let highlightedMaskView: UIView
    private let selectedMaskView: UIView

    private(set) var photoGridItem: PhotoGridItem?

    public var loadingColor = Theme.washColor

    var allowsMultipleSelection = false {
        didSet {
            updateSelectionState()
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            highlightedMaskView.isHidden = !isHighlighted
        }
    }

    override public var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }

    private var isFavorite: Bool = false {
        didSet {
            guard isFavorite else {
                isFavoriteBadge?.isHidden = true
                return
            }
            let badgeIconView: UIView
            if let isFavoriteBadge {
                badgeIconView = isFavoriteBadge
            } else {
                badgeIconView = UIView.container()
                badgeIconView.clipsToBounds = false

                let badgeShadow = GradientView(colors: [ .ows_blackAlpha40, .ows_blackAlpha40, .clear ])
                badgeShadow.gradientLayer.type = .radial
                badgeShadow.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
                badgeShadow.gradientLayer.endPoint = CGPoint(x: 1, y: 1)
                badgeIconView.addSubview(badgeShadow)

                let badgeIcon = UIImageView(image: UIImage(imageLiteralResourceName: "heart-fill-compact"))
                badgeIcon.tintColor = .white
                badgeIconView.addSubview(badgeIcon)

                badgeShadow.autoPinEdge(.top, to: .top, of: badgeIcon, withOffset: -20)
                badgeShadow.autoPinEdge(.trailing, to: .trailing, of: badgeIcon, withOffset: 20)
                badgeShadow.centerXAnchor.constraint(equalTo: badgeIconView.leadingAnchor).isActive = true
                badgeShadow.centerYAnchor.constraint(equalTo: badgeIconView.bottomAnchor).isActive = true

                badgeIcon.autoSetDimensions(to: .square(14))
                badgeIcon.autoPinEdge(toSuperviewEdge: .leading, withInset: 6)
                badgeIcon.autoPinEdge(toSuperviewEdge: .top)
                badgeIcon.autoPinEdge(toSuperviewEdge: .trailing)
                badgeIcon.autoPinEdge(toSuperviewEdge: .bottom, withInset: 5)

                contentView.addSubview(badgeIconView)
                badgeIconView.autoPinEdge(toSuperviewEdge: .leading)
                badgeIconView.autoPinEdge(toSuperviewEdge: .bottom)

                isFavoriteBadge = badgeIconView
            }
            badgeIconView.isHidden = false
            contentView.bringSubviewToFront(badgeIconView)
        }
    }

    override init(frame: CGRect) {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill

        highlightedMaskView = UIView()
        highlightedMaskView.alpha = 0.2
        highlightedMaskView.backgroundColor = Theme.darkThemePrimaryColor
        highlightedMaskView.isHidden = true

        selectedMaskView = UIView()
        selectedMaskView.alpha = 0.3
        selectedMaskView.backgroundColor = Theme.darkThemeBackgroundColor
        selectedMaskView.isHidden = true

        super.init(frame: frame)

        clipsToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(highlightedMaskView)
        contentView.addSubview(selectedMaskView)
        contentView.addSubview(selectionButton)

        imageView.autoPinEdgesToSuperviewEdges()
        highlightedMaskView.autoPinEdgesToSuperviewEdges()
        selectedMaskView.autoPinEdgesToSuperviewEdges()

        selectionButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 5)
        selectionButton.autoPinEdge(toSuperviewEdge: .top, withInset: 5)
    }

    @available(*, unavailable, message: "Unimplemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateSelectionState() {
        selectedMaskView.isHidden = !isSelected
        selectionButton.isSelected = isSelected
        selectionButton.allowsMultipleSelection = allowsMultipleSelection
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if let durationLabel = durationLabel,
           previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            durationLabel.font = Self.durationLabelFont()
        }
    }

    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.backgroundColor = newValue == nil ? loadingColor : .clear
        }
    }

    private static func durationLabelFont() -> UIFont {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption1)
        return UIFont.semiboldFont(ofSize: max(12, fontDescriptor.pointSize))
    }

    private func setMedia(itemType: PhotoGridItemType) {
        hideVideoDuration()
        switch itemType {
        case .video(let promisedDuration):
            updateVideoDurationWhenPromiseFulfilled(promisedDuration)
        case .animated:
            setCaption(itemType.formattedType)
        case .photo:
            break
        }
    }

    private func updateVideoDurationWhenPromiseFulfilled(_ promisedDuration: Promise<TimeInterval>) {
        let originalItem = photoGridItem
        promisedDuration.observe { [weak self] result in
            guard let self, self.photoGridItem === originalItem, case .success(let duration) = result else {
                return
            }
            self.setCaption(OWSFormat.localizedDurationString(from: duration))
        }
    }

    private func hideVideoDuration() {
        durationLabel?.isHidden = true
        durationLabelBackground?.isHidden = true
    }

    private func setCaption(_ caption: String) {
        if durationLabel == nil {
            let durationLabel = UILabel()
            durationLabel.textColor = .white
            durationLabel.font = Self.durationLabelFont()
            durationLabel.layer.shadowColor = UIColor.ows_blackAlpha20.cgColor
            durationLabel.layer.shadowOffset = CGSize(width: -1, height: -1)
            durationLabel.layer.shadowOpacity = 1
            durationLabel.layer.shadowRadius = 4
            durationLabel.shadowOffset = CGSize(width: 0, height: 1)
            durationLabel.adjustsFontForContentSizeCategory = true
            self.durationLabel = durationLabel
        }
        if durationLabelBackground == nil {
            let gradientView = GradientView(from: .clear, to: .ows_blackAlpha60)
            gradientView.gradientLayer.type = .axial
            gradientView.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientView.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            self.durationLabelBackground = gradientView
        }

        guard let durationLabel = durationLabel, let durationLabelBackground = durationLabelBackground else {
            return
        }

        if durationLabel.superview == nil {
            contentView.addSubview(durationLabel)
            durationLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 6)
            durationLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 4)
        }
        if durationLabelBackground.superview == nil {
            contentView.insertSubview(durationLabelBackground, belowSubview: durationLabel)
            durationLabelBackground.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
            durationLabelBackground.autoPinEdge(toSuperviewEdge: .leading)
            durationLabelBackground.autoPinEdge(toSuperviewEdge: .trailing)
            durationLabelBackground.autoPinEdge(toSuperviewEdge: .bottom)
        }

        durationLabel.isHidden = false
        durationLabelBackground.isHidden = false
        durationLabel.text = caption
        durationLabel.sizeToFit()

        if let isFavoriteBadge {
            contentView.bringSubviewToFront(isFavoriteBadge)
        }
    }

    private func setUpAccessibility(item: PhotoGridItem?) {
        self.isAccessibilityElement = true

        if let item {
            self.accessibilityLabel = [
                item.type.localizedString,
                MediaTileDateFormatter.formattedDateString(for: item.mediaMetadata?.creationDate)
            ]
                .compactMap { $0 }
                .joined(separator: ", ")
        } else {
            self.accessibilityLabel = ""
        }
    }

    public func makePlaceholder() {
        photoGridItem = nil
        image = nil
        setMedia(itemType: .photo)
        setUpAccessibility(item: nil)
    }

    func configure(item: PhotoGridItem) {
        photoGridItem = item

        // PHCachingImageManager returns multiple progressively better
        // thumbnails in the async block. We want to avoid calling
        // `configure(item:)` multiple times because the high-quality image eventually applied
        // last time it was called will be momentarily replaced by a progression of lower
        // quality images.
        image = nil
        item.asyncThumbnail { [weak self] image in
            guard let self else { return }

            guard let currentItem = self.photoGridItem else {
                return
            }

            guard currentItem === item else {
                return
            }

            if image == nil {
                Logger.debug("image == nil")
            }
            self.image = image
        }

        isFavorite = item.isFavorite
        setMedia(itemType: item.type)
        isFavorite = item.isFavorite
        setUpAccessibility(item: item)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        photoGridItem = nil
        imageView.image = nil
        isFavoriteBadge?.isHidden = true
        durationLabel?.isHidden = true
        durationLabelBackground?.isHidden = true
        highlightedMaskView.isHidden = true
        selectedMaskView.isHidden = true
        selectionButton.reset()
    }

    func mediaPresentationContext(collectionView: UICollectionView, in coordinateSpace: UICoordinateSpace) -> MediaPresentationContext? {
        guard let mediaSuperview = imageView.superview else {
            owsFailDebug("mediaSuperview was unexpectedly nil")
            return nil
        }
        let presentationFrame = coordinateSpace.convert(imageView.frame, from: mediaSuperview)
        let clippingAreaInsets = UIEdgeInsets(top: collectionView.adjustedContentInset.top, leading: 0, bottom: 0, trailing: 0)
        return MediaPresentationContext(
            mediaView: imageView,
            presentationFrame: presentationFrame,
            clippingAreaInsets: clippingAreaInsets
        )
    }
}
