import SwiftUI
import Combine
import Sugar

@available(iOS 13.0, *)
public class RefreshControl: ObservableObject, ScrollViewConsumer {

    public weak var scrollView: UIScrollView? {
        didSet {
            if let scrollView = scrollView {
                self.add(to: scrollView)
            }
        }
    }

    public init() {}

    public func endAnimating() {
        refreshControl?.endRefreshing()
    }

    private weak var refreshControl: UIRefreshControl?
    public var onValueChanged: (Action)?

    /// Adds (and stores) a `UIRefreshControl` to the `UIScrollView` provided.
    func add(to scrollView: UIScrollView) {

        // Only if not added already.
        guard self.refreshControl == nil else { return }

        // Create then add to scroll view.
        scrollView.refreshControl = UIRefreshControl().withTarget(
            self,
            action: #selector(self.onValueChangedAction),
            for: .valueChanged
        )

        // Reference (weak).
        self.refreshControl = scrollView.refreshControl
    }

    @objc private func onValueChangedAction() {
        self.onValueChanged?()
    }

    public func didResolveScrollView() {}
}

public protocol ScrollViewConsumer: AnyObject {
    var scrollView: UIScrollView? { get set }
    func didResolveScrollView()
}

public struct ScrollViewResolver<ConsumerType: ScrollViewConsumer>: UIViewRepresentable {

    private let consumer: ConsumerType

    public init(for consumer: ConsumerType) {
        self.consumer = consumer
    }

    public func makeUIView(context: Context) -> UIView {
        return UIView(frame: .zero)
    }

    public func updateUIView(_ view: UIView, context: Context) {
        if consumer.scrollView != nil { //Already resolved scrollView
            return
        }

        DispatchQueue.main.async {
            // Lookup view ancestry for any `UIScrollView` then callback if any.
            if let scrollView = view.searchViewAnchestors(for: UIScrollView.self) {
                consumer.scrollView = scrollView
                consumer.didResolveScrollView()
            }
        }
    }
}

extension UIView {

    /// Search ancestral view hierarchy for the given view type.
    func searchViewAnchestors<ViewType: UIView>(for viewType: ViewType.Type) -> ViewType? {
        if let matchingView = self.superview as? ViewType {
            return matchingView
        } else {
            return superview?.searchViewAnchestors(for: viewType)
        }
    }
}

private extension UIRefreshControl {

    /// Convinience method to assign target action inline.
    func withTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) -> UIRefreshControl {
        self.addTarget(target, action: action, for: controlEvents)
        return self
    }
}
