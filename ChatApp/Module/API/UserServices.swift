//
//  UserServices.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 28/01/24.
//

import Foundation

struct UserServices {
    static func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
}
