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
    
    func testPolicyRequireMinimumSizePass() {
        let testPassword = "gwydts5173"
        let minimumSize = 10
        
        passwordManager.requireMinimumSize(of: minimumSize)
        
        XCTAssertTrue(passwordManager.passwordIsValid(of: testPassword))
        
    }
    
    func testPolicyRequireMinimumSizeFail() {
        let testPassword = "gwydts5173"
        let minimumSize = 12
        
        passwordManager.requireMinimumSize(of: minimumSize)
        
        XCTAssertFalse(passwordManager.passwordIsValid(of: testPassword))
        
    }
    
    func testPolicyRequireMinimumSizeZero() {
        let testPassword = "gwydts5173"
        let minimumSize = 0
        
        passwordManager.requireMinimumSize(of: minimumSize)
        
        XCTAssertTrue(passwordManager.passwordIsValid(of: testPassword))
        
    }
    
    func testPolicyRequireSpecialSymbolPass() {
        let symbolSet = "!@#$%^&*()-_=+\\|[]{};:/?.>"
        
        
    }

}
