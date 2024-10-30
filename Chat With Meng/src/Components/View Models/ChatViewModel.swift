//
//  ChatViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore


@MainActor
class ChatViewModel: ObservableObject {
    @Published var chatViewSelection: ChatViewSelection = .messages
    @Published var showImagePicker: Bool = false
    @Published var showMenu:        Bool = true
    
    public func switchTo(view toView: ChatViewSelection, after delay: Int = 0, animationLength length: CGFloat = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            withAnimation(.snappy(duration: TimeInterval(length))) {
                self.chatViewSelection = toView
            }
        })
    }
    

    
    
    
    
    
    
}
