import SwiftUI

struct FriendViewSection: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @Binding var showFriends: Bool
    @Binding var friends: [Friend]
    var sectionTitle: String
    var width: CGFloat
    var height: CGFloat
    var hideTitle: Bool = false
    
    var body: some View {
        Section( content: {
            if self.showFriends {
                ForEach(friends) { friend in
                    if let index = friends.firstIndex(where: { $0.id == friend.id }) {
                        FriendRowView(
                            friend: $friends[index],
                            width: width,
                            height: height * 0.1
                        )
                        .padding([.leading, .trailing])
                        .padding(.top, index == 0 ? height * 0.01 : 0)
                        
                        if (index != chatViewModel.friends.count - 1) {
                            Divider()
                                .foregroundStyle(.primary)
                                .padding([.leading, .trailing])
                        }
                    }
                }
            }
        }, header: {
            if !hideTitle {
                HStack {
                    Text(sectionTitle)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.smooth) {
                            self.showFriends.toggle()
                        }
                    }
                    label: {
                        Image(systemName: "chevron.forward")
                            .font(.title3)
                    }
                    .tint(.secondary)
                    .rotationEffect(self.showFriends ? .degrees(90) : .zero)
                }
                .padding([.leading, .trailing], width * 0.05)
                .padding(.top, height * 0.01)
            }
        })
        
    }
}
