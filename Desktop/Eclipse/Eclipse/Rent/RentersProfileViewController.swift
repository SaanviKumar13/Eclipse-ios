import UIKit
import Firebase

class RentersProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Properties
    var rentedBooks: [RentersBook] = []
    var renterID: String
    var renterRating: Rating

    // MARK: - UI Components
    let averageRatingLabel = UILabel()
    private let profileImageView = UIImageView(image: UIImage(named: "profile"))
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    private let ratingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rate Renter", for: .normal)
        return button
    }()
    
    let bannerImageView = UIImageView(image: UIImage(named: "banner"))
    
    private var booksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let numberOfColumns: CGFloat = 3
        let spacing: CGFloat = 16
        let totalSpacing = spacing * (numberOfColumns - 1) // Total space between items
        let itemWidth = (UIScreen.main.bounds.width - (spacing * 2) - totalSpacing) / numberOfColumns
        
        layout.itemSize = CGSize(width: itemWidth, height: 240)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
        return collectionView
    }()


    // MARK: - Initialization
    init(renterID: String, rentedBooks: [RentersBook] = [], renterRating:Rating) {
        self.renterID = renterID
        self.rentedBooks = rentedBooks
        self.renterRating = renterRating
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRenterData()
        setupNotifications()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        setupHeaderView()
        setupBooksCollection()
    }
    
    private func setupHeaderView() {
        // Banner Image
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

        // Rate Renter Button
        ratingButton.translatesAutoresizingMaskIntoConstraints = false
        ratingButton.setTitle("Rate Renter", for: .normal)
        ratingButton.tintColor = .white
        ratingButton.backgroundColor = .systemBlue
        ratingButton.layer.cornerRadius = 8
        ratingButton.layer.shadowColor = UIColor.black.cgColor
        ratingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        ratingButton.layer.shadowOpacity = 0.2
        ratingButton.layer.shadowRadius = 4
        ratingButton.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
        view.addSubview(ratingButton)

        // Rating Icon (Star)
        let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
        starImageView.tintColor = .yellow
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(starImageView)
        averageRatingLabel.font = UIFont.systemFont(ofSize: 18)
        averageRatingLabel.textColor = .white
        averageRatingLabel.textAlignment = .left
        averageRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(averageRatingLabel)
        
        // Constraints to place "Rate Renter", star icon, and rating side by side
        NSLayoutConstraint.activate([
            ratingButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            ratingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ratingButton.heightAnchor.constraint(equalToConstant: 44),

            // Star icon constraints
            starImageView.centerYAnchor.constraint(equalTo: ratingButton.centerYAnchor),
            starImageView.leadingAnchor.constraint(equalTo: ratingButton.trailingAnchor, constant: 10),
            starImageView.widthAnchor.constraint(equalToConstant: 20),
            starImageView.heightAnchor.constraint(equalToConstant: 20),

            // Average Rating Label constraints
            averageRatingLabel.centerYAnchor.constraint(equalTo: ratingButton.centerYAnchor),
            averageRatingLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 5),
            averageRatingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

            let average = renterRating.averageRating
            averageRatingLabel.text = String(format: "%.2f", average)
    }


    
    private func setupBooksCollection() {
        booksCollectionView.delegate = self
        booksCollectionView.dataSource = self
        view.addSubview(booksCollectionView)
        
        booksCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            booksCollectionView.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 10),
            booksCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            booksCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            booksCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    
    private func loadRenterData() {
        fetchRenterDetails(renterID: renterID) { [weak self] name, renterRatingData in
            guard let self = self else { return }
            
            self.nameLabel.text = name
            self.navigationItem.title = name
        }
        
        fetchRentedBooks(renterID: renterID) { [weak self] books in
            guard let self = self else { return }
            self.rentedBooks = books
            self.booksCollectionView.reloadData()
        }
    }


    // MARK: - Actions
    @objc private func ratingButtonTapped() {
        let ratingPopup = RatingPopupView()
        
        // Assuming the popup will return a dictionary with keys: "bookQuality", "communication", "overallExperience"
        ratingPopup.setCompletion { [weak self] rating in
            guard let self = self else { return }
            
            // Update renter's rating using the dictionary returned from the popup
            self.updateRenterRating(rating)
        }
        
        view.addSubview(ratingPopup)
        ratingPopup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingPopup.topAnchor.constraint(equalTo: view.topAnchor),
            ratingPopup.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ratingPopup.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ratingPopup.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Method to update renter's rating in Firestore
    private func updateRenterRating(_ rating: Rating) {
        let ratingData = rating.toDictionary()
        Firestore.firestore().collection("renters").document(renterID).updateData(["rating": ratingData]) { error in
            if let error = error {
                print("Error updating rating: \(error.localizedDescription)")
            } else {
                print("Successfully updated renter rating")
            }
        }
    }

    // MARK: - Notifications
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleBookUpdate), name: NSNotification.Name("BookUpdated"), object: nil)
    }
    
    @objc private func handleBookUpdate() {
        fetchRentedBooks(renterID: renterID) { [weak self] books in
            self?.rentedBooks = books
            self?.booksCollectionView.reloadData()
        }
    }
}

// MARK: - Collection View Delegate & Data Source
extension RentersProfileViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rentedBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        cell.configure(with: rentedBooks[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBook = rentedBooks[indexPath.item]
//        let bookVC = BookViewController(book: selectedBook)
//        navigationController?.pushViewController(bookVC, animated: true)
    }
}

