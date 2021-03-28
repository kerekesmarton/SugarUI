import SwiftUI
import Combine
import Sugar

public struct NavigationViewModel<T: View> {
    public init(model: ButtonTheme.Model, destination: T, isActive: Binding<Bool>) {
        self.model = model
        self.destination = destination
        self._isActive = isActive
    }

    var model: ButtonTheme.Model
    var destination: T
    @Binding var isActive: Bool
}

public struct NavigationBarButtonModel {
    public init(model: ButtonTheme.Model, block: @escaping Action) {
        self.model = model
        self.block = block
    }

    var model: ButtonTheme.Model
    var block: Action
}

public extension View {

    func makeLoadingView() -> some View {
        return LoadingView()
    }

    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }

    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }

    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }

    func closeButton(_ block: @escaping Action) -> some View {
        navigationBarButton(.init(model: .image(Image(symbol: .xmark)), block: block))
    }

    func navigationBarButton(_ params: NavigationBarButtonModel) -> some View {
        Button(action: params.block) {
            ButtonTheme.makeInnerBody(model: params.model)
        }
        .buttonStyle(ButtonTheme.navigation)
        .frame(height: 30, alignment: .center)
    }

    func filledNavigationBarButton(_ params: NavigationBarButtonModel) -> some View {
        Button(action: params.block) {
            ButtonTheme.makeInnerBody(model: params.model)
        }
        .buttonStyle(ButtonTheme.filledNavigation)
        .frame(height: 30, alignment: .center)
    }

    func navigationLinkButton<T: View>(_ params: NavigationViewModel<T>) -> some View {
        NavigationLink(destination: params.destination, isActive: params.$isActive) {
            ButtonTheme.makeInnerBody(model: params.model)
        }
        .buttonStyle(ButtonTheme.navigation)
        .frame(height: 30, alignment: .center)
    }
}

public struct LoadingView: View {
    public var body: some View {
        VStack {
            Text("Loading").font(Font(.title3))
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        }
    }
}
