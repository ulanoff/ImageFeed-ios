//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 13.09.2023.
//

import Foundation

enum NetworkError: Error {
	case httpStatusCode(Int)
	case urlRequestError(Error)
	case urlSessionError
	case dataDecodingError
}
