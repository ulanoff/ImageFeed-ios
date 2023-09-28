//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 26.09.2023.
//

import Foundation

fileprivate struct Constants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashTokenRequestURLString = "https://unsplash.com/oauth/token"
    static let accessKey = "EgPXrKU7MEhOIoYDEYGwzZ2rtUm5srzOijOWJh9ggSY"
    static let secretKey = "_Qw5ZFSV97maoYaliQ6ifkTigch4cH7TtKF9TskssaI"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let responseType = "code"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
}
struct AuthConfiguration {
	static let standart = AuthConfiguration(
        accessKey: Constants.accessKey,
        secretKey: Constants.secretKey,
        redirectURI: Constants.redirectURI,
        accessScope: Constants.accessScope,
        responseType: Constants.responseType,
        defaultBaseURL: Constants.defaultBaseURL,
        authURLString: Constants.unsplashAuthorizeURLString,
        tokenRequestURLString: Constants.unsplashTokenRequestURLString
	)
	
	let accessKey: String
	let secretKey: String
	let redirectURI: String
	let accessScope: String
	let responseType: String
	let defaultBaseURL: URL
	let authURLString: String
	let tokenRequestURLString: String
}
