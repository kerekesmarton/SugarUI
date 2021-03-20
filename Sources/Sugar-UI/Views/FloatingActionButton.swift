import SwiftUI
import SFSymbols
import Additions

@available(iOS 13.0, *)
public struct FloatingActionButton: View {

    let height: Height
    let title: String?
    let icon: Image
    let action: Action
    @State var isShowing: Bool = true
    let crossIcon: Image = Image(symbol: .xmark)

    public enum Height: String, CaseIterable {
        case medium
        case large
        case xLarge
    }

    public init(title: String?, icon: Image, height: Height, action: @escaping Action) {
        self.title = title
        self.icon = icon
        self.action = action
        self.height = height
    }

    public var body: some View {
        Button(action: {
            self.action()
        }, label: {
            GeometryReader { g in
                self.buttonBody(geometry: g)
            }
        })
    }

    func buttonBody(geometry: GeometryProxy) -> some View {
        HStack(alignment: .center, spacing: 8) {
            if isShowing {
                self.icon
            } else {
                Button(action: {
                    withAnimation {
                        self.isShowing.toggle()
                    }
                }, label: {
                    self.icon
                })
            }

            self.title.map { value in
                Text(value)
                .lineLimit(1)
                .font(Font(.link1))
            }

            Button(action: {
                withAnimation {
                    self.isShowing.toggle()
                }
            }, label: {
                self.crossIcon
            })
        }
        .foregroundColor(Color(.primary))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: computeHeight, alignment: .center)
        .background(Color(.primary))
        .cornerRadius(radius)
        .clipped()
        .animation(.easeOut)
        .position(self.positions(geometry: geometry))
    }

    func positions(geometry: GeometryProxy) -> CGPoint {
        CGPoint(x: isShowing ? geometry.size.width/2 : geometry.size.width + Constants.widthAddon, y: geometry.size.height - Constants.approxMidY)
    }

    private struct Constants {
        static var approxWidth: CGFloat = 160
        static var approxMidY: CGFloat = 16
        static var peekWidth: CGFloat = 30

        static var widthAddon: CGFloat {
            Constants.approxWidth/2 - Constants.peekWidth
        }
    }

    var computeHeight: CGFloat {
        switch height {
        case .medium:
            return 40
        case .large:
            return 48
        case .xLarge:
            return 56
        }
    }

    var radius: CGFloat {
        return computeHeight/2
    }
}
