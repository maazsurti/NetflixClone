//
//  LoginViewController.swift
//  Netflix
//
//  Created by Maaz on 12/06/22.
//

import UIKit
import JGProgressHUD
import FirebaseAuth

class LoginViewController: UIViewController, SignUpViewControllerDelegate {
    
    private let signUpViewController = SignUpViewController()
    
    let spinner = JGProgressHUD(style: .dark)
    
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
    
    let loginButton: UIButton = {

        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .link
        button.setTitleColor(UIColor.label, for: .normal)
        return button
    }()
    
    let signUpLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Dont have an account?"
        label.textColor = .link
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
       // label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(UIColor.link, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
       // button.backgroundColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpViewController.emailCallback = { [weak self] email in
            
            self?.emailField.text = "\(email)"
        }
        
        // Adding subviews
        
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(signUpLabel)
        view.addSubview(signUpButton)
        
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        signUpViewController.delegate = self
    }
    
    @objc func signUpButtonTapped() {
        
        let vc = SignUpViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func backButtonTapped() {
        
        navigationController?.dismiss(animated: true)
    }
    
    @objc func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
    
            alert(title: "Oops", message: "Please enter all the information")
            return
        }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
     
            guard let strongSelf = self else {
                return }
            
            let safeEmail = DatabaseManager.shared.safeEmail(with: email)
            
            DatabaseManager.shared.getDataForPath(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"],
                          let lastName = userData["last_name"] else {
                              print("could not get the first and last name")
                                return
                            }
                    
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    
                case .failure(let error):
                    print("Failed to read data with error: ", error)
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            
                
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to login with the email: ", email)
                DispatchQueue.main.async {
                    
                    self?.alert(title: "Error", message: "Please check your details before entering")
                    self?.emailField.text = ""
                    self?.passwordField.text = ""
                }
                return
            }
            
            let user = result.user
            print("Logged in user ", user)
            strongSelf.navigationController?.dismiss(animated: true)
        
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didLogInNotification, object: nil)
            }
            
        })
    }
    
    func configure() {
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Login"
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        let leftItem = UIBarButtonItem(title: "Done",
                                   style: .done,
                                   target: self,
                                   action: #selector(backButtonTapped))
        
        navigationItem.leftBarButtonItem = leftItem
        
        leftItem.tintColor = .label
        
        signUpViewController.delegate = self
        
        
    }
    
    private func applyConstraints() {      
        
        emailField.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 30, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        passwordField.anchor(top: emailField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 30, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        loginButton.anchor(top: passwordField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 30, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        
        signUpLabel.anchor(top: nil, leading: view.leadingAnchor, trailing: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, padding: .init(top: 0, left: view.width / 5 , bottom: 0, right: 0))
        
        signUpLabel.widthAnchor.constraint(greaterThanOrEqualToConstant:  view.width/2.35).isActive = true
        signUpLabel.heightAnchor.constraint(greaterThanOrEqualToConstant:  view.height / 22).isActive = true
        
        signUpButton.anchor(top: nil, leading: signUpLabel.trailingAnchor, trailing: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, padding: .init(top: 0, left: 2 , bottom: 0, right: 0), size: .init(width: view.width / 6, height: view.height / 22))
        
    }

}

extension LoginViewController {
    
    func didTapSignUp(_ email: String) {
        
        emailField.text = "\(email)"
        
    }
}

