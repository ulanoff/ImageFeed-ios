//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 14.07.2023.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
	private var imageURL: URL
	
	private var scrollView = UIScrollView()
	private var imageView = UIImageView()
	private var backButton = UIButton()
	private var shareButton = UIButton()
	
	init(imageURL: URL) {
		self.imageURL = imageURL
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		KingfisherManager.shared.cache.clearMemoryCache()
	}
	
	override func viewDidLayoutSubviews() {
		centerImage()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
	
	@objc private func didTapBackButton(_ sender: UIButton) {
		dismiss(animated: true)
	}
	
	@objc private func didTapShareButton(_ sender: UIButton) {
		guard let image = imageView.image else { return }
		let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		present(activity, animated: true)
	}
}

private extension SingleImageViewController {
	func setupUI() {
		configureScrollView()
		configureBackButton()
		configureShareButton()
		configureMainView()
		configureConstraints()
		configureImageView()
	}
	
	func configureMainView() {
		view.backgroundColor = .ypBlack
		[scrollView, backButton, shareButton].forEach {
			view.addSubview($0)
		}
	}
	
	func configureImageView() {
		UIBlockingProgressHUD.show()
		imageView.kf.setImage(with: imageURL) { [weak self] result in
			UIBlockingProgressHUD.dismiss()
			guard let self else { return }
			switch result {
			case .success(let imageResult):
				self.rescaleAndCenterImageInScrollView(image: imageResult.image)
			case .failure(_):
				self.showError()
			}
		}
	}
	
	func configureScrollView() {
		scrollView.addSubview(imageView)
		scrollView.delegate = self
		scrollView.minimumZoomScale = 0.1
		scrollView.maximumZoomScale = 1.25
	}
	
	func configureBackButton() {
		backButton.setImage(UIImage(named: "Backward"), for: .normal)
		backButton.tintColor = .ypWhite
		backButton.addTarget(self, action: #selector(didTapBackButton(_:)), for: .touchUpInside)
		backButton.accessibilityIdentifier = "back button"
	}
	
	func configureShareButton() {
		shareButton.setImage(UIImage(named: "Share"), for: .normal)
		shareButton.backgroundColor = .ypBlack
		shareButton.tintColor = .ypWhite
		shareButton.layer.cornerRadius = 25
		shareButton.addTarget(self, action: #selector(didTapShareButton(_:)), for: .touchUpInside)
	}
	
	func configureConstraints() {
		[scrollView, imageView, backButton, shareButton].forEach {
			$0?.translatesAutoresizingMaskIntoConstraints = false
		}
		
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
			
			imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			
			backButton.widthAnchor.constraint(equalToConstant: 48),
			backButton.heightAnchor.constraint(equalToConstant: 48),
			backButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
			backButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
			
			shareButton.widthAnchor.constraint(equalToConstant: 50),
			shareButton.heightAnchor.constraint(equalToConstant: 50),
			shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			shareButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -17)
		])
	}
	
	func rescaleAndCenterImageInScrollView(image: UIImage) {
		let minZoomScale = scrollView.minimumZoomScale
		let maxZoomScale = scrollView.maximumZoomScale
		view.layoutIfNeeded()
		let visibleRectSize = scrollView.bounds.size
		let imageSize = image.size
		let hScale = visibleRectSize.width / imageSize.width
		let vScale = visibleRectSize.height / imageSize.height
		let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
		scrollView.setZoomScale(scale, animated: false)
		scrollView.layoutIfNeeded()
		let newContentSize = scrollView.contentSize
		let x = (newContentSize.width - visibleRectSize.width) / 2
		let y = (newContentSize.height - visibleRectSize.height) / 2
		scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
	}
	
	func centerImage() {
		let visibleRectSize = scrollView.bounds.size
		let contentSize = scrollView.contentSize
		var xOffset: CGFloat = 0
		var yOffset: CGFloat = 0
		if contentSize.width < visibleRectSize.width {
			xOffset = (visibleRectSize.width - contentSize.width) * 0.5
		}
		if contentSize.height < visibleRectSize.height {
			yOffset = (visibleRectSize.height - contentSize.height) * 0.5
		}
		scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: 0, right: 0)
	}
	
	func showError() {
		let alert = UIAlertController(title: "Что-то пошло не так(", message: "Попробовать еще раз?", preferredStyle: .alert)
		let noAction = UIAlertAction(title: "Не надо", style: .cancel) { [weak self] _ in
			guard let self else { return }
			dismiss(animated: true)
		}
		let yesAction = UIAlertAction(title: "Повторить", style: .default) { [ weak self ] _ in
			guard let self else { return }
			configureImageView()
		}
		alert.addAction(yesAction)
		alert.addAction(noAction)
		present(alert, animated: true)
	}
}

extension SingleImageViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		centerImage()
	}
}
