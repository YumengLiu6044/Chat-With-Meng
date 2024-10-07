//
//  PasswordPolicyTests.swift
//  Meng ChatTests
//
//  Created by Yumeng Liu on 7/13/24.
//

import XCTest
import SwiftUI
@testable import Meng_Chat

final class PasswordPolicyTests: XCTestCase {
    var passwordManager: PasswordManager = PasswordManager()
    
    override func setUp() {
        passwordManager = PasswordManager()
    }
    
    func testNoPolicyPass() {
        let testPassword = "wef"
        
        XCTAssertTrue(passwordManager.passwordIsValid(for: testPassword))
    }
    
    func testPolicyRequireMinimumSizePass() {
        let testPassword = "gwydts5173"
        let minimumSize = 10
        
        passwordManager.requireMinimumSize(of: minimumSize)
        
        XCTAssertTrue(passwordManager.passwordIsValid(for: testPassword))
        
    }
    
    func testPolicyRequireMinimumSizeFail() {
        let testPassword = "gwydts517"
        let minimumSize = 12
        
        passwordManager.requireMinimumSize(of: minimumSize)
        
        XCTAssertFalse(passwordManager.passwordIsValid(for: testPassword))
        
    }
    
    func testPolicyRequireMinimumSizeZero() {
        let testPassword = "gwydts5173"
        let minimumSize = 0
        
        passwordManager.requireMinimumSize(of: minimumSize)
        
        XCTAssertTrue(passwordManager.passwordIsValid(for: testPassword))
        
    }
    
    func testPolicyRequireSpecialSymbolPass() {
        let symbolSet = "!@#$%^&*()-_=+\\|[]{};:/?.<>"
        let testPassword = "Lym_23902921"
        
        passwordManager.requireSpecialSymbolFromSet(of: symbolSet)
        
        XCTAssertTrue(passwordManager.passwordIsValid(for: testPassword))
        
    }
    
    func testPolicyRequireSpecialSymbolFail() {
        let symbolSet = "!@#$%^&*()-_=+\\|[]{};:/?.>"
        let testPassword = "Lym23902921"
        
        passwordManager.requireSpecialSymbolFromSet(of: symbolSet)
        
        XCTAssertFalse(passwordManager.passwordIsValid(for: testPassword))
    }
    
    func testPolicyRequireUpperCasePass() {
        let testPassword = "diugrwefD"
        
        passwordManager.requireUpperCase()
        
        XCTAssertTrue(passwordManager.passwordIsValid(for: testPassword))
    }
    
    func testPolicyRequireUpperCaseFail() {
        let testPassword = "diugrweff"
        
        passwordManager.requireUpperCase()
        
        XCTAssertFalse(passwordManager.passwordIsValid(for: testPassword))
    }
    
    func testPolicyRequireLowerCasePass() {
        let testPassword = "diugrwefD"
        
        passwordManager.requireLowerCase()
        
        XCTAssertTrue(passwordManager.passwordIsValid(for: testPassword))
    }
    
    func testPolicyRequireLowerCaseFail() {
        let testPassword = "IDON\'THAVEALOWERCASEDLETTER"
        
        passwordManager.requireLowerCase()
        
        XCTAssertFalse(passwordManager.passwordIsValid(for: testPassword))
    }
    
    func testAllPossiblePoliciesPass() {
        let testPassword = "Jiuwefd*_3fd8dua"
        let minimumSize = 10
        let symbolSet = "~!@#$%^&*()_-+=|\\}]{[:;"
        
        passwordManager.requireLowerCase()
        passwordManager.requireUpperCase()
        passwordManager.requireMinimumSize(of: minimumSize)
        passwordManager.requireSpecialSymbolFromSet(of: symbolSet)
        
        XCTAssertTrue(passwordManager.passwordIsValid(for: testPassword))
        
    }
    
    func testAllPossiblePoliciesFail() {
        let testPassword = "kiuwefd3fd8dua"
        let minimumSize = 10
        let symbolSet = "~!@#$%^&*()_-+=|\\}]{[:;"
        let failedPolicies = [
            PasswordPolicy(message: "at least one uppercased letter", policy: {(password: String) -> (Bool) in return true}),
            PasswordPolicy(message: "at least one special symbol", policy: {(password: String) -> (Bool) in return true})
        ]
        
        passwordManager.requireLowerCase()
        passwordManager.requireUpperCase()
        passwordManager.requireMinimumSize(of: minimumSize)
        passwordManager.requireSpecialSymbolFromSet(of: symbolSet)
        
        XCTAssertFalse(
            passwordManager.passwordIsValid(for: testPassword) &&
            failedPolicies == passwordManager.policies.filter{$0.passed == false}
        )
        
    }
    
    
}
