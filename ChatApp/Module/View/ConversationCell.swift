//
//  ConversationCell.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 9/02/24.
//

import UIKit

class ConversationCell: UITableViewCell {
    // MARK: - Properties
    var viewModel: MessageViewModel? {
        didSet {
            configure()
        }
    }
    private let profileImageView = CustomImage(
        image: #imageLiteral(resourceName: "Google_Contacts_logo copy"),
        width: 60,
        height: 60,
        backgroundColor: .lightGray,
        cornerRadius: 30
    )
    
    private let fullname = CustomLabel(text: "Fullname", labelColor: UIColor(named: "textcolor"))
    private let recentMessage = CustomLabel(text: "Recent Message", labelColor: .lightGray)
    private let dateLabel = CustomLabel(text: "10/10/2022", labelColor: .lightGray)
    private let unreadMsgLabel = CustomReadLabel(
        text: "",
        txtFont: .boldSystemFont(ofSize: 15),
        height: 25,
        width: 25,
        cornerRadius: 12
    )
//    {
//        let label = UILabel()
//        label.text = "7"
//        label.textColor = .white
//        label.font = .boldSystemFont(ofSize: 15)
//        label.backgroundColor = .red
//        label.setDimensions(height: 25, width: 25)
//        label.layer.cornerRadius = 12
//        label.textAlignment = .center
//        label.clipsToBounds = true
//        return label
//    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.centerY(
            inView: self,
            leftAnchor:  self.leftAnchor
        )
        
        let stackView = UIStackView(arrangedSubviews: [fullname, recentMessage])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.centerY(
            inView: profileImageView, 
            leftAnchor: profileImageView.rightAnchor,
            paddingLeft: 15
        )
        
        let stackTrailing = UIStackView(arrangedSubviews: [dateLabel, unreadMsgLabel])
        stackTrailing.axis = .vertical
        stackTrailing.spacing = 7
        stackTrailing.alignment = .trailing
        
        addSubview(stackTrailing)
        stackTrailing.centerY(
            inView: profileImageView,
            rightAnchor: self.rightAnchor,
            paddingRight: 8
        )
        
//        addSubview(dateLabel)
//        dateLabel.centerY(
//            inView: self,
//            rightAnchor: self.rightAnchor,
//            paddingRight: 10
//        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        self.profileImageView.sd_setImage(with: viewModel.profileImageURL)
        self.fullname.text = viewModel.fullname
        self.recentMessage.text = viewModel.messageText
        self.dateLabel.text = viewModel.timestampString
        
        self.unreadMsgLabel.text = "\(viewModel.unReadCount)"
        self.unreadMsgLabel.isHidden = viewModel.shouldHideUnreadLabel
    }
}
