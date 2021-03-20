import SwiftUI
import Additions

extension Card {
    public struct ButtonModel {
        public init(model: ButtonTheme.Model, action: @escaping Action) {
            self.model = model
            self.action = action
        }

        var model:ButtonTheme.Model
        var action: Action
    }

    public enum FieldInfo: Identifiable {
        case title(title: String, detail: String)
        case images(images: [AsyncImageModel], placeholder: Image, badges: [Any])
        case image(image: AsyncImageModel?, placeholder: Image, badges: [Any])
        case infoLine([String])
        case secondInfoLine(String)
        case bar(leading: [ButtonModel], trailing: [ButtonModel])
        case longInfo(String)

        private enum Constants: String {
            case image
            case images
            case priceLine
            case infoLine
            case secondInfoLine
            case bar
            case longInfo
        }

        public var id: String {
            switch self {
            case .image:
                return Constants.image.rawValue
            case .images:
                return Constants.images.rawValue
            case .title(let price, let time):
                return Constants.priceLine.rawValue + price + " " + time
            case .infoLine(let info):
                return Constants.infoLine.rawValue + info.joined(separator: ", ")
            case .secondInfoLine(let info):
                return Constants.secondInfoLine.rawValue + info
            case .bar:
                return Constants.bar.rawValue
            case .longInfo:
                return Constants.longInfo.rawValue
            }
        }
    }

    public enum CardType: String, CaseIterable, Identifiable {
        case list
        case detail
        case minimal

        public var id: String {
            rawValue
        }
    }

}
