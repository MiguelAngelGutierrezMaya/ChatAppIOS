//
//  AuthProtocol.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 7/11/23.
//

import UIKit

protocol AuthModel {
    var formIsValid: Bool { get }
    var backgroundColor: UIColor { get }
    var buttonTitleColor: UIColor { get }
}
