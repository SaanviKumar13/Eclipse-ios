import UIKit

class BookListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var selectedGenre: String?
    var books: [BookF] = []
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .left
        label.backgroundColor = UIColor(hex: "005C78", alpha: 0.2)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupHeaderLabel()
        setupCollectionView()
        
        if let selectedGenre = selectedGenre {
            headerLabel.text = "   🌟 Explore books in \(selectedGenre.capitalized)!"
            fetchBooks(for: selectedGenre)
        } else {
            headerLabel.text = "🌟 Explore all available books!"
            fetchBooks(for: "all")
        }
    }
    
    private func setupHeaderLabel() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: 160, height: 300)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 24
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(BookCells.self, forCellWithReuseIdentifier: "BookCells")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchBooks(for genre: String) {
        Eclipse.fetchBooks(query: genre) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let books):
                    self?.books = books
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("Error fetching books: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCells", for: indexPath) as? BookCells else {
            return UICollectionViewCell()
        }
        
        let book = books[indexPath.item]
        cell.configure(book: book)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBook = books[indexPath.item]
        let bookDetailVC = BookViewController(book: selectedBook)
        navigationController?.pushViewController(bookDetailVC, animated: true)
    }

}

class BookCells: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 1
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemOrange
        return label
    }()
    
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private var imageCache = NSCache<NSString, UIImage>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(bookImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(ratingLabel)
        
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bookImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bookImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bookImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bookImageView.heightAnchor.constraint(equalToConstant: 180),
            
            titleLabel.topAnchor.constraint(equalTo: bookImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            ratingLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            ratingLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(book: BookF) {
        titleLabel.text = book.title
        subtitleLabel.text = book.authors?.joined(separator: ", ") ?? "Unknown Author"
        
        if let rating = book.averageRating {
            ratingLabel.text = "⭐️ \(String(rating))"
        } else {
            ratingLabel.text = "⭐️ N/A"
        }
        
        if let imageUrl = book.imageLinks?.smallThumbnail {
            loadImage(from: imageUrl)
        } else {
            bookImageView.image = UIImage(systemName: "book.fill")
        }
    }

    
    private func loadImage(from urlString: String) {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            bookImageView.image = cachedImage
            return
        }
        
        guard let imageUrl = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        let downloadTask = session.dataTask(with: imageUrl) { [weak self] (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                self?.imageCache.setObject(image, forKey: urlString as NSString)
                DispatchQueue.main.async {
                    self?.bookImageView.image = image
                }
            }
        }
        
        downloadTask.resume()
    }
}


