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
    
    public func switchTo(view toView: ViewSelection, after delay: Int = 1, animationLength length: Int = 1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            withAnimation(.smooth(duration: TimeInterval(length))) {
                self.currentView = toView
            }
        })
    }
    
    
}
