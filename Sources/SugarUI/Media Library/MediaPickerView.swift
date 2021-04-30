import SwiftUI
import Sugar
import Photos
import PhotosUI
import AVKit

struct MediaPickerView: View {

    init(assetType: MediaType, isPresented: Binding<Bool>) {
        let newRouter = MediaPickerRouter(isPresented: isPresented)
        presenter = MediaPickerPresenter(assetType: assetType, router: newRouter)
        router = newRouter
    }

    @ObservedObject var router: MediaPickerRouter
    @ObservedObject var presenter: MediaPickerPresenter

    var width: CGFloat {
        CGFloat(floor(UIScreen.main.bounds.width / 3))
    }
    
    var size: CGSize {
        return CGSize(width: width, height: width)
    }

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: width), spacing: 1, alignment: .top)]
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns) {
                ForEach(presenter.photoAssets) { asset in
                    MediaCell(asset: asset, size: size)
                }
            }
        }
        .onAppear {
            presenter.onAppear()
        }
        .navigationBarItems(
            trailing: Button(
                action: { presenter.requestPermission() },
                label: { ButtonTheme.makeInnerBody(model: .text("Request Permissions")) }
            )
        )
    }
}

class MediaPickerRouter: Router, ObservableObject {}

struct MediaPicker_Previews: PreviewProvider {
    static var previews: some View {
        MediaPickerView(assetType: .image(block: {_ in }), isPresented: .constant(true))
    }
}
