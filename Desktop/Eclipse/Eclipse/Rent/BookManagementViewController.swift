//
//  BookManagementViewController.swift
//  Eclipse
//
//  Created by admin48 on 12/11/24.
//

import UIKit

class BookManagementViewController: UIViewController {
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Lend", "Borrow"])
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let borrowedBooksVC = BorrowedBooksViewController()
    private let lentBooksVC = LentBooksViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        // Initial setup
        addChild(borrowedBooksVC)
        addChild(lentBooksVC)
        containerView.addSubview(borrowedBooksVC.view)
        containerView.addSubview(lentBooksVC.view)
        
        borrowedBooksVC.view.frame = containerView.bounds
        lentBooksVC.view.frame = containerView.bounds
        
        borrowedBooksVC.didMove(toParent: self)
        lentBooksVC.didMove(toParent: self)
 
        lentBooksVC.view.isHidden = true
    }
    
    private func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -13),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
       

    
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        borrowedBooksVC.view.isHidden = sender.selectedSegmentIndex == 0
        lentBooksVC.view.isHidden = sender.selectedSegmentIndex == 1
    }
}

