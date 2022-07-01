//
//  CreateAccountViewController.swift
//  Netflix
//
//  Created by Maaz on 28/06/22.
//

import UIKit
import JGProgressHUD
import FirebaseAuth

class CreateAccountViewController: UIViewController {
    
    let spinner = JGProgressHUD(style: .dark)
    
    let firstNameField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        textField.textColor = .label
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .emailAddress
        textField.attributedPlaceholder = NSAttributedString(string: "First Name",
                                                             attributes: [NSAttributedString.Key.foregroundColor: 1])
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

    override func viewDidLoad() {
        super.viewDidLoad()

        //adding subviews
        
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(retypePasswordField)
        view.addSubview(signUpButton)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyConstraints()
    }
    
    private func applyConstraints() {
        
        firstNameField.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        lastNameField.anchor(top: firstNameField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        emailField.anchor(top: lastNameField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        passwordField.anchor(top: emailField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        retypePasswordField.anchor(top: passwordField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
        signUpButton.anchor(top: retypePasswordField.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 25, left: 30, bottom: 0, right: 0), size: .init(width: view.width - 60, height: 52))
        
    }


}
