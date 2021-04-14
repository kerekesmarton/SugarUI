import SwiftUI
import Sugar

public struct ErrorView: View {

    public struct ActionModel {
        public let title: String
        public let image: Image?
        public let completion: Action

        public init(title: String, image: Image?, completion: @escaping Action) {
            self.title = title
            self.image = image
            self.completion = completion
        }

        var content: ButtonTheme.Model {
            if let image = image {
                return .combine(text: title, image: image)
            } else {
                return .text(title)
            }
        }
    }

    public struct Model {

        public init(title: String,
                    subtitle: String,
                    image: Image,
                    primaryAction: ActionModel?,
                    secondaryAction: ActionModel?) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.primaryAction = primaryAction
            self.secondaryAction = secondaryAction
        }

        let title: String
        let subtitle: String
        let image: Image
        let primaryAction: ActionModel?
        let secondaryAction: ActionModel?
    }

    public init(error: Model) {
        self.error = error
    }
    
    var error: Model

    public var body: some View {
        VStack(spacing: 16) {
            error.image
                .foregroundColor(Color(.secondary))

            Text(error.title)
                .foregroundColor(Color(.secondary))

            Text(error.subtitle)
                .foregroundColor(Color(.secondary))

            error.primaryAction.map { action in

                Button(action: {
                    action.completion()
                }, label: {
                    ButtonTheme.makeInnerBody(model: action.content)
                }).buttonStyle(ButtonTheme(size: .init(width: .extendable, height: .large), style: .filled))
            }

            error.secondaryAction.map { action in
                Button(action: {
                    action.completion()
                }, label: {
                    ButtonTheme.makeInnerBody(model: action.content)
                }).buttonStyle(ButtonTheme(size: .init(width: .extendable, height: .large), style: .flat))
            }
        }
    }
}


