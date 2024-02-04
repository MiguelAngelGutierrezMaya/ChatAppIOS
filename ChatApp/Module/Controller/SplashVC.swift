//
//  SplashVC.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 29/01/24.
//

import UIKit
import FirebaseAuth
import Factory

class SplashVC: UIViewController {
    @Injected(\.auth) var auth: Auth
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if auth.currentUser?.uid == nil {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } else {
            guard let uid = auth.currentUser?.uid else { return }
            showLoader(true)
            UserServices.fetchUser(uid: uid) { [self] user in
                showLoader(false)
                let controller = ConversationViewController(user: user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true, completion: nil)
            }
        }
    }
}
