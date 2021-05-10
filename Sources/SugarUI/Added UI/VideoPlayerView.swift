import SwiftUI
import Sugar
import AVFoundation
//https://github.com/ChrisMash/AVPlayer-SwiftUI/blob/master/AVPlayer-SwiftUI/VideoView.swift

class VideoPlayerUIView: UIView {
    private let player: AVPlayer
    private let playerLayer = AVPlayerLayer()
    private let videoPos: Binding<Double>
    private let videoDuration: Binding<Double>
    private let seeking: Binding<Bool>
    private var durationObservation: NSKeyValueObservation?
    private var timeObservation: Any?

    init(player: AVPlayer, videoPos: Binding<Double>, videoDuration: Binding<Double>, seeking: Binding<Bool>) {
        self.player = player
        self.videoDuration = videoDuration
        self.videoPos = videoPos
        self.seeking = seeking

        super.init(frame: .zero)

        backgroundColor = UIColor(named: "primary")
        playerLayer.player = player
        layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspectFill

        // Observe the duration of the player's item so we can display it
        // and use it for updating the seek bar's position
        durationObservation = player.currentItem?.observe(\.duration, changeHandler: { [weak self] item, change in
            guard let self = self else { return }
            self.videoDuration.wrappedValue = item.duration.seconds
        })

        // Observe the player's time periodically so we can update the seek bar's
        // position as we progress through playback
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self else { return }
            // If we're not seeking currently (don't want to override the slider
            // position if the user is interacting)
            guard !self.seeking.wrappedValue else {
                return
            }

            // update videoPos with the new video time (as a percentage)
            self.videoPos.wrappedValue = time.seconds / self.videoDuration.wrappedValue
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        playerLayer.frame = bounds
    }

    func cleanUp() {
        // Remove observers we setup in init
        durationObservation?.invalidate()
        durationObservation = nil

        if let observation = timeObservation {
            player.removeTimeObserver(observation)
            timeObservation = nil
        }
    }

}

// This is the SwiftUI view which wraps the UIKit-based PlayerUIView above
struct VideoPlayerContainerView: UIViewRepresentable {
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool

    let player: AVPlayer

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoPlayerContainerView>) {
        // This function gets called if the bindings change, which could be useful if
        // you need to respond to external changes
    }

    func makeUIView(context: UIViewRepresentableContext<VideoPlayerContainerView>) -> UIView {
        VideoPlayerUIView(player: player,
                                       videoPos: $videoPos,
                                       videoDuration: $videoDuration,
                                       seeking: $seeking)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        guard let playerUIView = uiView as? VideoPlayerUIView else {
            return
        }

        playerUIView.cleanUp()
    }
}

// This is the SwiftUI view that contains the controls for the player
struct VideoPlayerControlsView : View {
    internal init(
        videoPos: Binding<Double>,
        videoDuration: Binding<Double>,
        seeking: Binding<Bool>,
        player: AVPlayer) {
        self._videoPos = videoPos
        self._videoDuration = videoDuration
        self._seeking = seeking
        self.player = player
    }

    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool

    let player: AVPlayer

    @State private var playerPaused = true

    var body: some View {
        HStack {
            // Play/pause button
            Button(action: togglePlayPause) {
                ButtonTheme
                    .makeInnerBody(
                        model: .image(
                            Image(systemName: playerPaused ? "play" : "pause")
                        )
                    )
            }
            .buttonStyle(
                ButtonTheme(
                    size: ButtonTheme.Size.init(width: .fixed, height: .small),
                    style: .outline
                )
            )
            // Current video time
            Text("\(formatSecondsToHMS(videoPos * videoDuration))")
            // Slider for seeking / showing video progress
            Slider(value: $videoPos, in: 0...1, onEditingChanged: sliderEditingChanged)
            // Video duration
            Text("\(formatSecondsToHMS(videoDuration))")
        }
        .font(Font(.caption1))
        .foregroundColor(Color(.secondary))
    }

    private func togglePlayPause() {
        pausePlayer(!playerPaused)
    }

    private func pausePlayer(_ pause: Bool) {
        playerPaused = pause
        if playerPaused {
            player.pause()
        }
        else {
            player.play()
        }
    }

    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            // Set a flag stating that we're seeking so the slider doesn't
            // get updated by the periodic time observer on the player
            seeking = true
            pausePlayer(true)
        }

        // Do the seek if we're finished
        if !editingStarted {
            let targetTime = CMTime(seconds: videoPos * videoDuration,
                                    preferredTimescale: 600)
            player.seek(to: targetTime) { _ in
                // Now the seek is finished, resume normal operation
                self.seeking = false
                self.pausePlayer(false)
            }
        }
    }

    func formatSecondsToHMS(_ seconds: Double) -> String {
        guard !seconds.isNaN,
              let text = DateFormatters.timeHMSFormatter.string(from: seconds) else {
            return "00:00"
        }

        return text
    }
}

// This is the SwiftUI view which contains the player and its controls
public struct VideoPlayerView : View {
    public enum ControlsStyle {
        case underPlayer
        case overlay
    }

    // The progress through the video, as a percentage (from 0 to 1)
    @State private var videoPos: Double = 0
    // The duration of the video in seconds
    @State private var videoDuration: Double = 0
    // Whether we're currently interacting with the seek bar or doing a seek
    @State private var seeking = false

    private let player: AVPlayer
    private let style: ControlsStyle
    public init(url: URL, style: ControlsStyle = .overlay) {
        player = AVPlayer(url: url)
        self.style = style
    }

    public var body: some View {
        Group {
            switch style {
            case .underPlayer:
                VStack {
                    videoPlayer
                    VideoPlayerControlsView(videoPos: $videoPos,
                                            videoDuration: $videoDuration,
                                            seeking: $seeking,
                                            player: player)
                }
            case .overlay:
                videoPlayer.overlay(
                    VStack {
                        Spacer()
                        VideoPlayerControlsView(videoPos: $videoPos,
                                                videoDuration: $videoDuration,
                                                seeking: $seeking,
                                                player: player)
                            .padding(8)
                    }
                )
            }
        }
    }

    var videoPlayer: some View {
        VideoPlayerContainerView(videoPos: $videoPos,
                        videoDuration: $videoDuration,
                        seeking: $seeking,
                        player: player)        
    }
}
