//
//  Message.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/29/24.
//

import SwiftUI
import FirebaseFirestore

struct Message: Codable, Comparable, Identifiable {
    @DocumentID var id: String? = nil
    var contentType: ContentType = .text
    var content: String = ""
    var time: Date = .now
    var chatID: String = ""
    var fromUserID: String = ""
    var isRead: Bool = false
    
    static func <(lhs: Message, rhs: Message) -> Bool{
        return lhs.time < rhs.time
    }
    
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

extension Array where Element: Comparable {
    
    //insert item to sorted array
    mutating func insertSorted(newItem item: Element, descending: Bool = false) {
        let index = insertionIndexOf(elem: item) { descending ? ($0 < $1) : ($0 > $1) }
        insert(item, at: index)
    }
}

extension Array {
    
    //https://stackoverflow.com/a/26679191/8234523
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid
            }
        }
        return lo
    }
}
