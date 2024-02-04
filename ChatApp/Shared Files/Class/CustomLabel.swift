//
//  CustomLabel.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 20/11/23.
//

import UIKit

class CustomLabel: UILabel {
    
    init(
        text: String,
        txtFont: UIFont? = .systemFont(ofSize: 14),
        labelColor: UIColor? = .black
    ) {
        super.init(frame: .zero)
        self.text = text
        self.font = txtFont
        self.textColor = labelColor
        
        textAlignment = .center
        numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
