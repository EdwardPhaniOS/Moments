//
//  ProfileViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/2/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
   
    @IBAction func logOutDidTap(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }

        self.tabBarController?.selectedIndex = 0
    }
    
}
