//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 23/10/23.
//

import Foundation
import UIKit

struct LoginViewModel: AuthModel {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var backgroundColor: UIColor {
        return formIsValid ? .black : .black.withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : .white.withAlphaComponent(0.7)
    }
}
