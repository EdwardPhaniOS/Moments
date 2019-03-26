//
//  LoginViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/2/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Login to Moments"
        
        emailTextField.becomeFirstResponder()
        emailTextField.delegate = self
        passwordTextField.delegate = self

    }

    @IBAction func loginDidTap()
    {
        if emailTextField.text != "" && passwordTextField.text != ""
        {
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            Auth.auth().signIn(withEmail: email, password: password) { (dataResult, error) in
                if let error = error {
                    self.alert(title: "Oops!", message: "\(error.localizedDescription)", buttonTitle: "OK")
                    
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        } else {
            alert(title: "Oops!", message: "Invalid email or password", buttonTitle: "OK")
        }
    
    }
    
    @IBAction func backDidTap(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func alert(title: String, message: String, buttonTitle: String)
    {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)

        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension LoginViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            
        }
        else if textField == passwordTextField
        {
            passwordTextField.resignFirstResponder()
            loginDidTap()
        }
        
        return true
    }
    
}


