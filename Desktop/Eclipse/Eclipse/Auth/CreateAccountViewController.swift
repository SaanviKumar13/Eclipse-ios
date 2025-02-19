import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewController: UIViewController {

    private var nameTextField: UITextField!
    private var emailTextField: UITextField!
    private var birthdateTextField: UITextField!
    private var addressTextField: UITextField!
    private var phoneTextField: UITextField!
    private var passwordTextField: UITextField!

    private let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        // Heading label
        let headingLabel = UILabel()
        headingLabel.text = "Hey there!"
        headingLabel.font = UIFont.boldSystemFont(ofSize: 32)
        headingLabel.textColor = .black
        headingLabel.textAlignment = .left
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headingLabel)
        
        // Subheading label
        let subheadingLabel = UILabel()
        subheadingLabel.text = "Enter your information to get started with your reading journey"
        subheadingLabel.font = UIFont.systemFont(ofSize: 16)
        subheadingLabel.textColor = .gray
        subheadingLabel.numberOfLines = 0
        subheadingLabel.textAlignment = .left
        subheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subheadingLabel)
        
        // Stack view for text fields
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Create text fields
        nameTextField = createTextField(placeholder: "Name", labelColor: UIColor(hex: "#005C78"))
        emailTextField = createTextField(placeholder: "Email", labelColor: UIColor(hex: "#005C78"), keyboardType: .emailAddress)
        
        // Birthdate text field and date picker
        birthdateTextField = createTextField(placeholder: "Birthdate", labelColor: UIColor(hex: "#005C78"))
        birthdateTextField.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(birthdateChanged), for: .valueChanged)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        
        birthdateTextField.inputView = datePicker
        birthdateTextField.inputAccessoryView = toolbar
        
        addressTextField = createTextField(placeholder: "Address", labelColor: UIColor(hex: "#005C78"))
        phoneTextField = createTextField(placeholder: "Phone Number", labelColor: UIColor(hex: "#005C78"))
        
        passwordTextField = createTextField(placeholder: "Password", labelColor: UIColor(hex: "#005C78"))
        passwordTextField.isSecureTextEntry = true
        
        [nameTextField, emailTextField, birthdateTextField, addressTextField, phoneTextField, passwordTextField].forEach {
            stackView.addArrangedSubview($0)
        }
        
        // Create account button
        let createAccountButton = UIButton(type: .system)
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.backgroundColor = UIColor(hex: "#005C78")
        createAccountButton.layer.cornerRadius = 12
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        view.addSubview(createAccountButton)
        
        // Footer stack with already have account message and login button
        let alreadyHaveAccountLabel = UILabel()
        alreadyHaveAccountLabel.text = "Already have an account?"
        alreadyHaveAccountLabel.font = UIFont.systemFont(ofSize: 14)
        alreadyHaveAccountLabel.textColor = .gray
        alreadyHaveAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(UIColor(hex: "#005C78"), for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        
        let footerStack = UIStackView(arrangedSubviews: [alreadyHaveAccountLabel, loginButton])
        footerStack.axis = .horizontal
        footerStack.spacing = 4
        footerStack.alignment = .center
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerStack)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            subheadingLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 16),
            subheadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subheadingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            stackView.topAnchor.constraint(equalTo: subheadingLabel.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            createAccountButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            createAccountButton.heightAnchor.constraint(equalToConstant: 50),
            
            footerStack.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 20),
            footerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func birthdateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        birthdateTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc private func doneButtonTapped() {
        birthdateChanged()
        birthdateTextField.resignFirstResponder()
    }

    @objc private func createAccountTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let birthdate = birthdateTextField.text, !birthdate.isEmpty else {
            showAlert(message: "Please fill in all required fields.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "Error: \(error.localizedDescription)")
                return
            }

            if let user = authResult?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error updating profile: \(error.localizedDescription)")
                    } else {
                        print("Profile updated for \(user.uid)")
                    }
                }
                
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(user.uid).collection("userData").document("details")
                
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "birthdate": birthdate,
                    "address": self.addressTextField.text ?? "",
                    "phone": self.phoneTextField.text ?? "",
                    "createdAt": Timestamp(date: Date())
                ]
                
                userRef.setData(userData) { error in
                    if let error = error {
                        print("Error saving user data: \(error.localizedDescription)")
                    } else {
                        print("User profile saved successfully")
                    }
                }
            }

            let nextViewController = GenrePreferencesViewController()
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated: true, completion: nil)
        }
    }

    @objc private func loginTapped() {
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController = navController
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }

    private func createTextField(placeholder: String, labelColor: UIColor, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = labelColor
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 12
        textField.keyboardType = keyboardType
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}


