//
//  DatabaseManager.swift
//  Netflix
//
//  Created by Maaz on 19/06/22.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    public func insertUser(with user: AppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName.lowercased(),
            "last_name" : user.lastName.lowercased()
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write to the database")
                return
            }
            
            let newCollection: [[String: String]] = [
                ["name": user.firstName.lowercased() + " " + user.lastName.lowercased(),
                 "email": user.safeEmail.lowercased()
                ]
            ]
            
            self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
             })
         })
      }
    
    public func getDataForPath(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetchData))
                return
            }
            completion(.success(value))
        })
    }
    
    func safeEmail(with email: String) -> String {
        var value = email.replacingOccurrences(of: ".", with: "-")
        value = value.replacingOccurrences(of: "@", with: "_")
        return value
    }
}

