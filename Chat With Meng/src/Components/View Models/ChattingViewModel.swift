//
//  ChattingViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/28/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class ChattingViewModel: ObservableObject {
    @Published var isComposing: Bool = false
    @Published var searchkey: String = ""
    
    @Published var recipientList: [Friend] = []
    @Published var searchResults: [Friend] = []
    
    @Published var toast: Toast? = nil
    
    func searchForFriends(from friends: [Friend]) {
        self.searchResults = []
        
        for friend in friends where
        friend.userName.lowercased().contains(searchkey.lowercased()){
            self.searchResults.append(friend)
        }
    }
    
    public func makeFriend(from id: String?, notifications: Bool = true, completion: @escaping (Friend?) -> Void) {
        guard let id = id else {return completion(nil)}
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(id)
            .getDocument {
            document, error in
            
            if let error = error {
                self.toast = Toast(style: .error, message: error.localizedDescription)
            }
            else {
                if let document = document {
                    do {
                        let data = try document.data(as: User.self)
                        guard let friendID = data.id else {return}
                        let dataAsFriend = Friend(
                            email: data.email,
                            userID: friendID,
                            profilePicURL: data.profilePicURL,
                            userName: data.userName,
                            notifications: notifications,
                            profileOverlayData: data.profileOverlayData
                        )
                        return completion(dataAsFriend)
                        
                    } catch {
                        self.toast = Toast(style: .error, message: "Error decoding document")
                    }
                }
                else {
                    self.toast = Toast(style: .error, message: "Error getting document")
                }
            }
        }
        return completion(nil)
    }
    
}
