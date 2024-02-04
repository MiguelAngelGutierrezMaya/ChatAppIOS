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
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        title = user.fullname
        view.backgroundColor = .white
        
        let logOutBarButton = UIBarButtonItem(
            title: "Log Out",
            style: .plain,
            target: self,
            action: #selector(handleLogOut)
        )
        
        navigationItem.leftBarButtonItem = logOutBarButton
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
}
