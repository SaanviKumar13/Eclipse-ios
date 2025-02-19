import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    let categories = ["All", "Fiction", "Romance", "Dystopian", "Classic", "Mystery"]

    // MARK: - Properties
    private let quizButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start Quiz", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let quizText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Take a Quiz"
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quizView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let recommendedListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let bookMiddle: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray // Placeholder color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let bookLeft: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray // Placeholder color
        imageView.alpha = 0.7
        imageView.transform = CGAffineTransform(rotationAngle: -0.2)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let bookRight: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray // Placeholder color
        imageView.alpha = 0.7
        imageView.transform = CGAffineTransform(rotationAngle: 0.2)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let swipeBook: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray // Placeholder color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var selectedCategoryIndex: Int = 0
    
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupTableView()
        addGradientToQuizView()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add subviews
        view.addSubview(quizView)
        quizView.addSubview(quizText)
        quizView.addSubview(quizButton)
        view.addSubview(collectionView)
        view.addSubview(recommendedListTableView)
        view.addSubview(bookMiddle)
        view.addSubview(bookLeft)
        view.addSubview(bookRight)
        view.addSubview(swipeBook)
        
        // Add tap gesture to swipeBook
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(swipeBookTapped))
        swipeBook.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Quiz View
            quizView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            quizView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            quizView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            quizView.heightAnchor.constraint(equalToConstant: 150),
            
            // Quiz Text
            quizText.topAnchor.constraint(equalTo: quizView.topAnchor, constant: 20),
            quizText.leadingAnchor.constraint(equalTo: quizView.leadingAnchor, constant: 20),
            quizText.trailingAnchor.constraint(equalTo: quizView.trailingAnchor, constant: -20),
            
            // Quiz Button
            quizButton.bottomAnchor.constraint(equalTo: quizView.bottomAnchor, constant: -20),
            quizButton.centerXAnchor.constraint(equalTo: quizView.centerXAnchor),
            quizButton.widthAnchor.constraint(equalToConstant: 120),
            quizButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: quizView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 220),
            
            // Books Section
            bookMiddle.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            bookMiddle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookMiddle.widthAnchor.constraint(equalToConstant: 120),
            bookMiddle.heightAnchor.constraint(equalToConstant: 180),
            
            bookLeft.topAnchor.constraint(equalTo: bookMiddle.topAnchor),
            bookLeft.rightAnchor.constraint(equalTo: bookMiddle.leftAnchor, constant: -10),
            bookLeft.widthAnchor.constraint(equalToConstant: 120),
            bookLeft.heightAnchor.constraint(equalToConstant: 180),
            
            bookRight.topAnchor.constraint(equalTo: bookMiddle.topAnchor),
            bookRight.leftAnchor.constraint(equalTo: bookMiddle.rightAnchor, constant: 10),
            bookRight.widthAnchor.constraint(equalToConstant: 120),
            bookRight.heightAnchor.constraint(equalToConstant: 180),
            
            // Recommended List Table View
            recommendedListTableView.topAnchor.constraint(equalTo: bookMiddle.bottomAnchor, constant: 20),
            recommendedListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recommendedListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recommendedListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Swipe Book
            swipeBook.topAnchor.constraint(equalTo: bookMiddle.topAnchor),
            swipeBook.leadingAnchor.constraint(equalTo: bookLeft.leadingAnchor),
            swipeBook.trailingAnchor.constraint(equalTo: bookRight.trailingAnchor),
            swipeBook.bottomAnchor.constraint(equalTo: bookMiddle.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "categoryCell")
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupTableView() {
        recommendedListTableView.dataSource = self
        recommendedListTableView.delegate = self
        recommendedListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "recommendedListCell")
    }
    
    private func addGradientToQuizView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.0, green: 0.36, blue: 0.47, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 0.36, blue: 0.47, alpha: 0.6).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = quizView.bounds
        quizView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frame when view layout changes
        if let gradientLayer = quizView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = quizView.bounds
        }
    }
    
    // MARK: - Actions
    @objc private func swipeBookTapped() {
        let swipeVC = SwipeScreen()
        swipeVC.modalPresentationStyle = .fullScreen
        present(swipeVC, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendedLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recommendedListCell", for: indexPath)
        cell.textLabel?.text = recommendedLists[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
    
    // MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath)
        cell.backgroundColor = .lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.item]
        
        let bookListVC = BookListViewController()
        bookListVC.selectedGenre = selectedCategory
        bookListVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(bookListVC, animated: true)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


var recommendedLists: [RecommendedList] = [
    RecommendedList(
        title: "Italian Vacation Vibes",
        subtitle: "No need to book a flight- these books will transport you to Italy",
        books: [
            "9", // Beautiful Ruins
            "10", // One Italian Summer
            "11"  // Under the Tuscan Sun
        ]
    ),
    
    RecommendedList(
        title: "Romantic Reads",
        subtitle: "Heartfelt stories of love and relationships",
        books: [
            "2", // It Ends with Us
            "4", // Pride and Prejudice
            "9", // Beautiful Ruins
            "10", // One Italian Summer
            "7"  // The Great Gatsby
        ]
    ),
    
    RecommendedList(
        title: "Classic Literature",
        subtitle: "Timeless classics that have stood the test of time",
        books: [
            "3", // 1984
            "4", // Pride and Prejudice
            "8", // The Catcher in the Rye
            "5", // To Kill a Mockingbird
            "7"  // The Great Gatsby
        ]
    ),
    
    RecommendedList(
        title: "Fantasy & Adventure",
        subtitle: "Magical worlds and thrilling quests",
        books: [
            "13", // Harry Potter and the Goblet of Fire
            "14", // Percy Jackson
            "12", // Dark Matter
            "7",  // The Great Gatsby
            "8"   // The Catcher in the Rye
        ]
    ),
    
    RecommendedList(
        title: "Historical & Thought-Provoking",
        subtitle: "Books that inspire and challenge your views on history",
        books: [
            "16", // Killers of the Flower Moon
            "3",  // 1984
            "6",  // Where the Crawdads Sing
            "5",  // To Kill a Mockingbird
            "1"   // The Midnight Library
        ]
    )
]
