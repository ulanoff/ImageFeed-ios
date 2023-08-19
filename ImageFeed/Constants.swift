//
//  Constants.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 11.08.2023.
//

import Foundation

struct UnsplashApiConstants {
	static let UnsplashAuthorizeURL = URL(string: "https://unsplash.com/oauth/authorize")!
	static let UnsplashTokenRequestURL = URL(string: "https://unsplash.com/oauth/token")!
	static let AccessKey = "EgPXrKU7MEhOIoYDEYGwzZ2rtUm5srzOijOWJh9ggSY"
	static let SecretKey = "_Qw5ZFSV97maoYaliQ6ifkTigch4cH7TtKF9TskssaI"
	static let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
	static let AccessScope = "public+read_user+write_likes"
	static let ResponseType = "code"
	static let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
}

