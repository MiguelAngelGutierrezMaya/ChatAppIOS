//
//  CustomButton.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 7/11/23.
//

import UIKit

class CustomButton: UIButton {
    init(
        _ target: Any?,
        title: String,
        action: Selector,
        isEnabled: Bool
    ) {
        super.init(frame: .zero)
        
        //self.type = type
        blackButton(title: title, isEnabled: isEnabled)
        addTarget(target, action: action, for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
