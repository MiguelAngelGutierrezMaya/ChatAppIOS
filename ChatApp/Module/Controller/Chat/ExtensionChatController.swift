//
//  ExtensionChatController.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 31/08/24.
//

import UIKit
import PhotosUI
import SDWebImage
import ImageSlideshow

extension ChatViewController {
    @objc func handleCamera() {
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleGallery() {
        //        imagePicker.sourceType = .savedPhotosAlbum
        //        imagePicker.mediaTypes = ["public.image"]
        //        present(imagePicker, animated: true, completion: nil)
        
        imagePickerConfig.selectionLimit = 1
        
        imagePickerConfig.filter = .any(of: [.images, .videos])
        imagePickerConfig.preferredAssetRepresentationMode = .compatible
        
        if #available(iOS 17.0, *) {
            imagePickerConfig.mode = .default
        }
        
        imagePickerConfig.selection = .default
        
        let picker = PHPickerViewController(configuration: imagePickerConfig)
        picker.delegate = self
        
        DispatchQueue.main.async {
            self.present(picker, animated: true, completion: nil)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        dismiss(animated: true) {
            /// Media type
            guard let mediaType = info[.mediaType] as? String else { return }
            /// print("Media type: \(mediaType)")
            
            if mediaType == "public.image" {
                guard let image = info[.editedImage] as? UIImage else { return }
                
                self.uploadImage(withImage: image)
            } else if mediaType == "public.movie" {
                guard let videoURL = info[.mediaURL] as? URL else { return }
                
                self.uploadVideo(withURL: videoURL)
            }
        }
    }
}

extension ChatViewController: PHPickerViewControllerDelegate {
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)
        
        for result in results {
            /// Upload image or video
            
            let itemProvider = result.itemProvider
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let image = image as? UIImage {
                        self.uploadImage(withImage: image)
                    }
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let error = error {
                        print("Error loading video: \(error.localizedDescription)")
                        return
                    }
                    
                    if let url = url {
                        self.uploadVideo(withURL: url)
                    }
                }
            }
        }
    }
}

// MARK: - Upload Media
extension ChatViewController {
    func uploadImage(withImage image: UIImage) {
        DispatchQueue.main.async {
            self.showLoader(true)
        }
        
        FileUploader.uploadImage(image: image) { imageURL in
            MessageServices.fetchSingleRecentMessage(otherUser: self.otherUser) { unreadCount in
                MessageServices.uploadMessage(
                    imageURl: imageURL,
                    currentUser: self.currentUser,
                    otherUser: self.otherUser,
                    unreadCount: unreadCount + 1
                ) { error  in
                    DispatchQueue.main.async {
                        self.showLoader(false)
                    }
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                        return
                    }
                }
            }
        }
    }
    
    func uploadVideo(withURL url: URL) {
        DispatchQueue.main.async {
            self.showLoader(true)
        }
        
        FileUploader.uploadVideo(url: url) { videoURL in
            MessageServices.fetchSingleRecentMessage(otherUser: self.otherUser) { unReadMsgCount in
                MessageServices.uploadMessage(
                    videoUrl: videoURL,
                    currentUser: self.currentUser,
                    otherUser: self.otherUser,
                    unreadCount: unReadMsgCount + 1
                ) { error in
                    DispatchQueue.main.async {
                        self.showLoader(false)
                    }
                    
                    
                    if let error = error {
                        print("Error uploading video in messages: \(error.localizedDescription)")
                        return
                    }
                }
            }
        } failure: { error in
            print("Error uploading video: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.showLoader(false)
            }
        }
        
    }
}

// MARK: - chat delegate
extension ChatViewController: ChatCellDelegate {
    func cell(wantsToPlayVideo cell: ChatCell, videoURL: URL?) {
        guard let videoURL = videoURL else { return }
        
        let controller = VideoPlayerVC(videoURL: videoURL)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc(cellWithWantsToShowImage:image:) func cell(wantsToShowImage cell: ChatCell, image imageURL: URL?) {
        guard let imageURL = imageURL else { return }
        
        let slideShow = ImageSlideshow()
        
        SDWebImageManager.shared().loadImage(with: imageURL, progress: nil) { image,_,_,_,_,_  in
            guard let image = image else { return }
            
            slideShow.setImageInputs([
                ImageSource(image: image)
            ])
            
            slideShow.delegate = self as? ImageSlideshowDelegate
            
            let controller = slideShow.presentFullScreenController(from: self)
            controller.slideshow.activityIndicator = DefaultActivityIndicator()
        }
    }
}