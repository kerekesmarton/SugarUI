import SwiftUI
import Sugar
import Photos
import PhotosUI
import AVKit
import SFSymbols

struct MediaCell: View {

    @ObservedObject var asset: Asset
    let size: CGSize
    init(asset: Asset, size: CGSize) {
        self.asset = asset
        self.size = size
        asset.request()
    }

    var body: some View {
        VStack {
            Group {
                asset.image.map { uiImage in
                    Image(uiImage: uiImage)
                        .resizable()
                        .transition(.fade(duration: 0.2)) // Fade Transition with duration
                        .scaledToFill()
                }

                asset.video.map { item in
                    VideoPlayer(player: AVPlayer(playerItem: item))
                        .scaledToFill()
                }
            }
            .frame(width: size.width, height: size.height, alignment: .center)
            .cornerRadius(8)
            
            Button {
                asset.prepareForUpload()
            } label: {
                ButtonTheme.makeInnerBody(model: .combine(text: "Use", image: Image(symbol: SFSymbol.plus)))
            }
            .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .small), style: .filled))
        }
    }
}
