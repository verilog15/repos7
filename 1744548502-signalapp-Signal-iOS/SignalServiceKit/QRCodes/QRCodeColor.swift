//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

/// Preset color options for styled QR codes.
public enum QRCodeColor: String, UnknownEnumCodable, CaseIterable {
    case blue
    case white
    case grey
    case olive
    case green
    case orange
    case pink
    case purple

    public static var unknown: QRCodeColor { .blue }

    /// Background color for the QR code.
    public var background: UIColor {
        switch self {
        case .blue:
            return UIColor(rgbHex: 0x506ECD)
        case .white:
            return .white
        case .grey:
            return UIColor(rgbHex: 0x6A6C74)
        case .olive:
            return UIColor(rgbHex: 0xA89D7F)
        case .green:
            return UIColor(rgbHex: 0x829A6E)
        case .orange:
            return UIColor(rgbHex: 0xDE7134)
        case .pink:
            return UIColor(rgbHex: 0xE67899)
        case .purple:
            return UIColor(rgbHex: 0x9C84CF)
        }
    }

    /// Foreground color for the QR code.
    public var foreground: UIColor {
        switch self {
        case .blue:
            return UIColor(rgbHex: 0x2449C0)
        case .white:
            return .black
        case .grey:
            return UIColor(rgbHex: 0x464852)
        case .olive:
            return UIColor(rgbHex: 0x73694F)
        case .green:
            return UIColor(rgbHex: 0x55733F)
        case .orange:
            return UIColor(rgbHex: 0xD96B2D)
        case .pink:
            return UIColor(rgbHex: 0xBB617B)
        case .purple:
            return UIColor(rgbHex: 0x7651C5)
        }
    }

    /// Background color for the QR code share image.
    public var canvas: UIColor {
        switch self {
        case .blue:
            return UIColor(rgbHex: 0xEDF0FA)
        case .white:
            return UIColor(rgbHex: 0xF5F5F5)
        case .grey:
            return UIColor(rgbHex: 0xF0F0F1)
        case .olive:
            return UIColor(rgbHex: 0xF6F5F2)
        case .green:
            return UIColor(rgbHex: 0xF2F5F0)
        case .orange:
            return UIColor(rgbHex: 0xFCF1EB)
        case .pink:
            return UIColor(rgbHex: 0xFCF1F5)
        case .purple:
            return UIColor(rgbHex: 0xF5F3FA)
        }
    }

    /// Border color for the padding around the QR code.
    public var paddingBorder: UIColor {
        switch self {
        case .white:
            return UIColor(rgbHex: 0xE9E9E9)
        default:
            return .clear
        }
    }

    /// Color for the username displayed alongside the QR code.
    public var username: UIColor {
        switch self {
        case .white:
            return .black
        default:
            return .white
        }
    }
}
