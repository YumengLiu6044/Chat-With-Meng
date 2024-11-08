//
//  MessageRowView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 11/5/24.
//

import SwiftUI

struct MessageRowView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    
    var message: Message
    var width: CGFloat
    
    var senderIsSelf: Bool
    var showProfile: Bool
    
    @State private var senderObj: Friend?
    
    var body: some View {
        HStack {
            FlipGroup(if: senderIsSelf) {
                if let senderObj = senderObj, showProfile {
                    ProfilePicView(
                        imageURL: senderObj.profilePicURL,
                        imageOverlayData: senderObj.profileOverlayData,
                        width: width * 0.1,
                        height: width * 0.1
                    )
                    .padding(senderIsSelf ? .trailing : .leading, width * 0.02)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 22)
                }
                else {
                    Circle()
                        .hidden()
                        .frame(width: width * 0.1, height: width * 0.1)
                        .padding(senderIsSelf ? .trailing : .leading, width * 0.02)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                
                VStack(alignment: senderIsSelf ? .trailing : .leading) {
                    if showProfile {
                        Text(senderObj?.userName ?? "")
                            .font(.caption)
                            .foregroundStyle(.gray.opacity(0.5))
                    }
                    Text(message.content)
                        .font(.system(size: width * 0.048))
                        .lineSpacing(3)
                        .foregroundStyle(senderIsSelf ? .white : .primary)
                        .padding(width * 0.025)
                        .background {
                            RoundedRectangle(cornerRadius: width * 0.05)
                                .fill()
                                .foregroundStyle(senderIsSelf ? .blue : .gray.opacity(0.6))
                        }
                        .textSelection(.enabled)
                        .frame(maxWidth: width * 0.7, alignment: senderIsSelf ? .trailing : .leading)
                }
                .padding(senderIsSelf ? .trailing : .leading, width * 0.01)
            }
    
        }
        .frame(maxWidth: .infinity, alignment: senderIsSelf ? .trailing : .leading)
        .onAppear {
            Task {
                guard let sender = await FirebaseManager.makeFriend(from: message.fromUserID) else {return}
                withAnimation(.smooth) {
                    senderObj = sender
                }
            }
        }
    }
}

@ViewBuilder
func FlipGroup<V1: View, V2: View>(if value: Bool,
                @ViewBuilder _ content: @escaping () -> TupleView<(V1, V2)>) -> some View {
    let pair = content()
    if value {
        TupleView((pair.value.1, pair.value.0))
    } else {
        TupleView((pair.value.0, pair.value.1))
    }
}

#Preview {
    var previewVM = ChattingViewModel()
    
    MessageRowView(message: Message(contentType: .text, content: "Hello, how are you? I just want to make sure the app is working. I'm not interested in talking with you. Hello, how are you? I just want to make sure the app is working. I'm not interested in talking with you. Hello, how are you? I just want to make sure the app is working. I'm not interested in talking with you. Hello, how are you? I just want to make sure the app is working. I'm not interested in talking with you. ",fromUserID: "yaLJd3clPWYoWWXFVw0BjnpxBV12"), width: 400, senderIsSelf: true, showProfile: true)
        .environmentObject(previewVM)
//        .onAppear {
//            previewVM.chatObjInView = Chat(
//                userIDArray: [
//                    "nNtajS9jsrZFuWN1cGW0OaeHEUK2" : nil,
//                    "yaLJd3clPWYoWWXFVw0BjnpxBV12" : nil
//                ]
//            )
//            previewVM.messagesInView = [
//                Message(contentType: .text,
//                        content: "Hello, how are you? I just want to make sure the app is working. I'm not interested in talking with you",
//                        fromUserID: "yaLJd3clPWYoWWXFVw0BjnpxBV12"
//                       ),
//                Message(contentType: .text,
//                        content: "You know what? Same",
//                        fromUserID: "nNtajS9jsrZFuWN1cGW0OaeHEUK2"
//                       )
//            ]
//        }
}
