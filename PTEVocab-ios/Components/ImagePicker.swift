//
//  ImagePicker.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 23/1/21.
//
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable{
    
    @Binding var image: UIImage?
    @Binding var chosen: Bool
    // Allow to dimiss the imagepicker once we done with picking.
    @Environment(\.presentationMode) var presentationMode
    
    
    func makeCoordinator() ->ImagePickerCoordinator {
        ImagePickerCoordinator(imagePicker: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
}

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    let imagePicker: ImagePicker
    
    init(imagePicker: ImagePicker){
        self.imagePicker = imagePicker
    }
    
    // When user cancel to choose the image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.presentationMode.wrappedValue.dismiss()
    }
    
    // When user choose the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.presentationMode.wrappedValue.dismiss()
        
        // Want to make sure we have access to the image - use guardz
        if let image = info[.editedImage] as? UIImage {
            print("Edited Image picked")
            imagePicker.image = UIImage(data: image.compress())
            imagePicker.chosen = true
        } else if let image = info[.originalImage] as? UIImage{
            print("Original Image picked")
            imagePicker.image = UIImage(data: image.compress())
            imagePicker.chosen = true
        } else {
            print("ImagePicker : No image found")
            return
        }
        
    }
}
