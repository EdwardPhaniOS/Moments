//
//  ContactPickerViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 3/10/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import Firebase
import VENTokenField

class ContactPickerViewController: UITableViewController
{
    struct Storyboard
    {
        static let contactCell = "ContactCell"
        static let showChatViewController = "ShowChatViewController"
    }
    
    var currentUser: User!
    var chats: [Chat]!
    var accounts = [User]()
    var selectedAccounts = [User]()
    
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var contactsPickerField: VENTokenField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup TableView
        title = "New Message"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = tableView.rowHeight
        
        //Current User
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
        let navController = tabBarController.viewControllers?.first as! UINavigationController
        let newsfeedTVC = navController.topViewController as! NewsfeedTableViewController
        if let user = newsfeedTVC.currentUser {
            self.currentUser = user
        }
        
        //Contacts Picker Field
        contactsPickerField.placeholderText = "Search..."
        contactsPickerField.setColorScheme(UIColor.blue)
        contactsPickerField.delimiters = [",", ";", "--"]
        contactsPickerField.toLabelTextColor = UIColor.black
        contactsPickerField.dataSource = self
        contactsPickerField.delegate = self
        
        self.fetchUser()
    }
    
    func fetchUser()
    {
        let refAccount = FIRDatabaseReference.users(uid: currentUser.uid).reference().child("follows")
        refAccount.observe(.childAdded) { (dataSnapShot) in
            let userDictionary = dataSnapShot.value as? [String : Any]
            if let userDict = userDictionary {
                let user = User(dictionary: userDict)
                
                self.accounts.insert(user, at: 0)
                
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.contactCell, for: indexPath) as! ContactTableViewCell
        let user = accounts[indexPath.row]
        
        cell.user = user
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell
        cell.added = !cell.added
        
        if cell.added == true {
            self.addRecipient(account: cell.user)
        } else {
            let firstIndex = selectedAccounts.firstIndex(of: cell.user)
            self.deleteRecipient(account: cell.user, index: firstIndex!)
        }
    }
    
    //MARK: - Helper Methods
    
    func addRecipient(account: User)
    {
        self.selectedAccounts.append(account)
        self.contactsPickerField.reloadData()
    }
    
    func deleteRecipient(account: User, index: Int)
    {
        self.selectedAccounts.remove(at: index)
        self.contactsPickerField.reloadData()
    }
    
    //MARK: Chat
    @IBAction func nextDidTap()
    {
        var chatAccounts = self.selectedAccounts
        chatAccounts.append(currentUser)
        
        if let chat = findChat(among: chatAccounts) {
            self.performSegue(withIdentifier: Storyboard.showChatViewController, sender: chat)
        } else {
            var title = ""
            for acc in chatAccounts {
                if title == "" {
                    title += "\(acc.fullName)"
                } else {
                    title += ", \(acc.fullName)"
                }
            }
            
            let newChat = Chat(users: chatAccounts, title: title, featuredImageUID: chatAccounts.first!.uid)
            self.performSegue(withIdentifier: Storyboard.showChatViewController, sender: newChat)
        }
    }
    
    func findChat(among chatAccounts: [User]) -> Chat?
    {
        if chats == nil {
            return nil
        }
        
        for chat in chats
        {
            var result = [Bool]()
            
            for user in chatAccounts {
                if chat.users.contains(user) {
                    result.append(true)
                } else {
                    result.append(false)
                }
            }
            
            if !result.contains(false) {
                return chat
            }
        }
        
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showChatViewController {
            let chat = sender as! Chat
            let chatVC = segue.destination as! ChatViewController
            chatVC.senderId = currentUser.uid
            chatVC.senderDisplayName = currentUser.username
            
            chatVC.chat = chat
            chatVC.currentUser = self.currentUser
            chatVC.hidesBottomBarWhenPushed = true
        }
    }
}

// MARK: - VENTokenFieldDataSource

extension ContactPickerViewController : VENTokenFieldDataSource
{
    func tokenField(_ tokenField: VENTokenField, titleForTokenAt index: UInt) -> String {
        return selectedAccounts[Int(index)].username
    }
    
    func numberOfTokens(in tokenField: VENTokenField) -> UInt {
        return UInt(selectedAccounts.count)
    }
}


// MARK: - VENTokenFieldDelegate

extension ContactPickerViewController : VENTokenFieldDelegate
{
    func tokenField(_ tokenField: VENTokenField, didEnterText text: String) {
        //
    }
    
    func tokenField(_ tokenField: VENTokenField, didDeleteTokenAt index: UInt) {
        let indexPath = IndexPath(row: Int(index), section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell
        self.deleteRecipient(account: cell.user, index: Int(index))
        cell.added = !cell.added
    }
}
