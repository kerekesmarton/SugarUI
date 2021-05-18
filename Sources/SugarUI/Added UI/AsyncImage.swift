import SwiftUI
import Combine
import Foundation
import Sugar
import SDWebImageSwiftUI

public struct AsyncImage: View, Equatable {
    var model: AsyncImageModel?
    let placeholder: Image?
    let format: AsyncImageModel.VideoQuality
    @StateObject var presenter = AsyncImagePresenter()

    public init(model: AsyncImageModel?, format: AsyncImageModel.VideoQuality, placeholder: Image?) {
        self.model = model
        self.placeholder = placeholder
        self.format = format
    }
    
    private func makePlaceholder() -> some View {
        Group {
            if let placeholder = placeholder {
                placeholder
                    .resizable()
                    .scaledToFill()
            } else {
                Color(.secondary)
            }
        }
    }

    public var body: some View {
        Group {
            switch presenter.state {
            case .loading:
                ActivityIndicator(isAnimating: .constant(true), style: .large)
                    .transition(.opacity)
                    .scaledToFill()
            case .image(let image):
                image
                    .resizable()
                    .transition(.fade(duration: 0.2)) // Fade Transition with duration
                    .scaledToFill()
            case .video(let url):
                VideoPlayerView(url: url, style: .underPlayer)
            case .error:
                makePlaceholder()
            }
        }
        .onAppear {
            guard let model = model else {
                presenter.loadPlaceholder()
                return
            }
            presenter.load(model: model, format: format)
        }
    }

    public static func == (lhs: AsyncImage, rhs: AsyncImage) -> Bool {
        lhs.model == rhs.model
    }
}

class AsyncImagePresenter: ObservableObject {
    enum State {
        case loading
        case image(Image)
        case video(URL)
        case error(MediaError)
    }

    @Published var state: State = .loading
    @Inject private var downloader: ImageDownloading

    deinit {
        cancel()
    }

    private var cancellable: AnyCancellable?

    private func loadImage(_ model: AsyncImageModel) {
        downloader.download(model: model) { (progress) in
            print(progress)
        } completion: { (result) in

            guard let image = try? result.get() else {
                self.state = .error(MediaError.empty)
                return
            }
            self.state = .image(Image(uiImage: image))
        }
    }

    private func loadVideo(_ model: AsyncImageModel, format: AsyncImageModel.VideoQuality) {
        downloader.videoUrl(model: model, quality: .xLarge) { (result) in
            switch result {
            case .success(let url):
                self.state = .video(url)
            case .failure(let error):
                self.state = .error(error)
            }
        }
    }

    func load(model: AsyncImageModel, format: AsyncImageModel.VideoQuality) {
        if model.isVideo {
            loadVideo(model, format: format)
        } else {
            loadImage(model)
        }
    }

    func loadPlaceholder() {
        state = .error(MediaError.empty)
    }

    func cancel() {
        cancellable?.cancel()
    }
}
