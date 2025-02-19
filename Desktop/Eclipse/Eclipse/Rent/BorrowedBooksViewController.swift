//
//  BorrowedBooksViewController.swift
//  Eclipse
//
//  Created by admin48 on 12/11/24.
//

import UIKit

class BorrowedBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BookCardDelegate {

    private let viewRequestsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Requests(3)", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Borrowed Books"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BookCard.self, forCellReuseIdentifier: "BookCard")
        return tableView
    }()

    private let borrowedBooks: [BookData] = [
        BookData(title: "Gone Girl", borrowedFrom: "@janedoe", lentTo: nil, price: "₹150", days: "3 Days", coverImage: UIImage(named: "gone_girl") ?? UIImage()),
        BookData(title: "The Devotion of Suspect X", borrowedFrom: "@sarahj", lentTo: nil, price: "₹100", days: "2 Days", coverImage: UIImage(named: "devotion_of_suspect_x") ?? UIImage()),
        BookData(title: "Verity", borrowedFrom: "@johndoe", lentTo: nil, price: "₹100", days: "2 Days", coverImage: UIImage(named: "verity") ?? UIImage())
        
        
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(viewRequestsButton)
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self

        viewRequestsButton.addTarget(self, action: #selector(viewRequestsButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            viewRequestsButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            viewRequestsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func viewRequestsButtonTapped() {
        let requestsVC = RentalRequestsAcceptViewController()
        navigationController?.pushViewController(requestsVC, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return borrowedBooks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookCard", for: indexPath) as? BookCard else {
            fatalError("Failed to dequeue BookCard")
        }
        cell.configure(with: borrowedBooks[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func didTapChat(for book: BookData) {
        let chatVC = ChatViewController()
        chatVC.title = "Chat with \(book.borrowedFrom ?? "User")"
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func didTapReturn(for book: BookData) {
//           let feedbackVC = FeedbackViewController()
//           navigationController?.pushViewController(feedbackVC, animated: true)
       }
}

