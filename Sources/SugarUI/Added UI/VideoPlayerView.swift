import Foundation
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    internal init(url: URL, title: String) {
        self.title = title
        self.presenter = VideoPlayerPresenter(url: url)
    }

    var title: String

    @ObservedObject var presenter: VideoPlayerPresenter

    var body: some View {
        VideoPlayer(player: presenter.player) {
            VStack {
                Spacer()
                Text(title)
                    .foregroundColor(Color(.primary))
                    .background(Color.white.opacity(0.7))
                if presenter.showLoading {
                    makeLoadingView()
                }
            }
        }
        .scaledToFill()
        .onAppear {
            presenter.preBuffer()
        }
    }
}

class VideoPlayerPresenter: ObservableObject {
    init(url: URL) {
        self.url = url
    }

    private var url: URL

    @Published var showLoading = false

    lazy var player: AVPlayer = {
        return AVPlayer(url: url)
    }()

    func preBuffer() {
        player.automaticallyWaitsToMinimizeStalling = true
        player.preroll(atRate: 1, completionHandler: { (ready) in
            self.showLoading = !ready
        })
    }
}



struct VideoPlayerView_Previews: PreviewProvider {
    static let url = URL(string: "https://woopdo112648-dev.s3-eu-west-1.amazonaws.com/vid/vid.m3u8")!

    static var previews: some View {
        VideoPlayerView(url: url, title: "")
            .previewLayout(.fixed(width: 325, height: 250))
    }
}
