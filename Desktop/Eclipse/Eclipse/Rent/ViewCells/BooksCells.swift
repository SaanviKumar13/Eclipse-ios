import UIKit
import SDWebImage

class BooksCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with book: RentersBook) {
        imageView.image = UIImage(systemName: "book.fill") // Placeholder image
        
        let imageURL = book.imageURL
        
        let secureURL = imageURL.replacingOccurrences(of: "http://", with: "https://")
        print("🔗 Loading Image URL: \(secureURL)")

        guard let url = URL(string: secureURL) else {
            print("❌ Invalid URL: \(secureURL)")
            return
        }

        downloadImage(from: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image ?? UIImage(systemName: "book.fill")
            }
        }
    }
}


class BookCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with book: RentersBook) {
        imageView.image = UIImage(systemName: "book.fill") // Placeholder image
        
        let imageURL = book.imageURL
        
        let secureURL = imageURL.replacingOccurrences(of: "http://", with: "https://")
        
        guard let url = URL(string: secureURL) else {
            return
        }
        
        imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "book.fill"))
    }
}


