import UIKit

// MARK: - AuthorCellDelegate Protocol
protocol AuthorCellDelegate: AnyObject {
    func didFollowAuthor(_ authorName: String)
}

// MARK: - AuthorPreferencesViewController
class AuthorPreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AuthorCellDelegate {
    
    var followedAuthors = [String]()
    let authors = [
        ("Jane Austen", "jane_austen", "An English novelist known for her romantic fiction. Her works explore themes of love, social class, and women's independence."),
        ("Michelle Obama", "michelle_obama", "An American attorney and author who served as the First Lady of the United States from 2009 to 2017."),
        ("Sarah James", "sarah_james", "A contemporary author acclaimed for her heartfelt narratives and rich character development."),
        ("Mark Twain", "mark_twain", "An American writer, humorist, and lecturer known for his classic novels."),
        ("Haruki Murakami", "haruki_murakami", "A Japanese author known for his surreal and imaginative narratives.")
    ]

    let tableView = UITableView()
    let continueButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Authors"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AuthorCell.self, forCellReuseIdentifier: "AuthorCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = UIColor(hex: "#005C78")
        continueButton.layer.cornerRadius = 12
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -16),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6),
            continueButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func continueButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSetAuthorPreferences")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorCell", for: indexPath) as! AuthorCell
        let author = authors[indexPath.row]
        cell.configure(with: author)
        cell.delegate = self
        return cell
    }

    func didFollowAuthor(_ authorName: String) {
        if !followedAuthors.contains(authorName) {
            followedAuthors.append(authorName)
        }
    }
}

// MARK: - AuthorCell
class AuthorCell: UITableViewCell {
    
    weak var delegate: AuthorCellDelegate?
    private let backgroundCardView = UIView()
    private let authorImageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let followButton = UIButton(type: .system)
    private var isFollowing = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundCardView.backgroundColor = UIColor(hex: "#F8F8F8")
        backgroundCardView.layer.cornerRadius = 16
        backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        backgroundCardView.layer.shadowOpacity = 0.1
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backgroundCardView.layer.shadowRadius = 8
        backgroundCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundCardView)
        
        authorImageView.contentMode = .scaleAspectFill
        authorImageView.clipsToBounds = true
        authorImageView.layer.cornerRadius = 10
        authorImageView.layer.borderColor = UIColor(hex: "#005C78").cgColor
        authorImageView.layer.borderWidth = 2
        authorImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundCardView.addSubview(authorImageView)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textColor = UIColor(hex: "#005C78")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundCardView.addSubview(nameLabel)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundCardView.addSubview(descriptionLabel)
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(.white, for: .normal)
        followButton.backgroundColor = UIColor(hex: "#005C78")
        followButton.layer.cornerRadius = 12
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        backgroundCardView.addSubview(followButton)
        
        NSLayoutConstraint.activate([
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            backgroundCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            authorImageView.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 16),
            authorImageView.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 16),
            authorImageView.widthAnchor.constraint(equalToConstant: 80),
            authorImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: authorImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: followButton.topAnchor, constant: -12),
            
            followButton.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 16),
            followButton.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -16),
            followButton.bottomAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: -16),
            followButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    func configure(with authorInfo: (String, String, String)) {
        nameLabel.text = authorInfo.0
        authorImageView.image = UIImage(named: authorInfo.1)
        descriptionLabel.text = authorInfo.2
        followButton.setTitle(isFollowing ? "Following" : "Follow", for: .normal)
        followButton.backgroundColor = isFollowing ? .white : UIColor(hex: "#005C78")
    }

    @objc private func followButtonTapped() {
        isFollowing.toggle()
        followButton.setTitle(isFollowing ? "Following" : "Follow", for: .normal)
        followButton.backgroundColor = isFollowing ? .gray : UIColor(hex: "#005C78")
        
        if let authorName = nameLabel.text {
            delegate?.didFollowAuthor(authorName)
        }
    }
}


