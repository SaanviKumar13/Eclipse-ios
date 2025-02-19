
import UIKit
import Foundation

struct Book1: Identifiable {
    var id = UUID()
    var title: String
    var imageName: String
    var description: String
    let amazonRating: String
    let goodreadsRating: String
}

class SwipeScreen: UIViewController {
    var currentBookIndex = 0
    var bookView: UIView!
    let books: [Book1] = [
        Book1(title: "The Great Gatsby", imageName: "great_gatsby", description: "A novel by F. Scott Fitzgerald that explores the themes of decadence, idealism, resistance to change, social upheaval, and excess, set in the Roaring Twenties. It follows the story of Jay Gatsby, a mysterious millionaire, and his obsession with the beautiful Daisy Buchanan, as narrated by Nick Carraway, who becomes entangled in Gatsby's world of wealth and disillusionment.", amazonRating: "4.5", goodreadsRating: "3.91"),
        
        Book1(title: "To Kill a Mockingbird", imageName: "to_kill_a_mocking_bird", description: "Published in 1960, Harper Lee's Pulitzer Prize-winning novel is a poignant exploration of racial injustice and moral growth in the Deep South during the 1930s. Through the eyes of young Scout Finch, the story delves into the complexities of human behavior and empathy, as her father, Atticus Finch, defends a black man accused of raping a white woman, challenging the prejudices of their community.", amazonRating: "4.5", goodreadsRating: "3.91"),
        
        Book1(title: "1984", imageName: "1984", description: "George Orwell's dystopian novel is a chilling portrayal of a totalitarian regime that employs surveillance, propaganda, and thought control to maintain power. Set in a world where the Party, led by Big Brother, suppresses individuality and freedom, the story follows Winston Smith, a low-ranking member of the Party who begins to question the oppressive system and seeks truth and rebellion in a society that demands conformity.", amazonRating: "4.5", goodreadsRating: "3.91")]
    var bookImageView: UIImageView!
    var bookTitleLabel: UILabel!
    var detailsCardView: UIView!
    var amazonRatingLabel: UILabel!
    var goodreadsRatingLabel: UILabel!
    var isDescriptionExpanded = false
    private var originalTransform: CGAffineTransform = .identity
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private let swipeThreshold: CGFloat = 100.0
    private var currentAngle: CGFloat = 0.0
    var likedBooks: [Book1] = []
    var rejectedBooks: [Book1] = []

    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPanGesture()
        displayBook(at: currentBookIndex)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")

        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        let dismissButton = UIButton(type: .system)
               dismissButton.setTitle("< Back", for: .normal)
               dismissButton.setTitleColor(UIColor(hex: "#005C78"), for: .normal)
               dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
               dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
               dismissButton.translatesAutoresizingMaskIntoConstraints = false
               topBar.addSubview(dismissButton)

               NSLayoutConstraint.activate([
                   topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                   topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   topBar.heightAnchor.constraint(equalToConstant: 50),

                   dismissButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
                   dismissButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
               ])

        let titleLabel = UILabel()
        titleLabel.text = " Start Swiping!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = UIColor(hex: "#005C78")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(titleLabel)

        let iconsStackView = UIStackView()
        iconsStackView.axis = .horizontal
        iconsStackView.spacing = 10
        iconsStackView.distribution = .equalSpacing
        iconsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let alreadyReadButton = createAlreadyReadButton()
        let saveButton = createSaveButton()
        let filterButton = createFilterButton()
        
        iconsStackView.addArrangedSubview(alreadyReadButton)
        iconsStackView.addArrangedSubview(saveButton)
        iconsStackView.addArrangedSubview(filterButton)
        
        topBar.addSubview(iconsStackView)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 50),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
         titleLabel.leadingAnchor.constraint(equalTo: dismissButton.trailingAnchor, constant: 12),
            iconsStackView.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            iconsStackView.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16)
        ])

        bookView = UIView()
        bookView.backgroundColor = .white
        bookView.layer.cornerRadius = 20
        bookView.layer.shadowColor = UIColor.black.cgColor
        bookView.layer.shadowOpacity = 0.3
        bookView.layer.shadowOffset = CGSize(width: 0, height: 6)
        bookView.layer.shadowRadius = 10
        bookView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bookView)

         bookImageView = UIImageView()
         bookImageView.contentMode = .scaleAspectFill
         bookImageView.layer.cornerRadius = 20
         bookImageView.clipsToBounds = true
         bookImageView.translatesAutoresizingMaskIntoConstraints = false
         bookView.addSubview(bookImageView)

         bookTitleLabel = UILabel()
         bookTitleLabel.font = UIFont.boldSystemFont(ofSize: 28)
         bookTitleLabel.textColor = .black
         bookTitleLabel.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(bookTitleLabel)
 
                amazonRatingLabel = UILabel()
                amazonRatingLabel.font = UIFont.systemFont(ofSize: 16)
                amazonRatingLabel.textColor = .gray
                amazonRatingLabel.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(amazonRatingLabel)

                goodreadsRatingLabel = UILabel()
                goodreadsRatingLabel.font = UIFont.systemFont(ofSize: 16)
                goodreadsRatingLabel.textColor = .gray
                goodreadsRatingLabel.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(goodreadsRatingLabel)

         bookImageView.isUserInteractionEnabled = true
         bookImageView.addGestureRecognizer(UITapGestureRecognizer(target:self , action:#selector(handleBookImageTap)))

         NSLayoutConstraint.activate([
             bookView.centerXAnchor.constraint(equalTo:view.centerXAnchor),
             bookView.centerYAnchor.constraint(equalTo:view.centerYAnchor),
             bookView.widthAnchor.constraint(equalTo:view.widthAnchor , multiplier :0.8),
             bookView.heightAnchor.constraint(equalTo:view.heightAnchor , multiplier :0.6),

             bookImageView.topAnchor.constraint(equalTo :bookView.topAnchor),
             bookImageView.bottomAnchor.constraint(equalTo :bookView.bottomAnchor),
             bookImageView.leadingAnchor.constraint(equalTo :bookView.leadingAnchor),
             bookImageView.trailingAnchor.constraint(equalTo :bookView.trailingAnchor),

             bookTitleLabel.topAnchor.constraint(equalTo :bookImageView.bottomAnchor , constant :20),
                       bookTitleLabel.leadingAnchor.constraint(equalTo :view.leadingAnchor , constant :20),

                       amazonRatingLabel.topAnchor.constraint(equalTo :bookTitleLabel.bottomAnchor , constant :8),
                       amazonRatingLabel.leadingAnchor.constraint(equalTo :view.leadingAnchor , constant :20),

                       goodreadsRatingLabel.topAnchor.constraint(equalTo :amazonRatingLabel.bottomAnchor , constant :4),
                       goodreadsRatingLabel.leadingAnchor.constraint(equalTo :view.leadingAnchor , constant :20)
                   ])
     }

   
    @objc private func dismissButtonTapped() {
           self.dismiss(animated: true, completion: nil)
       }

    private func displayBook(at index: Int) {
        guard books.indices.contains(index) else { return }
        
        let book = books[index]
        
        if let image = UIImage(named: book.imageName) {
            bookImageView.image = image
        }
        
        bookTitleLabel.text = book.title
        amazonRatingLabel.text = "Amazon Rating: ⭐️\(book.amazonRating)"
            goodreadsRatingLabel.text = "Goodreads Rating: ⭐️\(book.goodreadsRating)"
    }

    @objc private func handleBookImageTap() {
        guard !isDescriptionExpanded else { return }
        
        let book = books[currentBookIndex]

        let dimmedView = UIView()
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmedView.alpha = 0
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmedView)
        
        let bottomSheetView = UIView()
        bottomSheetView.backgroundColor = UIColor.systemBackground
    
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetView.addSubview(blurView)
        
        bottomSheetView.layer.cornerRadius = 24
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetView.layer.shadowColor = UIColor.black.cgColor
        bottomSheetView.layer.shadowOpacity = 0.1
        bottomSheetView.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomSheetView.layer.shadowRadius = 10
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomSheetView)
      
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemGray6.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 500)
        bottomSheetView.layer.insertSublayer(gradientLayer, at: 0)
   
        let pullIndicator = UIView()
        pullIndicator.backgroundColor = UIColor.systemGray4
        pullIndicator.layer.cornerRadius = 2.5
        pullIndicator.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetView.addSubview(pullIndicator)
        
        let titleLabel = UILabel()
        titleLabel.text = book.title
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = UIColor.label // System label color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetView.addSubview(titleLabel)
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.systemGray5
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetView.addSubview(separatorLine)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetView.addSubview(scrollView)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = book.description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        descriptionLabel.textColor = UIColor.secondaryLabel
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(descriptionLabel)
        
        let closeButton = UIButton(type: .system)
        closeButton.backgroundColor = UIColor.systemGray6
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(UIColor(hex: "#005C78"), for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        closeButton.layer.cornerRadius = 20
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.systemGray5.cgColor
        closeButton.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetView.addSubview(closeButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeBottomSheet))
        dimmedView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
         
            blurView.topAnchor.constraint(equalTo: bottomSheetView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor),
            
      
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 500),
            bottomSheetView.heightAnchor.constraint(equalToConstant: 500),
           
            pullIndicator.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 12),
            pullIndicator.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            pullIndicator.widthAnchor.constraint(equalToConstant: 40),
            pullIndicator.heightAnchor.constraint(equalToConstant: 5),
          
            titleLabel.topAnchor.constraint(equalTo: pullIndicator.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -24),
            
            separatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            separatorLine.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            scrollView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            descriptionLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            descriptionLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
            
            closeButton.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 24),
            closeButton.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -24),
            closeButton.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor, constant: -34),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        bottomSheetView.tag = 100
        dimmedView.tag = 101
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            bottomSheetView.transform = CGAffineTransform(translationX: 0, y: -500)
            dimmedView.alpha = 1
        })
        
        isDescriptionExpanded = true
        amazonRatingLabel = UILabel()
            amazonRatingLabel.font = UIFont.systemFont(ofSize: 16)
            amazonRatingLabel.textColor = .gray
            amazonRatingLabel.translatesAutoresizingMaskIntoConstraints = false
            bottomSheetView.addSubview(amazonRatingLabel)
        
            goodreadsRatingLabel = UILabel()
            goodreadsRatingLabel.font = UIFont.systemFont(ofSize: 16)
            goodreadsRatingLabel.textColor = .gray
            goodreadsRatingLabel.translatesAutoresizingMaskIntoConstraints = false
            bottomSheetView.addSubview(goodreadsRatingLabel)
        
            NSLayoutConstraint.activate([
                amazonRatingLabel.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -8),
                amazonRatingLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 24),

                goodreadsRatingLabel.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -8),
                goodreadsRatingLabel.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -24)
            ])
    }

    private func createAlreadyReadButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "book.fill"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(alreadyReadButtonTapped), for: .touchUpInside)
        return button
    }


    private func createSaveButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }

    private func createFilterButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }

    @objc private func alreadyReadButtonTapped() {
        print("Already Read button tapped")
    }

    @objc private func saveButtonTapped() {
        print("Save button tapped")
    }

    @objc private func filterButtonTapped() {
        print("Filter button tapped")
        
    }


    @objc private func closeBottomSheet() {
        if let bottomSheetView = view.viewWithTag(100),
           let dimmedView = view.viewWithTag(101) {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                bottomSheetView.transform = .identity
                dimmedView.alpha = 0
            }) { _ in
                bottomSheetView.removeFromSuperview()
                dimmedView.removeFromSuperview()
            }
        }
        
        isDescriptionExpanded = false
    }

    private func setupPanGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bookView.addGestureRecognizer(panGestureRecognizer)
        bookView.isUserInteractionEnabled = true
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            originalTransform = bookView.transform
            
        case .changed:
            let rotation = translation.x / view.bounds.width * .pi / 8
            let scale = max(1 - abs(translation.x) / view.bounds.width * 0.2, 0.8)
            
            let transform = CGAffineTransform.identity
                .translatedBy(x: translation.x, y: translation.y)
                .rotated(by: rotation)
                .scaledBy(x: scale, y: scale)
            
            bookView.transform = transform
    
            let swipeProgress = abs(translation.x / swipeThreshold)
            if translation.x > 0 {
           
                bookView.layer.backgroundColor = UIColor.green.withAlphaComponent(min(swipeProgress * 0.3, 0.3)).cgColor
            } else {
            
                bookView.layer.backgroundColor = UIColor.red.withAlphaComponent(min(swipeProgress * 0.3, 0.3)).cgColor
            }
            
        case .ended:
            let shouldSwipe = abs(translation.x) > swipeThreshold || abs(velocity.x) > 1000
            if shouldSwipe {
                let direction: SwipeDirection = translation.x > 0 ? .right : .left
                completeSwipeAnimation(direction: direction, velocity: velocity)
            } else {
                cancelSwipeAnimation()
            }
            
        default:
            cancelSwipeAnimation()
        }
    }

    private func completeSwipeAnimation(direction: SwipeDirection, velocity: CGPoint) {
        let translationX: CGFloat = direction == .left ? -view.bounds.width * 2 : view.bounds.width * 2
        let translationY: CGFloat = velocity.y * 0.3
      
        if books.indices.contains(currentBookIndex) {
            let currentBook = books[currentBookIndex]
            if direction == .left {
                rejectedBooks.append(currentBook)
                print("Book '\(currentBook.title)' added to rejected list")
            } else {
                likedBooks.append(currentBook)
                print("Book '\(currentBook.title)' added to liked list")
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            let rotation = direction == .left ? -Double.pi / 4 : Double.pi / 4
            self.bookView.transform = CGAffineTransform.identity
                .translatedBy(x: translationX, y: translationY)
                .rotated(by: rotation)
                .scaledBy(x: 0.8, y: 0.8)
            self.bookView.alpha = 0
        }) { _ in
        
            self.currentBookIndex += 1
            if self.currentBookIndex >= self.books.count {
                return
            }
            
            self.displayBook(at: self.currentBookIndex)
            
            self.bookView.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: 50)
                .scaledBy(x: 0.9, y: 0.9)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
                self.bookView.transform = .identity
                self.bookView.alpha = 1
            })
            
            print("Liked Books: \(self.likedBooks.count)")
            print("Rejected Books: \(self.rejectedBooks.count)")
        }
    }


    private func cancelSwipeAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: {
            self.bookView.transform = .identity
            self.bookView.layer.backgroundColor = UIColor.clear.cgColor
        })
    }
   

    private func createIconButton(named iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: iconName), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        return button
    }
    func getLikedBooks() -> [Book1] {
        return likedBooks
    }

    func getRejectedBooks() -> [Book1] {
        return rejectedBooks
    }

    func clearLists() {
        likedBooks.removeAll()
        rejectedBooks.removeAll()
        print("Cleared all lists")
    }
}

enum SwipeDirection {
    case left, right
}



class FullDescriptionViewController: UIViewController {
    var descriptionText: String?
    private let buyButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Buy for $19.99", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            button.backgroundColor = UIColor(hex: "#005C78")
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.heightAnchor.constraint(equalToConstant: 55).isActive = true
            button.widthAnchor.constraint(equalToConstant: 150).isActive = true
            return button
        }()
        
        private let rentButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Rent for $4.99", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            button.backgroundColor = .clear
            button.setTitleColor(UIColor(hex: "#005C78"), for: .normal)
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor(hex: "#005C78").cgColor
            button.layer.cornerRadius = 12
            button.heightAnchor.constraint(equalToConstant: 55).isActive = true
            button.widthAnchor.constraint(equalToConstant: 150).isActive = true
            return button
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let descriptionLabel = UILabel()
        descriptionLabel.text = descriptionText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}


