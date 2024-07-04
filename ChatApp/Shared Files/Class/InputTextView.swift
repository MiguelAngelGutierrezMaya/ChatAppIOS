//
//  InputTextView.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 12/03/24.
//

import Foundation
import UIKit

class InputTextView: UITextView {
    let placeHolderLabel = CustomLabel(text: "  Type a message...", labelColor: .lightGray)
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = UIColor(named: "textView")
        layer.cornerRadius = 15
        isScrollEnabled = false
        font = .systemFont(ofSize: 16)
        
        addSubview(placeHolderLabel)
        placeHolderLabel.centerY(
            inView: self,
            leftAnchor: leftAnchor,
            rightAnchor: rightAnchor,
            paddingLeft: 8
        )
        
        addObserver()
        
        paddingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextDidChange),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
    }
    
    public func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: UITextView.textDidChangeNotification,
            object: nil
        )
    }
    
    @objc func handleTextDidChange() {
        placeHolderLabel.isHidden = !text.isEmpty
    }
}

extension UITextView {
    func paddingView() {
        self.textContainerInset = UIEdgeInsets(
            top: 10,
            left: 12,
            bottom: 10,
            right: 12
        )
    }
}
