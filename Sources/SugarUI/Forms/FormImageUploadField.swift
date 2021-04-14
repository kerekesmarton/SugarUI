import SwiftUI
import Sugar

public protocol UploadableMedia: Equatable {
    var id: String { get }
    var identityId: String { get }
}

public struct FormImageUploadField<T: UploadableMedia>: View, Equatable {
    public init(header: String, fileUploadResult: Binding<FileUploadResult<T>>) {
        self.header = header
        self._fileUploadResult = fileUploadResult
    }

    var header: String
    @Binding var fileUploadResult: FileUploadResult<T>

    @State private var pickerShown = false

    public var body: some View {
        Section(header: Text(header).font(Font(.title3)),
                footer:
                    Text(verbatim: fileUploadResult.error?.recoverySuggestion ?? "")
                        .foregroundColor(Color(.error))
                        .font(Font(.caption1))
        ) {
            VStack {
                HStack {
                    Text("Choose an image")

                    Spacer()

                    Button(action: {
                        self.pickerShown.toggle()
                    }, label: {
                        ButtonTheme.makeInnerBody(model: .image(Image(symbol: .cameraOnRectangle)))
                    })
                        .buttonStyle(ButtonTheme(size: .init(width: .fixed, height: .large), style: .filled))
                }
                .frame(height: 44)

                Group {
                    switch fileUploadResult {
                    case .success(let media), .existing(let media):
                        AsyncImage(
                            model: AsyncImageModel(id: media.id, identityId: media.identityId),
                            placeholder: nil
                        )
                    case .uploading(let progress):
                        HStack {
                            ProgressView(progress)
                            Text("Uploading")
                        }

                    case .picked(let image):
                        Image(uiImage: image)
                            .resizable()
                            .transition(.fade(duration: 0.2)) // Fade Transition with duration
                            .scaledToFill()
                    case .none, .error:
                        EmptyView()
                    }
                }
            }
            .sheet(isPresented: $pickerShown) {
                ImagePickerView(sourceType: .photoLibrary, isPresented: self.$pickerShown) { (image) in
                    self.fileUploadResult = .picked(image)
                }
            }
        }
    }

    public static func == (lhs: FormImageUploadField, rhs: FormImageUploadField) -> Bool {
        lhs.fileUploadResult == rhs.fileUploadResult
    }
}

extension FormImageUploadField {

    public enum FileUploadResult<T: Equatable>: Equatable {

        case success(T)
        case error(ServiceError)
        case uploading(Progress)
        case picked(UIImage)
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
