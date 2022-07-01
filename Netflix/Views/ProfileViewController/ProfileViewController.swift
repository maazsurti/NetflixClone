//
//  ProfileViewController.swift
//  Netflix
//
//  Created by Maaz on 23/06/22.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let userLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        
        view.backgroundColor = .systemBackground
        
        let name = UserDefaults.standard.object(forKey: "name") as? String
        
        guard let fullName = name?.components(separatedBy: " ") else { return }
        
        let firstName = fullName[0].capitalizingFirstLetter()
        let lastName = fullName[1].capitalizingFirstLetter()
        
        userLabel.text = "Welcome, \(firstName) \(lastName)"
        
        // adding subviews
        
        view.addSubview(userLabel)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        userLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, padding: .init(top: 0, left: view.width / 8, bottom: 0, right: 0))
        
        userLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: view.width / 2 ).isActive = true
        userLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: view.height/8).isActive = true
        
        //userLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    

}
