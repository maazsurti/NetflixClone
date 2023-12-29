//
//  SignUpViewController.swift
//  Netflix
//
//  Created by Maaz on 12/06/22.
//

import UIKit
import JGProgressHUD
import FirebaseAuth

typealias callback = (String) -> ()

protocol SignUpViewControllerDelegate: AnyObject {
    
    func didTapSignUp(_ email: String)
}

class SignUpViewController: UIViewController {
    
    var emailCallback: callback?
    
    weak var delegate: SignUpViewControllerDelegate?
    
    let spinner = JGProgressHUD(style: .dark)
    
    let firstNameField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        textField.textColor = .label
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .emailAddress
        textField.setPlaceholder(text: "First Name", color: .placeholderText)
        textField.layer.cornerRadius = 13
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let lastNameField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        textField.textColor = .label
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .emailAddress
        textField.attributedPlaceholder = NSAttributedString(string: "Last Name",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText])
        textField.layer.cornerRadius = 13
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let emailField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        textField.textColor = .label
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .emailAddress
        textField.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText])
        textField.layer.cornerRadius = 13
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        textField.textColor = .label
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText])
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 13
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let retypePasswordField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        textField.textColor = .label
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.attributedPlaceholder = NSAttributedString(string: "Re-type password",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText])
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 13
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let signUpButton: UIButton = {

        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .link
        button.setTitleColor(UIColor.label, for: .normal)
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        // Adding subviews
        
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(retypePasswordField)
        view.addSubview(signUpButton)
        
    }
    
    @objc func signUpButtonTapped() {

        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              let retypePassword = retypePasswordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !retypePassword.isEmpty
        else {

            alertUserLoginError()
            return
        }

        if password.count <= 6 {

            alert(title: "Error", message: "Password must be more than 6 characters long")
            return

        } else if password != retypePassword {

            alert(title: "Error", message: "Both passwords do not match")
            return

        }

        //spinner.show(in: view)

        let AppUser =  AppUser(firstName: firstName,
                               lastName: lastName,
                               emailAddress: email)

        //Creating user

        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult, error in

            guard let result = authResult, error == nil else {
                print("Error creating user", error as Any)
                self?.alert(title: "Error", message: "An unknown error occured. Please try again after sometime")
                return
            }

            // Caching their username and email

            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            UserDefaults.standard.set(email, forKey: "email")

            let user = result.user
            print("User: ", user)

        })


        DatabaseManager.shared.insertUser(with: AppUser, completion: { success in

            if success {

                print("Details added")
            }
        })
        
        if let emailAdd = emailCallback {
            
            emailAdd(email)
        }
        
        //self.spinner.dismiss(animated: true)
        self.alert(title: "Success", message: "Account created Succesfully!") { [weak self]_  in
            
            self?.delegate?.didTapSignUp(email)
            self?.navigationController?.popViewController(animated: true)
            
        }
        
        //NotificationCenter.default.post(name: .didSignUp, object: nil)

    }
    
    @objc func alertUserLoginError(){
        alert(title: "Woops", message: "Please enter all the information to create a new account")
    }

    
    func configure() {
        
        var firstName = UserDefaults.standard.object(forKey: "name") as? String
        firstName = firstName?.components(separatedBy: " ").first
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Sign Up"
        
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        //setting up placeholder data
//        firstNameField.text = "Maaz"
//        lastNameField.text = "Surti"
//        emailField.text = "maaz@gmail.com"
//        passwordField.text = "password"
//        retypePasswordField.text = "password"
        
    }
    
    func applyConstraints() {
        
        firstNameField.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        lastNameField.anchor(top: firstNameField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        emailField.anchor(top: lastNameField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        passwordField.anchor(top: emailField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        retypePasswordField.anchor(top: passwordField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        signUpButton.anchor(top: retypePasswordField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
    }
    
    
}
