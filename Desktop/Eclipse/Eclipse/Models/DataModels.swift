import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - List Model
struct List {
    let id: String
    let title: String
    let bookIDs: [String]
    let isPrivate: Bool
    let createdAt: Date

    static func from(document: DocumentSnapshot) -> List? {
        let data = document.data()
        guard let title = data?["title"] as? String,
              let bookIDs = data?["bookIDs"] as? [String],
              let isPrivate = data?["isPrivate"] as? Bool,
              let timestamp = data?["createdAt"] as? Timestamp else {
            print("Error parsing List from Firestore document: \(document.data() ?? [:])")
            return nil
        }
        return List(
            id: document.documentID,
            title: title,
            bookIDs: bookIDs,
            isPrivate: isPrivate,
            createdAt: timestamp.dateValue()
        )
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "bookIDs": bookIDs,
            "isPrivate": isPrivate,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}

// MARK: - ImageLinks Model
struct ImageLinks:Codable {
    let smallThumbnail: String
    let thumbnail: String
}

// MARK: - BookF Model
struct BookF:Encodable, Decodable {
    let id: String
    let title: String
    let subtitle: String?
    let authors: [String]?
    let description: String?
    let averageRating: Double?
    let ratingsCount: Int?
    let imageLinks: ImageLinks?
    let previewLink: String?
    let pageCount: Int?
}

struct BookResponse: Encodable, Decodable {
    let items: [BookF]?
}

struct RecommendedList{
    var title: String
    var subtitle: String
    var books: [String]
}

struct BookRequest {
    let title: String
    let renter: String
    let profileImage: UIImage
    let price: String
    let days: String
    let bookCover: UIImage
    let status: String
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool

}

struct Rating {
    var bookQuality: Double
    var communication: Double
    var overallExperience: Double
    
    // Initializer to make it easy to initialize a Rating object
    init(bookQuality: Double, communication: Double, overallExperience: Double) {
        self.bookQuality = bookQuality
        self.communication = communication
        self.overallExperience = overallExperience
    }
    
    // You can also add a method to compute the average rating if needed
    var averageRating: Double {
        return (bookQuality + communication + overallExperience) / 3.0
    }
    
    // Method to convert the Rating object into a dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "bookQuality": bookQuality,
            "communication": communication,
            "overallExperience": overallExperience
        ]
    }
    
    // A static method to initialize Rating from a dictionary fetched from Firestore
    static func fromDictionary(_ dictionary: [String: Double]) -> Rating? {
        guard let bookQuality = dictionary["bookQuality"],
              let communication = dictionary["communication"],
              let overallExperience = dictionary["overallExperience"] else {
            return nil
        }
        
        return Rating(bookQuality: bookQuality, communication: communication, overallExperience: overallExperience)
    }
}

struct Renter {
    var id: String
    var name: String
    var books: [RentersBook]
    var rating: Rating?
}

struct RentersBook: Codable {
    let title: String
    let authors: [String]
    let description: String
    let price: Double
    let imageURL: String
    let id: String
    let addedAt: Date

//    enum CodingKeys: String, CodingKey {
//        case title, authors, description, price, imageURL, id, addedAt
//    }
}
