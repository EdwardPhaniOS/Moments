//
//  PostComposerViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/7/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit

class PostComposerViewController: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var shareBarButtonItem: UIBarButtonItem!
    
    var image: UIImage!
    var imagePickerSourceType: UIImagePickerController.SourceType!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        textView.text = ""
        textView.becomeFirstResponder()
        textView.delegate = self
        
        shareBarButtonItem.isEnabled = false
        imageView.image = image
        
        tableView.allowsSelection = false
    }
    
    @IBAction func cancelDidTap()
    {
        textView.resignFirstResponder()
        self.textView.text = ""
        
        self.image = nil
        self.imageView.image = nil
        
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func shareDidTap(_ sender: Any)
    {
        if let image = image,
            let caption = textView.text
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
            let firstNavVC = tabBarController.viewControllers?.first as! UINavigationController
            let newsfeedTVC = firstNavVC.topViewController as! NewsfeedTableViewController
            let currentUser = newsfeedTVC.currentUser
            
            if let currentUser = currentUser
            {
                let newMedia = Media(type: "image", caption: caption, createdBy: currentUser, image: image)
                newMedia.save { (error) in
                    
                    if let error = error {
                        self.alert(title: "Oops!", message: error.localizedDescription, buttonTitle: "OK")
                        
                    } else {
                        currentUser.share(newMedia: newMedia)
                    }
                }
                
            }
        }
        
        self.cancelDidTap()
    }
    
    func alert(title: String, message: String, buttonTitle: String)
    {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension PostComposerViewController : UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView)
    {
        shareBarButtonItem.isEnabled = textView.text != ""
    }
}
