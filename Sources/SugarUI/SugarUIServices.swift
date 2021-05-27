import Foundation
import Sugar

class SugarUIServices: ServiceProvider {
    var appTasks = [AppTask]()

    lazy var imageCache = LocalImageCache()
    func modules() -> [Register] {
        [
            Register(ImageStorage.self) { self.imageCache },
        ]
    }
}
