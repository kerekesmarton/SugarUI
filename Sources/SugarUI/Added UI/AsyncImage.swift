import SwiftUI
import Combine
import Foundation
import Sugar
import SDWebImageSwiftUI

public struct AsyncImage: View, Equatable {
    var model: AsyncImageModel?
    var placeholder: Image?
    @ObservedObject var presenter: AsyncImagePresenter

    public init(model: AsyncImageModel?, placeholder: Image?) {
        self.model = model
        self.placeholder = placeholder
        presenter = AsyncImagePresenter(media: model)
        presenter.load()
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
                VideoPlayerView(url: url)
            case .error:
                makePlaceholder()
            }
        }
    }

    public static func == (lhs: AsyncImage, rhs: AsyncImage) -> Bool {
        lhs.presenter == rhs.presenter
    }
}

class AsyncImagePresenter: ObservableObject, Equatable {
    enum Model {
        case loading
        case image(Image)
        case video(URL)
        case error(MediaError)
    }

    @Published var state: Model = .loading
    private let model: AsyncImageModel?
    @Inject private var downloader: ImageDownloading

    init(media: AsyncImageModel?) {
        self.model = media
    }

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

    private func loadVideo(_ model: AsyncImageModel) {
        downloader.videoUrl(model: model, quality: .medium) { (result) in
            switch result {
            case .success(let url):
                self.state = .video(url)
            case .failure(let error):
                self.state = .error(error)
            }
        }
    }

    func load() {
        guard let model = model else {
            state = .error(MediaError.empty)
            return
        }

        if model.isVideo {
            loadVideo(model)
        } else {
            loadImage(model)
        }

    }

    func cancel() {
        cancellable?.cancel()
    }

    static func == (lhs: AsyncImagePresenter, rhs: AsyncImagePresenter) -> Bool {
        lhs.model == rhs.model
    }
}
