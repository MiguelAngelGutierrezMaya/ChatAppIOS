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
import AVKit

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
    
    //MARK: - upload audio
    static func uploadAudio(audioURL: URL, completion: @escaping(String) -> Void) {
        let uid = auth.currentUser?.uid ?? "/audioFiles/"
        let filename = NSUUID().uuidString
        let ref = storage.reference(withPath: "/\(uid)/\(filename)")
        ref.putFile(from: audioURL, metadata: nil) { metadata, error in
            
            if let error = error {
                print("DEBUG: Failed to upload audio \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                
                if let error = error {
                    print("DEBUG: Failed to download audio url \(error.localizedDescription)")
                    return
                }
                
                guard let audioUrl = url?.absoluteString else { return }
                completion(audioUrl)
            }
        }
    }
    
    //MARK: - upload video
    static func uploadVideo(
        url: URL,
        success : @escaping (String) -> Void,
        failure : @escaping (Error) -> Void
    ) {
        
        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        let path = NSTemporaryDirectory() + name
        
        let dispatchgroup = DispatchGroup()
        
        dispatchgroup.enter()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputurl = documentsURL.appendingPathComponent(name)
        var ur = outputurl
        
        self.convertVideo(toMPEG4FormatForVideo: url as URL, outputURL: outputurl) { (session) in
            ur = session.outputURL!
            dispatchgroup.leave()
        }
        
        dispatchgroup.wait()
        
        let data = NSData(contentsOf: ur as URL)
        
        do {
            try data?.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            print(error)
        }
        
        let storageRef = storage.reference().child("Videos").child(name)
        if let uploadData = data as Data? {
            storageRef.putData(uploadData, metadata: nil
                               , completion: { (metadata, error) in
                if let error = error {
                    failure(error)
                }else{
                    storageRef.downloadURL { (url, error) in
                        guard let fileURL = url?.absoluteString else {return}
                        success(fileURL)
                    }
                }
            })
        }
    }
    
    static func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
        let asset = AVURLAsset(url: inputURL as URL, options: nil)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously(completionHandler: {
            handler(exportSession)
        })
    }
    
    // TODO: - Refactor this method to improve uploads from iphone 13
    //    static func uploadVideo(
    //        url: URL,
    //        success: @escaping (String) -> Void,
    //        failure: @escaping (Error) -> Void
    //    ) async {
    //        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
    //        let path = NSTemporaryDirectory() + name
    //
    //        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //        let outputurl = documentsURL.appendingPathComponent(name)
    //
    //        // Convertir el video asíncronamente
    //        await self.convertVideo(toMPEG4FormatForVideo: url, outputURL: outputurl) { (session, error) in
    //
    //            if let error = error {
    //                failure(error)
    //            }
    //
    //            if session.status == .completed, let outputURL = session.outputURL {
    //                do {
    //                    let data = try Data(contentsOf: outputURL)
    //                    let storageRef = storage.reference().child("Videos").child(name)
    //
    //                    // Subir el video a Firebase Storage
    //                    storageRef.putData(data, metadata: nil) { (metadata, error) in
    //                        if let error = error {
    //                            failure(error)
    //                        } else {
    //                            storageRef.downloadURL { (url, error) in
    //                                if let fileURL = url?.absoluteString {
    //                                    success(fileURL)
    //                                } else if let error = error {
    //                                    failure(error)
    //                                }
    //                            }
    //                        }
    //                    }
    //                } catch {
    //                    failure(error)
    //                }
    //            } else if let error = session.error {
    //                failure(error)
    //            }
    //        }
    //    }
    
    //    static func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession, Error?) -> Void) async {
    //
    //        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //        let destinationURL = documentsURL.appendingPathComponent(inputURL.lastPathComponent)
    //
    //        do {
    //            try FileManager.default.copyItem(at: inputURL, to: destinationURL)
    //        } catch {
    //            print("Error copying file: \(error)")
    //        }
    //
    //        let asset = AVURLAsset(url: destinationURL)
    //        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
    //        exportSession?.outputURL = outputURL
    //        exportSession?.outputFileType = .mp4
    //        if #available(iOS 18, *) {
    //            do {
    //                try await exportSession?.export(to: outputURL, as: .mp4)
    //            } catch {
    //                handler(exportSession!, error)
    //            }
    //        } else {
    //            //        exportSession?.exportAsynchronously {
    //            //            if let exportSession = exportSession {
    //            //                handler(exportSession, nil)
    //            //            }
    //            //        }
    //        }
    //    }
}
