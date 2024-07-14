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
        let testPassword = "gwydts5173"
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
        let symbolSet = "!@#$%^&*()-_=+\\|[]{};:/?.>"
        let testPassword = "Lym_23902921"
        
        passwordManager.requireSpecialSymbolFromSet(of: symbolSet)
        
        XCTAssertTrue(passwordManager.passwordIsValid(for: testPassword))
        
    }
    
    func testPolicyRequireSpecialSymbolFail() {
        let symbolSet = "!@#$%^&*()-_=+\\|[]{};:/?.>"
        let testPassword = "Lym23902921"
        
        passwordManager.requireSpecialSymbolFromSet(of: symbolSet)
        
        XCTAssertTrue(passwordManager.passwordIsValid(for: testPassword))
    }

}
