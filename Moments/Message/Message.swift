//
//  Message.swift
//  Moments
//
//  Created by Tan Vinh Phan on 3/9/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import Foundation
import Firebase

public struct MessageType {
    static let text = "text"
    static let image = "image"
    static let video = "video"
}

class Message
{
    var ref: DatabaseReference
    let uid: String
    var senderUID: String
    var senderDisplayName: String
    var lastUpdate: Date
    var type: String
    var text: String

    init(senderDisplayName: String, senderUID: String, type: String, text: String)
    {
        self.ref = FIRDatabaseReference.messages.reference().childByAutoId()
        self.uid = ref.key!
        self.senderDisplayName = senderDisplayName
        self.senderUID = senderUID
        self.type = type
        self.text = text
        self.lastUpdate = Date()
    }
    
    init(dictionary: [String : Any])
    {
        self.uid = dictionary["uid"] as! String
        self.senderDisplayName = dictionary["senderDisplayName"] as! String
        self.senderUID = dictionary["senderUID"] as! String
        self.type = dictionary["type"] as! String
        self.text = dictionary["text"] as! String
        self.lastUpdate =
            Date(timeIntervalSince1970: dictionary["lastUpdate"] as! Double)
        self.ref = FIRDatabaseReference.messages.reference().child(uid)
    }
    
    func save()
    {
        ref.setValue(toDictionary())
    }
    
    func toDictionary() -> [String : Any]
    {
        return [
            "uid" : self.uid,
            "senderDisplayName" : self.senderDisplayName,
            "senderUID" : self.senderUID,
            "lastUpdate" : self.lastUpdate.timeIntervalSince1970,
            "type" : self.type,
            "text" : self.text
        ]
    }
}

extension Message : Equatable {
    static public func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.uid == rhs.uid
    }
}









