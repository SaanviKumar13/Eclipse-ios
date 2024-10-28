//
//  User.swift
//  Eclipse
//
//  Created by user@87 on 28/10/24.
//

import Foundation

import Foundation

struct User {
    var id: String
    var username: String
    var email: String
    var password: String
    var address: String
    var favoriteGenres: [Genre]
    var favoriteAuthors: [Author]
    var library: Library
    var readingLists: [ReadingList]
    var borrowerRating: BorrowerRating
    var lenderRating: LenderRating
}

struct BorrowerRating {
    var punctuality: Int
    var careOfBook: Int
    var paymentPromptness: Int
    
    var averageRating: Double {
        return (Double(punctuality) + Double(careOfBook) + Double(paymentPromptness)) / 3.0
    }
}

struct LenderRating {
    var punctuality: Int
    var qualityOfBook: Int
    var generalBehavior: Int
    
    var averageRating: Double {
        return (Double(punctuality) + Double(qualityOfBook) + Double(generalBehavior)) / 3.0
    }
}
