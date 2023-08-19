//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 07.07.2023.
//

import UIKit

class ImagesListCell: UITableViewCell {
	@IBOutlet private var cellImageView: UIImageView!
	@IBOutlet private var likeButton: UIButton!
	@IBOutlet private var dateLabel: UILabel!
	
	static let reuseIdentifier = "ImagesListCell"
	
	func configureCell(with image: UIImage, isLiked: Bool, date: Date) {
		selectionStyle = .none
		cellImageView.image = image
		likeButton.tintColor = isLiked ? .ypRed : .ypWhiteSemitransperent
		dateLabel.text = ImageDateFormatter.shared.string(from: Date())
	}
}
