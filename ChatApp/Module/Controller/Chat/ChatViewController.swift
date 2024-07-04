//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 22/02/24.
//

import UIKit

class ChatViewController: UICollectionViewController {
    // MARK: - Properties
    private let reuseIdentifier = "ChatCell"
    private var messages: [Message] = []
    
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
    
    private var currentUser: User
    private var otherUser: User
    
    
    // MARK: - Lifecycle
    init(otherUser: User, currentUser: User) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    private func fetchMessages() {
        MessageServices.fetchMessages(otherUser: otherUser) { messages in
            self.messages = messages
            self.collectionView.reloadData()
        }
    }
    
    private func markReadAllMsg() {
        MessageServices.markReadAllMsg(otherUser: otherUser)
    }
}


extension ChatViewController {
    // MARK: - UICollectionViewDataSource
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return messages.count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as! ChatCell
        let message = messages[indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        //let message = messages[indexPath.row]
        // cell.configure(text: message)
        return cell
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
        let message = messages[indexPath.row]
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
}
