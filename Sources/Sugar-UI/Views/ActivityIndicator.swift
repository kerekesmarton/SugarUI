import UIKit
import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
    public init(isAnimating: Binding<Bool>, style: UIActivityIndicatorView.Style) {
        self.style = style
        _isAnimating = isAnimating
    }

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
