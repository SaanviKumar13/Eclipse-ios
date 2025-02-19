import UIKit

class RatingPopupView: UIView {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate this Renter"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = UIColor(hex: "005C78")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    private let ratingsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()
    
    private var selectedRatings = Rating(bookQuality: 0.0, communication: 0.0, overallExperience: 0.0)
    private var completion: ((Rating) -> Void)?
    
    // Update to handle closure after initialization
    func setCompletion(_ completion: @escaping (Rating) -> Void) {
        self.completion = completion
    }

    init() {
        super.init(frame: .zero)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(ratingsStackView)
        containerView.addSubview(submitButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        ratingsStackView.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        addRatingRow(to: ratingsStackView, label: "Book Quality", parameter: "bookQuality")
        addRatingRow(to: ratingsStackView, label: "Communication", parameter: "communication")
        addRatingRow(to: ratingsStackView, label: "Overall Experience", parameter: "overallExperience")
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 400),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            ratingsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            ratingsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            ratingsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            submitButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            submitButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func addRatingRow(to stackView: UIStackView, label: String, parameter: String) {
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.spacing = 8
        rowStackView.alignment = .center
        
        let textLabel = UILabel()
        textLabel.text = label
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLabel.textColor = .black
        textLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rowStackView.addArrangedSubview(textLabel)
        
        let starsRowStackView = UIStackView()
        starsRowStackView.axis = .horizontal
        starsRowStackView.spacing = 8
        starsRowStackView.distribution = .fillEqually
        
        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.setImage(UIImage(systemName: "star"), for: .normal)
            starButton.tintColor = UIColor(hex: "005C78")
            starButton.tag = i
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starsRowStackView.addArrangedSubview(starButton)
        }
        
        rowStackView.addArrangedSubview(starsRowStackView)
        stackView.addArrangedSubview(rowStackView)
        
        // Initialize ratings for each parameter
        switch parameter {
        case "bookQuality":
            selectedRatings.bookQuality = 0.0
        case "communication":
            selectedRatings.communication = 0.0
        case "overallExperience":
            selectedRatings.overallExperience = 0.0
        default:
            break
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        // Debug: Log when a star button is tapped
        print("Star tapped: \(sender.tag)")
        
        guard let rowStackView = sender.superview?.superview as? UIStackView,
              let textLabel = rowStackView.arrangedSubviews.first as? UILabel else {
            print("Error: Could not find parameter label.")
            return
        }
        
        let parameterName = textLabel.text ?? ""
        print("Parameter: \(parameterName), Rating: \(sender.tag)")
        
        // Update the rating for each parameter
        updateSelectedRating(for: parameterName, rating: sender.tag)
        updateStars(for: parameterName, rating: sender.tag)
        
        // Debug: Log the selected ratings after update
        print("Updated Rating: \(selectedRatings)")
    }

    
    private func updateSelectedRating(for parameter: String, rating: Int) {
        // Debug: Log the parameter and rating being set
        print("Updating rating for \(parameter) to \(rating)")
        
        switch parameter {
        case "Book Quality":
            selectedRatings.bookQuality = Double(rating)
        case "Communication":
            selectedRatings.communication = Double(rating)
        case "Overall Experience":
            selectedRatings.overallExperience = Double(rating)
        default:
            print("Error: Unknown parameter \(parameter)")
        }
    }

    
    private func updateStars(for parameter: String, rating: Int) {
        for view in ratingsStackView.arrangedSubviews {
            if let rowStackView = view as? UIStackView,
               let textLabel = rowStackView.arrangedSubviews.first as? UILabel {
                if textLabel.text == parameter {
                    let starButtons = (rowStackView.arrangedSubviews.last as? UIStackView)?.arrangedSubviews as? [UIButton]
                    for (index, button) in starButtons?.enumerated() ?? [].enumerated() {
                        if index < rating {
                            button.setImage(UIImage(systemName: "star.fill"), for: .normal)
                        } else {
                            button.setImage(UIImage(systemName: "star"), for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func closeTapped() {
        removeFromSuperview()
    }
    
    @objc private func submitTapped() {
        // Debug print to check selected ratings when submitting
        print("Ratings Submitted: \(selectedRatings)")
        completion?(selectedRatings)
        removeFromSuperview()
    }
}

