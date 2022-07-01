//
//  AppUser.swift
//  Netflix
//
//  Created by Maaz on 19/06/22.
//

import Foundation

struct AppUser: Codable {
    
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
