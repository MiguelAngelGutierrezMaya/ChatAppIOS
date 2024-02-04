//
//  LoginGoogle.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 18/01/24.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

extension LoginViewController {
    func showTextInputPrompt(
        withMessage message: String,
        completionBlock: @escaping ((Bool, String?) -> Void)
    ) {
        let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionBlock(false, nil)
        }
        weak var weakPrompt = prompt
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = weakPrompt?.textFields?.first?.text else { return }
            completionBlock(true, text)
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(cancelAction)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    
    @objc func setupGoogle(){
        guard let clientID = self.fapp?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { (response: GIDSignInResult?, error: Error?) in
            
            if let error = error {
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard
                let authentication = response?.user
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: authentication.idToken?.tokenString ?? "",
                accessToken: authentication.accessToken.tokenString
            )
            
            self.auth.signIn(with: credential) { result, error in
                if let error = error {
                    let authError = error as NSError
                    
                    if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                        let resolver = authError
                            .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                        var displayNameString = ""
                        for tmpFactorInfo in resolver.hints {
                            displayNameString += tmpFactorInfo.displayName ?? ""
                            displayNameString += " "
                        }
                        
                        self.showTextInputPrompt(
                            withMessage: "Select factor to sign in\n\(displayNameString)") { userPressedOK, displayName in
                                var selectedHint: PhoneMultiFactorInfo?
                                for tmpFactorInfo in resolver.hints {
                                    if displayName == tmpFactorInfo.displayName {
                                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                                    }
                                }
                                
                                self.phoneProvider.verifyPhoneNumber(
                                    with: selectedHint!,
                                    uiDelegate: nil,
                                    multiFactorSession: resolver.session) { verificationId, error in
                                        if let error = error {
                                            self.showMessage(title: "Error", message: "Multi factor start sign in failed. Error: \(error.localizedDescription)")
                                            return
                                        }
                                        
                                        self.showTextInputPrompt(
                                            withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                            completionBlock: { userPressedOK, verificationCode in
                                                let credential: PhoneAuthCredential? = self.phoneProvider
                                                    .credential(
                                                        withVerificationID: verificationId!,
                                                        verificationCode: verificationCode!
                                                    )
                                                
                                                let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                                    .assertion(with: credential!)
                                                
                                                resolver.resolveSignIn(with: assertion!) { authResult, error in
                                                    if let error = error {
                                                        self.showMessage(title: "Error", message: "Multi factor finanlize sign in failed. Error: \(error.localizedDescription)")
                                                        return
                                                    }
                                                    
                                                    self.navigationController?.popViewController(animated: true)
                                                }
                                            }
                                        )
                                        
                                    }
                            }
                    } else {
                        self.showMessage(title: "Error", message: error.localizedDescription)
                        return
                    }
                }
                
                self.updateUserInfo()
            }
        }
    }
}

// MARK: - Login user info
extension LoginViewController {
    func updateUserInfo() {
        guard let user = auth.currentUser else { return }
        
        guard let email = user.email,
              let fullname = user.displayName,
              let photoURL = user.photoURL else { return }
        
        let uid = user.uid
        let username = fullname.replacingOccurrences(of: " ", with: "").lowercased()
        
        getImage(withImageURL: photoURL) { image in
            let credential = AuthCredentialEmail(
                email: email,
                fullname: fullname,
                uid: uid,
                username: username,
                profileImage: image
            )
            
            AuthServices.registerWithGoogle(credential: credential) { error in
                self.showLoader(true)
                if let error = error {
                    self.showMessage(title: "Error", message: error.localizedDescription)
                    return
                }
                
                self.navToConversationVC()
            }
        }
    }
}
