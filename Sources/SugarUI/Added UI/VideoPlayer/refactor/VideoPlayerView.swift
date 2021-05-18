//import SwiftUI
//import Sugar
//import AVFoundation
//import AVKit
//import SFSymbols
//
//public struct VideoPlayerView : View, Equatable {
//    public static func == (lhs: VideoPlayerView, rhs: VideoPlayerView) -> Bool {
//        lhs.presenter == rhs.presenter
//    }
//
//    public enum ControlsStyle {
//        case underPlayer
//        case overlay
//    }
//
//    @ObservedObject private var presenter: VideoPlayerPresenter
//    private let style: ControlsStyle
//    private let placeholder: Image?
//    public init(url: URL, placeholder: Image? = nil, style: ControlsStyle = .overlay) {
//        self.placeholder = placeholder
//        self.style = style
//        presenter = VideoPlayerPresenter(url: url)
//    }
//
//    public var body: some View {
//        switch style {
//        case .underPlayer:
//            VStack {
//                videoPlayer
//                videoControls
//            }
//        case .overlay:
//            ZStack {
//                videoPlayer
//                VStack {
//                    Spacer()
//                    videoControls
//                        .padding(8)
//                }
//            }
//        }
//    }
//
//    var videoPlayer: some View {
//        VideoPlayerContainerView(player: presenter.player, playerItem: presenter.playerItem)
//    }
//
//    var videoControls: some View {
//        HStack {
//            Button(action: {
//                presenter.togglePlayPause()
//            }) {
//                ButtonTheme
//                    .makeInnerBody(
//                        model: .toggle(isOn: presenter.isPlaying, active: Image(symbol: .pause), inactive: Image(symbol: .play))
//                    )
//            }
//            .buttonStyle(
//                ButtonTheme(
//                    size: ButtonTheme.Size.init(width: .fixed, height: .small),
//                    style: .outline
//                )
//            )
//
//            Text(presenter.progress)
////            ProgressView(value: presenter.videoPos)
//            Slider(value: $presenter.videoPos)
//            Text(presenter.total)
//        }
//        .font(Font(.caption1))
//        .foregroundColor(Color(.secondary))
//    }
//}
//
//private class VideoPlayerPresenter: ObservableObject, Equatable {
//    init(url: URL) {
//        self.url = url
//        playerItem = AVPlayerItem(url: url)
//        player = AVPlayer(playerItem: playerItem)
//        startObservingPlayer()
//    }
//
//    deinit {
//        if let observation = stateObservation {
//            observation.invalidate()
//            stateObservation = nil
//        }
//
//        if let observation = timeObservation {
//            player.removeTimeObserver(observation)
//            timeObservation = nil
//        }
//
//        player.replaceCurrentItem(with: nil)
//    }
//
//    @Published var videoPos: Double = 0
//    @Published var videoDuration: Double = 0
//    @Published var seeking: Bool = false
//    @Published var error: MediaError? = nil
//    @Published var progress: String = ""
//    @Published var total: String = ""
//    var durationReady = false
//    let player: AVPlayer
//    let playerItem: AVPlayerItem
//    let url: URL
//
//    private var stateObservation: NSKeyValueObservation?
//    private var timeObservation: Any?
//
//    private func startDurationObserving() {
//        guard timeObservation == nil else { return }
//
//        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: nil) { [weak self] time in
//            guard self?.seeking == false, let duration = self?.playerItem.duration.seconds else {
//                return
//            }
//
////            self?.videoDuration = duration
////            self?.videoPos = time.seconds / duration
////            self?.progress = self?.formatSecondsToHMS(time.seconds) ?? ""
////            self?.total = self?.formatSecondsToHMS(duration) ?? ""
//        }
//    }
//
//    func startObservingPlayer() {
//        stateObservation = playerItem.observe(\.status, changeHandler: { [weak self] item, change in
//            switch item.status {
//            case .readyToPlay:
//                self?.startDurationObserving()
//            case .failed:
//                self?.error = .playbackFailed
//            case .unknown:
//                ()
//            }
//        })
//    }
//
//    var isPlaying: Binding<Bool> {
//        .init { [weak self] in
//            self?.player.timeControlStatus == .playing
//        } set: { [weak self] value in
//            self?.pausePlayer(!value)
//        }
//    }
//
//    func togglePlayPause() {
//        pausePlayer(isPlaying.wrappedValue)
//    }
//
//    private func pausePlayer(_ pause: Bool) {
//        if pause {
//            player.pause()
//        }
//        else {
//            player.play()
//        }
//    }
//
//    private func sliderEditingChanged(editingStarted: Bool) {
//        if editingStarted {
//            seeking = true
//            pausePlayer(true)
//        }
//
//        // Do the seek if we're finished
//        if !editingStarted {
//            let targetTime = CMTime(seconds: videoPos * videoDuration,
//                                    preferredTimescale: 600)
//            player.seek(to: targetTime) { _ in
//                self.seeking = false
//                self.pausePlayer(false)
//            }
//        }
//    }
//
//    func rewindVideo(by seconds: Float64) {
//        let currentTime = player.currentTime()
//        var newTime = CMTimeGetSeconds(currentTime) - seconds
//        if newTime <= 0 {
//            newTime = 0
//        }
//        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
//
//    }
//
//    func forwardVideo(by seconds: Float64) {
//        let currentTime = player.currentTime()
//        if let duration = player.currentItem?.duration {
//            var newTime = CMTimeGetSeconds(currentTime) + seconds
//            if newTime >= CMTimeGetSeconds(duration) {
//                newTime = CMTimeGetSeconds(duration)
//            }
//            player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
//        }
//    }
//
//    static func == (lhs: VideoPlayerPresenter, rhs: VideoPlayerPresenter) -> Bool {
//        lhs.url == rhs.url
//    }
//
//    func formatSecondsToHMS(_ seconds: Double) -> String {
//        guard !seconds.isNaN,
//              let text = DateFormatters.timeHMSFormatter.string(from: seconds) else {
//            return "00:00"
//        }
//
//        return text
//    }
//
//}
