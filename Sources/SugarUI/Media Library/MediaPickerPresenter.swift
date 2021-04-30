import SwiftUI
import Sugar
import Photos
import PhotosUI

class MediaPickerPresenter: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {

    @Published var photoAssets = [Asset]()
    weak var router: Router?
    let assetType: MediaType
    var assets = PHFetchResult<PHAsset>()

    init(assetType: MediaType, router: Router) {
        self.assetType = assetType
        self.router = router

        super.init()
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func onAppear() {
        if hasPermissions {
            load()
        }
    }

    func requestPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .restricted, .denied:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url, options: [:]) { (result) in
                self.onAppear()
            }
            return
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { _ in
                self.onAppear()
            }
            return
        case .limited, .authorized:
            return
        }
    }

    private func load() {
        PHPhotoLibrary.shared().register(self)

        switch assetType {
        case .image:
            assets = PHAsset.fetchAssets(with: .image, options: nil)
        case .movie:
            assets = PHAsset.fetchAssets(with: .video, options: nil)
        }

        var _photoAssets = [Asset]()
        assets.enumerateObjects { (phAsset, index, stop) in
            let asset = Asset(asset: phAsset, type: self.assetType, options: .list, delegate: self)
            _photoAssets.append(asset)
        }

        DispatchQueue.main.async { [weak self] in
            self?.photoAssets = _photoAssets
        }
    }

    private var hasPermissions: Bool {
        PHPhotoLibrary.authorizationStatus() == .authorized
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if hasPermissions {
            load()
        }
    }
}


extension MediaPickerPresenter: AssetDelegate {
    func didFinishPick() {
        router?.dismiss()
    }
}
