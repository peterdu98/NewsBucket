//
//  NewsModel.swift
//  NewsBucket
//
//  Created by Peter Du on 14/4/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import Foundation

//MARK: - Traditional API section
struct TraditionalStore: Decodable {
    let articles: [Article]
}

struct Article: Decodable {
    let source: [String: String?]
    let author: String?
    let title: String?
    let description: String?
    let publishedAt: String?
}

//MARK: - Developer API section
struct DeveloperStore: Decodable {
    let hits: [Post]
}

struct Post: Decodable, Identifiable {
    var id: String {
        return objectID
    }
    let objectID: String
    let title: String?
    let author: String?
    let url: String?
    let created_at: String?
}
