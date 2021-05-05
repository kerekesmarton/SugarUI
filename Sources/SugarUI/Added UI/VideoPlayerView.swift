import Foundation
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    internal init(url: URL?, title: String) {
        self.title = title
        self.presenter = VideoPlayerPresenter(url: url)
    }

    var title: String

    @ObservedObject var presenter: VideoPlayerPresenter

    var body: some View {
        VideoPlayer(player: presenter.makePlayer) {
            VStack {
                    Spacer()
                    Text(title)
                        .foregroundColor(Color(.primary))
                        .background(Color.white.opacity(0.7))
                }
        }
        .scaledToFill()
        .onAppear {
            presenter.preBuffer()
        }
    }
}

class VideoPlayerPresenter: ObservableObject {
    init(url: URL?) {
        self.url = url
    }

    private var url: URL?

    var makePlayer: AVPlayer? {
        guard let url = url else { return nil }
        return player
    }

    lazy var player: AVPlayer = {
        return AVPlayer(url: url!)
    }()

    func preBuffer() {
        makePlayer?.automaticallyWaitsToMinimizeStalling = true
        makePlayer?.preroll(atRate: 1, completionHandler: { (ready) in
            <#code#>
        })
    }
}
