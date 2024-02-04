//
//  FileUploader.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 4/01/24.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage
import Factory

struct FileUploader {
    @Injected(\.auth) static private var auth: Auth
    @Injected(\.storage) static private var storage: Storage
    
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let imagedata = image.jpegData(compressionQuality: 0.75) else { return }
        
        let uid = auth.currentUser?.uid ?? "/profileImages/"
        let filename = NSUUID().uuidString
        let ref = storage.reference(withPath: "/\(uid)/\(filename)")
        ref.putData(imagedata, metadata: nil) { metadata, error in
            
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                
                if let error = error {
                    print("DEBUG: Failed to download image url \(error.localizedDescription)")
                    return
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                completion(imageUrl)
            }
            
        }
    }
}
