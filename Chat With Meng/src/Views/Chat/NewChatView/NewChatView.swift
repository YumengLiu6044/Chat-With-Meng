//
//  NewChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/29/24.
//

import SwiftUI

struct NewChatView: View {
    var memebrs: [Friend] = []
    var host: User = User()
    
    var width: CGFloat = 400
    var height: CGFloat = 700
    
    @FocusState private var focus: FocusField?
    
    @State private var groupName: String = ""
    
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
                .padding()
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
                    .padding(.leading)
                
                Spacer()
                
                Button {
                    
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
            .navigationTitle("New Chat")
        }
    }
}

#Preview {
    NewChatView()
}
