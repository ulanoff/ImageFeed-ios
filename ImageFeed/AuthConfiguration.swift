//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 26.09.2023.
//

import Foundation

let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
let UnsplashTokenRequestURLString = "https://unsplash.com/oauth/token"
let AccessKey = "EgPXrKU7MEhOIoYDEYGwzZ2rtUm5srzOijOWJh9ggSY"
let SecretKey = "_Qw5ZFSV97maoYaliQ6ifkTigch4cH7TtKF9TskssaI"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let ResponseType = "code"
let DefaultBaseURL = URL(string: "https://api.unsplash.com")!

struct AuthConfiguration {
	static let standart = AuthConfiguration(
		accessKey: AccessKey,
		secretKey: SecretKey,
		redirectURI: RedirectURI,
		accessScope: AccessScope,
		responseType: ResponseType,
		defaultBaseURL: DefaultBaseURL,
		authURLString: UnsplashAuthorizeURLString,
		tokenRequestURLString: UnsplashTokenRequestURLString
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
