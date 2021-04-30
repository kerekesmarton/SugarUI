import Foundation
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    var url: URL?
    var title: String

    private var player: AVPlayer? {
        guard let url = url else { return nil }
        return AVPlayer(url: url)
    }

    var body: some View {
        VideoPlayer(player: player) {
            VStack {
                    Spacer()
                    Text(title)
                        .foregroundColor(Color(.primary))
                        .background(Color.white.opacity(0.7))
                }
        }
        .scaledToFill()
    }
}
