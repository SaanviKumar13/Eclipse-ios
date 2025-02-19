import UIKit

class MessageCell: UITableViewCell {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bubbleBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(bubbleBackgroundView)
        bubbleBackgroundView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            bubbleBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleBackgroundView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -12),
        ])
    }
    
    func configure(with message: Message) {
        messageLabel.text = message.text
        
        if message.isFromUser {
            bubbleBackgroundView.backgroundColor = UIColor(red: 0, green: 92/255, blue: 120/255, alpha: 1)
            messageLabel.textColor = .white
            bubbleBackgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60).isActive = true
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        } else {
            bubbleBackgroundView.backgroundColor = UIColor.systemGray5
            messageLabel.textColor = .black
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            bubbleBackgroundView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60).isActive = true
        }
    }
}

