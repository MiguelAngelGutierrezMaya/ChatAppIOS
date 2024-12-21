//
//  MessageServices.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 9/04/24.
//

import Foundation
import FirebaseFirestoreInternal
import FirebaseAuth
import Factory

let RECENT_MESSAGE = "recent-message"

struct MessageServices {
    @Injected(\.auth) static private var auth: Auth
    
    static func fetchMessages(otherUser: User, completion: @escaping(([Message])-> Void)) {
        guard let uid = auth.currentUser?.uid else { return }
        
        var messages = [Message]()
        let query = COLLECTION_MESSAGES
            .document(uid)
            .collection(otherUser.uid)
            .order(by: "timestamp")
        
        query.addSnapshotListener { snapshot, error in
            guard let documentChanges = snapshot?.documentChanges.filter({
                $0.type == .added
            }) else { return }
            
            messages.append(contentsOf: documentChanges.map({
                Message(dictionary: $0.document.data())
            }))
            
            completion(messages)
        }
    }
    
    static func fetchRecentMessages(completion: @escaping([Message]) -> Void) {
        guard let uid = auth.currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES
            .document(uid)
            .collection(RECENT_MESSAGE)
            .order(
                by: "timestamp",
                descending: true
            )
        
        query.addSnapshotListener { snapshot, _ in
            guard let documentChanges = snapshot?.documentChanges else {return}
            let messages = documentChanges.map({
                Message(dictionary: $0.document.data())
            })
            completion(messages)
        }
    }
    
    static func uploadMessage(
        message: String = "",
        imageURl: String = "",
        videoUrl: String = "",
        currentUser: User,
        otherUser: User,
        unreadCount: Int,
        completion: ((Error?) -> Void)?
    ) {
        let dataFrom: [String: Any] = [
            "text": message,
            "fromId": currentUser.uid,
            "toId": otherUser.uid,
            "timestamp": Timestamp(date: Date()),
            "username": otherUser.username,
            "fullname": otherUser.fullname,
            "profileImageUrl": otherUser.profileImageURL,
            "new_msg": 0,
            "imageUrl": imageURl,
            "videoUrl": videoUrl
        ]
        
        let dataTo: [String: Any] = [
            "text": message,
            "fromId": currentUser.uid,
            "toId": otherUser.uid,
            "timestamp": Timestamp(date: Date()),
            "username": currentUser.username,
            "fullname": currentUser.fullname,
            "profileImageUrl": currentUser.profileImageURL,
            "new_msg": unreadCount,
            "imageUrl": imageURl,
            "videoUrl": videoUrl
        ]
        
        COLLECTION_MESSAGES
            .document(currentUser.uid)
            .collection(otherUser.uid)
            .addDocument(
                data: dataFrom
            ) { _ in
                COLLECTION_MESSAGES
                    .document(otherUser.uid)
                    .collection(currentUser.uid)
                    .addDocument(
                        data: dataTo,
                        completion: completion
                    )
                COLLECTION_MESSAGES
                    .document(currentUser.uid)
                    .collection(RECENT_MESSAGE)
                    .document(otherUser.uid)
                    .setData(dataFrom)
                COLLECTION_MESSAGES
                    .document(otherUser.uid)
                    .collection(RECENT_MESSAGE)
                    .document(currentUser.uid)
                    .setData(dataTo)
            }
    }
    
    static func fetchSingleRecentMessage(
        otherUser: User,
        completion: @escaping(Int) -> Void
    ) {
        guard let uid = auth.currentUser?.uid else {
            completion(0)
            return
        }
        
        COLLECTION_MESSAGES
            .document(otherUser.uid)
            .collection(RECENT_MESSAGE)
            .document(uid)
            .getDocument { snapshot, _ in
                guard let data = snapshot?.data() else {
                    completion(0)
                    return
                }
                
                let message = Message(dictionary: data)
                completion(message.new_msg)
            }
    }
    
    static func markReadAllMsg(otherUser: User) {
        guard let uid = auth.currentUser?.uid else { return }
        
        let dataUpdate: [String: Any] = [
            "new_msg": 0
        ]
        
        COLLECTION_MESSAGES
            .document(uid)
            .collection(RECENT_MESSAGE)
            .document(otherUser.uid)
            .updateData(dataUpdate)
    }
}
