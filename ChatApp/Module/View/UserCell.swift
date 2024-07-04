//
//  UserCell.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 17/02/24.
//

import UIKit

class UserCell: UITableViewCell {
    // MARK: - Properties
    var viewModel: UserViewModel? {
        didSet {
            configure()
        }
    }
    private let profileImageView = CustomImage(
        width: 64,
        height: 64,
        backgroundColor: .lightGray,
        cornerRadius: 32
    )
    
    private let username = CustomLabel(
        text: "Username",
        txtFont: .boldSystemFont(ofSize: 17),
        labelColor: UIColor(named: "textcolor")
    )
    private let fullname = CustomLabel(text: "Fullname", labelColor: .lightGray)
    
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
        
        let stackView = UIStackView(arrangedSubviews: [username, fullname])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.centerY(
            inView: profileImageView,
            leftAnchor: profileImageView.rightAnchor,
            paddingLeft: 15
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        self.fullname.text = viewModel.fullname
        self.username.text = viewModel.username
        self.profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
}
