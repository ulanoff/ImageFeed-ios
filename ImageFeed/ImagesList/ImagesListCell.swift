//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 07.07.2023.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
	func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

class ImagesListCell: UITableViewCell {
	static let reuseIdentifier = "ImagesListCell"
	weak var delegate: ImagesListCellDelegate?
	
	private var cellImageView = UIImageView()
	private var likeButton = UIButton()
	private var dateLabel = UILabel()
	
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	override func prepareForReuse() {
		cellImageView.kf.cancelDownloadTask()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureCell(with photo: Photo, fetchCompletion: ((Result<RetrieveImageResult, Error>) -> Void)?) {
		selectionStyle = .none
		
		guard let thumbURL = URL(string: photo.thumbImageURL),
			  let _ = URL(string: photo.largeImageURL)
		else {
			assertionFailure("Failed to create URLs for cell")
			return
		}
		cellImageView.kf.indicatorType = .activity
		cellImageView.kf.setImage(with: thumbURL, placeholder: UIImage(named: "photo_placeholder")) { result in
			switch result {
			case .success(let value):
				fetchCompletion?(.success(value))
			case .failure(let error):
				fetchCompletion?(.failure(error))
			}
		}
		likeButton.tintColor = photo.isLiked ? .ypRed : .ypWhiteSemitransperent
		dateLabel.text = ImageDateFormatter.shared.string(from: photo.createdAt ?? Date())
	}
	
	func setIsLiked(isLiked: Bool) {
		likeButton.tintColor = isLiked ? .ypRed : .ypWhiteSemitransperent
	}
	
	@objc func didTapLikeButton(_ sender: UIButton?) {
		delegate?.imagesListCellDidTapLike(self)
	}
}

private extension ImagesListCell {
	func setupUI() {
		configureCellImageView()
		configureLikeButton()
		configureDateLabel()
		
		
		[cellImageView, likeButton, dateLabel].forEach {
			contentView.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		configureCell()
		configureConstraints()
	}
	
	func configureCell() {
		backgroundColor = .ypBlack
	}
	
	func configureCellImageView() {
		cellImageView.layer.cornerRadius = 16
		cellImageView.clipsToBounds = true
		cellImageView.image = UIImage(systemName: "questionmark")
		cellImageView.contentMode = .scaleAspectFill
	}
	
	func configureLikeButton() {
		likeButton.setImage(UIImage(named: "Heart"), for: .normal)
		likeButton.addTarget(self, action: #selector(didTapLikeButton(_:)), for: .touchUpInside)
	}
	
	func configureDateLabel() {
		dateLabel.text = "27 августа 2022"
		dateLabel.textColor = .ypWhite
		dateLabel.font = .systemFont(ofSize: 13)
	}
	
	func configureConstraints() {
		NSLayoutConstraint.activate([
			cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			
			dateLabel.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: -8),
			dateLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
			dateLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8),
			
			likeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
			likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor),
			likeButton.widthAnchor.constraint(equalToConstant: 44),
			likeButton.heightAnchor.constraint(equalToConstant: 44)
		])
	}
}
