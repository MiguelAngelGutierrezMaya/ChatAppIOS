//
//  CustomInputView.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 12/03/24.
//

import Foundation
import UIKit

protocol CustomInputViewDelegate: AnyObject {
    func inputView(
        _ view: CustomInputView,
        wantUploadMessage message: String
    )
}

class CustomInputView: UIView {
    // Mark - Properties
    weak var delegate: CustomInputViewDelegate?
    let inputTextView = InputTextView()
    
    private let postBackgroundColor: CustomImage = {
        let tap = UITapGestureRecognizer(
            target: CustomInputView.self,
            action: #selector(handlePostButton)
        )
        let iv = CustomImage(
            width: 40,
            height: 40,
            backgroundColor: .red,
            cornerRadius: 20
        )
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(
            UIImage(systemName: "paperplane.fill"),
            for: .normal
        )
        button.tintColor = .white
        button.addTarget(
            self,
            action: #selector(handlePostButton),
            for: .touchUpInside
        )
        button.setDimensions(height: 28, width: 28)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [inputTextView, postBackgroundColor]
        )
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // Mark - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "background")
        autoresizingMask = .flexibleHeight
        addSubview(stackView)
        stackView.anchor(
            top: topAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingLeft: 5,
            paddingRight: 5
        )
        addSubview(postButton)
        postButton.center(inView: postBackgroundColor)
        inputTextView.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: safeAreaLayoutGuide.bottomAnchor,
            right: postBackgroundColor.leftAnchor,
            paddingTop: 12,
            paddingLeft: 8,
            paddingBottom: 5,
            paddingRight: 8
        )
        
        let dividerView = UIView()
        dividerView.backgroundColor = .lightGray
        addSubview(dividerView)
        dividerView.anchor(
            top: topAnchor,
            left: leftAnchor,
            right: rightAnchor,
            height: 0.5
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    public func removeObservers() {
        inputTextView.removeObserver()
    }
    
    // Mark - Helpers
    @objc func handlePostButton() {
        delegate?.inputView(
            self,
            wantUploadMessage: inputTextView.text
        )
    }
    
    func clearTextView() {
        inputTextView.text = ""
        inputTextView.placeHolderLabel.isHidden = false
    }
}
