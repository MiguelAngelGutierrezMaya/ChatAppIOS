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

class CustomReadLabel: UILabel {
        
        init(
            text: String,
            txtFont: UIFont? = .boldSystemFont(ofSize: 20),
            height: CGFloat = 30,
            width: CGFloat = 30,
            cornerRadius: CGFloat = 20,
            isHidden: Bool = false
        ) {
            super.init(frame: .zero)
            
            self.text = text
            self.textColor = .white
            self.font = txtFont
            self.backgroundColor = .red
            self.setDimensions(height: height, width: width)
            self.layer.cornerRadius = cornerRadius
            self.textAlignment = .center
            self.clipsToBounds = true
            self.isHidden = isHidden
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
