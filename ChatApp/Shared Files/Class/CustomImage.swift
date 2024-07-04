//
//  CustomImage.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 20/11/23.
//

import UIKit

class CustomImage: UIImageView {
    init(
        image: UIImage? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        backgroundColor: UIColor? = nil,
        cornerRadius: CGFloat = 0
    ) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFill
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        
        if let image = image {
            self.image = image
        }
        
//        if let width = width, let height = height {
//            setDimensions(height: height, width: width)
//        }
        
        if let width = width {
            setWidth(width)
        }
        
        if let height = height {
            setHeight(height)
        }
        
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
