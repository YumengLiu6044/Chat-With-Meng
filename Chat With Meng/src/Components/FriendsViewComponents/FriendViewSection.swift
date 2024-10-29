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
        
        if self.showFriends {
            VStack(spacing: height * 0.025) {
                ForEach(friends) { friend in
                    if let index = friends.firstIndex(where: { $0.id == friend.id }) {
                        FriendRowView(
                            friend: $friends[index],
                            width: width,
                            height: height * 0.1,
                            resultState: determineState(of: friends[index])
                        )
                        .padding([.leading, .trailing])
                        .scrollTransition {
                            content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                        }
                        
                        if (index != friends.count - 1) {
                            Divider()
                                .foregroundStyle(.primary)
                                .padding([.leading, .trailing])
                        }
                    }
                }
            }
        }
    }
    
    private func determineState(of friend: Friend) -> FriendRowState {
        if self.chatViewModel.friendRequests.contains(friend) {
            return .requested
        }
        else if self.chatViewModel.friends.contains(friend) {
            return .friended
        }
        else {
            return .searched
        }
    }
}
