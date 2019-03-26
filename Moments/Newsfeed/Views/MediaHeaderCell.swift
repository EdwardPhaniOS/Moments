//
//  MediaHeaderCell.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/13/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import SAMCache

class MediaHeaderCell: UITableViewCell
{
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    var currentUser: User!
    var media: Media! {
        didSet{
            if currentUser != nil {
                self.updateUI()
            }
        }
    }
    
    var cache = SAMCache.shared()

    func updateUI()
    {
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2.0
        profileImage.layer.masksToBounds = true
        
        usernameButton.setTitle(media.createdBy.username, for: [])
        
        followButton.layer.cornerRadius = 2.0
        followButton.layer.borderWidth = 1.0
        followButton.layer.borderColor = followButton.tintColor.cgColor
        followButton.layer.masksToBounds = true
        
        profileImage.image = UIImage(named: "icon-defaultAvatar")
        
        let mediaCreatedBy = media.createdBy
        let imageKey = "\(mediaCreatedBy.uid)-profileImage"
        
        if let profileImage = cache?.image(forKey: imageKey) {
            self.profileImage.image = profileImage
        
        } else {
            mediaCreatedBy.downloadProfilePicture { (image, error) in
                
                if let profileImage = image
                {
                    self.cache?.setImage(profileImage, forKey: imageKey)
                    self.profileImage.image = profileImage
                }
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        if currentUser.uid == mediaCreatedBy.uid {
            followButton.isHidden = true
            
        } else if currentUser.follows.contains(mediaCreatedBy) == false {
            followButton.setTitle("Follow", for: [])
            
        } else {
            followButton.setTitle("Unfollow", for: [])
        }
    }
   
    @IBAction func followButtonDidTap(_ sender: Any)
    {
        let mediaCreatedBy = media.createdBy
        if currentUser.follows.contains(mediaCreatedBy) == false
        {
            currentUser.follow(user: mediaCreatedBy)
            mediaCreatedBy.isFollowedBy(user: currentUser)
            followButton.setTitle("Unfollow", for: [])
            
        } else {
            currentUser.unFollow(user: mediaCreatedBy)
            mediaCreatedBy.unFollowedBy(user: currentUser)
            followButton.setTitle("Follow", for: [])
        }
        
        self.updateUI()
    }
    
}
