import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back!"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor(hex: "#005C78")
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 12
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor(hex: "#005C78")
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 12
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#005C78")
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(UIColor(hex: "#005C78"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        stackView.axis = .vertical
        stackView.spacing = 24
        
        let bottomStackView = UIStackView(arrangedSubviews: [alreadyHaveAccountLabel, createAccountButton])
        bottomStackView.axis = .vertical
        bottomStackView.spacing = 4
        bottomStackView.alignment = .center
        
        [titleLabel, stackView, loginButton, bottomStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            bottomStackView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            bottomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func loginTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please fill in all required fields.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .userNotFound:
                    self?.showAlert(message: "No account found with that email. Please create an account.")
                case .wrongPassword:
                    self?.showAlert(message: "Incorrect password. Please try again.")
                case .operationNotAllowed:
                    self?.showAlert(message: "This sign-in method is not allowed. Please check your Firebase configuration.")
                default:
                    self?.showAlert(message: "Message: \(error.localizedDescription)")
                }
                return
            }
            
            let tabBarController = TabBarController()
            tabBarController.modalPresentationStyle = .fullScreen
            self?.present(tabBarController, animated: true)
        }
    }
    
    @objc private func createAccountTapped() {
        let createAccountVC = CreateAccountViewController()
        createAccountVC.modalPresentationStyle = .fullScreen
        present(createAccountVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

