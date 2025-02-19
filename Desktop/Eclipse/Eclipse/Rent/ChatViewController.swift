//
//  ChatViewController.swift
//  Eclipse
//
//  Created by admin48 on 17/11/24.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var messages: [Message] = []
    private let messageInputBar = UIView()
    private let messageTextField = UITextField()
    private var isFirstMessage = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigation()
        setupViews()
    }
    
    private func setupNavigation() {
        title = "Sarah J"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupViews() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Start the chat with Sarah J"
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .systemGray
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Today 9:41"
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.textAlignment = .center
        headerView.addSubview(subtitleLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.backgroundColor = .white
        messageInputBar.layer.borderWidth = 1
        messageInputBar.layer.borderColor = UIColor.systemGray5.cgColor
        view.addSubview(messageInputBar)
        
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.placeholder = "Message"
        messageTextField.borderStyle = .none
        messageTextField.returnKeyType = .send
        messageTextField.delegate = self
        messageInputBar.addSubview(messageTextField)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            
            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputBar.heightAnchor.constraint(equalToConstant: 60),
            
            messageTextField.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: 16),
            messageTextField.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -16),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return true }
        
        messages.append(Message(text: text, isFromUser: true))
        tableView.reloadData()
        textField.text = nil
        
        if isFirstMessage {
            isFirstMessage = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.messages.append(Message(text: "Hi, you can come around by 5:00 PM to pick the book.", isFromUser: false))
                self.tableView.reloadData()
            }
        }
        
        return true
    }
}

