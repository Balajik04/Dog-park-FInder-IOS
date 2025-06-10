//
//  ProfilePhotoPicker.swift
//  dogtraffic
//
//  Created by Balaji on 6/8/25.
//

import SwiftUI
import PhotosUI

struct ProfilePhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: ProfilePhotoPicker
        
        init(_ parent: ProfilePhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    guard let self = self, let uiImage = image as? UIImage else { return }
                    
                    DispatchQueue.main.async {
                        self.parent.selectedImageData = uiImage.jpegData(compressionQuality: 0.8)
                    }
                }
            }
        }
    }
}
