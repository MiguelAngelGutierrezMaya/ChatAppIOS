//
//  Firebase+Injection.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 4/01/24.
//

import Foundation
import Factory
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Firebase

extension Container {
    public var auth: Factory<Auth> {
        return Factory(self) {
            return Auth.auth()
        }.singleton
    }
    
    public var app: Factory<FirebaseApp?> {
        return Factory(self) {
            return FirebaseApp.app()
        }.singleton
    }
    
    public var firestore: Factory<Firestore> {
        return Factory(self) {
            return Firestore.firestore()
        }.singleton
    }
    
    public var storage: Factory<Storage> {
        return Factory(self) {
            return Storage.storage()
        }.singleton
    }
    
    public var phoneProvider: Factory<PhoneAuthProvider> {
        return Factory(self) {
            return PhoneAuthProvider.provider()
        }.singleton
    }
}
