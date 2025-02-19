import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Properties
    private var rentableBooks: [RentersBook] = [] // Array to store rented books
    private var currentUser: User? // Firebase Auth user
    private let db = Firestore.firestore()

    // UI Components
    private let profileImageView = UIImageView(image: UIImage(named: "profile"))
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()

    private let addBooksButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Books", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(addBooksButtonTapped), for: .touchUpInside)
        return button
    }()

    private let booksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 120, height: 150)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(BookssCell.self, forCellWithReuseIdentifier: "BookssCell")
        return collectionView
    }()

    private let createAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Create an account to start exploring"
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = true
        return label
    }()

    private let loginSignupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login / Signup", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(loginSignupButtonTapped), for: .touchUpInside)
        return button
    }()

    private let noBooksLabel: UILabel = {
        let label = UILabel()
        label.text = "You have no books to rent. Add some books to get started!"
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        setupUI()
        checkUserLoginStatus()
        loadRenterData()
        setupLongPressGesture()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        setupHeaderView()
        setupBooksCollection()
        setupCreateAccountLabel()
        setupLoginSignupButton()
        setupNoBooksLabel()
    }

    private func setupHeaderView() {
        // Banner Image
        let bannerImageView = UIImageView(image: UIImage(named: "banner"))
        bannerImageView.contentMode = .scaleAspectFill
        bannerImageView.clipsToBounds = true
        view.addSubview(bannerImageView)
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 250)
        ])

        // Profile Image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        view.addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: bannerImageView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: bannerImageView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])

        // Name Label
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: bannerImageView.centerXAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: bannerImageView.trailingAnchor, constant: -10)
        ])

        // Add Books Button
        addBooksButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addBooksButton)
        NSLayoutConstraint.activate([
            addBooksButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            addBooksButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addBooksButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupBooksCollection() {
        booksCollectionView.delegate = self
        booksCollectionView.dataSource = self
        view.addSubview(booksCollectionView)

        booksCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            booksCollectionView.topAnchor.constraint(equalTo: addBooksButton.bottomAnchor, constant: 20),
            booksCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            booksCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            booksCollectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func setupCreateAccountLabel() {
        view.addSubview(createAccountLabel)
        createAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupLoginSignupButton() {
        view.addSubview(loginSignupButton)
        loginSignupButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginSignupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginSignupButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginSignupButton.widthAnchor.constraint(equalToConstant: 200),
            loginSignupButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        loginSignupButton.isHidden = Auth.auth().currentUser != nil
    }

    private func setupNoBooksLabel() {
        view.addSubview(noBooksLabel)
        noBooksLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noBooksLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noBooksLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noBooksLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noBooksLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        noBooksLabel.isHidden = true
    }

    // MARK: - Firebase Auth Check
    private func checkUserLoginStatus() {
        if Auth.auth().currentUser != nil {
            // User is logged in
            currentUser = Auth.auth().currentUser
            setupKebabMenu()
            createAccountLabel.isHidden = true
            addBooksButton.isHidden = false
            loginSignupButton.isHidden = true
            nameLabel.text = currentUser?.displayName ?? "User" // Display user's name
        } else {
            // User is not logged in
            createAccountLabel.isHidden = false
            addBooksButton.isHidden = true
            loginSignupButton.isHidden = false
            nameLabel.text = "Profile"
        }
    }

    @objc private func addBooksButtonTapped() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }

    @objc private func loginSignupButtonTapped() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }

    // MARK: - Kebab Menu
    private func setupKebabMenu() {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Edit Profile", image: UIImage(systemName: "pencil")) { _ in
                self.editProfile()
            },
            UIAction(title: "Book Support", image: UIImage(systemName: "questionmark.circle")) { _ in
                self.bookSupport()
            },
            UIAction(title: "Log Out", image: UIImage(systemName: "arrow.backward.circle"), attributes: .destructive) { _ in
                self.logOut()
            }
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
    }

    private func editProfile() {
        let editVC = EditProfileViewController()
        navigationController?.pushViewController(editVC, animated: true)
    }

    private func bookSupport() {
        let bookSupportVC = BookSupportViewController()
        navigationController?.pushViewController(bookSupportVC, animated: true)
    }

    private func logOut() {
        do {
            try Auth.auth().signOut()
            checkUserLoginStatus()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    private func loadRenterData() {
        guard let userID = currentUser?.uid else {
            return
        }

        db.collection("renters").document(userID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                return
            }

            guard let data = snapshot?.data(),
                  let rentedBooksArray = data["rentedBooks"] as? [[String: Any]] else {
                self.rentableBooks = []
                self.noBooksLabel.isHidden = false
                self.booksCollectionView.reloadData()
                return
            }

            var rentedBooks: [RentersBook] = []

            for bookData in rentedBooksArray {
                let book = createRentersBook(from: bookData)
                rentedBooks.append(book)
            }

            self.rentableBooks = rentedBooks
            self.noBooksLabel.isHidden = !self.rentableBooks.isEmpty
            self.booksCollectionView.reloadData()
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




    // MARK: - Long Press Gesture
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        booksCollectionView.addGestureRecognizer(longPressGesture)
    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let point = gesture.location(in: booksCollectionView)
        if let indexPath = booksCollectionView.indexPathForItem(at: point) {
            let selectedBook = rentableBooks[indexPath.item]
            showBookOptions(for: selectedBook)
        }
    }

    private func showBookOptions(for book: RentersBook) {
        let alert = UIAlertController(title: "Book Options", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Edit Price", style: .default) { _ in
            self.editBookPrice(for: book)
        })

        alert.addAction(UIAlertAction(title: "Remove from Rent", style: .destructive) { _ in
            self.removeBookFromRent(book)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func editBookPrice(for book: RentersBook) {
        let alert = UIAlertController(title: "Edit Price", message: "Enter new price for \(book.title)", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "New Price"
            textField.keyboardType = .decimalPad
            textField.text = String(format: "%.2f", book.price) // Show current price
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let newPriceText = alert.textFields?.first?.text,
                  let newPrice = Double(newPriceText) else {
                return // Exit if input is invalid
            }

            self.updateBookPrice(bookID: book.id, newPrice: newPrice) { success in
                if success {
                    DispatchQueue.main.async {
                        self.loadRenterData() // Refresh data
                    }
                }
            }
        })

        present(alert, animated: true)
    }

    func updateBookPrice(bookID: String, newPrice: Double, completion: @escaping (Bool) -> Void) {
        guard let userID = currentUser?.uid else {
            return
        }
        let renterRef = db.collection("renters").document(userID)

        renterRef.getDocument { document, error in
            guard let document = document, document.exists,
                  var rentedBooks = document.data()?["rentedBooks"] as? [[String: Any]] else {
                print("Error fetching renter's books: \(error?.localizedDescription ?? "No data found")")
                completion(false)
                return
            }

            // Find the book in rentedBooks and update its price
            if let index = rentedBooks.firstIndex(where: { $0["id"] as? String == bookID }) {
                rentedBooks[index]["price"] = newPrice

                // Write updated array back to Firestore
                renterRef.updateData(["rentedBooks": rentedBooks]) { error in
                    if let error = error {
                        print("Error updating price: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Price updated successfully")
                        completion(true)
                    }
                }
            } else {
                print("Book not found in rentedBooks")
                completion(false)
            }
        }
    }



    private func removeBookFromRent(_ book: RentersBook) {
        let alert = UIAlertController(
            title: "Remove Book",
            message: "Are you sure you want to remove \"\(book.title)\" from rent?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
            self.deleteBook(bookID: book.id) { success in
                if success {
                    DispatchQueue.main.async {
                        self.loadRenterData() // Refresh the UI
                    }
                } else {
                    self.showErrorMessage("Failed to remove book. Please try again.")
                }
            }
        })

        present(alert, animated: true)
    }

    // MARK: - Firestore Delete Function
    private func deleteBook(bookID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = currentUser?.uid else {
            return
        }
        let renterRef = db.collection("renters").document(userID)

        renterRef.getDocument { document, error in
            guard let document = document, document.exists,
                  var rentedBooks = document.data()?["rentedBooks"] as? [[String: Any]] else {
                print("Error fetching rented books: \(error?.localizedDescription ?? "No data found")")
                completion(false)
                return
            }

            // Remove the book from the array
            rentedBooks.removeAll { $0["id"] as? String == bookID }

            // Update Firestore with the new rentedBooks array
            renterRef.updateData(["rentedBooks": rentedBooks]) { error in
                if let error = error {
                    print("Error removing book: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Book successfully removed from rent")
                    completion(true)
                }
            }
        }
    }


    // MARK: - Error Handling
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Collection View Delegate & Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rentableBooks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = booksCollectionView.dequeueReusableCell(withReuseIdentifier: BookssCell.reuseIdentifier, for: indexPath) as? BookssCell else {
            fatalError("Could not dequeue BookssCell")
        }
        let book = rentableBooks[indexPath.item]
        cell.configure(with: book)
        return cell
    }

}
