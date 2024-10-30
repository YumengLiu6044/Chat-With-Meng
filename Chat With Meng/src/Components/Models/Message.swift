//
//  Message.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/29/24.
//

import SwiftUI
import FirebaseFirestore

struct Message: Codable {
    @DocumentID var id: String? = nil
    var contentType: ContentType = .text
    var content: String = ""
    var time: Date = .now
    var chatID: String = ""
    var fromUserID: String = ""
    var isRead: Bool = false
    
    enum keys : String, CodingKey {
        case id
        case contentType
        case content
        case time
        case chatID
        case fromUserID
        case isRead
    }
}
