//
//  ChatTableViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 3/11/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController {
    
    var currentUser: User! {
        didSet {
            self.chats.removeAll()
            self.fetchInbox()
        }
    }
    var chats: [Chat] = []
    var selectedChat: Chat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup TableView
        title = "Inbox"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.delegate = self
        
        self.findCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.findCurrentUser()
    }
    
    private func findCurrentUser()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
        let navController = tabBarController.viewControllers?.first as! UINavigationController
        let newsfeedTVC = navController.topViewController as! NewsfeedTableViewController
        if let user = newsfeedTVC.currentUser {
            self.currentUser = user
        }
    }
    
    func fetchInbox()
    {
        let refUser = FIRDatabaseReference.users(uid: self.currentUser.uid).reference().child("chatIds")
        
        refUser.observe(.childAdded) { (snapshot) in
            let chatID = snapshot.key
            self.fetchChat(chatId: chatID)
        }
    }
    
    private func fetchChat(chatId: String)
    {
        let refChat = FIRDatabaseReference.chats.reference().child(chatId)
        refChat.observe(.value) { (snapshot) in
            let chatDictionary = snapshot.value as? [String : Any]
            if let chatDict = chatDictionary {
                let chat = Chat(dictionary: chatDict)
                
                if !self.chats.contains(chat) {
                    self.chats.insert(chat, at: 0)
                } else {
                    self.chats.removeFirst()
                    self.chats.insert(chat, at: 0)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    struct Storyboard {
        static let chatCell = "ChatCell"
        static let showContactPicker = "ShowContactPicker"
        static let showChatViewController = "ShowChatViewController"
        static let showPreviousChat = "ShowPreviousChat"
    }
    
    @IBAction func addDidTap(_ sender: Any) {
        self.performSegue(withIdentifier: Storyboard.showContactPicker, sender: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.chatCell, for: indexPath) as! ChatTableViewCell
        let newChat = self.chats[indexPath.row]
        cell.chat = newChat
        
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.selectedChat = self.chats[indexPath.row]
        self.performSegue(withIdentifier: Storyboard.showPreviousChat, sender: selectedChat)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  Storyboard.showPreviousChat {
            let chatVC = segue.destination as! ChatViewController
            
            let chat = sender as! Chat
            chatVC.chat = chat
            chatVC.currentUser = self.currentUser
            chatVC.senderId = currentUser.uid
            chatVC.senderDisplayName = currentUser.username
            chatVC.hidesBottomBarWhenPushed = true
        }
    }
    
}

