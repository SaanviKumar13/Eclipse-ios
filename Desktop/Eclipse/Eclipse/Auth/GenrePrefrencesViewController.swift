import UIKit

class GenrePreferencesViewController: UIViewController {
    
    let genres = [
        ("Fiction", "book.fill"),
        ("Non-Fiction", "book.fill"),
        ("Fantasy", "sparkles"),
        ("Mystery", "magnifyingglass"),
        ("Romance", "heart.fill"),
        ("Historical", "book.closed"),
        ("Biography", "person.fill"),
        ("Self-Help", "person.3.fill"),
        ("Poetry", "textformat.size"),
        ("Graphic Novel", "rectangle.compress.vertical")
    ]
    
    var selectedGenres: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "Selected Preferences"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let bubbleStackView = UIStackView()
        bubbleStackView.axis = .vertical
        bubbleStackView.spacing = 16
        bubbleStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bubbleStackView)
        
        var horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 16
        horizontalStackView.distribution = .fillEqually
        
        for (index, genre) in genres.enumerated() {
            let bubbleButton = createBubbleButton(for: genre)
            horizontalStackView.addArrangedSubview(bubbleButton)
            
            if (index + 1) % 2 == 0 || index == genres.count - 1 {
                bubbleStackView.addArrangedSubview(horizontalStackView)
                
                if index < genres.count - 1 {
                    horizontalStackView = UIStackView()
                    horizontalStackView.axis = .horizontal
                    horizontalStackView.spacing = 16
                    horizontalStackView.distribution = .fillEqually
                }
            }
        }

        let nextButton = UIButton()
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = UIColor(hex: "#005C78")
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 10
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            bubbleStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            bubbleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bubbleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nextButton.topAnchor.constraint(equalTo: bubbleStackView.bottomAnchor, constant: 30),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func createBubbleButton(for genre: (String, String)) -> UIButton {
        let genreName = genre.0
        let symbolName = genre.1
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = genreName
        configuration.image = UIImage(systemName: symbolName)
        
        configuration.baseForegroundColor = UIColor(hex: "#005C78")
        configuration.imagePadding = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        
        let titleAttributes = AttributeContainer([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        configuration.attributedTitle = AttributedString(genreName, attributes: titleAttributes)
        configuration.background.backgroundColor = .white
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        
        button.layer.borderColor = UIColor(hex: "#005C78").cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        button.addTarget(self, action: #selector(bubbleTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return button
    }
    
    @objc private func bubbleTapped(_ sender: UIButton) {
        guard let configuration = sender.configuration,
              let attributedTitle = configuration.attributedTitle else {
            print("Button configuration or title is nil.")
            return
        }

        let titleString = attributedTitle.description
        
        guard !titleString.isEmpty else {
            print("Title string is empty.")
            return
        }

        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                sender.transform = CGAffineTransform.identity
            })
        }

        if selectedGenres.contains(titleString) {
            selectedGenres.removeAll { $0 == titleString }
            sender.configuration?.background.backgroundColor = .white
            sender.configuration?.baseForegroundColor = UIColor(hex: "#005C78")
        } else {
            selectedGenres.append(titleString)
            sender.configuration?.background.backgroundColor = UIColor(hex: "#005C78")
            sender.configuration?.baseForegroundColor = .white
        }
    }
    
    @objc private func nextButtonTapped() {
        let nextViewController = AuthorPreferencesViewController()
        nextViewController.modalPresentationStyle = .fullScreen
        present(nextViewController, animated: true, completion: nil)
    }
}


