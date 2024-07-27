//
//  ChatHeader.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 27/07/24.
//

import UIKit

class ChatHeader: UICollectionReusableView {
    var datevalue: String? {
        didSet {
           configure()
        }
    }
    
    private let dateLabel: CustomLabel = {
        let label = CustomLabel(
            text: "Sunday, 27 July",
            txtFont: .boldSystemFont(ofSize: 16),
            labelColor: UIColor(named: "textcolor")
        )
        
        label.backgroundColor = .systemGray.withAlphaComponent(0.5)
        label.setDimensions(height: 30, width: 100)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dateLabel)
        dateLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let datevalue = datevalue else { return }
        dateLabel.text = datevalue
    }
}
