//
//  ContactTableViewCell.swift
//  Moments
//
//  Created by Tan Vinh Phan on 3/9/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell
{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var emailTextLabel: UILabel!
    
    var user: User! {
        didSet {
            self.updateUI()
        }
    }
    
    var added: Bool = false {
        didSet {
            if added == false {
                self.checkboxImageView.image = UIImage(named: "icon-checkbox")
            } else {
                self.checkboxImageView.image = UIImage(named: "icon-checkbox-filled")
            }
        }
    }
    
    func updateUI()
    {   if let user = user {
        self.displayNameLabel.text = user.username
        self.emailTextLabel.text = user.fullName
        self.checkboxImageView.image = UIImage(named: "icon-checkbox")
        
        user.downloadProfilePicture { (image, error) in
            if let image = image {
                self.profileImageView.image = image
                self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width / 2.0
                self.profileImageView.layer.masksToBounds = true
            }
        }
        }
    }
}












