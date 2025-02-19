import Foundation
import UIKit
import Firebase
import FirebaseFirestore

let db = Firestore.firestore()

/// Adapter to convert Firestore data into a `BookF` model.
struct BookFAdapter {
    static func fromFirestoreData(_ data: [String: Any]) -> BookF? {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String else {
            return nil
        }
        
        return BookF(
            id: id,
            title: title,
            subtitle: data["subtitle"] as? String,
            authors: data["authors"] as? [String],
            description: data["description"] as? String,
            averageRating: data["averageRating"] as? Double,
            ratingsCount: data["ratingsCount"] as? Int,
            imageLinks: extractImageLinks(from: data["imageURL"]),
            previewLink: data["previewLink"] as? String,
            pageCount: data["pageCount"] as? Int
        )
    }

    private static func extractImageLinks(from value: Any?) -> ImageLinks? {
        guard let imageURL = value as? String else {
            return nil
        }
        return ImageLinks(smallThumbnail: imageURL, thumbnail: imageURL)
    }
}

/// Downloads an image from a given URL.
/// - Parameters:
///   - url: The URL of the image.
///   - completion: A completion handler returning the downloaded `UIImage`.
func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, _, _ in
        completion(data.flatMap { UIImage(data: $0) })
    }.resume()
}

/// Fetches the user's status lists (e.g., "Currently Reading", "Want to Read").
/// - Parameters:
///   - userID: The ID of the user.
///   - completion: A completion handler returning a `Result` with an array of `List` objects or an `Error`.
func fetchStatusLists(userID: String, completion: @escaping (Result<[List], Error>) -> Void) {
    let ref = db.collection("users").document(userID).collection("statusLists")
    ref.getDocuments { snapshot, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        let statusLists = snapshot?.documents.compactMap { doc -> List? in
            let data = doc.data()
            return List(
                id: doc.documentID,
                title: data["title"] as? String ?? "Untitled",
                bookIDs: data["bookIDs"] as? [String] ?? [],
                isPrivate: data["isPrivate"] as? Bool ?? false,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )
        } ?? []
        
        completion(.success(statusLists))
    }
}

/// Fetches the user's custom book lists.
/// - Parameters:
///   - userID: The ID of the user.
///   - completion: A completion handler returning a `Result` with an array of `List` objects or an `Error`.
func fetchCustomLists(userID: String, completion: @escaping (Result<[List], Error>) -> Void) {
    let ref = db.collection("users").document(userID).collection("customLists")
    ref.getDocuments { snapshot, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        let customLists = snapshot?.documents.compactMap { doc -> List? in
            let data = doc.data()
            return List(
                id: doc.documentID,
                title: data["title"] as? String ?? "Untitled",
                bookIDs: data["bookIDs"] as? [String] ?? [],
                isPrivate: data["isPrivate"] as? Bool ?? false,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )
        } ?? []

        completion(.success(customLists))
    }
}

/// Adds a new custom list for the user.
/// - Parameters:
///   - userID: The ID of the user.
///   - list: The `List` object to be added.
///   - completion: A completion handler returning a `Result` of success or failure.
func addCustomList(userID: String, list: List, completion: @escaping (Result<Void, Error>) -> Void) {
    let ref = db.collection("users").document(userID).collection("customLists")
    
    let newList = [
        "title": list.title,
        "bookIDs": list.bookIDs,
        "isPrivate": list.isPrivate
    ] as [String: Any]

    ref.document(list.id).setData(newList) { error in
        if let error = error {
            completion(.failure(error))
            return
        }
        completion(.success(()))
    }
}

/// Fetches book details from Firestore.
/// - Parameters:
///   - bookID: The ID of the book.
///   - completion: A completion handler returning a `BookF` object or `nil` if not found.
func fetchBookDetails(bookID: String, completion: @escaping (BookF?) -> Void) {
    let ref = db.collection("books").document(bookID)
    ref.getDocument { snapshot, error in
        if let error = error {
            print("Error fetching book details: \(error.localizedDescription)")
            completion(nil)
            return
        }
        guard let data = snapshot?.data() else {
            completion(nil)
            return
        }
        completion(BookFAdapter.fromFirestoreData(data))
    }
}

/// Fetches details of a renter.
/// - Parameters:
///   - renterID: The ID of the renter.
///   - completion: A completion handler returning the renter's name or `nil` if not found.
func fetchRenterDetails(renterID: String, completion: @escaping (String?, [String: Double]?) -> Void) {
    db.collection("renters").document(renterID).getDocument { (document, error) in
        if let error = error {
            completion(nil, nil)
            return
        }
        
        guard let document = document, document.exists else {
            completion(nil, nil)
            return
        }
        
        guard let data = document.data() else {
            completion(nil, nil)
            return
        }
        
        // Fetch renter's name
        let name = data["name"] as? String
        
        // Fetch renter's rating dictionary (bookQuality, communication, overallExperience)
        if let renterRating = data["renterRating"] as? [String: Double] {
            // Pass the renter's name and the entire rating dictionary
            completion(name, renterRating)
        } else {
            // If rating doesn't exist, pass nil for the rating
            completion(name, nil)
        }
    }
}



/// Fetches the list of books rented by a renter.
/// - Parameters:
///   - renterID: The ID of the renter.
///   - completion: A completion handler returning an array of `BookF` objects.
func fetchRentedBooks(renterID: String, completion: @escaping ([RentersBook]) -> Void) {
    let db = Firestore.firestore()
    
    db.collection("renters").document(renterID).getDocument { (document, error) in
        if let error = error {
            print("Error fetching rented books: \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard let document = document, document.exists, let data = document.data() else {
            print("No valid data found for renter")
            completion([])
            return
        }
        
        if let rentedBooksData = data["rentedBooks"] as? [[String: Any]] {
            let books = rentedBooksData.compactMap { bookData -> RentersBook? in
                guard let title = bookData["title"] as? String,
                      let authors = bookData["authors"] as? [String],
                      let description = bookData["description"] as? String,
                      let price = bookData["price"] as? Double,
                      let imageURL = bookData["imageURL"] as? String,
                      let id = bookData["id"] as? String,
                      let timestamp = bookData["addedAt"] as? Timestamp else {
                    return nil
                }
                
                return RentersBook(
                    title: title,
                    authors: authors,
                    description: description,
                    price: price,
                    imageURL: imageURL,
                    id: id,
                    addedAt: timestamp.dateValue()
                )
            }
            completion(books)
        } else {
            print("No rentedBooks field in renter document")
            completion([])
        }
    }
}


/// Fetch Books from API Function

var cachedBooks: [String: [BookF]] = [:]

func fetchBooks(query: String, completion: @escaping (Result<[BookF], Error>) -> Void) {
    if let cachedData = cachedBooks[query] {
        completion(.success(cachedData))
        return
    }
    
    guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=subject:\(encodedQuery)") else {
        completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
        return
    }
    
    let session = URLSession(configuration: .default)
    
    session.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
            return
        }
        
        do {
            if let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
               let itemsArray = jsonObj["items"] as? [[String: Any]] {
                
                var books: [BookF] = []
                
                for item in itemsArray {
                    if let volumeInfo = item["volumeInfo"] as? [String: Any] {
                        let id = item["id"] as? String ?? "Unknown ID"
                        let title = (volumeInfo["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                        let subtitle = (volumeInfo["subtitle"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                        let authors = volumeInfo["authors"] as? [String]
                        let description = (volumeInfo["description"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                        let averageRating = volumeInfo["averageRating"] as? Double
                        let ratingsCount = volumeInfo["ratingsCount"] as? Int
                        let pageCount = volumeInfo["pageCount"] as? Int
                        let previewLink = volumeInfo["previewLink"] as? String
                        
                        var imageLinks: ImageLinks?
                        if let imageLinksDict = volumeInfo["imageLinks"] as? [String: AnyObject],
                           let smallThumbnail = imageLinksDict["smallThumbnail"] as? String,
                           let thumbnail = imageLinksDict["thumbnail"] as? String {
                            imageLinks = ImageLinks(smallThumbnail: smallThumbnail, thumbnail: thumbnail)
                        }
                        
                        let book = BookF(
                            id: id,
                            title: title ?? "Unknown Title",
                            subtitle: subtitle,
                            authors: authors,
                            description: description,
                            averageRating: averageRating,
                            ratingsCount: ratingsCount,
                            imageLinks: imageLinks,
                            previewLink: previewLink,
                            pageCount: pageCount
                        )
                        
                        books.append(book)
                    }
                }
                
                // Cache the fetched books
                cachedBooks[query] = books
                
                completion(.success(books))
            } else {
                completion(.failure(NSError(domain: "Invalid JSON structure", code: 500, userInfo: nil)))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}

func fetchRenters(completion: @escaping (Result<[Renter], Error>) -> Void) {
    db.collection("renters").getDocuments { snapshot, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let documents = snapshot?.documents else {
            let error = NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No renters found."])
            completion(.failure(error))
            return
        }

        var renters: [Renter] = []

        for document in documents {
            let data = document.data()

            guard let name = data["name"] as? String else {
                continue
            }

            // Handling rentedBooks as an array of book objects
            var rentedBooks: [RentersBook] = []

            if let rentedBooksArray = data["rentedBooks"] as? [[String: Any]] {
                for bookData in rentedBooksArray {
                    let book = createRentersBook(from: bookData)
                    rentedBooks.append(book)
                }
            } else {
                print("DEBUG: rentedBooks field is missing or invalid in document \(document.documentID)")
            }

            // Extract renter rating if available
            var renterRating: Rating? = nil
            if let renterRatingData = data["rating"] as? [String: Double] {
                renterRating = Rating.fromDictionary(renterRatingData)
            }

            let renter = Renter(id: document.documentID, name: name, books: rentedBooks, rating: renterRating)
            renters.append(renter)
        }
        completion(.success(renters))
    }
}

// Helper function to create a RentersBook from Firestore data
private func createRentersBook(from bookData: [String: Any]) -> RentersBook {
    let title = bookData["title"] as? String ?? "Unknown Title"
    let authors = bookData["authors"] as? [String] ?? ["Unknown Author"]
    let description = bookData["description"] as? String ?? "No description available"
    let price = bookData["price"] as? Double ?? 0.0
    let imageURL = bookData["imageURL"] as? String ?? ""
    let id = bookData["id"] as? String ?? UUID().uuidString
    let addedAtString = bookData["addedAt"] as? String ?? ""
    let addedAt = ISO8601DateFormatter().date(from: addedAtString) ?? Date()

    return RentersBook(
        title: title,
        authors: authors,
        description: description,
        price: price,
        imageURL: imageURL,
        id: id,
        addedAt: addedAt
    )
}

/// Fetch Currently Rented Books from Firestore

func fetchCurrentlyRentedBooks(for userID: String, completion: @escaping (Result<[RentersBook], Error>) -> Void) {
    let borrowedBooksRef = db.collection("users").document(userID).collection("borrowedBooks")

    borrowedBooksRef.getDocuments { snapshot, error in
        if let error = error {
            print("Error fetching rented books: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        guard let documents = snapshot?.documents, !documents.isEmpty else {
            completion(.failure(NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No rented books found."])))
            return
        }

        var books: [RentersBook] = []

        for document in documents {
            let data = document.data()

            if let bookArray = data["books"] as? [[String: Any]] { // Extract book array
                for var bookDict in bookArray {
                    // Convert Firestore Timestamp to a format that can be serialized
                    if let timestamp = bookDict["addedAt"] as? Timestamp {
                        bookDict["addedAt"] = timestamp.dateValue().timeIntervalSince1970
                    }
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: bookDict)
                        let decodedBook = try JSONDecoder().decode(RentersBook.self, from: jsonData)
                        books.append(decodedBook)
                    } catch {
                        print("Error decoding RentersBook: \(error)")
                    }
                }
            }
        }
        completion(.success(books))
    }
}





    // Fetch Suggested Books from Firestore
    func fetchSuggestedBooks(completion: @escaping (Result<[String], Error>) -> Void) {
        db.collection("books").limit(to: 5).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let documents = snapshot?.documents else {
                completion(.failure(NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No suggested books found."])))
                return
            }

            let bookIDs = documents.compactMap { $0.data()["googleBooksId"] as? String }
            completion(.success(bookIDs))
        }
    }

func updateRenterRating(_ rating: Rating, renterID: String) {
    // Assuming the renter ratings are stored in a collection called "renters" in Firestore
    let renterRef = db.collection("renters").document(renterID)
    
    // Create the rating data using the Rating struct
    let ratingData: [String: Any] = [
        "bookQuality": rating.bookQuality,         // Use the bookQuality from the Rating struct
        "communication": rating.communication,     // Use the communication from the Rating struct
        "overallExperience": rating.overallExperience // Use the overallExperience from the Rating struct
    ]
    
    // Update the renter document with the new rating data
    renterRef.updateData(ratingData) { error in
        if let error = error {
            print("Error updating renter rating: \(error.localizedDescription)")
        } else {
            print("Renter rating updated successfully")
        }
    }
}



func searchBooks(query: String, completion: @escaping (Result<[BookF], Error>) -> Void) {
    let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
        return
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
            return
        }
        
        do {
            let response = try JSONDecoder().decode(BookResponse.self, from: data)
            if let items = response.items {
                completion(.success(items))
            } else {
                completion(.failure(NSError(domain: "No items found", code: 404, userInfo: nil)))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
