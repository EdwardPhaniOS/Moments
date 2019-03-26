//
//  FIRDatabaseReference.swift
//  Moments
//
//  Created by Tan Vinh Phan on 1/22/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import Foundation
import Firebase

enum FIRDatabaseReference
{
    case root
    case users(uid: String)
    case media                  //posts
    case chats
    case messages
    
    //MARK: - Public
    
    func reference() -> DatabaseReference {
        return rootRef.child(path)
    }
    
    private var rootRef: DatabaseReference {
        return Database.database().reference()
    }
    
    private var path: String {
        switch self {
        case .root:
            return ""
        case .users(let uid):
            return "users/\(uid)"
        case .media:
            return "media"
        case .chats:
            return "chats"
        case .messages:
            return "messages"
    }
}
}

enum FIRStorageReference {
    case root
    case images         //for post
    case profileImages  //for user
    
    func reference() -> StorageReference {
        return baseRef.child(path)
    }
    
    private var baseRef: StorageReference {
        return Storage.storage().reference()
    }
    
    private var path: String {
        switch self {
        case .root:
            return ""
        case .images:
            return "images"
        case.profileImages:
            return "profileImages"
        }
    }
}


