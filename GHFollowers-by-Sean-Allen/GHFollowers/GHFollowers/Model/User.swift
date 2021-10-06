//
//  User.swift
//  GHFollowers
//
//  Created by Леонид on 17.08.2021.
//

import Foundation

struct User: Codable {
    let login: String
    let avatarUrl: String
    var name: String?
    var location: String?
    var bio: String?
    let publicRepos: Int
    let publicGist: Int?
    let htmlUrl: String
    let following: Int
    let followers: Int
    let createdAt: Date
}
