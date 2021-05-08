import SwiftUI
import Sugar

public protocol UploadableVideo: Equatable {
    var id: String { get }
    var identityId: String { get }
    var url: URL? { get }
}

public struct FormVideoUploadField<T: UploadableVideo>: View, Equatable {
    public init(header: String, fileUploadResult: Binding<FileUploadResult<T>>) {
        self.header = header
        self._fileUploadResult = fileUploadResult
    }

    var header: String
    @Binding var fileUploadResult: FileUploadResult<T>
    @ObservedObject var router = FormVideoUploadRouter(isPresented: .constant(false))

    public var body: some View {
        Section(header: Text(header).font(Font(.title3)),
                footer:
                    Text(verbatim: fileUploadResult.error?.recoverySuggestion ?? "")
                        .foregroundColor(Color(.error))
                        .font(Font(.caption1))
        ) {
            VStack {
                HStack {

                    Text("Choose a video")
                        .foregroundColor(Color(.primary))
                        .font(Font(.small))

                    Spacer()

                    Button(action: {
                        router.navigateTo(
                            MediaPickerView(assetType: .movie(block: { (url) in
                                self.fileUploadResult = .picked(url)
                            }), isPresented: router.isNavigating)
                        )
                    }, label: {
                        ButtonTheme.makeInnerBody(model: .image(Image(symbol: .cameraOnRectangle)))
                    })
                    .navigation(router)
                    .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .large), style: .filled))
                }
                .frame(height: 44)

                Group {
                    switch fileUploadResult {
                    case .success(let media), .existing(let media):
                        Group {
                            if let url = media.url {
                                VideoPlayerView(url: url)
                            } else {
                                makeErrorView(MediaError.empty)
                            }
                        }
                    case .uploading(let progress):
                        HStack {
                            ProgressView(progress)
                            Text("Uploading")
                        }

                    case .picked(let url):
                        VideoPlayerView(url: url)
                    case .none, .error:
                        EmptyView()
                    }
                }
            }            
        }
    }

    public static func == (lhs: FormVideoUploadField, rhs: FormVideoUploadField) -> Bool {
        lhs.fileUploadResult == rhs.fileUploadResult
    }
}

class FormVideoUploadRouter: Router, ObservableObject {}

extension FormVideoUploadField {

    public enum FileUploadResult<T: Equatable>: Equatable {

        case success(T)
        case error(ServiceError)
        case uploading(Progress)
        case picked(URL)
        case existing(T)
        case none

        public var uploaded: T? {
            guard case .success(let media) = self else {
                return nil
            }
            return media
        }

        public var error: ServiceError? {
            guard case .error(let error) = self else {
                return nil
            }
            return error
        }

        public mutating func set(_ progress: Progress) {
            switch self {
            case .error, .none, .uploading, .picked:
                self = .uploading(progress)
            case .existing, .success:
                return
            }
        }

        public static func == (lhs: FileUploadResult<T>, rhs: FileUploadResult<T>) -> Bool {
            return lhs.uploaded == rhs.uploaded
        }
    }
}
