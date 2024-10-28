//
//  Book.swift
//  Eclipse
//
//  Created by user@87 on 28/10/24.
//

import Foundation

struct Book {
    var id: String
    var title: String
    var author: Author
    var genre: Genre
    var description: String
    var coverImageURL: URL?
    var tags: [Tag]
    var rating: Double
    var price: Double?
    var rentersNearby: Int
    var seriesInfo: SeriesInfo?
}

struct SeriesInfo {
    var seriesName: String
    var bookOrder: Int
}

struct Tag {
    var id: String
    var name: String
}
