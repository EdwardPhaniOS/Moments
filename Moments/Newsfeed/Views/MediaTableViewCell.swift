//
//  MediaTableViewCell.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/14/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import SAMCache

protocol MediaTableViewCellDelegate: class
{
    func commentButtonDidTap(media: Media)
    
    func viewAllCommentDidTap(media: Media)
}

class MediaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var numberOfLikesButton: UIButton!
    @IBOutlet weak var viewAllCommentsButton: UIButton!
    
    var currentUser: User!
    var media: Media! {
        didSet {
            if currentUser != nil {
                self.updateUI()
            }
        }
    }
    
    var cache = SAMCache.shared()
    weak var delegate: MediaTableViewCellDelegate?
    
    func updateUI()
    {
        self.mediaImageView.image = nil
        let imageKey = "\(self.media.uid)-mediaImage"
        
        if let mediaImage = cache?.image(forKey: imageKey) {
            self.mediaImageView.image = mediaImage
        
        } else {
            media.downloadMedia { (image, error) in
                if let mediaImage = image {
                    self.cache?.setImage(mediaImage, forKey: imageKey)
                    self.mediaImageView.image = mediaImage
                }
                
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                }
            }
        }
        
        captionLabel.text = media.caption
        likeButton.setImage(UIImage(named: "icon-like"), for: [])
        
        let numberOfLike = media.likes.count
        if numberOfLike <= 1 {
            numberOfLikesButton.setTitle("❤️ \(numberOfLike) like", for: [])
            if media.likes.contains(currentUser) {
                likeButton.setImage(UIImage(named: "icon-like-filled"), for: [])
            }
            
        } else {
            numberOfLikesButton.setTitle("❤️ \(numberOfLike) likes", for: [])
        }
        
        
        let numberOfComments = media.comments.count
        if numberOfComments <= 1 {
            viewAllCommentsButton.setTitle("\(numberOfComments) comment", for: [])
            
        } else {
            viewAllCommentsButton.setTitle("View all \(numberOfComments) comments", for: [])
        }
        
    }
    
    @IBAction func likeDidTap()
    {
        if media.likes.contains(currentUser) {
            media.unlikedBy(user: currentUser)
            likeButton.setImage(UIImage(named: "icon-like"), for: [])
            
        } else {
            media.likedBy(user: currentUser)
            likeButton.setImage(UIImage(named: "icon-like-filled"), for: [])
        }
        
        self.updateUI()
    }
    
    @IBAction func commentDidTap()
    {
        delegate?.commentButtonDidTap(media: self.media)
    }
    
    @IBAction func shareDidTap()
    {
        
    }
    
    @IBAction func numberOfLikesDidTap()
    {
        
    }
    
    @IBAction func viewAllCommentsDidTap()
    {
        delegate?.viewAllCommentDidTap(media: self.media)
    }
}
