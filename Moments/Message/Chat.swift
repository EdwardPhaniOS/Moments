//
//  Chat.swift
//  Moments
//
//  Created by Tan Vinh Phan on 3/8/19.
//  Copyright © 2019 PTV. All rights reserved.
//
//Relax, you are doing fine

import Foundation
import Firebase

class Chat
{
    var uid: String
    var ref: DatabaseReference
    var users: [User]
    var lastMessage: String
    var lastUpdate: Double
    var lastSender: String
    var lastSenderUID: String
    var messageIds: [String]
    var title: String
    var featuredImageUID: String
    
    init(users: [User], title: String, featuredImageUID: String)
    {
        self.users = users
        self.title = title
        self.featuredImageUID = featuredImageUID
        self.lastUpdate = Date().timeIntervalSince1970
        self.messageIds = []
        self.lastMessage = ""
        self.lastSender = ""
        self.lastSenderUID = ""
        
        self.ref = FIRDatabaseReference.chats.reference().childByAutoId()
        self.uid = ref.key!
    }
    
    init(dictionary: [String : Any])
    {
        self.featuredImageUID = dictionary["featuredImageUID"] as! String
        self.lastMessage = dictionary["lastMessage"] as! String
        self.lastUpdate = dictionary["lastUpdate"] as! Double
        self.title = dictionary["title"] as! String
        self.lastSender = dictionary["lastSender"] as! String
        self.lastSenderUID = dictionary["lastSenderUID"] as! String
        
        self.users = []
        if let usersDict = dictionary["users"] as? [String : Any]
        {
            for (_ , userDict) in usersDict {
                let user = User(dictionary: userDict as! [String : Any])
                users.append(user)
            }
        }
        
        self.messageIds = []
        for (_, messageId) in dictionary["messageIds"] as! [String : Any] {
            self.messageIds.append(messageId as! String)
        }
        
        self.uid = dictionary["uid"] as! String
        self.ref = FIRDatabaseReference.chats.reference().child("\(uid)")
    }
    
    func save()
    {
        ref.setValue(toDictionary())
        
        let userRef = ref.child("users")
        for user in users {
            userRef.childByAutoId().setValue(user.toDictionary())
        }
        
        let messageIdsRef = ref.child("messageIds")
        for messageId in messageIds {
            messageIdsRef.childByAutoId().setValue(messageId)
        }
    }
    
    func toDictionary() -> [String : Any]
    {
        return
            [
                "uid" : uid,
                "lastMessage" : lastMessage,
                "lastUpdate" : lastUpdate,
                "lastSender" : lastSender,
                "lastSenderUID" : lastSenderUID,
                "title" : title,
                "featuredImageUID" : featuredImageUID
            ]
    }
}

extension Chat {
    func downloadFeaturedImage(completion: @escaping (UIImage?, Error?) -> Void)
    {
        FIRImage.downloadProfileImage(self.lastSenderUID) { (image, error) in
            completion(image, error)
        }
    }

    func send(message: Message)
    {
        self.messageIds.append(message.uid)
        self.lastMessage = message.text
        self.lastUpdate = Date().timeIntervalSince1970
        self.lastSender = message.senderDisplayName
        self.lastSenderUID = message.senderUID

        ref.child("lastUpdate").setValue(lastUpdate)
        ref.child("lastMessage").setValue(lastMessage)
        ref.child("lastSender").setValue(lastSender)
        ref.child("lastSenderUID").setValue(lastSenderUID)
        ref.child("messageIds").childByAutoId().setValue(message.uid)
    }
    
    func addMessageId(chat: Chat, message: Message)
    {
        self.messageIds.append(message.uid)
        self.lastMessage = message.text
        self.lastUpdate = Date().timeIntervalSince1970
        self.lastSender = message.senderDisplayName
        self.lastSenderUID = message.senderUID
        
        let refChat = chat.ref
        refChat.child("lastMessage").setValue(chat.lastMessage)
        refChat.child("lastUpdate").setValue(chat.lastUpdate)
        refChat.child("lastSender").setValue(chat.lastSender)
        refChat.child("lastSenderUID").setValue(chat.lastSenderUID)
        
        let count = chat.messageIds.count
        refChat.child("messageIds").childByAutoId().setValue(chat.messageIds[count - 1])
    }
}

extension Chat : Equatable {}

func == (lhs: Chat, rhs: Chat) -> Bool {
    return lhs.uid == rhs.uid
}





