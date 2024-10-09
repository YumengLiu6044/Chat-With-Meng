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
    
    public func switchTo(view toView: ViewSelection, animationLength length: Int = 2) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(length), execute: {
            withAnimation(.snappy(duration: TimeInterval(length))) {
                self.currentView = toView
            }
        })
    }
    
    
}
