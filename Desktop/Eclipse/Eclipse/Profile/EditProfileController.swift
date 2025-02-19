import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseAuth

class EditProfileViewController: UIViewController, PHPickerViewControllerDelegate {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.layer.cornerRadius = 50
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameTextField = createTextField(withPlaceholder: "Name")
    private let dobTextField = createTextField(withPlaceholder: "Date of Birth")
    private let emailTextField = createTextField(withPlaceholder: "Email")
    private let phoneTextField = createTextField(withPlaceholder: "Phone")
    private let genrePreferencesTextField = createTextField(withPlaceholder: "Genre Preferences")
    private let authorPreferencesTextField = createTextField(withPlaceholder: "Author Preferences")
    private let addressTextField = createTextField(withPlaceholder: "Address")
    
    private var isEditingProfile = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupNavigationBar()
        setupUI()
        setupProfileImageTapGesture()
        setupDatePicker()
        fetchUserDataFromFirestore()
    }
    
    // MARK: - Setup UI
    private func setupNavigationBar() {
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfileTapped))
        navigationItem.rightBarButtonItem = editButton
    }
    
        private func setupUI() {
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)

            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 24 // Increased spacing
            stackView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(stackView)
    
            // Add profile image
            stackView.addArrangedSubview(profileImageView)
    
            // Add name field
            stackView.addArrangedSubview(createFieldStack(labelText: "Name", textField: nameTextField))
    
            // Add other fields
            stackView.addArrangedSubview(createFieldStack(labelText: "Date of Birth", textField: dobTextField))
            stackView.addArrangedSubview(createFieldStack(labelText: "Email", textField: emailTextField))
            stackView.addArrangedSubview(createFieldStack(labelText: "Phone", textField: phoneTextField))
            stackView.addArrangedSubview(createFieldStack(labelText: "Genre Preferences", textField: genrePreferencesTextField))
            stackView.addArrangedSubview(createFieldStack(labelText: "Author Preferences", textField: authorPreferencesTextField))
            stackView.addArrangedSubview(createFieldStack(labelText: "Address", textField: addressTextField))
    
            NSLayoutConstraint.activate([
                // ScrollView constraints
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    
                // ContentView constraints
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
    
                // StackView constraints
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
    
                // Profile image constraints
                profileImageView.widthAnchor.constraint(equalToConstant: 100),
                profileImageView.heightAnchor.constraint(equalToConstant: 100),
                profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ])
        }
    
    private func createFieldStack(labelText: String, textField: UITextField) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        textField.borderStyle = .none
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(textField)
        
        return stackView
    }
    
    // MARK: - Date Picker Setup
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        dobTextField.inputView = datePicker
        dobTextField.inputAccessoryView = toolbar
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dobTextField.text = formatter.string(from: sender.date)
    }
    
    @objc private func doneButtonTapped() {
        dobTextField.resignFirstResponder()
    }
    
    // MARK: - Helper Functions
    private static func createTextField(withPlaceholder placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    // MARK: - Actions
    @objc private func editProfileTapped() {
        if isEditingProfile {
            saveProfileChanges()
        } else {
            enableEditing(true)
            isEditingProfile = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProfileChanges))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditing))
        }
    }
    
    @objc private func saveProfileChanges() {
        guard let user = Auth.auth().currentUser else { return }
        
        let dob = dobTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        let address = addressTextField.text ?? ""
        let genrePreferences = genrePreferencesTextField.text?.split(separator: ",").map { String($0) } ?? []
        let authorPreferences = authorPreferencesTextField.text?.split(separator: ",").map { String($0) } ?? []
        
        saveUserInfoToFirestore(dob: dob, email: email, phone: phone, address: address, genrePreferences: genrePreferences, authorPreferences: authorPreferences)
        
        enableEditing(false)
        isEditingProfile = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfileTapped))
        navigationItem.leftBarButtonItem = nil
    }
    
    @objc private func cancelEditing() {
        enableEditing(false)
        isEditingProfile = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfileTapped))
        navigationItem.leftBarButtonItem = nil
        fetchUserDataFromFirestore() // Reset to original data
    }
    
    private func enableEditing(_ enabled: Bool) {
        nameTextField.isUserInteractionEnabled = enabled
        emailTextField.isUserInteractionEnabled = enabled
        phoneTextField.isUserInteractionEnabled = enabled
        genrePreferencesTextField.isUserInteractionEnabled = enabled
        authorPreferencesTextField.isUserInteractionEnabled = enabled
        addressTextField.isUserInteractionEnabled = enabled
        dobTextField.isUserInteractionEnabled = enabled
        
        // Add visual feedback for editable fields
        if enabled {
            nameTextField.layer.borderColor = UIColor.systemBlue.cgColor
            nameTextField.layer.borderWidth = 1
            nameTextField.layer.cornerRadius = 5
            emailTextField.layer.borderColor = UIColor.systemBlue.cgColor
            emailTextField.layer.borderWidth = 1
            emailTextField.layer.cornerRadius = 5
            phoneTextField.layer.borderColor = UIColor.systemBlue.cgColor
            phoneTextField.layer.borderWidth = 1
            phoneTextField.layer.cornerRadius = 5
            genrePreferencesTextField.layer.borderColor = UIColor.systemBlue.cgColor
            genrePreferencesTextField.layer.borderWidth = 1
            genrePreferencesTextField.layer.cornerRadius = 5
            authorPreferencesTextField.layer.borderColor = UIColor.systemBlue.cgColor
            authorPreferencesTextField.layer.borderWidth = 1
            authorPreferencesTextField.layer.cornerRadius = 5
            addressTextField.layer.borderColor = UIColor.systemBlue.cgColor
            addressTextField.layer.borderWidth = 1
            addressTextField.layer.cornerRadius = 5
            dobTextField.layer.borderColor = UIColor.systemBlue.cgColor
            dobTextField.layer.borderWidth = 1
            dobTextField.layer.cornerRadius = 5
        } else {
            nameTextField.layer.borderWidth = 0
            emailTextField.layer.borderWidth = 0
            phoneTextField.layer.borderWidth = 0
            genrePreferencesTextField.layer.borderWidth = 0
            authorPreferencesTextField.layer.borderWidth = 0
            addressTextField.layer.borderWidth = 0
            dobTextField.layer.borderWidth = 0
        }
    }
    
    // MARK: - Firebase Integration
    private func fetchUserDataFromFirestore() {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid).collection("userData").document("details")
        
        userRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("User data does not exist.")
                return
            }
            
            let dob = document.get("birthdate") as? String ?? ""
            let email = document.get("email") as? String ?? ""
            let phone = document.get("phone") as? String ?? ""
            let address = document.get("address") as? String ?? ""
            let genrePreferences = document.get("genrePreferences") as? [String] ?? []
            let authorPreferences = document.get("authorPreferences") as? [String] ?? []
            
            DispatchQueue.main.async {
                self?.nameTextField.text = document.get("name") as? String ?? ""
                self?.dobTextField.text = dob
                self?.emailTextField.text = email
                self?.phoneTextField.text = phone
                self?.addressTextField.text = address
                self?.genrePreferencesTextField.text = genrePreferences.joined(separator: ", ")
                self?.authorPreferencesTextField.text = authorPreferences.joined(separator: ", ")
                
                if let dobDate = DateFormatter().date(from: dob) {
                    self?.dobTextField.text = DateFormatter().string(from: dobDate)
                }
            }
        }
    }
    
    private func saveUserInfoToFirestore(dob: String, email: String, phone: String, address: String, genrePreferences: [String], authorPreferences: [String]) {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid).collection("userData").document("details")
        
        userRef.setData([
            "name": nameTextField.text ?? "",
            "birthdate": dob,
            "email": email,
            "phone": phone,
            "address": address,
            "genrePreferences": genrePreferences,
            "authorPreferences": authorPreferences
        ]) { error in
            if let error = error {
                print("Error saving data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully.")
            }
        }
    }
    
    // MARK: - Image Picker
    private func setupProfileImageTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }

    @objc private func profileImageTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let result = results.first {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
//
//import UIKit
//import PhotosUI
//import FirebaseFirestore
//import FirebaseAuth
//
//class EditProfileViewController: UIViewController, PHPickerViewControllerDelegate {
//    
//    // MARK: - UI Components
//    private let scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        return scrollView
//    }()
//    
//    private let contentView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "person.circle.fill")
//        imageView.tintColor = .systemGray
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 60 // Ensure it's a circle
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    private let nameTextField = createTextField(withPlaceholder: "Name")
//    private let dobTextField = createTextField(withPlaceholder: "Date of Birth")
//    private let emailTextField = createTextField(withPlaceholder: "Email")
//    private let phoneTextField = createTextField(withPlaceholder: "Phone")
//    private let genrePreferencesTextField = createTextField(withPlaceholder: "Genre Preferences")
//    private let authorPreferencesTextField = createTextField(withPlaceholder: "Author Preferences")
//    private let addressTextField = createTextField(withPlaceholder: "Address")
//    
//    private var isEditingProfile = false
//    
//    // Custom Blue Color
//    private let customBlueColor = UIColor(hex: "#005C78") // Replace with your hex value
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.systemBackground
//        setupNavigationBar()
//        setupUI()
//        setupProfileImageTapGesture()
//        setupDatePicker()
//        fetchUserDataFromFirestore()
//    }
//    
//    // MARK: - Setup UI
//    private func setupNavigationBar() {
//        title = "Profile"
//        navigationController?.navigationBar.prefersLargeTitles = true
//        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfileTapped))
//        navigationItem.rightBarButtonItem = editButton
//    }
//    
//    private func setupUI() {
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//        
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 24 // Increased spacing
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(stackView)
//        
//        // Add profile image
//        stackView.addArrangedSubview(profileImageView)
//        
//        // Add name field
//        stackView.addArrangedSubview(createFieldStack(labelText: "Name", textField: nameTextField))
//        
//        // Add other fields
//        stackView.addArrangedSubview(createFieldStack(labelText: "Date of Birth", textField: dobTextField))
//        stackView.addArrangedSubview(createFieldStack(labelText: "Email", textField: emailTextField))
//        stackView.addArrangedSubview(createFieldStack(labelText: "Phone", textField: phoneTextField))
//        stackView.addArrangedSubview(createFieldStack(labelText: "Genre Preferences", textField: genrePreferencesTextField))
//        stackView.addArrangedSubview(createFieldStack(labelText: "Author Preferences", textField: authorPreferencesTextField))
//        stackView.addArrangedSubview(createFieldStack(labelText: "Address", textField: addressTextField))
//        
//        NSLayoutConstraint.activate([
//            // ScrollView constraints
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            // ContentView constraints
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            
//            // StackView constraints
//            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
//            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
//            
//            // Profile image constraints
//            profileImageView.widthAnchor.constraint(equalToConstant: 120),
//            profileImageView.heightAnchor.constraint(equalToConstant: 120),
//            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//        ])
//    }
//    
//    private func createFieldStack(labelText: String, textField: UITextField) -> UIStackView {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.spacing = 10
//        stackView.alignment = .center
//        stackView.distribution = .fill
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let label = UILabel()
//        label.text = labelText
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        label.textColor = UIColor.secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        textField.borderStyle = .none
//        textField.isUserInteractionEnabled = false
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        
//        stackView.addArrangedSubview(label)
//        stackView.addArrangedSubview(textField)
//        
//        return stackView
//    }
//    
//    // MARK: - Date Picker Setup
//    private func setupDatePicker() {
//        let datePicker = UIDatePicker()
//        datePicker.datePickerMode = .date
//        datePicker.preferredDatePickerStyle = .wheels
//        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
//        
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        toolbar.setItems([flexibleSpace, doneButton], animated: true)
//        
//        dobTextField.inputView = datePicker
//        dobTextField.inputAccessoryView = toolbar
//    }
//    
//    @objc private func dateChanged(_ sender: UIDatePicker) {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        dobTextField.text = formatter.string(from: sender.date)
//    }
//    
//    @objc private func doneButtonTapped() {
//        dobTextField.resignFirstResponder()
//    }
//    
//    // MARK: - Helper Functions
//    private static func createTextField(withPlaceholder placeholder: String) -> UITextField {
//        let textField = UITextField()
//        textField.placeholder = placeholder
//        textField.borderStyle = .none
//        textField.isUserInteractionEnabled = false
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        return textField
//    }
//    
//    // MARK: - Actions
//    @objc private func editProfileTapped() {
//        if isEditingProfile {
//            saveProfileChanges()
//        } else {
//            enableEditing(true)
//            isEditingProfile = true
//            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProfileChanges))
//            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditing))
//        }
//    }
//    
//    @objc private func saveProfileChanges() {
//        guard let user = Auth.auth().currentUser else { return }
//        
//        let dob = dobTextField.text ?? ""
//        let email = emailTextField.text ?? ""
//        let phone = phoneTextField.text ?? ""
//        let address = addressTextField.text ?? ""
//        let genrePreferences = genrePreferencesTextField.text?.split(separator: ",").map { String($0) } ?? []
//        let authorPreferences = authorPreferencesTextField.text?.split(separator: ",").map { String($0) } ?? []
//        
//        saveUserInfoToFirestore(dob: dob, email: email, phone: phone, address: address, genrePreferences: genrePreferences, authorPreferences: authorPreferences)
//        
//        enableEditing(false)
//        isEditingProfile = false
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfileTapped))
//        navigationItem.leftBarButtonItem = nil
//    }
//    
//    @objc private func cancelEditing() {
//        enableEditing(false)
//        isEditingProfile = false
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfileTapped))
//        navigationItem.leftBarButtonItem = nil
//        fetchUserDataFromFirestore() // Reset to original data
//    }
//    
//    private func enableEditing(_ enabled: Bool) {
//        nameTextField.isUserInteractionEnabled = enabled
//        emailTextField.isUserInteractionEnabled = enabled
//        phoneTextField.isUserInteractionEnabled = enabled
//        genrePreferencesTextField.isUserInteractionEnabled = enabled
//        authorPreferencesTextField.isUserInteractionEnabled = enabled
//        addressTextField.isUserInteractionEnabled = enabled
//        dobTextField.isUserInteractionEnabled = enabled
//        
//        // Add visual feedback for editable fields
//        if enabled {
//            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0)) // Increased padding
//            nameTextField.leftView = paddingView
//            nameTextField.leftViewMode = .always
//            nameTextField.layer.borderColor = customBlueColor.cgColor
//            nameTextField.layer.borderWidth = 1
//            nameTextField.layer.cornerRadius = 8
//            nameTextField.layer.masksToBounds = true
//            
//            emailTextField.leftView = paddingView
//            emailTextField.leftViewMode = .always
//            emailTextField.layer.borderColor = customBlueColor.cgColor
//            emailTextField.layer.borderWidth = 1
//            emailTextField.layer.cornerRadius = 8
//            emailTextField.layer.masksToBounds = true
//            
//            phoneTextField.leftView = paddingView
//            phoneTextField.leftViewMode = .always
//            phoneTextField.layer.borderColor = customBlueColor.cgColor
//            phoneTextField.layer.borderWidth = 1
//            phoneTextField.layer.cornerRadius = 8
//            phoneTextField.layer.masksToBounds = true
//            
//            genrePreferencesTextField.leftView = paddingView
//            genrePreferencesTextField.leftViewMode = .always
//            genrePreferencesTextField.layer.borderColor = customBlueColor.cgColor
//            genrePreferencesTextField.layer.borderWidth = 1
//            genrePreferencesTextField.layer.cornerRadius = 8
//            genrePreferencesTextField.layer.masksToBounds = true
//            
//            authorPreferencesTextField.leftView = paddingView
//            authorPreferencesTextField.leftViewMode = .always
//            authorPreferencesTextField.layer.borderColor = customBlueColor.cgColor
//            authorPreferencesTextField.layer.borderWidth = 1
//            authorPreferencesTextField.layer.cornerRadius = 8
//            authorPreferencesTextField.layer.masksToBounds = true
//            
//            addressTextField.leftView = paddingView
//            addressTextField.leftViewMode = .always
//            addressTextField.layer.borderColor = customBlueColor.cgColor
//            addressTextField.layer.borderWidth = 1
//            addressTextField.layer.cornerRadius = 8
//            addressTextField.layer.masksToBounds = true
//            
//            dobTextField.leftView = paddingView
//            dobTextField.leftViewMode = .always
//            dobTextField.layer.borderColor = customBlueColor.cgColor
//            dobTextField.layer.borderWidth = 1
//            dobTextField.layer.cornerRadius = 8
//            dobTextField.layer.masksToBounds = true
//        } else {
//            nameTextField.layer.borderWidth = 0
//            emailTextField.layer.borderWidth = 0
//            phoneTextField.layer.borderWidth = 0
//            genrePreferencesTextField.layer.borderWidth = 0
//            authorPreferencesTextField.layer.borderWidth = 0
//            addressTextField.layer.borderWidth = 0
//            dobTextField.layer.borderWidth = 0
//        }
//    }
//    
//    // MARK: - Firebase Integration
//    private func fetchUserDataFromFirestore() {
//        guard let user = Auth.auth().currentUser else { return }
//        
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(user.uid).collection("userData").document("details")
//        
//        userRef.getDocument { [weak self] (document, error) in
//            if let error = error {
//                print("Error fetching user data: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let document = document, document.exists else {
//                print("User data does not exist.")
//                return
//            }
//            
//            let dob = document.get("birthdate") as? String ?? ""
//            let email = document.get("email") as? String ?? ""
//            let phone = document.get("phone") as? String ?? ""
//            let address = document.get("address") as? String ?? ""
//            let genrePreferences = document.get("genrePreferences") as? [String] ?? []
//            let authorPreferences = document.get("authorPreferences") as? [String] ?? []
//            
//            DispatchQueue.main.async {
//                self?.nameTextField.text = document.get("name") as? String ?? ""
//                self?.dobTextField.text = dob
//                self?.emailTextField.text = email
//                self?.phoneTextField.text = phone
//                self?.addressTextField.text = address
//                self?.genrePreferencesTextField.text = genrePreferences.joined(separator: ", ")
//                self?.authorPreferencesTextField.text = authorPreferences.joined(separator: ", ")
//                
//                if let dobDate = DateFormatter().date(from: dob) {
//                    self?.dobTextField.text = DateFormatter().string(from: dobDate)
//                }
//            }
//        }
//    }
//    
//    private func saveUserInfoToFirestore(dob: String, email: String, phone: String, address: String, genrePreferences: [String], authorPreferences: [String]) {
//        guard let user = Auth.auth().currentUser else { return }
//        
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(user.uid).collection("userData").document("details")
//        
//        userRef.setData([
//            "name": nameTextField.text ?? "",
//            "birthdate": dob,
//            "email": email,
//            "phone": phone,
//            "address": address,
//            "genrePreferences": genrePreferences,
//            "authorPreferences": authorPreferences
//        ]) { error in
//            if let error = error {
//                print("Error saving data: \(error.localizedDescription)")
//            } else {
//                print("User data saved successfully.")
//            }
//        }
//    }
//    
//    // MARK: - Image Picker
//    private func setupProfileImageTapGesture() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
//        profileImageView.addGestureRecognizer(tapGesture)
//        profileImageView.isUserInteractionEnabled = true
//    }
//
//    @objc private func profileImageTapped() {
//        var config = PHPickerConfiguration()
//        config.selectionLimit = 1
//        config.filter = .images
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = self
//        present(picker, animated: true, completion: nil)
//    }
//
//    // MARK: - PHPickerViewControllerDelegate
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        if let result = results.first {
//            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
//                if let image = object as? UIImage {
//                    DispatchQueue.main.async {
//                        self.profileImageView.image = image
//                    }
//                }
//            }
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//}
//
//
//on clicking edit everything is freezing and I have to re run the app
