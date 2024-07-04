//
//  UserViewModel.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 24/03/24.
//

import Foundation

struct UserViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    var username: String {
        return user.username
    }
    var profileImageUrl: URL? {
        return URL(string: user.profileImageURL)
    }
    
    init(user: User) {
        self.user = user
    }
}
