import SwiftUI
import Sugar
import SwiftUIPager

public struct ImageCarouselView: View {
    private var media: [AsyncImageModel]
    private var placeholder: Image?
    private var format: AsyncImageModel.VideoQuality
    @Binding var currentIndex: Int

    public init(media: [AsyncImageModel], placeholder: Image?, format: AsyncImageModel.VideoQuality, currentIndex: Binding<Int>) {
        self.media = media
        self.placeholder = placeholder
        self.format = format
        self._currentIndex = currentIndex
    }

    public var body: some View {
        Pager(page: .withIndex(currentIndex), data: media, id: \.self) { item in
            AsyncImage(model: item, format: format, placeholder: placeholder)
        }
        .pagingPriority(.simultaneous)
        .onPageChanged { (int) in
            self.currentIndex = int
        }
    }
}
