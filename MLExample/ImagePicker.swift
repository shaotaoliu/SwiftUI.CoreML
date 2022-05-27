import UIKit
import SwiftUI

public struct ImagePicker: UIViewControllerRepresentable {
    
    public enum SourceType {
        case camera
        case library
    }
    
    @Environment(\.presentationMode) private var presentationMode
    @Binding private var selectedImage: UIImage?
    private var sourceType: UIImagePickerController.SourceType
    
    public init(sourceType: SourceType, selectedImage: Binding<UIImage?>) {
        
        switch sourceType {
        case .camera:
            self.sourceType = .camera
        case .library:
            self.sourceType = .photoLibrary
        }
        
        self._selectedImage = selectedImage
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
