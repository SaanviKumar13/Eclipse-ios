import UIKit

class BookSupportViewController: UIViewController {
    
    private let caseSections = ["Open Cases", "Closed Cases"]
    private let books = [
        [
            ["title": "Harry Potter", "image": "harry_potter_goblet_of_fire"],
            ["title": "Mockingbird", "image": "to_kill_a_mocking_bird"],
            ["title": "1984", "image": "1984"]
        ],
        [
            ["title": "Whiplash", "image": "whiplash"],
            ["title": "Oceania", "image": "oceania"]
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.title = "Book Support"

        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        for (index, section) in caseSections.enumerated() {
            let sectionLabel = UILabel()
            sectionLabel.text = section
            sectionLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
            sectionLabel.textAlignment = .left
            sectionLabel.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(sectionLabel)
            
            let booksStackView = UIStackView()
            booksStackView.axis = .vertical
            booksStackView.spacing = 15
            booksStackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(booksStackView)
            
            for book in books[index] {
                if let title = book["title"], let imageName = book["image"] {
                    let bookCard = createBookCard(title: title, imageName: imageName)
                    booksStackView.addArrangedSubview(bookCard)
                }
            }
        }
    }
    
    private func createBookCard(title: String, imageName: String) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 15
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowRadius = 4
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let bookImageView = UIImageView()
        bookImageView.image = UIImage(named: imageName)
        bookImageView.contentMode = .scaleAspectFill
        bookImageView.clipsToBounds = true
        bookImageView.layer.cornerRadius = 10
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(bookImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "SFPro-Regular", size: 18)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        let chatButton = UIButton(type: .system)
        chatButton.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        chatButton.tintColor = UIColor(named: "#005C78") ?? .systemBlue
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(chatButton)
        
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 100),
            
            bookImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            bookImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            bookImageView.widthAnchor.constraint(equalToConstant: 60),
            bookImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            chatButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chatButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chatButton.widthAnchor.constraint(equalToConstant: 30),
            chatButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return cardView
    }
    
    @objc private func chatButtonTapped() {
        let chatVC = ChatViewController()
        navigationController?.pushViewController(chatVC, animated: true)
    }
}


