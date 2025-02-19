
import UIKit
import SDWebImage // For image loading

class BookssCell: UICollectionViewCell {

    // MARK: - Properties
    static let reuseIdentifier = "BookssCell" // Ensure consistency when registering

    // UI Components
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true // Ensures the rounded corners work
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowRadius = 4
        contentView.layer.masksToBounds = false // Important: Allows shadow effect

        // Add subviews
        contentView.addSubview(bookImageView)

        // Constraints
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bookImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bookImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            bookImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            bookImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Configuration
    func configure(with book: RentersBook) {
        guard let imageURL = URL(string: book.imageURL) else {
            bookImageView.image = UIImage(named: "placeholder")
            return
        }
        
        // Use SDWebImage to load image
        bookImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"), options: [.continueInBackground, .highPriority])
    }
}
