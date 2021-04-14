import Foundation
import SwiftUI
import Sugar

extension ServiceError {
    var alertTitleText: Text {
        Text(errorDescription)
            .foregroundColor(Color(.error))
            .font(Font(.title2))
    }

    var alertMessageText: Text {
        Text(recoverySuggestion)
            .foregroundColor(Color(.primary))
            .font(Font(.body))
    }

    public func alert() -> Alert {
        Alert(
            title: alertTitleText,
            message: alertMessageText,
            dismissButton: Alert.Button.cancel()
        )
    }

    public func alert(action: @escaping Action) -> Alert {
        Alert(
            title: alertTitleText,
            message: alertMessageText,
            dismissButton: Alert.Button.cancel(Text("Ok"), action: action)
        )
    }
}
