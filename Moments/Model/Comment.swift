//
//  Comment.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/11/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import Foundation
import Firebase

class Comment
{
    var mediaUID: String
    var uid: String
    var createdTime: Double
    var from: User
    var caption: String
    var ref: DatabaseReference
    
    init(mediaUID: String, from: User, caption: String)
    {
        self.mediaUID = mediaUID
        self.from = from
        self.caption = caption
        
        self.createdTime = Date().timeIntervalSince1970
        self.ref = FIRDatabaseReference.media.reference().child("\(mediaUID)/comments").childByAutoId()
        
        self.uid = ref.key!
    }
    
    init(dictionary: [String : Any])
    {
        self.mediaUID = dictionary["mediaUID"] as! String
        self.uid = dictionary["uid"] as! String
        self.createdTime = dictionary["createdTime"] as! Double
        self.caption = dictionary["caption"] as! String
        
        let fromDict = dictionary["from"] as! [String : Any]
        let user = User(dictionary: fromDict)
        self.from = user
        
        self.ref = FIRDatabaseReference.media.reference().child("\(mediaUID)/comments/\(uid)")
    }
    
    func save()
    {
        ref.setValue(toDictionary())
    }
    
    func toDictionary() -> [String : Any] {
        return
            [
                "mediaUID" : mediaUID,
                "uid" : uid,
                "createdTime" : createdTime,
                "from" : from.toDictionary(),
                "caption" : caption,
        ]
    }
}

extension Comment : Equatable
{
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    
}

