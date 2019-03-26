//
//  FIRImage.swift
//  Moments
//
//  Created by Tan Vinh Phan on 1/23/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import Foundation
import Firebase

class FIRImage
{
    var image: UIImage
    var downloadURL: URL?
    var downloadLink: String!
    var ref: StorageReference!
    
    init(image: UIImage)
    {
        self.image = image
    }
}

extension FIRImage
{
    func saveProfileImage(_ userUID: String, _ completion: @escaping (Error?) -> Void)
    {
        let resizedImage = image.resize()
        let imageJPEGData = resizedImage.jpegData(compressionQuality: 0.9)
        
        ref = FIRStorageReference.profileImages.reference().child(userUID)
        //rootRef/profileImage/user225
        
        downloadLink = ref.description
        
        ref.putData(imageJPEGData!, metadata: nil) { (metaData, error) in
            completion(error)
        }
    }
    
    func save(_ uid: String, completion: @escaping (Error?) -> Void)
    {
        
        let resizedImage = image.resize()
        let imageJPEGData = resizedImage.jpegData(compressionQuality: 0.9)
        
        ref = FIRStorageReference.images.reference().child(uid)
        // ~/images/uid
        
        downloadLink = ref.description
        
        ref.putData(imageJPEGData!, metadata: nil) { (metaData, error) in
            completion(error)
        }
    }
}

extension FIRImage
{
    class func downloadProfileImage(_ uid: String, _ completion: @escaping (UIImage?, Error?) -> Void)
    {
        let ref = FIRStorageReference.profileImages.reference().child(uid)
        ref.getData(maxSize: 1 * 1024 * 1024) { (dataImage, error) in
            
            if dataImage != nil && error == nil
            {
                let image = UIImage(data: dataImage!)
                completion(image, nil)
            } else
            {
                completion(nil, error)
            }
        }
    }

    class func downloadImage(_ uid: String, _ completion: @escaping (UIImage?, Error?) -> Void)
    {
        let ref = FIRStorageReference.images.reference().child(uid)
        ref.getData(maxSize: 1 * 1024 * 1024) { (dataImage, error) in
            if dataImage != nil && error == nil
            {
                let image = UIImage(data: dataImage!)
                completion(image, nil)
            } else
            {
                completion(nil, error)
            }
        }
    }
}

private extension UIImage
{
    func resize() -> UIImage
    {
        let ratio = self.size.width / self.size.height
        let height: CGFloat = 800.0
        let width = height * ratio
        
        let newSize = CGSize(width: width, height: height)
        let newRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: newRectangle)
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
}


