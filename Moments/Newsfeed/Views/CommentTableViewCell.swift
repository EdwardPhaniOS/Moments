//
//  CommentTableViewCell.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/16/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell
{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var commentTextLabel: UILabel!
    
    var comment: Comment! {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI() -> Void
    {
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0
        profileImageView.layer.masksToBounds = true
        profileImageView.image = UIImage(named: "icon-defaultAvatar")
        
        comment.from.downloadProfilePicture { [weak self] (image, error) in
            if let image = image {
                self?.profileImageView.image = image
            }
            
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
        }
        
        commentTextLabel.text = comment.caption
        usernameButton.setTitle("\(comment.from.username)", for: [])
    }
    
}
