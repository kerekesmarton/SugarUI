import SwiftUI
import SFSymbols

@available(iOS 13.0, *)
public struct SearchBox: View {

    @Binding var text: String
    @State private var isEditing = false
    @State private var ishighlighted: Bool

    public init(text: Binding<String>, highlighted: Bool = false) {
        self._text = text
        self._ishighlighted = .init(initialValue: highlighted)
    }

    public var body: some View {
        HStack {
            textBar
            cancelButton
        }.frame(height: 48)
    }

    private var textBar: some View {
        HStack(alignment: .center, spacing: 0) {

            Image(symbol: .magnifyingglass)
                .padding(.horizontal, 8)
                .layoutPriority(1)

            TextField("Search ...", text: $text, onEditingChanged: { _ in
                self.isEditing = true
            })
                .font(Font(.body))
                .frame(minHeight: 40)
                .foregroundColor(foregroundColor)
                .autocapitalization(.none)
                .onTapGesture { self.isEditing = true }
        }
        .background(backgroundColor)
        .cornerRadius(8)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var cancelButton: some View {
        Group {
            if isEditing && !text.isEmpty {
                Button(action: {
                    self.text = ""
                    self.isEditing = false
                    UIApplication.shared.endEditing(true)
                }) {
                    ButtonTheme.makeInnerBody(model: .image(Image(symbol: .clear)))
                }.buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .flat))
            }
        }
    }

    private var foregroundColor: Color {
        if isEditing || ishighlighted {
            return Color(.secondary)
        } else {
            return Color(.secondary)
        }
    }

    private var backgroundColor: Color {
        Color(.background)
    }
}
