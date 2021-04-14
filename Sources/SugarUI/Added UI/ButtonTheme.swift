import SwiftUI

public struct ButtonTheme: ButtonStyle {
    public init(size: ButtonTheme.Size, style: ButtonTheme.Style) {
        self.size = size
        self.style = style
    }
    
    public static let navigation = ButtonTheme(size: .init(width: .fixed, height: .large), style: .flat)

    public static let filledNavigation = ButtonTheme(size: .init(width: .fixed, height: .large), style: .filled)
    
    public enum Style: String, CaseIterable {
        case filled
        case outline
        case flat
        
        case disabled
    }
    
    public struct Size {
        public init(width: ButtonTheme.Size.Width, height: ButtonTheme.Size.Height) {
            self.width = width
            self.height = height
        }

        var width: Width
        var height: Height
        
        public enum Height: String, CaseIterable {
            case small
            case large
        }
        
        public enum Width: String, CaseIterable {
            case fixed
            case extendable
        }
    }
    
    var size: Size
    var style: Style
    
    private var font: Font {
        switch size.height {
        case .large:
            return Font(.link1)
        case .small:
            return Font(.link2)
        }
    }
    
    private var maxHeight: CGFloat {
        switch size.height {
        case .small:
            return 32
        case .large:
            return 40
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .filled:
            return Color(.primary)
        case .outline, .flat:
            return Color(.secondary)
        case .disabled:
            return Color(.disabled)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .filled:
            return Color(.secondary)
        case .outline, .flat, .disabled:
            return Color.clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .filled, .flat, .disabled:
            return Color.clear
        case .outline:
            return Color(.background)
        }
    }

    private var sidePadding: CGFloat {
        switch size.height {
        case .large:
            return 16
        case .small:
            return 12
        }
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .font(font)
            .lineLimit(1)
            .foregroundColor(foregroundColor)
            .padding(EdgeInsets(top: 0, leading: sidePadding, bottom: 0, trailing: sidePadding))
            .frame(maxHeight: maxHeight, alignment: .center)
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(borderColor, lineWidth: 2))
    }
    
    public enum Model {
        case text(String)
        case image(Image)
        case combine(text: String, image: Image)
    }
    
    public static func makeInnerBody(model: Model) -> some View {

        Group {
            switch model {
            case .text(let text):
                Text(text)
            case .image(let image):
                image
            case .combine(let text, let image):
                HStack(alignment: .center, spacing: 8) {
                    image
                    Text(text)
                }
            }
        }
    }
}

struct Button_Previews: PreviewProvider {

    static var previews: some View {
        VStack(alignment: .center, spacing: 20) {

            Section(header: Text("Text only")) {

                Spacer().frame(maxHeight: 20)

                Button(action: { print("pressed") }, label: {
                    Text("Hello, World!")
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .large), style: .filled))

                Button(action: { print("pressed") }, label: {
                    Text("Hello, World!")
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .filled))

                Button(action: { print("pressed") }, label: {
                    Text("Hello, World!")
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .large), style: .outline))

                Button(action: { print("pressed") }, label: {
                    Text("Hello, World!")
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .outline))
            }

            Section(header: Text("Icon + Text")) {

                Spacer().frame(maxHeight: 20)

                Button(action: { print("pressed") }, label: {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("Hello, World!")
                    }
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .large), style: .filled))

                Button(action: { print("pressed") }, label: {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("Hello, World!")
                    }
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .filled))

                Button(action: { print("pressed") }, label: {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("Hello, World!")
                    }
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .large), style: .outline))

                Button(action: { print("pressed") }, label: {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("Hello, World!")
                    }
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .outline))
            }

            Section(header: Text("Icon only")) {

                Spacer().frame(maxHeight: 20)

                Button(action: { print("pressed") }, label: {
                    Image(systemName: "bubble.left")
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .large), style: .filled))

                Button(action: { print("pressed") }, label: {
                    Image(systemName: "bubble.left")
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .filled))

                Button(action: { print("pressed") }, label: {
                    Image(systemName: "bubble.left")
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .large), style: .outline))

                Button(action: { print("pressed") }, label: {
                    Image(systemName: "bubble.left")
                })
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .outline))
            }
        }
    }
}
