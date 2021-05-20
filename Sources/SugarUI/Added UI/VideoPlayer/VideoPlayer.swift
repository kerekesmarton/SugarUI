import SwiftUI
import Sugar
import AVFoundation
import AVKit
import SFSymbols

public struct VideoPlayerView : View, Equatable {
    public static func == (lhs: VideoPlayerView, rhs: VideoPlayerView) -> Bool {
        lhs.presenter == rhs.presenter
    }

    public enum ControlsStyle {
        case underPlayer
        case overlay
    }

    @ObservedObject private var presenter: VideoPlayerPresenter
    private let style: ControlsStyle
    private let placeholder: Image?
    public init(url: URL, placeholder: Image? = nil, style: ControlsStyle = .overlay) {
        self.placeholder = placeholder
        self.style = style
        presenter = VideoPlayerPresenter(url: url)
    }

    public var body: some View {
        switch style {
        case .underPlayer:
            VStack {
                VideoPlayer(player: presenter.player)
                videoControls.padding(2)
            }
        case .overlay:
            VideoPlayer(player: presenter.player) {
                VStack {
                    Spacer()
                    videoControls
                        .padding(2)
                }
            }
        }
    }

    var videoControls: some View {
        HStack {
            Button(action: {
                presenter.rewindVideo(by: 10)
            }) {
                ButtonTheme
                    .makeInnerBody(
                        model: .image(Image(symbol: .gobackward10))
                    )
            }

            Button(action: {
                presenter.forwardVideo(by: 10)
            }) {
                ButtonTheme
                    .makeInnerBody(
                        model: .image(Image(symbol: .goforward10))
                    )
            }

            Spacer()
            Text("\(presenter.progress):\(presenter.total)")
        }
        .buttonStyle(
            ButtonTheme(
                size: ButtonTheme.Size.init(width: .fixed, height: .large),
                style: .outline
            )
        )
        .font(Font(.caption1))
        .foregroundColor(Color(.secondary))
    }
}

private class VideoPlayerPresenter: ObservableObject, Equatable {
    init(url: URL) {
        self.url = url
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        startObservingPlayer()
    }

    deinit {
        if let observation = stateObservation {
            observation.invalidate()
            stateObservation = nil
        }

        if let observation = timeObservation {
            player.removeTimeObserver(observation)
            timeObservation = nil
        }

        player.replaceCurrentItem(with: nil)
    }

    @Published var error: MediaError? = nil
    @Published var progress: String = ""
    @Published var total: String = ""
    let player: AVPlayer
    let playerItem: AVPlayerItem
    let url: URL

    private var stateObservation: NSKeyValueObservation?
    private var timeObservation: Any?

    private func startDurationObserving() {
        guard timeObservation == nil else { return }

        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: nil) { [weak self] time in
            guard let duration = self?.playerItem.duration.seconds else {
                return
            }

            self?.progress = self?.formatSecondsToHMS(time.seconds) ?? ""
            self?.total = self?.formatSecondsToHMS(duration) ?? ""
        }
    }

    func startObservingPlayer() {
        stateObservation = playerItem.observe(\.status, changeHandler: { [weak self] item, change in
            switch item.status {
            case .readyToPlay:
                self?.startDurationObserving()
            case .failed:
                self?.error = .playbackFailed
            case .unknown:
                ()
            }
        })
    }

    func rewindVideo(by seconds: Float64) {
        let currentTime = player.currentTime()
        var newTime = CMTimeGetSeconds(currentTime) - seconds
        if newTime <= 0 {
            newTime = 0
        }
        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
    }

    func forwardVideo(by seconds: Float64) {
        let currentTime = player.currentTime()
        let duration = playerItem.duration
        var newTime = CMTimeGetSeconds(currentTime) + seconds
        if newTime >= CMTimeGetSeconds(duration) {
            newTime = CMTimeGetSeconds(duration)
        }
        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
    }

    func formatSecondsToHMS(_ seconds: Double) -> String {
        guard !seconds.isNaN,
              let text = DateFormatters.timeHMSFormatter.string(from: seconds) else {
            return "00:00"
        }

        return text
    }

    static func == (lhs: VideoPlayerPresenter, rhs: VideoPlayerPresenter) -> Bool {
        lhs.url == rhs.url
    }
}
