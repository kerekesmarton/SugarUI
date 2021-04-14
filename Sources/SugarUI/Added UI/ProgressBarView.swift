import SwiftUI

@available(iOS 13.0, *)
public struct ProgressBarView: View {
    private let height: CGFloat = 4
    private let animationWidth: CGFloat = 64
    private let gradient = Gradient(colors: [Color(.primary).dim(.d60), Color(.primary), Color(.primary).dim(.d60)])
    @Binding var isShowing: Bool

    public init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }

    private var repeatingAnimation: Animation {
        Animation
            .linear(duration: 1)
            .repeatForever(autoreverses: false)
    }

    public var body: some View {
        GeometryReader { geometry in
            if self.isShowing {
                Rectangle()
                    .fill(LinearGradient(gradient: self.gradient, startPoint: .leading, endPoint: .trailing))
                    .frame(width: self.animationWidth, height: self.height)
                    .transformEffect(.init(translationX: self.progress, y: 0))
                    .animation(self.repeatingAnimation)
                    .onAppear { withAnimation { self.start(geometry: geometry) } }
                    .onDisappear { withAnimation { self.stop() } }
            }
        }
    }

    @State var progress: CGFloat = 0.0
    @State var timer: Timer?

    func start(geometry: GeometryProxy) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation {
                self.progress += 10
            }
            if self.progress == geometry.size.width + self.animationWidth/2 {
                self.progress = 0
            }
        }
    }

    func stop() {
        self.progress = 0
        self.timer?.invalidate()
    }
}
