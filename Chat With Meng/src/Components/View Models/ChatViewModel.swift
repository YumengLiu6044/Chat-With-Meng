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
    
    public func switchTo(view toView: ChatViewSelection, after delay: Int = 0, animationLength length: CGFloat = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            withAnimation(.smooth(duration: TimeInterval(length))) {
                self.chatViewSelection = toView
            }
        })
    }
}
