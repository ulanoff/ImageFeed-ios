//
//  ProfilePicture.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 13.07.2023.
//

import UIKit

final class ProfilePicture: UIImageView {
	override init(image: UIImage?, highlightedImage: UIImage? = nil) {
		super.init(image: image, highlightedImage: highlightedImage)
		contentMode = .scaleAspectFill
		clipsToBounds = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.width / 2
	}
}
