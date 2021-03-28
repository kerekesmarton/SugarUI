import SwiftUI
import Sugar

public struct BannerView: View {
    @Binding var isPresenting: Bool
    @State private var dragOffset: CGSize = .zero

    private let style: Style
    private var title: LocalizedStringKey?
    private let message: LocalizedStringKey
    private let dismissButtonTitle: String?
    private var secondaryButton: ButtonModel?
    private let hasActions: Bool

    public enum Style: String, CaseIterable {
        case info
        case success
        case warning
        case error
    }

    public struct ButtonModel {
        let title: String
        let action: Action

        public init(title: String,
                    action: @escaping Action) {
            self.title = title
            self.action = action
        }
    }

    public init(
        isPresenting: Binding<Bool>,
        style: Style,
        title: LocalizedStringKey?,
        message: LocalizedStringKey,
        dismissButtonTitle: String?,
        secondaryButton: ButtonModel?
    ) {
        self._isPresenting = isPresenting
        self.style = style
        self.title = title
        self.message = message
        self.dismissButtonTitle = dismissButtonTitle
        self.secondaryButton = secondaryButton
        self.hasActions = secondaryButton != nil || dismissButtonTitle != nil
    }

    public var body: some View {
        Group {
            if isPresenting {
                VStack(alignment: .leading) {
                    if title != nil {
                        Text(title!)
                            .font(Font(.subhead))
                            .padding(.bottom, 8)
                            .padding(.trailing, 8)
                    }

                    HStack {
                        Text(message)
                            .font(Font(.small))
                            .padding(.trailing, 8)
                        Spacer()
                    }

                    if hasActions {
                        HStack {
                            Spacer()
                            dismissButtonTitle.map { title in
                                Button(action: {
                                    self.isPresenting = false
                                }) {
                                    ButtonTheme.makeInnerBody(model: .text(title))
                                }.buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .flat))
                            }

                            secondaryButton.map { model in
                                Button(action: {
                                    self.isPresenting = false
                                    model.action()
                                }) {
                                    ButtonTheme.makeInnerBody(model: .text(model.title))
                                }.buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .flat))
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: hasActions ? 8 : 16, trailing: 8))
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(radius: 16, corners: [.bottomLeft, .bottomRight])
                .offset(y: self.dragOffset.height)
                .gesture(
                    DragGesture()
                        .onChanged {
                            let yTranslation = $0.translation.height
                            if yTranslation < 20 {
                                self.dragOffset = $0.translation
                            }
                    }
                    .onEnded { _ in
                        self.dragOffset = .zero
                        self.isPresenting = false
                    }
                )}
        }
        .transition(.move(edge: .top))
        .animation(.default)
        .onAppear {
            if !self.hasActions {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.isPresenting = false
                }
            }
        }
    }

    private var backgroundColor: Color {
        Color(.background)
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
struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        BannerView(
            isPresenting: .constant(true),
            style: .info,
            title: "Lorem ipsum dolor sit amet. Title.",
            message: "Lorem ipsum dolor sit amet. Lorem ipsum message.",
            dismissButtonTitle: "Ok",
            secondaryButton: .init(title: "Got it", action: {}))
    }
}
