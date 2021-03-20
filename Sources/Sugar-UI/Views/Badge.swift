import SwiftUI

@available(iOS 13.0, *)
public struct Badge: View {

    public enum Category: Equatable {
        case extraSmall(String)
        case small(String)
        case medium(String)
        case icon(Image)

        var text: String? {
            switch self {
            case .extraSmall(let value), .small(let value), .medium(let value):
                return value
            default:
                return nil
            }
        }

        var isIcon: Image? {
            guard case .icon(let value) = self else { return nil }
            return value
        }
    }

    public enum BadgeColor {
        case surface
        case secondary
        case success
        case warning
        case onSurface
        case primary
        case error
    }

    private struct Padding {
        static let extraSmall: CGFloat = 2
        static let small: CGFloat = 4
        static let medium: CGFloat = 6
        static let large: CGFloat = 8
        static let extraLarge: CGFloat = 12
    }

    private struct Size {
        static let height: CGFloat = 16
    }

    private var category: Category
    private var color: BadgeColor

    public init(category: Category,
                color: BadgeColor) {
        self.category = category
        self.color = color
    }

    public var body: some View {
        makeBody()
            .foregroundColor(badgeColors.foreground)
            .background(badgeColors.background)
            .cornerRadius(.infinity)
    }

    private func makeBody() -> some View {
        Group {
            category.text.map { text in
                makeTextView(text: text)
            }

            category.isIcon.map { icon in
                self.makeIconView(icon: icon)
            }
        }
    }

    private func makeTextView(text: String) -> some View {
        Text(text)
            .padding(padding)
            .font(font)
    }

    private func makeIconView(icon: Image) -> some View {
        icon
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: Size.height, height: Size.height)
            .padding(padding)
    }

    private var font: Font? {
        switch category {
        case .extraSmall:
            return Font(.caption2)
        case .small:
            return Font(.caption1)
        case .medium:
            return Font(.small)
        case .icon:
            return nil
        }
    }

    private var padding: EdgeInsets {
        switch category {
        case .extraSmall:
            return EdgeInsets(top: Padding.extraSmall, leading: Padding.medium, bottom: Padding.extraSmall, trailing: Padding.medium)
        case .small:
            return EdgeInsets(top: Padding.medium, leading: Padding.large, bottom: Padding.medium, trailing: Padding.large)
        case .medium:
            return EdgeInsets(top: Padding.medium, leading: Padding.extraLarge, bottom: Padding.medium, trailing: Padding.extraLarge)
        case .icon:
            return EdgeInsets(top: Padding.small, leading: Padding.large, bottom: Padding.small, trailing: Padding.large)
        }
    }

    private var badgeColors: (foreground: Color, background: Color) {
        switch color {
        case .surface:
            return (Color(.secondary), Color(.background))
        case .onSurface:
            return (Color(.background), Color(.secondary))
        case .success:
            return (Color(.background), Color(.success))
        case .warning:
            return (Color(.background), Color(.warning))
        case .secondary:
            return (Color(.background), Color(.secondary))
        case .primary:
            return (Color(.secondary), Color(.primary))
        case .error:
            return (Color(.background), Color(.error))
        }
    }
}
