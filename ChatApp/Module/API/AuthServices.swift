//
//  AuthServices.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 14/12/23.
//

import UIKit
import FirebaseAuth
import Factory

struct AuthCredentials {
    let email: String
    let fullname: String
    let password: String
    let username: String
    let profileImage: UIImage
}

struct AuthCredentialEmail {
    let email: String
    let fullname: String
    let uid: String
    let username: String
    let profileImage: UIImage
}

struct AuthServices {
    @Injected(\.auth) static private var auth: Auth
    
    static func loginUser(
        withEmail email: String,
        password: String,
        completion: @escaping(AuthDataResult?, Error?) -> Void
    ) {
        auth.signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(credential: AuthCredentials, completion: @escaping(Error?) -> Void) {
        FileUploader.uploadImage(image: credential.profileImage) { imageUrl in
            auth.createUser(
                withEmail: credential.email,
                password: credential.password
            ) { result, error in
                
                if let error = error {
                    return completion(error)
                }
                
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = [
                    "email": credential.email,
                    "fullname": credential.fullname,
                    "profileImageURL": imageUrl,
                    "uid": uid,
                    "username": credential.username
                ] as [String: Any]
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    static func registerWithGoogle(
        credential: AuthCredentialEmail,
        completion: @escaping(Error?) -> Void
    ) {
        FileUploader.uploadImage(image: credential.profileImage) { imageUrl in
            let data: [String: Any] = [
                "email": credential.email,
                "fullname": credential.fullname,
                "profileImageURL": imageUrl,
                "uid": credential.uid,
                "username": credential.username
            ] as [String: Any]
            
            COLLECTION_USERS.document(credential.uid).setData(data, completion: completion)
        }
    }
}
