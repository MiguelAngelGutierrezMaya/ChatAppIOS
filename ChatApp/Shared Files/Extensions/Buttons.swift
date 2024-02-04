//
//  Buttons.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 16/10/23.
//

import UIKit

extension UIButton {
    func attributedText(firstPart: String, secondPart: String) {
        let atts: [NSAttributedString.Key: Any] = [
            .foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: 16)
        ]
        
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart) ", attributes: atts)
        
        let boldAtts: [NSAttributedString.Key: Any] = [
            .foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.88),
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: boldAtts))
        
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func blackButton(title: String, isEnabled: Bool) {
        setTitle(title, for: .normal)
        tintColor = .white
        backgroundColor = .black.withAlphaComponent(0.5)
        setTitleColor(.white.withAlphaComponent(0.7), for: .normal)
        setHeight(50)
        layer.cornerRadius = 5
        titleLabel?.font = .boldSystemFont(ofSize: 19)
        self.isEnabled = isEnabled
    }
}
