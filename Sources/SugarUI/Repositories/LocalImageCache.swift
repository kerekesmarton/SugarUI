import Foundation
import Sugar
import SDWebImage

class LocalImageCache: ImageStorage {

    @Inject var dispatch: Dispatching
    
    init() {
        DispatchQueue.global().async {
            SDImageCache.shared.deleteOldFiles()
        }
    }

    func cachedImage(for model: AsyncImageModel, completion: @escaping (UIImage?) -> Void) {
        dispatch.block {
            guard let image = SDImageCache.shared.imageFromCache(forKey: model.id) else {
                completion(nil)
                return
            }
            completion(image)
        }
    }

    func store(_ data: Data, for model: AsyncImageModel, completion: @escaping Action) {
        guard let image = UIImage(data: data) else {
            return
        }

        SDImageCache.shared.store(image, forKey: model.id) {
            completion()
        }
    }

    func erase(_ block: @escaping Action) {
        dispatch.block {
            SDImageCache.shared.clear(with: .all) {
                block()
            }
        }
    }

    func downloadImage(with url: URL, completion: @escaping (UIImage?, Data?, Error?, Bool) -> Void) {
        SDWebImageDownloader.shared.downloadImage(with: url) { (image, data, error, finished) in
            completion(image, data, error, finished)
        }
    }
}
