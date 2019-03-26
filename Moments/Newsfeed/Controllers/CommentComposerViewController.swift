//
//  CommentComposerViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/27/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit

class CommentComposerViewController: UIViewController
{
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
    
    var currentUser: User!
    var media: Media!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = postBarButtonItem
        navigationItem.title = "Share new comment"
        
        postBarButtonItem.isEnabled = false
        captionTextView.text = ""
        captionTextView.becomeFirstResponder()
        captionTextView.delegate = self
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0
        profileImageView.layer.masksToBounds = true
        
        if let currentUser = currentUser
        {
            self.usernameLabel.setTitle("\(currentUser.username)", for: [])
            
            if currentUser.profileImage == nil
            {
                profileImageView.image = UIImage(named: "icon-defaultAvatar")
                currentUser.downloadProfilePicture { (image, error) in
                    if let profileImage = image {
                        self.profileImageView.image = profileImage
                    }
                }
            
            } else {
                profileImageView.image = currentUser.profileImage
            }
        }
        
    }
    
    //MARK: - Target / Action
    
    @IBAction func postDidTap()
    {
        let comment = Comment(mediaUID: media.uid, from: currentUser, caption: captionTextView.text)
        comment.save()
        media.comments.append(comment)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CommentComposerViewController : UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView)
    {
        if textView.text == "" {
            postBarButtonItem.isEnabled = false

        } else {
            postBarButtonItem.isEnabled = true
        }
    }
}
