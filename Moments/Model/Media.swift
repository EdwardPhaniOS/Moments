//
//  Media.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/4/19.
//  Copyright © 2019 PTV. All rights reserved.

import UIKit
import Firebase

class Media
{
    var uid: String
    let type: String  //"image" or "video"
    var caption: String
    var createdTime: Double
    var createdBy: User
    var likes: [User]
    var comments: [Comment]
    var mediaImage: UIImage!
    
    init(type: String, caption: String, createdBy: User, image: UIImage)
    {
        self.type = type
        self.caption = caption
        self.createdBy = createdBy
        self.mediaImage = image
        
        self.createdTime = Date().timeIntervalSince1970     //number of second from 1970 to now
        self.comments = []
        self.likes = []
        
        self.uid = FIRDatabaseReference.media.reference().childByAutoId().key!
    }
    
    init(dictionary: [String : Any])
    {
        self.uid = dictionary["uid"] as! String
        self.type = dictionary["type"] as! String
        self.caption = dictionary["caption"] as! String
        self.createdTime = dictionary["createdTime"] as! Double
        
        let createdByDict = dictionary["createdBy"] as! [String : Any]
        self.createdBy = User(dictionary: createdByDict)
        
        self.likes = []
        if let likesDict = dictionary["likes"] as? [String : Any]
        {
            for (_, userDict) in likesDict {
                if let userDict = userDict as? [String : Any] {
                    let user = User(dictionary: userDict)
                    likes.append(user)
                }
            }
        }
        
        self.comments = []
        if let comments = dictionary["comments"] as? [String : Any]
        {
            for (_, commentDict) in comments
            {
                if let commentDict = commentDict as? [String : Any] {
                    let comment = Comment(dictionary: commentDict)
                    self.comments.append(comment)
                }
            }
        }
    }
    
    func save(completion: @escaping (Error?) -> Void)
    {
        let ref = FIRDatabaseReference.media.reference().child(uid)
        ref.setValue(toDictionary())
        
        // Save Likes
        for like in likes {
            ref.child("likes/\(like.uid)").setValue(like.toDictionary())
        }
        
        // Save Comments
        for comment in comments {
            ref.child("comments/\(comment.uid)").setValue(comment.toDictionary())
        }
        
        // Upload Image to storage database (it takes sometime)
        let firImage = FIRImage(image: self.mediaImage)
        firImage.save(self.uid) { (error) in
            completion(error)
        }
        
    }
    
    func toDictionary() -> [String : Any]
    {
        return
            [
                "uid" : uid,
                "type" : type,
                "caption" : caption,
                "createdTime" : createdTime,
                "createdBy" : createdBy.toDictionary()
        ]
    }
    
}

extension Media
{
    func downloadMedia(completion: @escaping (UIImage?, Error?) -> Void)
    {
        FIRImage.downloadImage(self.uid) { (uiImage, error) in
            completion(uiImage, error)
        }
    }
   
    class func observeNewMedia(_ completion: @escaping (Media) -> Void)
    {
        FIRDatabaseReference.media.reference().observe(.childAdded) { (dataSnapshot) in
            let mediaDict = dataSnapshot.value as! [String : Any]
            let media = Media(dictionary: mediaDict)
            
            completion(media)
        }
    }
        
    func observeNewComment(_ completion: @escaping (Comment) -> Void)
    {
        FIRDatabaseReference.media.reference().child("\(uid)/comments").observe(.childAdded) { (dataSnapShot) in
            let comment = Comment(dictionary: dataSnapShot.value as! [String : Any])
            completion(comment)
            
        }
    }
    
    func likedBy(user: User)
    {
        self.likes.append(user)
        let ref = FIRDatabaseReference.media.reference().child("\(uid)/likes/\(user.uid)")
        
        ref.setValue(user.toDictionary())
    }
    
    func unlikedBy(user: User)
    {
        if let firstIndex = likes.firstIndex(of: user) {
            self.likes.remove(at: firstIndex)
            let ref = FIRDatabaseReference.media.reference().child("\(uid)/likes/\(user.uid)")
            
            ref.setValue(nil)
        }
    }
}

extension Media : Equatable
{
    static func == (lhs: Media, rhs: Media) -> Bool {
        return lhs.uid == rhs.uid
    }
    
}
