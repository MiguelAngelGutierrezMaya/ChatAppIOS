//
//  User.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 28/01/24.
//

import Foundation

struct User {
    let email: String
    let fullname: String
    let profileImageURL: String
    let uid: String
    let username: String
    
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
    }
}
