//
//  SignupTableViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 1/27/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import Firebase

class SignupTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var imagePickerHelper: ImagePickerHelper!
    var profileImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Create New Account"
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0
        profileImageView.layer.masksToBounds = true
        profileImageView.image = UIImage(named: "icon-defaultAvatar")
        
        emailTextField.delegate = self
        fullNameTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    @IBAction func createNewAccountDidTap()
    {   //TODO:
        //create a new account
        //save the user data, take photo
        //login the user
        
        if emailTextField.text != ""
            && (passwordTextField.text?.count)! >= 6
            && isPasswordValid(passwordTextField.text!) == true
            && (usernameTextField.text?.count)! >= 6
            && fullNameTextField.text != ""
            && profileImage != nil
        {
            let fullName = fullNameTextField.text!
            let email = emailTextField.text!
            let username = usernameTextField.text!
            let password = passwordTextField.text!
            
            //create a new account
            Auth.auth().createUser(withEmail: email, password: password) { (dataResult, error) in
                if error != nil {
                    self.errorAlert(title: "Oops!", message: (error?.localizedDescription)!)
                    
                } else if let result = dataResult {
                    let newUser = User(uid: result.user.uid, username: username, fullName: fullName, bio: "", website: "", follows: [], followedBy: [], profileImage: self.profileImage)
                    
                    //save the user data
                    newUser.save(completion: { (error) in
                        if error != nil {
                            self.errorAlert(title: "Oops!", message: (error?.localizedDescription)!)
                            
                        } else {
                            //login User
                            Auth.auth().signIn(withEmail: email, password: password, completion: { (dataResult, error) in
                                if let error = error {
                                    self.errorAlert(title: "Oops!", message: error.localizedDescription)
                                    
                                } else {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        }
                    })
                }
            }
        }
            
        else if emailTextField.text == ""
            || (usernameTextField.text?.count)! < 6
            || fullNameTextField.text == ""
            || profileImage == nil
        {
            self.errorAlert(title: "Invalid information", message: "Please check your username, full name, email address and profile image")
        }
            
        else if isPasswordValid(passwordTextField.text!) == false
        {
            self.errorAlert(title: "Invalid password", message: "Password length is more than 6 characters and the password must have one special character (!,@,#,...) and one alphabet character (a - z)")
        }
    }
    
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,}")
        return passwordTest.evaluate(with: password)
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeProfilePhotoDidTap()
    {
        //        imagePickerHelper = ImagePickerHelper(viewController: self, completion: { (image) in
        //            self.profileImageView.image = image
        //            self.profileImage = image
        //        })
        
        imagePickerHelper = ImagePickerHelper(viewController: self, completion: { (image) in
            self.profileImage  = image
            self.profileImageView.image = image
        })
    }
}

extension SignupTableViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            fullNameTextField.becomeFirstResponder()
            
        } else if textField == fullNameTextField {
            usernameTextField.becomeFirstResponder()
            
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
            
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            createNewAccountDidTap()
        }
        
        return true
    }
}
