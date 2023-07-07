//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 07.07.2023.
//

import UIKit

class ImagesListCell: UITableViewCell {
	@IBOutlet var cellImageView: UIImageView!
	@IBOutlet var likeButton: UIButton!
	@IBOutlet var dateLabel: UILabel!
	
	static let reuseIdentifier = "ImagesListCell"
}
