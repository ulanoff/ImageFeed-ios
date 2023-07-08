//
//  ImageDateFormatter.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 08.07.2023.
//

import Foundation

class ImageDateFormatter: DateFormatter {
	static let shared = ImageDateFormatter()
	
	override init() {
		super.init()
		dateStyle = .long
		timeStyle = .none
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
