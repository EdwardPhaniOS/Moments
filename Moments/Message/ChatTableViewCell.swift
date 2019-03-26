//
//  ChatTableViewCell.swift
//  Moments
//
//  Created by Tan Vinh Phan on 3/9/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import SAMCache

class ChatTableViewCell: UITableViewCell
{
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var titileLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    var chat: Chat! {
        didSet {
            self.updateUI()
        }
    }
    
    var cache = SAMCache.shared()
    
    func updateUI()
    {   if let chat = chat {
        titileLabel.text = chat.lastSender
        lastMessageLabel.text = chat.lastMessage
        
        self.featuredImageView.layer.cornerRadius = self.featuredImageView.bounds.width / 2.0
        self.featuredImageView.layer.masksToBounds = true
        self.featuredImageView.image = nil
        
        let lastIndex = chat.messageIds.count - 1
        let imageKey = "\(self.chat.messageIds[lastIndex])-profileImage"

        if let profileImage = cache?.image(forKey: imageKey) {
            self.featuredImageView.image = profileImage
        } else {
            chat.downloadFeaturedImage { (profileImage, error) in
                if let image = profileImage {
                    self.cache?.setImage(image, forKey: imageKey)
                    self.featuredImageView.image = image
                }
            }
        }
        }
    }
}
