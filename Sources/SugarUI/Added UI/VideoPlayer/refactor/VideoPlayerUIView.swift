import Foundation
import AVFoundation
import SwiftUI
import AVKit

struct VideoPlayerContainerView: UIViewRepresentable {
    let view: VideoPlayerUIView
    let playerItem: AVPlayerItem

    init(player: AVPlayer, playerItem: AVPlayerItem) {
        self.playerItem = playerItem
        view = VideoPlayerUIView(player: player)
    }

    func updateUIView(_ uiView: VideoPlayerUIView, context: UIViewRepresentableContext<VideoPlayerContainerView>) {

    }

    func makeUIView(context: UIViewRepresentableContext<VideoPlayerContainerView>) -> VideoPlayerUIView {
        return view
    }
}

class VideoPlayerUIView: UIView {
    let playerLayer: AVPlayerLayer
    init(player: AVPlayer) {
        playerLayer = AVPlayerLayer(player: player)

        super.init(frame: .zero)
        layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
