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
        
        policies.append(
            PasswordPolicy(
                message: "at least \(size) characters",
                policy: checkMinimumSize
            )
        )
    }
    
    public func requireSpecialSymbolFromSet(of symbolSet: String) {
        func checkSpecialSymbol(with password: String) -> Bool {
            return password.filter{symbolSet.contains($0)}.count > 0
        }
        
        policies.append(
            PasswordPolicy(
                message: "at least one special symbol",
                policy: checkSpecialSymbol
            )
        )
    }
    
    
    public func requireUpperCase() {
        func checkUpperCase(with password: String) -> Bool {
            return password.filter{$0.isUppercase}.count > 0
        }
        
        policies.append(
            PasswordPolicy(
                message: "at least one uppercased letter",
                policy: checkUpperCase
            )
        )
    }
    
    public func requireLowerCase() {
        func checkLowerCase(with password: String) -> Bool {
            return password.filter{$0.isLowercase}.count > 0
        }
        
        policies.append(
            PasswordPolicy(
                message: "at least one lowercased letter",
                policy: checkLowerCase
            )
        )
    }
    
    
    public func passwordIsValid(for password: String) -> Bool {
        for i in 0..<policies.count {
            policies[i].passed = policies[i].policy(password)
        }
        return policies.allSatisfy{$0.passed}
    }
}


struct PasswordPolicy: Identifiable, Equatable {
    static func == (lhs: PasswordPolicy, rhs: PasswordPolicy) -> Bool {
        return lhs.message == rhs.message
    }
    
    let id = UUID()
    let message: String
    let policy: ((String) -> Bool)
    var passed: Bool = true
}
