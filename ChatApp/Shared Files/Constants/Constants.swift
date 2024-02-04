//
//  Constants.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 14/12/23.
//

import Firebase
import Factory
import FirebaseFirestore

var firestore: Firestore {
    @Injected(\.firestore) var firestore
    return firestore
}

let COLLECTION_USERS = firestore.collection("users")
