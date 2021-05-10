import SwiftUI

public struct StatusBarStyleKey: PreferenceKey {
    public static var defaultValue: UIStatusBarStyle = .default

    public static func reduce(value: inout UIStatusBarStyle, nextValue: () -> UIStatusBarStyle) {
        value = nextValue()
    }
}

public class HostingController: UIHostingController<AnyView> {
    var statusBarStyle = UIStatusBarStyle.default

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }

    public init<T: View>(wrappedView: T) {
        let observer = Observer()

        let observedView = AnyView(wrappedView.onPreferenceChange(StatusBarStyleKey.self) { style in
            observer.value?.statusBarStyle = style
        })

        super.init(rootView: observedView)
        observer.value = self
    }

    private class Observer {
        weak var value: HostingController?
        init() {}
    }

    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
        // We aren't using storyboards, so this is unnecessary
        fatalError("Unavailable")
    }
}
