//
//  ImagePickerHelper.swift
//  Moments
//
//  Created by Tan Vinh Phan on 1/27/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import MobileCoreServices

typealias ImagePickerHelperCompletion = ((UIImage?) -> Void)

class ImagePickerHelper: NSObject
{
    //action sheet, imagePickerController ==> viewController
    weak var viewController: UIViewController!
    var completion: ImagePickerHelperCompletion?
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, completion: ImagePickerHelperCompletion?)
    {
        self.viewController = viewController
        self.completion = completion
    
        super.init()
        
        self.showPhotoSourceSelection()
    }
    
    func showPhotoSourceSelection()
    {
        let actionSheet = UIAlertController(title: "Pick New Photo", message: "Would you like to open photos libarary or camera", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        { (action) in
            self.showImagePicker(sourceType: .camera)
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default)
        { (action) in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photosLibraryAction)
        actionSheet.addAction(cancelAction)

        viewController.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        
        viewController.present(imagePicker, animated: true, completion: nil)
    }
}

extension ImagePickerHelper : UIImagePickerControllerDelegate & UINavigationControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        viewController.dismiss(animated: true, completion: nil)
        completion!(image)
    }
}






