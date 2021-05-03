import Foundation
import Photos
import Sugar

extension PHAsset: Identifiable {}

protocol AssetDelegate: class {
    func didFinishPick()
}

public class Asset: ObservableObject, Identifiable, Hashable {

    enum RequestOptions {
        case list
        case detail
        case upload
    }

    @Published var image: UIImage? = nil
    @Published var video: AVPlayerItem? = nil
    @Inject var dispatch: Dispatching

    let options: RequestOptions
    let asset: PHAsset
    let type: MediaType
    var size: CGSize = CGSize(width: 120, height: 120)
    weak var delegate: AssetDelegate?

    init(asset: PHAsset, type: MediaType, options: RequestOptions, delegate: AssetDelegate?) {
        self.asset = asset
        self.type = type
        self.options = options
        self.delegate = delegate
    }

    private var manager = PHImageManager.default()

    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func request() {
        dispatch.block {
            switch self.type {
            case .image:
                let requestOptions = self.imageRequest(options: self.options)
                self.manager.requestImage(for: self.asset, targetSize: self.size, contentMode: .aspectFill, options: requestOptions) { [weak self] (image, info) in
                    self?.dispatch.dispatchMain {
                        self?.image = image
                    }
                }
            case .movie:
                let requestOptions = self.videoRequest(options: self.options)
                self.manager.requestPlayerItem(forVideo: self.asset, options: requestOptions) { [weak self] (item, options) in
                    self?.dispatch.dispatchMain {
                        self?.video = item
                    }
                }
            }
        }
    }

    func prepareForUpload() {
        dispatch.block {
            switch self.type {
            case .image(block: let block):
                let requestOptions = self.imageRequest(options: .upload)
                self.manager.requestImageDataAndOrientation(for: self.asset, options: requestOptions) { (data, identifier, orientation, options) in
                    guard let data = data, let image = UIImage(data: data) else {
                        return
                    }
                    self.dispatch.dispatchMain {
                        block(image)
                        self.delegate?.didFinishPick()
                    }
                }
            case .movie(block: let block):
                let requestOptions = self.videoRequest(options: .upload)
                self.manager.requestAVAsset(forVideo: self.asset, options: requestOptions) { (asset, audioMix, options) in
                    guard let asset = asset as? AVURLAsset else {
                        return
                    }
                    self.dispatch.dispatchMain {
                        block(asset.url)
                        self.delegate?.didFinishPick()
                    }
                }
            }
        }

    }



    private func imageRequest(options: RequestOptions) -> PHImageRequestOptions {

        let requestOptions = PHImageRequestOptions()
        switch options {
        case .list:
            requestOptions.deliveryMode = .fastFormat
            requestOptions.isNetworkAccessAllowed = false
            requestOptions.isSynchronous = false
        case .detail:
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.isSynchronous = false
        case .upload:
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.isSynchronous = false
        }
        return requestOptions
    }

    private func videoRequest(options: RequestOptions) -> PHVideoRequestOptions {
        let requestOptions = PHVideoRequestOptions()
        switch options {
        case .list:
            requestOptions.deliveryMode = .fastFormat
            requestOptions.isNetworkAccessAllowed = false
        case .detail:
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isNetworkAccessAllowed = true
        case .upload:
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isNetworkAccessAllowed = true
        }
        return requestOptions
    }
}

extension UIImage: ObservableObject {}
extension AVPlayerItem: ObservableObject {}
