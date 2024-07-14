//
//  PasswordPolicy.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/13/24.
//

import Foundation

class PasswordManager: ObservableObject {
    @Published var policies: [PasswordPolicy] = []
    
    public func requireMinimumSize(of size: Int) {
        func checkMinimumSize(with password: String) -> Bool {
            return password.count >= size
        }
        
        policies.append(PasswordPolicy(
            message: "at least \(size) characters",
            content: checkMinimumSize)
        )
    }
    
    public func requireSpecialSymbolFromSet(of symbolSet: String) {
        
    }
    
    
    public func requireUpperCase() {
        
    }
    
    public func requireLowerCase() {
        
    }
    
    
    public func passwordIsValid(of password: String) -> Bool {
        for policy in self.policies {
            if !policy.content(password) {
                return false
            }
        }
        return true
    }
}


struct PasswordPolicy: Identifiable {
    let id = UUID()
    let message: String
    let content: ((String) -> Bool)
}
