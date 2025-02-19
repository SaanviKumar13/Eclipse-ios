import UIKit
import FirebaseFirestore
import FirebaseAuth

class BookViewController: UIViewController {
    private let book: BookF
    private let db = Firestore.firestore()
    private var isBookAdded: Bool = false {
        didSet {
            updateAddButtonAppearance()
        }
    }

    private let bookImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()

    private let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Buy", for: .normal)
        button.setTitleColor(UIColor(hex: "005C78"), for: .normal)
        button.layer.borderColor = UIColor(hex: "005C78").cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let rentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rent", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "005C78")
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    private let addToLibraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    init(book: BookF) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUI()
        checkIfBookIsAdded()

        buyButton.addTarget(self, action: #selector(navigateToRentersNearby), for: .touchUpInside)
        rentButton.addTarget(self, action: #selector(navigateToRentersNearby), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        addToLibraryButton.addTarget(self, action: #selector(addToLibraryTapped), for: .touchUpInside)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = book.title
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: bookmarkButton),
            UIBarButtonItem(customView: addToLibraryButton)
        ]

        let buttonStack = UIStackView(arrangedSubviews: [buyButton, rentButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.alignment = .center
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIStackView(arrangedSubviews: [bookImageView, titleLabel, descriptionLabel, buttonStack])
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.alignment = .center
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            bookImageView.widthAnchor.constraint(equalToConstant: 200),
            bookImageView.heightAnchor.constraint(equalToConstant: 300),
            descriptionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }

    private func configureUI() {
        titleLabel.text = book.title
        descriptionLabel.text = book.description ?? "No description available."

        if let imageUrl = book.imageLinks?.thumbnail, let url = URL(string: imageUrl) {
            downloadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.bookImageView.image = image ?? UIImage(systemName: "book.fill")
                }
            }
        } else {
            bookImageView.image = UIImage(systemName: "book.fill")
        }
    }

    private func checkIfBookIsAdded() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("renters").document(userID).getDocument { [weak self] document, error in
            if let data = document?.data(), let rentedBooks = data["rentedBooks"] as? [[String: Any]] {
                self?.isBookAdded = rentedBooks.contains { $0["id"] as? String == self?.book.id }
            }
        }
    }
    @objc private func addToLibraryTapped() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let alert = UIAlertController(title: "Enter Price", message: "Enter the price you want to rent the book for per day", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Price per day"
            textField.keyboardType = .decimalPad
        }

        // Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Save button
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let priceText = alert.textFields?.first?.text,
                  let price = Double(priceText) else { return }
            
            // Prepare book data with price
            let bookData: [String: Any] = [
                "id": self.book.id,
                "title": self.book.title,
                "authors": self.book.authors ?? [],
                "imageURL": self.book.imageLinks?.thumbnail ?? "",
                "addedAt": Timestamp(),
                "description": self.book.description ?? "",
                "price": price // Store the entered price
            ]

            // Store book data in Firestore
            self.db.collection("renters").document(userID).setData([
                "rentedBooks": FieldValue.arrayUnion([bookData])
            ], merge: true) { error in
                if error == nil {
                    self.isBookAdded = true
                    self.showConfirmationAlert()
                } else {
                    // Handle error if any
                    self.showErrorMessage("Failed to add the book to your library.")
                }
            }
        })

        present(alert, animated: true)
    }

    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func updateAddButtonAppearance() {
        addToLibraryButton.tintColor = isBookAdded ? UIColor(hex: "#008000") : UIColor(hex: "005C78")
    }

    @objc private func navigateToRentersNearby() {
//        let rentersVC = RentersNearbyViewController()
//        navigationController?.pushViewController(rentersVC, animated: true)
    }

    @objc private func bookmarkButtonTapped() {
//        let addToLibraryVC = AddToLibraryViewController()
//        addToLibraryVC.book = book
//
//        let navController = UINavigationController(rootViewController: addToLibraryVC)
//        navController.modalPresentationStyle = .formSheet
//        present(navController, animated: true, completion: nil)
    }
    
    private func showConfirmationAlert() {
        let alert = UIAlertController(title: "Success", message: "Book added to your rentals!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


