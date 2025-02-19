import UIKit

class OnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "Find Your Next Read"
        titleLabel.textColor = UIColor(hex: "#005C78")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let cardStack = UIStackView(arrangedSubviews: [
            CardView(imageName: "magnifyingglass", title: "Explore", description: "Discover a vast collection of books available for rent in your area and find your next great read!", isSystemImage: true),
            CardView(imageName: "hand.thumbsup.fill", title: "Personalized Recommendations", description: "Get book suggestions tailored to your taste based on your reading history and preferences.", isSystemImage: true),
            CardView(imageName: "house.fill", title: "Rent From Those Near You", description: "Easily borrow books from people nearby and enjoy convenient, community-driven reading.", isSystemImage: true)
        ])
        
        cardStack.axis = .vertical
        cardStack.spacing = 30
        cardStack.layoutMargins = UIEdgeInsets(top: 50, left: 16, bottom: 0, right: 16)
        cardStack.isLayoutMarginsRelativeArrangement = true
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardStack)
        
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = UIColor(hex: "#005C78")
        continueButton.layer.cornerRadius = 10
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(navigateToHome), for: .touchUpInside)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cardStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            cardStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func navigateToHome() {
        let tabBarController = TabBarController()
        let window = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first }
            .first
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}

class CardView: UIView {
    
    init(imageName: String, title: String, description: String, isSystemImage: Bool) {
        super.init(frame: .zero)
        setupView(imageName: imageName, title: title, description: description, isSystemImage: isSystemImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(imageName: String, title: String, description: String, isSystemImage: Bool) {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        let imageView: UIImageView
        if isSystemImage {
            imageView = UIImageView(image: UIImage(systemName: imageName))
        } else {
            imageView = UIImageView(image: UIImage(named: imageName))
        }
        imageView.tintColor = UIColor(hex: "#005C78")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(hex: "#005C78")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 8
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [imageView, textStack])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
