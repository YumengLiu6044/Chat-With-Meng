//
//  ChatViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import Foundation
import SwiftUI

enum ChatViewSelection : Hashable {
    case messages, friends, settings
}

class ChatViewModel: ObservableObject {
    @Published var chatViewSelection: ChatViewSelection = .messages
    @Published var showMenu: Bool = true
    @Published var currentUser: User = User()
    @Published var toast: Toast? = nil
    
    public func switchTo(view toView: ChatViewSelection, after delay: Int = 0, animationLength length: CGFloat = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            withAnimation(.snappy(duration: TimeInterval(length))) {
                self.chatViewSelection = toView
            }
        })
    }
    
    public func initializeCurrentUser() -> Void {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument {
            document, error in
            if let error = error {
                self.toast = Toast(style: .error, message: error.localizedDescription)
            }
            else {
                if let document = document {
                    do {
                        self.currentUser = try document.data(as: User.self)
                        print(self.currentUser)
                    } catch {
                        self.toast = Toast(style: .error, message: "Error decoding document")
                    }
                }
                else {
                    self.toast = Toast(style: .error, message: "Error getting document")
                }
            }
        }
        
    }

}
