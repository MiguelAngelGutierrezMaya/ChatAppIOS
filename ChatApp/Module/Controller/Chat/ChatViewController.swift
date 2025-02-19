//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 22/02/24.
//

import UIKit
import PhotosUI
import AVFoundation

class ChatViewController: UICollectionViewController {
    // MARK: - Properties
    private let reuseIdentifier = "ChatCell"
    private let chatHeaderIdentifier = "ChatHeader"
    private var messages: [[Message]] = []
    
    var player: AVPlayer?
    var currentCellAudioSubscribed: ChatCell?
    
    private lazy var customInputView: CustomInputView = {
        let frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: 50
        )
        let view = CustomInputView(frame: frame)
        view.delegate = self
        return view
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    lazy var imagePickerConfig: PHPickerConfiguration = {
        var config = PHPickerConfiguration()
        //        config.filter = .
        //        config.selectionLimit = 1
        //        let picker = PHPickerViewController(configuration: config)
        //        picker.delegate = self
        return config
    }()
    
    private lazy var attachAlert: UIAlertController = {
        let alert = UIAlertController(
            title: "Attach File",
            message: "Select the button you want to attach from",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Camera",
                style: .default,
                handler: { _ in
                    self.handleCamera()
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Gallery",
                style: .default,
                handler: { _ in
                    self.handleGallery()
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Location",
                style: .default,
                handler: { _ in
                    self.present(self.locationAlert, animated: true)
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "cancel",
                style: .cancel
            )
        )
        
        return alert
    }()
    
    private lazy var locationAlert: UIAlertController = {
       let alert = UIAlertController(
            title: "Share Location",
            message: "Select the button you want to share location from",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Current Location",
                style: .default,
                handler: { _ in
                    self.handleCurrentLocation()
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Google Map",
                style: .default,
                handler: { _ in
                    self.handleGoogleMapsLocation()
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "cancel",
                style: .cancel
            )
        )
        
        return alert
    }()
        
    
    var currentUser: User
    var otherUser: User
    
    
    // MARK: - Lifecycle
    init(otherUser: User, currentUser: User) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(
            ChatHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: chatHeaderIdentifier
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.markReadAllMsg()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        markReadAllMsg()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        customInputView.removeObservers()
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    // MARK: - Helpers
    private func configureUI() {
        title = otherUser.fullname
        collectionView.backgroundColor = UIColor(named: "background")
        collectionView.register(
            ChatCell.self,
            forCellWithReuseIdentifier: reuseIdentifier
        )
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDragWithAccessory
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    private func fetchMessages() {
        MessageServices.fetchMessages(otherUser: otherUser) { messages in
            // self.messages = messages
            
            let groupedMessages = Dictionary(
                grouping: messages
            ) { (element) -> String in
                let dateValue = element.timestamp.dateValue()
                let stringDateValue = self.stringValue(forDate: dateValue) ?? ""
                return stringDateValue
            }
            
            self.messages.removeAll()
            
            let sortedKeys = groupedMessages.keys.sorted { $0 < $1 }
            
            sortedKeys.forEach { key in
                let values = groupedMessages[key]
                self.messages.append(values ?? [])
            }
            
            self.collectionView.reloadData()
            
            // await before scrolling to last item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.collectionView.scrollToLastItem()
            }
        }
    }
    
    private func markReadAllMsg() {
        MessageServices.markReadAllMsg(otherUser: otherUser)
    }
}

// MARK: - UICollectionViewDataSource
extension ChatViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let firstMessage = messages[indexPath.section].first else {
                return UICollectionReusableView()
            }
            
            let dateValue = firstMessage.timestamp.dateValue()
            let stringValue = stringValue(forDate: dateValue)
            
            let cell = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: chatHeaderIdentifier,
                for: indexPath
            ) as! ChatHeader
            
            cell.datevalue = stringValue
            
            return cell
        }
        
        return UICollectionReusableView()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return messages.count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return messages[section].count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as! ChatCell
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        cell.delegate = self
        //let message = messages[indexPath.row]
        // cell.configure(text: message)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(
            width: view.frame.width, height: 50
        )
    }
}

// MARK: - Delegate Flow Layout
extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .init(
            top: 15,
            left: 0,
            bottom: 15,
            right: 0
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: 50
        )
        let cell = ChatCell(frame: frame)
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        // let text = messages[indexPath.row]
        // cell.configure(text: text)
        cell.layoutIfNeeded()
        
        let targetSize = CGSize(
            width: view.frame.width,
            height: 1000
        )
        let estimatedSize = cell.systemLayoutSizeFitting(
            targetSize
        )
        return .init(
            width: view.frame.width,
            height: estimatedSize.height
        )
    }
}

// MARK: - CustomInputViewDelegate
extension ChatViewController: CustomInputViewDelegate {
    
    func inputViewForAttach(_ view: CustomInputView) {
        present(attachAlert, animated: true)
    }
    
    func inputView(_ view: CustomInputView, wantUploadMessage message: String) {
        MessageServices.fetchSingleRecentMessage(otherUser: otherUser) { [self] unreadCount in
            MessageServices.uploadMessage(
                message: message,
                currentUser: currentUser,
                otherUser: otherUser, unreadCount: unreadCount + 1) { [self] _ in
                    collectionView.reloadData()
                }
        }
        
        view.clearTextView()
    }
    
    func inputViewForAudio(_ view: CustomInputView, audioURL: URL) {
        self.showLoader(true)
        FileUploader.uploadAudio(audioURL: audioURL) { audioString in
            MessageServices.fetchSingleRecentMessage(
                otherUser: self.otherUser
            ) { unreadCount in
                MessageServices.uploadMessage(
                    audioUrl: audioString,
                    currentUser: self.currentUser,
                    otherUser: self.otherUser,
                    unreadCount: unreadCount
                ) { error in
                    self.showLoader(false)
                    
                    if let error = error {
                        print("Error uploading audio: \(error.localizedDescription)")
                        return
                    }
                }
            }
        }
    }
}
