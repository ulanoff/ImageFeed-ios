//
//  Array+Ext.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 19.09.2023.
//

import Foundation

extension Array {
	func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
		var newArray = self
		if index >= 0 && index < newArray.count {
			newArray[index] = newValue
		}
		return newArray
	}
}
