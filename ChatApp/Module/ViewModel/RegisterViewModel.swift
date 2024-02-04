//
//  RegisterViewModel.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 7/11/23.
//

import Foundation
import UIKit

struct RegisterViewModel: AuthModel {
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
            && password?.isEmpty == false
            && fullname?.isEmpty == false
            && username?.isEmpty == false
    }
    
    var backgroundColor: UIColor {
        return formIsValid ? .black : .black.withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : .white.withAlphaComponent(0.7)
    }
}
