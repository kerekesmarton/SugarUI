import SwiftUI
import PhotosUI

struct MediaPicker: UIViewControllerRepresentable {

    init(isPresented: Binding<Bool>, completion: @escaping (URL?) -> Void) {
        self.coordinator = Coordinator(isPresented: isPresented, completion: completion)
    }

    let coordinator: Coordinator

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .videos

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        coordinator
    }

    class Coordinator: Router, PHPickerViewControllerDelegate {
        init(isPresented: Binding<Bool>, completion: @escaping (URL?) -> Void) {
            self.completion = completion
            super.init(isPresented: isPresented)
        }
        let completion: (URL?) -> Void

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let itemProvider = results.first?.itemProvider else {
                self.dismiss()
                self.completion(nil)
                return
            }
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {//"public.mpeg-4"
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, err in
                    DispatchQueue.main.sync {
                        self.completion(url)
                        self.dismiss()
                    }
                }
            }
        }
    }
}
