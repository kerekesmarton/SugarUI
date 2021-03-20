import SwiftUI
import SFSymbols
import Additions

public struct Card: View {
    
    var fields: [FieldInfo]
    var cardType: CardType
    @State private var currentImageIndex = 0
    
    public init(type: CardType, info: [FieldInfo]) {
        self.cardType = type
        self.fields = info
    }
    
    private func makeLine(field: FieldInfo) -> some View {
        Group {
            switch field {
            case .bar(leading: let leading, trailing: let trailing):
                makeButtonBar(leading: leading, trailing: trailing)
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 13, trailing: 0))
            case .image(image: let media, placeholder: let placeholder, badges: _):
                makeImageCarousel([media].compactMap { $0 }, placeholder: placeholder)
            case .images(images: let media, placeholder: let placeholder, badges: _):
                makeImageCarousel(media, placeholder: placeholder)
            case .infoLine(let info):
                Text(verbatim: info.joined(separator: "・"))
                    .font(Font(.small))
                    .foregroundColor(Color(.secondary))
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    .highPriorityGesture(TapGesture().onEnded { self._onTap?()})
            case .secondInfoLine(let info):
                Text(verbatim: info)
                    .font(Font(.smallExtra))
                    .foregroundColor(Color(.primary))
                    .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
            case .title(title: let title, detail: let detail):
                makeTitle(title, detail)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    .highPriorityGesture(TapGesture().onEnded { self._onTap?()})
            case .longInfo(let info):
                Text(verbatim: info)
                    .font(Font(.body))
                    .foregroundColor(Color(.primary))
                    .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }

    private func makeImageCarousel(_ media: [AsyncImageModel], placeholder: Image?) -> some View {
        ImageCarouselView(media: media, placeholder: placeholder, imageHeight: imageHeight, currentIndex: $currentImageIndex)
            .frame(minHeight: imageHeight, maxHeight: imageHeight, alignment: .center)
            .cornerRadius(16)
            .clipped()
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0))
            .highPriorityGesture(TapGesture().onEnded { self._onTap?()})
    }
    
    private func makeTitle(_ text: String, _ time: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(verbatim: text)
                .font(Font(.title2))
                .foregroundColor(Color(.primary))

            if cardType != .minimal {
                Spacer()
                Text(verbatim: time)
                    .font(Font(.caption2))
                    .foregroundColor(Color(.secondary))
            }
        }
    }
    
    private func makeButton(_ model: ButtonModel) -> some View {
        Button(action: model.action) {
            ButtonTheme.makeInnerBody(model: model.model)
        }.buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .outline))
    }
    
    private func makeButtonBar(leading: [ButtonModel],
                       trailing: [ButtonModel]) -> some View {
        HStack {
            
            ForEach(0..<leading.count, id: \.self) { i in
                self.makeButton(leading[i])
            }
            
            Spacer()
            
            ForEach(0..<trailing.count, id: \.self) { i in
                self.makeButton(trailing[i])
            }
            
        }.frame(height: 40, alignment: .center)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(fields) { field in
                self.makeLine(field: field)
            }
        }
    }

    private var _onTap: Action?
    public func onTap(_ block: @escaping Action) -> Card {
        var copy = self
        copy._onTap = block
        return copy
    }
    
    private var imageHeight: CGFloat {
        switch self.cardType {
        case .list:
            return 200
        case .detail, .minimal:
            return 120
        }
    }
}

struct Card_Previews: PreviewProvider {

    static var messageButton: Card.ButtonModel {
        .init(model: .combine(text: "Message", image: Image(symbol: .ellipsesBubble))) {

        }
    }

    static var callButton: Card.ButtonModel {
        .init(model: .image(Image(symbol: .phone))) {

        }
    }

    static var favoriteButton: Card.ButtonModel {
        .init(model: .image(Image(symbol: .heart))) {

        }
    }

    static var emptyResources = [AsyncImageModel(id: "", identityId: ""),
                                 AsyncImageModel(id: "", identityId: "")]

    static var previews: some View {

        List {
            Card(type: .list, info: [.title(title: "Info", detail: "Yesterday"),
                                     .images(images: emptyResources, placeholder: Image("dancer1"), badges: []),
                                     .infoLine(["Salsa", "Afro", "Fast"]),
                                     .secondInfoLine("New York"),
                                     .bar(leading: [Self.messageButton, Self.callButton],
                                          trailing: [ Self.favoriteButton])])

            Card(type: .detail, info: [.title(title: "Info", detail: "yesterday"),
                                       .images(images: emptyResources, placeholder: Image("dancer1"), badges: []),
                                       .infoLine(["Salsa", "Afro", "Fast", "New York"]),
                                       .bar(leading: [Self.messageButton, Self.callButton],
                                            trailing: [ Self.favoriteButton])])
        }
    }
}
