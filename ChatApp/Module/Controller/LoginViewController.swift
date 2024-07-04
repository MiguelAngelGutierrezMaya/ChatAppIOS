//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Keybe on 1/09/23.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import Factory

class LoginViewController: UIViewController {
    //MARK - Injected properties
    @Injected(\.auth) var auth: Auth
    @Injected(\.app) var fapp: FirebaseApp?
    @Injected(\.phoneProvider) var phoneProvider: PhoneAuthProvider
    
    //MARK - Properties
    var viewModel = LoginViewModel()
    
    private let welcomeLabel: CustomLabel = CustomLabel(
        text: "Hey, Welcome",
        txtFont: .boldSystemFont(ofSize: 20)
    )
    
    private let profileImageView: UIImageView = CustomImage(
        image: #imageLiteral(resourceName: "profile"),
        width: 50,
        height: 50
    )
    //    {
    //        let iv = UIImageView()
    //        // using #imageLiteral(resourceName: "profile") instead of UIImage(named: "profile")
    //        iv.image = #imageLiteral(resourceName: "profile")
    //        iv.contentMode = .scaleAspectFit
    //        iv.setDimensions(height: 50, width: 50)
    //        return iv
    //    }()
    
    //    private let emailTF: UITextField = {
    //        let tf = UITextField()
    //        tf.tintColor = .black
    //        tf.setHeight(50)
    //        tf.placeholder = "Email"
    //        tf.backgroundColor = .lightGray
    //        tf.keyboardType = .emailAddress
    //        return tf
    //    }()
    
    private let emailTF: CustomTextField = CustomTextField(
        placeholer: "Email",
        keyboardType: .emailAddress
    )
    
    //    private let passwordTF: UITextField = {
    //        let tf = UITextField()
    //        tf.tintColor = .black
    //        tf.setHeight(50)
    //        tf.placeholder = "Password"
    //        tf.backgroundColor = .lightGray
    //        tf.isSecureTextEntry = true
    //        return tf
    //    }()
    
    private let passwordTF: CustomTextField = CustomTextField(
        placeholer: "Password",
        isSecureText: true
    )
    
    //    private lazy var loginButton: UIButton = {
    //        let button = UIButton(type: .system)
    //        button.setTitle("Log in", for: .normal)
    //        button.tintColor = .white
    //        button.backgroundColor = .black.withAlphaComponent(0.5)
    //        button.setTitleColor(.white.withAlphaComponent(0.7), for: .normal)
    //        button.setHeight(50)
    //        button.layer.cornerRadius = 5
    //        button.titleLabel?.font = .boldSystemFont(ofSize: 19)
    //        button.addTarget(self, action: #selector(handleLoginVC), for: .touchUpInside)
    //        button.isEnabled = false
    //
    //        return button
    //    }()
    
    private lazy var loginButton: CustomButton = CustomButton(
        self,
        title: "Log in",
        action: #selector(handleLoginVC),
        isEnabled: false
    )
    
    private lazy var forgetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstPart: "Forget your password?", secondPart: "Get help signing in")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleForgetPassword), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstPart: "Don't Have any account?", secondPart: "Sign up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        return button
    }()
    
    private let contLabel: CustomLabel = CustomLabel(
        text: "Or continue with google",
        labelColor: .lightGray
    )
    //    {
    //        let label = UILabel()
    //        label.text = "Or continue with google"
    //        label.textColor = .lightGray
    //        label.font = .systemFont(ofSize: 14)
    //        return label
    //    }()
    
    private lazy var googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Google", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.setDimensions(height: 50, width: 150)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        
        return button
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureForTextFiled()
        dissmissKeyboardOnTap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObserverOnShowKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    //MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = UIColor(named: "background")
        
        view.addSubview(welcomeLabel)
        welcomeLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        welcomeLabel.centerX(inView: view)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: welcomeLabel.bottomAnchor, paddingTop: 20)
        profileImageView.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [emailTF, passwordTF, loginButton, forgetPasswordButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
        
        view.addSubview(signUpButton)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        signUpButton.centerX(inView: view)
        
        view.addSubview(contLabel)
        contLabel.centerX(inView: view, topAnchor: forgetPasswordButton.bottomAnchor, paddingTop: 30)
        view.addSubview(googleButton)
        googleButton.centerX(inView: view, topAnchor: contLabel.bottomAnchor, paddingTop: 12)
        
    }
    
    private func configureForTextFiled() {
        emailTF.addTarget(self, action: #selector(handleTextChange(sender:)), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(handleTextChange(sender:)), for: .editingChanged)
    }
    
    @objc func handleLoginVC() {
        guard let email = emailTF.text?.lowercased() else { return }
        guard let password = passwordTF.text else { return }
        
        showLoader(true)
        
        AuthServices.loginUser(
            withEmail: email,
            password: password) { result, error in
                self.showLoader(false)
                
                if let error = error {
                    self.showMessage(title: "Error", message: error.localizedDescription)
                    return
                }
                
                self.navToConversationVC()
            }
    }
    
    @objc func handleForgetPassword() {
        print("DEBUG: Forget password button pressed")
    }
    
    @objc func handleSignUp() {
        let controller = RegisterViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleGoogleSignIn() {
        showLoader(true)
        setupGoogle()
    }
    
    @objc func handleTextChange(sender: UITextField) {
        sender == emailTF ?
        viewModel.email = sender.text :
        (viewModel.password = sender.text)
        updateForm()
    }
    
    private func updateForm() {
        loginButton.isEnabled = viewModel.formIsValid
        loginButton.backgroundColor = viewModel.backgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
    
    public func navToConversationVC() {
        guard let uid = auth.currentUser?.uid else { return }
        showLoader(true)
        UserServices.fetchUser(uid: uid) { user in
            self.showLoader(false)
            let controller = ConversationViewController(user: user)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
}

// MARK: - RegisterViewControllerDelegate
extension LoginViewController: RegisterVC_Delegate {
    func didSuccCreateAccount(_ vc: RegisterViewController) {
        //        vc.showLoader(false)
        vc.navigationController?.popViewController(animated: true)
        self.navToConversationVC()
    }
}
