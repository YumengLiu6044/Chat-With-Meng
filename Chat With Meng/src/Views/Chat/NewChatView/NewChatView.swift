//
//  NewChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/29/24.
//

import SwiftUI

struct NewChatView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    
    var width: CGFloat = 400
    var height: CGFloat = 700
    
    @FocusState private var focus: FocusField?
    
    @State private var groupName: String = ""
    @State private var members: [Friend] = []
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Group name")
                    .font(.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .leading])
                
                TextField(
                    "Name", text: $groupName,
                    prompt: Text("Name").foregroundStyle(.gray)
                )
                .frame(height: height * 0.02)
                .padding()
                .background(.ultraThickMaterial)
                .clipShape(.rect(cornerRadius: width * 0.03))
                .shadow(radius: 3)
                .overlay {
                    RoundedRectangle(cornerRadius: width * 0.03)
                        .stroke(.blue.opacity(0.8), lineWidth: (focus == .groupName) ? 2 : 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing])
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.asciiCapable)
                .focused($focus, equals: .groupName)
                .onDisappear {
                    focus = nil
                }
                
                Text("Members")
                    .font(.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .top])
                
                ScrollView {
                    LazyVGrid(columns: self.columns, spacing: width * 0.01) {
                        ForEach(self.members) { member in
                            VStack {
                                ProfilePicView(
                                    imageURL: member.profilePicURL,
                                    imageOverlayData: member.profileOverlayData,
                                    width: width * 0.2,
                                    height: width * 0.2
                                )
                                .padding(.top)
                                
                                Text(member.userName)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        
                        .scrollTransition {
                            content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                        }
                    }
                }
                .scrollClipDisabled()
                
                Spacer()
                
                Button {
                    chattingVM.makeGroupChat(with: groupName, of: members) {
                        result in
                        if result {
                            chattingVM.showNewChat = false
                            chattingVM.isComposing = false
                        }
                    }
                }
                label: {
                    HStack {
                        Spacer()
                        Text("Create chat")
                            .font(.title2)
                        Spacer()
                    }
                }
                .disabled(groupName.isEmpty)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: width * 0.03))
                .tint(.blue)
                .shadow(radius: 5)
                .padding([.bottom], height * 0.13)
                .padding([.leading, .trailing])
                .frame(alignment: .bottom)
                

            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("New Chat")
            .onAppear {
                self.chattingVM.getMembers { members in
                    guard let members = members else {return}
                    withAnimation {
                        self.members = members
                    }
                }
            }
        }
    }
}

//#Preview {
//    NewChatView()
//}
