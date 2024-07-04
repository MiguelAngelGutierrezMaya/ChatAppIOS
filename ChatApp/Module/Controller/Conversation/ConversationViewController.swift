//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 13/01/24.
//

import UIKit
import FirebaseAuth
import Factory

class ConversationViewController: UIViewController {
    //
    @Injected(\.auth) var auth: Auth
    
    // MARK: - Properties
    private var user: User
    private let tableView = UITableView()
    private let reuseIdentifier = "ConversationCell"
    
    private let unreadMsgLabel = CustomReadLabel(
        text: "",
        height: 30,
        width: 30,
        cornerRadius: 15
    )
    
    private var unReadCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.unreadMsgLabel.isHidden = self.unReadCount == 0
                self.unreadMsgLabel.text = String(self.unReadCount)
            }
        }
    }
//    {
//        let label = UILabel()
//        label.text = "7"
//        label.textColor = .white
//        label.font = .boldSystemFont(ofSize: 20)
//        label.backgroundColor = .red
//        label.setDimensions(height: 40, width: 40)
//        label.layer.cornerRadius = 20
//        label.textAlignment = .center
//        label.clipsToBounds = true
//        return label
//    }()
    
    private var conversations: [Message] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var conversationDictionary: [String: Message] = [String: Message]()
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
        fetchConversations()
    }
    
    // MARK: - Helpers
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.backgroundColor = UIColor(named: "background")
        tableView.register(
            ConversationCell.self,
            forCellReuseIdentifier: reuseIdentifier
        )
        tableView.tableFooterView = UIView() // Remove empty cells
    }
    
    private func configureUI() {
        title = user.fullname
        view.backgroundColor = UIColor(named: "background")
        
        let logOutBarButton = UIBarButtonItem(
            title: "Log Out",
            style: .plain,
            target: self,
            action: #selector(handleLogOut)
        )
        let newConversationBarButton = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(handleNewChat)
        )
        
        navigationItem.leftBarButtonItem = logOutBarButton
        navigationItem.rightBarButtonItem = newConversationBarButton
        
        view.addSubview(tableView)
        tableView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 15,
            paddingRight: 15
        )
        view.addSubview(unreadMsgLabel)
        unreadMsgLabel.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            paddingLeft: 20,
            paddingBottom: 20
        )
    }
    
    private func fetchConversations() {
        MessageServices.fetchRecentMessages { [self] conversations in
            conversations.forEach { conversation in
                self.conversationDictionary[conversation.chatPartnerID] = conversation
            }
            
            self.conversations = Array(self.conversationDictionary.values)
            
            unReadCount = 0
            
            self.conversations.forEach { msg in
                self.unReadCount = msg.new_msg
            }
            
            unreadMsgLabel.text = "\(unReadCount)"
            
            UIApplication.shared.applicationIconBadgeNumber = unReadCount
        }
    }
    
    // MARK: - Actions
    @objc func handleLogOut() {
        do {
            try auth.signOut()
            
            dismiss(animated: true, completion: nil)
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    @objc func handleNewChat() {
        let controller = NewChatViewController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
    
    private func openChat(currentUser: User, otherUser: User) {
        let controller = ChatViewController(
            otherUser: otherUser,
            currentUser: currentUser
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier, for: indexPath
        ) as! ConversationCell
        let conversation = conversations[indexPath.row]
        cell.viewModel = MessageViewModel(message: conversation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        
        showLoader(true)
        
        UserServices.fetchUser(uid: conversation.chatPartnerID) { [self] otherUser in
            showLoader(false)
            openChat(currentUser: user, otherUser: otherUser)
        }
    }
}

// MARK: - NewChatViewControllerDelegate
extension ConversationViewController: NewChatViewControllerDelegate {
    func controller(_ controller: NewChatViewController, wantsToStartChatWith otherUser: User) {
        controller.dismiss(animated: true, completion: nil)
        openChat(currentUser: user, otherUser: otherUser)
    }
}
