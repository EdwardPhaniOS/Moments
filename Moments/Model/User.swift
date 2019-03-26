//
//  User.swift
//  Moments
//
//  Created by Tan Vinh Phan on 1/22/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import Foundation
import Firebase

class User
{
    let uid: String
    var username: String
    var fullName: String
    var bio: String
    var website: String
    var profileImage: UIImage?
    
    var follows: [User]
    var followedBy: [User]
    
    //MARK: - Initializers
    
    init(uid: String, username: String, fullName: String, bio: String, website: String, follows: [User], followedBy: [User], profileImage: UIImage?)
    {
        self.uid = uid
        self.username = username
        self.fullName = fullName
        self.bio = bio
        self.website = website
        self.profileImage = profileImage
        self.follows = follows
        self.followedBy = followedBy
    }
    
    init(dictionary: [String : Any])
    {
        self.uid = dictionary["uid"] as! String
        self.username = dictionary["username"] as! String
        self.fullName = dictionary["fullName"] as! String
        self.bio = dictionary["bio"] as! String
        self.website = dictionary["website"] as! String
        
        follows = []
        if let followsDict = dictionary["follows"] as? [String : Any]
        {
            for (_, userDict) in followsDict {
                follows.append(User(dictionary: userDict as! [String : Any]))
            }
        }
        
        followedBy = []
        if let followedByDict = dictionary["followedBy"] as? [String : Any]
        {
            for (_, userDict) in followedByDict {
                follows.append(User(dictionary: userDict as! [String : Any]))
            }
        }
    }
    
    func save(completion: @escaping (Error?) -> Void) {
        let ref = FIRDatabaseReference.users(uid: uid).reference()
        ref.setValue(toDictionary())
        
        for user in follows {
            ref.child("follows/\(user.uid)").setValue(user.toDictionary())
        }
        
        for user in followedBy {
            ref.child("followedBy/\(user.uid)").setValue(user.toDictionary())
        }
        
        if let profileImage = self.profileImage
        {
            let firImage = FIRImage(image: profileImage)
            
            firImage.saveProfileImage(self.uid) { (error) in
                completion(error)
            }
        }
    }
    
    func toDictionary() -> [String : Any]
    {
        return
            [
                "uid" : uid,
                "username" : username,
                "fullName" : fullName,
                "bio" : bio,
                "website" : website,
            ]
    }
    
}

extension User
{
    func share(newMedia: Media)
    {
        FIRDatabaseReference.users(uid: self.uid).reference().child("media").childByAutoId().setValue(newMedia.uid)
    }
    
    func downloadProfilePicture(completion: @escaping (UIImage?, NSError?) -> Void)
    {
        FIRImage.downloadProfileImage(uid) { (image, error) in
            if let image = image {
                self.profileImage = image
                completion(image, error as NSError?)
            }
        }
    }
    
    func follow(user: User)
    {
        self.follows.append(user)
        let ref = FIRDatabaseReference.users(uid: uid).reference().child("follows/\(user.uid)")
        
        ref.setValue(user.toDictionary())
        
    }
    
    func unFollow(user: User)
    {
        if let firstIndex = follows.firstIndex(of: user) {
             follows.remove(at: firstIndex)
            let ref = FIRDatabaseReference.users(uid: uid).reference().child("follows/\(user.uid)")
            
            ref.setValue(nil)
        }
    }
    
    func isFollowedBy(user: User)
    {
        self.followedBy.append(user)
        let ref = FIRDatabaseReference.users(uid: uid).reference().child("followedBy/\(user.uid)")
        
        ref.setValue(user.toDictionary())
    }
    
    func unFollowedBy(user: User)
    {
        if let firstIndex = followedBy.firstIndex(of: user) {
            followedBy.remove(at: firstIndex)
            let ref = FIRDatabaseReference.users(uid: uid).reference().child("followedBy/\(user.uid)")
            
            ref.setValue(nil)
        }
    }
    
    func save(new chat: Chat)
    {
        FIRDatabaseReference.users(uid: self.uid).reference().child("chatIds/\(chat.uid)").setValue(true)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}

