//
//  Library.swift
//  Eclipse
//
//  Created by user@87 on 28/10/24.
//

import Foundation

struct Library {
    var booksByGenre: [Genre: [Book]]
    var statusLists: StatusLists
}

struct StatusLists {
    var wantToRead: [Book]
    var currentlyReading: [Book]
    var finished: [Book]
    var didNotFinish: [Book]
    var customLists: [ReadingList]
}

struct ReadingList {
    var id: String
    var name: String
    var books: [Book]
    var isPrivate: Bool
}
