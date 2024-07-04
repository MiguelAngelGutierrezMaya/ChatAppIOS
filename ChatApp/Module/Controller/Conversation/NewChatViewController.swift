//
//  NewChatViewController.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 3/02/24.
//

import UIKit
import Factory
import FirebaseAuth

protocol NewChatViewControllerDelegate: AnyObject {
    func controller(_ controller: NewChatViewController, wantsToStartChatWith user: User)
}

class NewChatViewController: UIViewController {
    //
    @Injected(\.auth) var auth: Auth
    
    // mark: - Properties
    weak var delegate: NewChatViewControllerDelegate?
    private let tableView = UITableView()
    private let reuseIdentifier = "UserCell"
    private var users: [User] = []{
        didSet {
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
        fetchUsers()
    }
    
    // MARK: - Helpers
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.backgroundColor = UIColor(named: "background")
        tableView.register(
            UserCell.self,
            forCellReuseIdentifier: reuseIdentifier
        )
        tableView.tableFooterView = UIView() // Remove empty cells
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor(named: "background")
        title = "Search"
        
        view.addSubview(tableView)
        tableView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 15,
            paddingRight: 15
        )
    }
    
    private func fetchUsers() {
        showLoader(true)
        UserServices.fetchUsers { users in
            self.showLoader(false)
            self.users = users
            
            guard let uid = self.auth.currentUser?.uid else { return }
            guard let index = self.users.firstIndex(where: { $0.uid == uid }) else { return }
            
            self.users.remove(at: index)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier, for: indexPath
        ) as! UserCell
        let user = users[indexPath.row]
        cell.viewModel = UserViewModel(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        delegate?.controller(self, wantsToStartChatWith: user)
    }
}
