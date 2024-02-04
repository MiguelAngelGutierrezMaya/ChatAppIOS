//
//  CustomTextField.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 7/11/23.
//

import UIKit

class CustomTextField: UITextField {
    init(
        placeholer: String,
        keyboardType: UIKeyboardType = .default,
        isSecureText: Bool = false
    ) {
        super.init(frame: .zero)
        
        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 12)
        leftView = spacer
        leftViewMode = .always
        
        borderStyle = .none
        textColor = .black
        keyboardAppearance = .light
        clearButtonMode = .whileEditing
        backgroundColor = #colorLiteral(red: 0.965680182, green: 0.965680182, blue: 0.965680182, alpha: 1)
        setHeight(50)
        
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureText
        
        attributedPlaceholder = NSAttributedString(
            string: placeholer,
            attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
