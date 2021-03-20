import SwiftUI
import Additions
import SwiftUIPager

public struct ImageCarouselView: View {
    private var media: [AsyncImageModel]
    private var placeholder: Image?
    private var imageHeight: CGFloat
    @Binding var currentIndex: Int

    public init(media: [AsyncImageModel], placeholder: Image?, imageHeight: CGFloat, currentIndex: Binding<Int>) {
        self.media = media
        self.placeholder = placeholder
        self.imageHeight = imageHeight
        self._currentIndex = currentIndex
    }

    public var body: some View {
        Pager(page: $currentIndex, data: media, id: \.self, content: { item in
            AsyncImage(model: item, placeholder: placeholder)
        }).pagingPriority(.simultaneous)
    }
}
