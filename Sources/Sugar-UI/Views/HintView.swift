import SwiftUI

@available(iOS 13.0, *)
public struct HintView: View {
    @Binding var isPresenting: Bool
    @State private var dragOffset: CGSize = .zero

    private let style: Style
    private let message: LocalizedStringKey

    public enum Style: String, CaseIterable {
        case info
        case success
        case warning
        case error
    }

    public init(
        isPresenting: Binding<Bool>,
        style: Style,
        message: LocalizedStringKey
    ) {
        self._isPresenting = isPresenting
        self.style = style
        self.message = message
    }

    public var body: some View {
        Group {
            if isPresenting {
                HStack {
                    Text(message)
                        .font(Font(.small))
                        .padding(.trailing, 8)
                    Spacer()
                }
                .padding(16)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(16)
            }
        }
        .transition(.slide)
        .animation(.default)
    }

    private var backgroundColor: Color {
        return Color(.background)
    }

    private var foregroundColor: Color {
        switch style {
        case .info:
            return Color(.secondary)
        case .success:
            return Color(.success)
        case .warning:
            return Color(.warning)
        case .error:
            return Color(.error)
        }
    }
}

@available(iOS 13.0, *)
struct HintView_Previews: PreviewProvider {
    static var previews: some View {
        HintView(isPresenting: .constant(true), style: .info, message: "Lorem ipsum dolor sit amet. Lorem ipsum message.")
    }
}
