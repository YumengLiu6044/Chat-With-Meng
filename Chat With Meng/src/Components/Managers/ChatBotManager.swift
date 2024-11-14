//
//  ChatBotManager.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 11/13/24.
//

import Foundation
import SwiftUI

//content = {
//    "chat_id": "i dont exist",
//    "prompt": "Sure, in 10 min?",
//    "temperature": 0.5,
//    "max_new_tokens": 100,
//    "repetition_penalty": 1.15,
//    "custom_stop_tokens": "<|eot_id|>"
//}

struct RequestBody: Codable {
    var chat_id: String
    var prompt: String
    var temperature: Double = 0.5
    var max_new_tokens: Int = 100
    var repetition_penalty: Double = 1.15
    var custom_stop_tokens: String = "<|eot_id|>"
}

struct Response: Codable {
    var generated_text: String
}

class ChatBotManager {
    static func sendMessageToBot(message: Message) {
        // send url request, receive response
        loadDataFromURL(chat_id: message.chatID, prompt: message.content) {
            result in
            guard let result = result else {return}
            
            roboSend(
                fromSender: FirebaseConstants.botID,
                toChat: message.chatID,
                contentType: .text,
                content: result,
                time: .now
            )
        }
        
    }
    
    static func roboSend(
        fromSender senderID: String,
        toChat chatID: String,
        contentType: ContentType,
        content: String,
        time: Date
    ) {
        
        var message = Message(
            contentType: contentType,
            content: content,
            chatID: chatID,
            fromUserID: senderID
        )
        
        // Add message to chatLogs at chatID
        guard let messageID = FirebaseManager.updateChatLog(atChatID: chatID, message: message)
        else {
            print("No message id found")
            return
        }
        message.id = messageID
        
        // For all members of chat, send message to incomingMessages
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chats)
            .document(chatID)
            .getDocument() {
                doc, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                do {
                    guard let data = try doc?.data(as: Chat.self) else {return}
                    for member in data.userIDArray {
                        if member.key == FirebaseConstants.botID {
                            continue
                        }
                        else {
                            FirebaseManager.setIncomingMessage(for: member.key, message: message)
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                    return
                }
                
            }
    }
    
    static private func loadDataFromURL(chat_id: String, prompt: String, completion: @escaping (String?) -> Void ) {
        let URLString = "http://34.72.119.6:9092/generate/"

        guard let url = URL(string: URLString) else {
            print("Invalid URL")
            return completion(nil)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let body = RequestBody(chat_id: chat_id, prompt: prompt)
        do {
            
            request.httpBody = try JSONEncoder().encode(body)
            let task = URLSession.shared.dataTask(with: request) {
                data, res, error in
                if let error = error {
                    print(error.localizedDescription)
                    return completion(nil)
                }
                
                if let data = data, let res = res {
                    do {
                        let response = try JSONDecoder().decode(Response.self, from: data)
                        return completion(response.generated_text)
                    }
                    catch {
                        print(error.localizedDescription)
                        return completion(nil)
                    }
                }
                return completion(nil)
            }
            task.resume()
            
        }
        catch {
            print("Error while getting response")
            return completion(nil)
        }
    }
}
