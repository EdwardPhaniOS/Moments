//
//  WelcomeViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 1/27/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //check if the user login or not
        Auth.auth().addStateDidChangeListener { (auth, firUser) in
            if let user = firUser {
                self.dismiss(animated: false, completion: nil)

            } else {

            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Auth.auth().addStateDidChangeListener { (auth, firUser) in
            if let user = firUser {
                self.dismiss(animated: false, completion: nil)
                
            } else {
                
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    

}
