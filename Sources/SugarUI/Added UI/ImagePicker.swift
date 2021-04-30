import SwiftUI
import Sugar

public enum MediaType {
    case movie(block: (URL) -> Void)
    case image(block: (UIImage) -> Void)

    var rawValue: String {
        switch self {
        case .image:
            return "public.image"
        case .movie:
            return "public.movie"
        }
    }
}

public struct ImagePickerView: UIViewControllerRepresentable {
    public init(sourceType: UIImagePickerController.SourceType, type: MediaType, isPresented: Binding<Bool>) {
        self.sourceType = sourceType
        self.type = type
        _isPresented = isPresented
    }

    let sourceType: UIImagePickerController.SourceType
    let type: MediaType
    @Binding var isPresented: Bool

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.mediaTypes = [type.rawValue]
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            type: type,
            onDismiss: { self.isPresented.toggle() }
        )
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        let type: MediaType
        private let onDismiss: Action

        init(type: MediaType, onDismiss: @escaping Action) {
            self.type = type
            self.onDismiss = onDismiss
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            switch type {
            case .image(let block):
                if let image = info[.originalImage] as? UIImage {
                    block(image)
                }
            case .movie(let block):
                if let url = info[.mediaURL] as? URL {
                    block(url)
                }
            }

            self.onDismiss()
        }

        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }

    }

}
