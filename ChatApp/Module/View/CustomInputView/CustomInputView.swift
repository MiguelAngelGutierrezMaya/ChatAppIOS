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
    func inputViewForAttach(_ view: CustomInputView)
    func inputViewForAudio(_ view: CustomInputView, audioURL: URL)
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
        iv.isHidden = true
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
        button.isHidden = true
        return button
    }()
    
    private lazy var attachButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "paperclip.circle"), for: .normal)
        button.setDimensions(height: 40, width: 40)
        button.tintColor = .red
        button.addTarget(self, action: #selector(handleAttachButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
        button.setDimensions(height: 40, width: 40)
        button.tintColor = .red
        button.addTarget(self, action: #selector(handleRecordButton), for: .touchUpInside)
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [inputTextView, postBackgroundColor, attachButton, recordButton]
        )
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // TODO: Record view
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setDimensions(height: 40, width: 100)
        button.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendRecordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = .white
        button.backgroundColor = .red
        button.setDimensions(height: 40, width: 100)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSendRecordButton), for: .touchUpInside)
        return button
    }()
    
    let timerLabel = CustomLabel(
        text: "00:00",
        labelColor: UIColor(named: "textcolor")
    )
    
    lazy var recordStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [cancelButton, timerLabel, sendRecordButton]
        )
        stack.axis = .horizontal
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()
    
    var duration: CGFloat = 0.0
    var timer: Timer?
    var recorder = AKAudioRecorder.shared
    
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
        
        addSubview(recordStackView)
        recordStackView.anchor(
            top: topAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 15,
            paddingLeft: 12,
            paddingRight: 12
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextDidChange),
            name: InputTextView.textDidChangeNotification,
            object: nil
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
    
    @objc func handleAttachButton() {
        delegate?.inputViewForAttach(self)
    }
    
    @objc func handleRecordButton() {
        stackView.isHidden = true
        recordStackView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.recorder.myRecordings.removeAll() /// Delete all recordings
            self.recorder.record() /// Will start recording
            self.setTimer()
        }
    }
    
    @objc func handleTextDidChange() {
        let isTextEmpty = inputTextView.text.isEmpty || inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || inputTextView.text == ""
        
        postButton.isHidden = isTextEmpty
        postBackgroundColor.isHidden = isTextEmpty
        
        attachButton.isHidden = !isTextEmpty
        recordButton.isHidden = !isTextEmpty
    }
}
