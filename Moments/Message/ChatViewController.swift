//
//  ChatViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 3/13/19.
//  Copyright © 2019 PTV. All rights reserved.
//
/*
 1 - Send a text message - locally - x
 2 - Save message to firebase - x
 3 - Download and observe messages
 4 - Fetch messages to ChatVC
 */

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {
    
    var chat: Chat!
    var currentUser: User!
    
    var messageRef = FIRDatabaseReference.messages.reference()
    
    var message = [Message]()
    var jsqMessages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var outgoingAvatarView: JSQMessagesAvatarImage!
    var incomingAvatarView: JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = chat.title
        self.setupBubbleImages()
        self.setupAvatarImages()
        
        let backButton = UIBarButtonItem(image: UIImage(named: "icon-back"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.observeMessages()
        
    }
    
    @objc func back(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Avatar
    func setupBubbleImages()
    {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    func setupAvatarImages()
    {
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 32.0, height: 32.0)
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 32.0, height: 32.0)
        
        let defaultProfileImage: UIImage! = UIImage(named: "icon-defaultAvatar")
        self.outgoingAvatarView = JSQMessagesAvatarImage.avatar(with: defaultProfileImage)
        self.incomingAvatarView = JSQMessagesAvatarImage.avatar(with: defaultProfileImage)
        
        self.currentUser.downloadProfilePicture { (image, error) in
            if let image = image {
                self.outgoingAvatarView = JSQMessagesAvatarImage.avatar(with: image)
            }
            
            self.errorReport(error: error)
        }
    }
    
    func errorReport(error: Error!)
    {
        if error != nil {
            print("Error: failed to download avatar image - \(error.localizedDescription)")
        }
    }
    
}

// MARK: - JSQMessagesViewController DataSource (Collection View DataSource)

extension ChatViewController
{
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return jsqMessages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsqMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let jsqMessage = jsqMessages[indexPath.item]

        if jsqMessage.senderId == self.senderId {
            cell.textView.textColor = UIColor.white
        } else {
            cell.textView.textColor = UIColor.black
        }

        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let jsqMessage = jsqMessages[indexPath.item]
        
        if jsqMessage.senderId == self.senderId
        {
            return outgoingBubbleImageView
            
        } else {
            return incomingBubbleImageView
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        let jsqMessage = jsqMessages[indexPath.item]
        
        if jsqMessage.senderId == self.senderId {
            return outgoingAvatarView
            
        } else {
            self.setupIncomingAvatar(user: chat.users, jsqMessage: jsqMessage)
            return incomingAvatarView
        }
    }
    
    private func setupIncomingAvatar(user: [User], jsqMessage: JSQMessage)
    {
        for user in chat.users {
            if jsqMessage.senderId == user.uid
            {
                user.downloadProfilePicture { (image, error) in
                    if let image = image {
                         self.incomingAvatarView = JSQMessagesAvatarImage.avatar(with: image)
                    }
                    
                    self.errorReport(error: error)
                }
            }
        }
    }
    
}

// MARK: - Send Messages

extension ChatViewController
{
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        if chat.messageIds.count == 0
        {
            chat.save()
            for user in chat.users {
                user.save(new: chat)
            }
            
            let newMessage = createNewMessage(user: self.currentUser, text: text)
            chat.send(message: newMessage)
        
        } else {
            let newMessage = createNewMessage(user: self.currentUser, text: text)
            chat.addMessageId(chat: chat, message: newMessage)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    func createNewMessage(user: User, text: String) -> Message
    {
        let newMessage = Message(senderDisplayName: user.username, senderUID: user.uid, type: MessageType.text, text: text)
        newMessage.save()
        
        return newMessage
    }
}

extension ChatViewController
{
    private func observeMessages()
    {
        let chatMessageIdsRef = chat.ref.child("messageIds")
        chatMessageIdsRef.observe(DataEventType.childAdded) { (snapshot) in
            let messageId = snapshot.value as! String
            
            FIRDatabaseReference.messages.reference().child(messageId).observe(DataEventType.value, with: { (dataSnapshot) in
                let message = Message(dictionary: dataSnapshot.value as! [String : Any])
                self.message.append(message)
                self.add(message)
                self.finishReceivingMessage()
            })
            
        }
    }
    
    private func add(_ message: Message )
    {        
        if message.type == MessageType.text
        {
            let jsqMessage = JSQMessage(senderId: message.senderUID, displayName: message.senderDisplayName, text: message.text)
            jsqMessages.append(jsqMessage!)
        }
    }
}



