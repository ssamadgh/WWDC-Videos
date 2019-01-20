//
//  AAPLDataSourcePlaceholder.swift
//  TangramUI
//
//  Created by 黄伯驹 on 2017/12/16.
//  Copyright © 2017年 黄伯驹. All rights reserved.
//

import UIKit

/**
A general purpose placeholder class for representing the no content or error message placeholders in a data source.
*/
struct AAPLDataSourcePlaceholder {
	
    /// The title of the placeholder. This is typically displayed larger than the message.
    var title: String?
	
    /// The message of the placeholder. This is typically displayed in using a smaller body font.
    var message: String?
	
    /// An image for the placeholder. This is displayed above the title.
    var image: UIImage?
    
    var activityIndicator = false

    static var placeholderWithActivityIndicator: AAPLDataSourcePlaceholder {
        return AAPLDataSourcePlaceholder(title: nil, message: nil, image: nil, activityIndicator: true)
    }
	
	static func placeholderWithTitle(title: String, message: String, image: UIImage) -> AAPLDataSourcePlaceholder {
		return AAPLDataSourcePlaceholder(title: title, message: message, image: image, activityIndicator: false)
	}
}
