//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Keybe on 1/09/23.
//

import Foundation
import UIKit

protocol RegisterVC_Delegate: AnyObject {
    func didSuccCreateAccount(_ vc: RegisterViewController)
}

class RegisterViewController: UIViewController {
    //MARK - Properties
    weak var delegate: RegisterVC_Delegate?
    
    var viewModel = RegisterViewModel()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstPart: "Already hace an account?", secondPart: "Login up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.setDimensions(height: 140, width: 140)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handlePlusButton), for: .touchUpInside)
        return button
    }()
    
    private let emailTF: CustomTextField = CustomTextField(
        placeholer: "Email",
        keyboardType: .emailAddress
    )
    
    private let passwordTF: CustomTextField = CustomTextField(
        placeholer: "Password",
        isSecureText: true
    )
    
    private let fullNameTF = CustomTextField(placeholer: "Fullname")
    
    private let userNameTF = CustomTextField(placeholer: "Username")
    
    //    private lazy var signUpButton: UIButton = {
    //        let button = UIButton(type: .system)
    //        button.setTitle("Sign Up", for: .normal)
    //        button.tintColor = .white
    //        button.backgroundColor = .black.withAlphaComponent(0.5)
    //        button.setTitleColor(.white.withAlphaComponent(0.7), for: .normal)
    //        button.setHeight(50)
    //        button.layer.cornerRadius = 5
    //        button.titleLabel?.font = .boldSystemFont(ofSize: 19)
    //        button.addTarget(self, action: #selector(handleSignUpVC), for: .touchUpInside)
    //        button.isEnabled = false
    //
    //        return button
    //    }()
    
    private lazy var signUpButton: CustomButton = CustomButton(
        self,
        title: "Sign Up",
        action: #selector(handleSignUpVC),
        isEnabled: false
    )
    
    private var profileImage: UIImage?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureForTextFiled()
        dissmissKeyboardOnTap()
        addObserverOnShowKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    //MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        alreadyHaveAccountButton.centerX(inView: view)
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(
            inView: view,
            topAnchor: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 30
        )
        
        let stackView = UIStackView(arrangedSubviews: [
            emailTF,
            passwordTF,
            fullNameTF,
            userNameTF,
            signUpButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(
            top: plusPhotoButton.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 30,
            paddingLeft: 30,
            paddingRight: 30
        )
    }
    
    private func configureForTextFiled() {
        emailTF.addTarget(
            self,
            action: #selector(handleTextChange(sender:)),
            for: .editingChanged
        )
        passwordTF.addTarget(
            self,
            action: #selector(handleTextChange(sender:)),
            for: .editingChanged
        )
        fullNameTF.addTarget(
            self,
            action: #selector(handleTextChange(sender:)),
            for: .editingChanged
        )
        userNameTF.addTarget(
            self,
            action: #selector(handleTextChange(sender:)),
            for: .editingChanged
        )
    }
    
    @objc func handleAlreadyHaveAccount() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handlePlusButton() {
        // Select image from gallery
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: false, completion: nil)
    }
    
    @objc func handleSignUpVC() {
        guard let email = emailTF.text?.lowercased() else { return }
        guard let password = passwordTF.text else { return }
        guard let fullname = fullNameTF.text else { return }
        guard let username = userNameTF.text?.lowercased() else { return }
        guard let profileImage = profileImage else { return }
        
        let credentials = AuthCredentials(
            email: email,
            fullname: fullname, 
            password: password,
            username: username,
            profileImage: profileImage
        )
        
        showLoader(true)
        
        AuthServices.registerUser(credential: credentials) { error in
            
            self.showLoader(false)
            
            if let error = error {
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            
            self.delegate?.didSuccCreateAccount(self)
        }
        
    }
    
    @objc func handleTextChange(sender: UITextField) {
        if sender == emailTF {
            viewModel.email = sender.text
        } else if sender == passwordTF {
            viewModel.password = sender.text
        } else if sender == fullNameTF {
            viewModel.fullname = sender.text
        } else {
            viewModel.username = sender.text
        }
        
        updateForm()
    }
    
    private func updateForm() {
        signUpButton.isEnabled = viewModel.formIsValid
        signUpButton.backgroundColor = viewModel.backgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        self.profileImage = selectedImage
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true, completion: nil)
    }
}
