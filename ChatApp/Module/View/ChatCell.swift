//
//  ChatCell.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 22/02/24.
//

import UIKit

protocol ChatCellDelegate: AnyObject {
    func cell(wantsToPlayVideo cell: ChatCell, videoURL: URL?)
    func cell(wantsToShowImage cell: ChatCell, image: URL?)
}

class ChatCell: UICollectionViewCell {
    // MARK: - Properties
    weak var delegate: ChatCellDelegate?
    
    var viewModel: MessageViewModel? {
        didSet { configure() }
    }
    
    private let profileImageView = CustomImage(
        width: 30,
        height: 30,
        backgroundColor: .lightGray,
        cornerRadius: 15
    )
    
    private let dateLabel = CustomLabel(
        text: "10/10/2022",
        txtFont: .systemFont(ofSize: 12),
        labelColor: .lightGray
    )
    
    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.9215686275, blue: 0.9137254902, alpha: 1)
        view.layer.cornerRadius = 12
        return view
    }()
    
    var bubbleRightAnchor: NSLayoutConstraint!
    var bubbleLeftAnchor: NSLayoutConstraint!
    
    var dateRightAnchor: NSLayoutConstraint!
    var dateLeftAnchor: NSLayoutConstraint!
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.text = "Some text message"
        tv.textColor = .black
        tv.font = .systemFont(ofSize: 16)
        return tv
    }()
    
    private lazy var postImage: CustomImage = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImage))
        let image = CustomImage()
        image.isHidden = true
        
        image.addGestureRecognizer(tap)
        image.isUserInteractionEnabled = true
        return image
    }()
    
    private lazy var postVideo: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle("Play video", for: .normal)
        button.addTarget(
            self,
            action: #selector(handleVideoButton),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(
            left: leftAnchor,
            bottom: bottomAnchor,
            paddingLeft: 10
        )
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.anchor(
            top: bubbleContainer.topAnchor,
            left: bubbleContainer.leftAnchor,
            bottom: bubbleContainer.bottomAnchor,
            right: bubbleContainer.rightAnchor,
            paddingTop: 4,
            paddingLeft: 12,
            paddingBottom: 4,
            paddingRight: 12
        )
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(
            equalTo: profileImageView.rightAnchor,
            constant: 12
        )
        bubbleLeftAnchor.isActive = false
        
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(
            equalTo: rightAnchor,
            constant: -12
        )
        bubbleRightAnchor.isActive = false
        
        addSubview(dateLabel)
        
        dateLeftAnchor = dateLabel.leftAnchor.constraint(
            equalTo: bubbleContainer.rightAnchor,
            constant: 12
        )
        dateLeftAnchor.isActive = false
        
        dateRightAnchor = dateLabel.rightAnchor.constraint(
            equalTo: bubbleContainer.leftAnchor,
            constant: -12
        )
        dateRightAnchor.isActive = false
        
        dateLabel.anchor(bottom: bottomAnchor)
        
        addSubview(postImage)
        postImage.anchor(
            top: bubbleContainer.topAnchor,
            left: bubbleContainer.leftAnchor,
            bottom: bubbleContainer.bottomAnchor,
            right: bubbleContainer.rightAnchor,
            paddingTop: 4,
            paddingLeft: 12,
            paddingBottom: 4,
            paddingRight: 12
        )
        
        addSubview(postVideo)
        postVideo.anchor(
            top: bubbleContainer.topAnchor,
            left: bubbleContainer.leftAnchor,
            bottom: bubbleContainer.bottomAnchor,
            right: bubbleContainer.rightAnchor,
            paddingTop: 4,
            paddingLeft: 12,
            paddingBottom: 4,
            paddingRight: 12
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        textView.text = viewModel.messageText
        textView.textColor = viewModel.messageColor
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        dateRightAnchor.isActive = viewModel.rightAnchorActive
        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        dateLeftAnchor.isActive = viewModel.leftAnchorActive
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        profileImageView.isHidden = viewModel.shouldHideProfileImage
        
        guard let timestamp = viewModel.timestampString else { return }
        dateLabel.text = timestamp
        
        postImage.sd_setImage(with: viewModel.imageURL)
        textView.isHidden = viewModel.isTextHide
        postImage.isHidden = viewModel.isImageHide
        postVideo.isHidden = viewModel.isVideoHide
        
        if !viewModel.isImageHide {
            postImage.isHidden = false
            postImage.setHeight(200)
        }
    }
    
    @objc func handleVideoButton() {
        guard let videoURL = viewModel?.videoURL else { return }
        delegate?.cell(wantsToPlayVideo: self, videoURL: videoURL)
    }
    
    @objc func handleImage() {
        guard let imageURL = viewModel?.imageURL else { return }
        delegate?.cell(wantsToShowImage: self, image: imageURL)
    }
}
