//
//  AppViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/8/24.
//

import Foundation
import SwiftUI

enum ViewSelection: Hashable {
    case login, chat
}

class AppViewModel: ObservableObject {
    @Published var currentView: ViewSelection = .login
    
    @AppStorage("saved_email") private var savedEmail: String = ""
    @AppStorage("saved_password") private var savedPassword: String = ""
    @AppStorage("saved_profil_pic_url") private var savedProfilePicURL: String = ""
    
    
    public func switchTo(view toView: ViewSelection, after delay: Int = 0, animationLength length: CGFloat = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            withAnimation(.snappy(duration: TimeInterval(length))) {
                self.currentView = toView
            }
        })
    }
    
    public func saveLoginInfo(_ userEmail: String, _ userPassword: String) {
        savedEmail = userEmail
        savedPassword = userPassword
    }
    
    public func clearSavedLoginInfo() {
        savedEmail = ""
        savedPassword = ""
    }
    
    public func retrieveLoginInfo() -> (String, String) {
        return (savedEmail, savedPassword)
        
    }
    
    public func signOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
            savedPassword = ""
            savedEmail = ""

        } catch {
            print("Failed to sign out")
        }
    }
    
    
}
