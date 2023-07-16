//
//  UIColor+Ext.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 07.07.2023.
//

import UIKit

extension UIColor {
	static var ypRed: UIColor { UIColor(named: "YP Red") ?? .red }
	static var ypBlack: UIColor { UIColor(named: "YP Black") ?? .black }
	static var ypWhite: UIColor { UIColor(named: "YP White") ?? .white }
	static var ypWhiteSemitransperent: UIColor { UIColor(named: "YP White (Alpha 50)") ?? UIColor(white: 1, alpha: 0.5) }
	static var ypGray: UIColor { UIColor(named: "YP Gray") ?? .lightGray }
}
