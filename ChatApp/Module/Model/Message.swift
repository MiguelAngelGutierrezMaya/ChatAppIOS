//
//  Message.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 17/04/24.
//

import FirebaseFirestoreInternal

import FirebaseAuth
import Factory

var auth: Auth {
    @Injected(\.auth) var auth
    return auth
}

struct Message {
    let text: String
    let fromId: String
    let toId: String
    let timestamp: Timestamp
    let username: String
    let fullname: String
    let profileImageUrl: String
    
    var isFromCurrentUser: Bool
    
    var chatPartnerID: String {
        return isFromCurrentUser ? toId : fromId
    }
    
    let new_msg: Int
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.username = dictionary["username"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
        self.isFromCurrentUser = fromId == auth.currentUser?.uid
        self.new_msg = dictionary["new_msg"] as? Int ?? 0
    }
}
