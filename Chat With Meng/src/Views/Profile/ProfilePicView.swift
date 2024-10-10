//
//  OnlineImageView.swift
//  Weather
//
//  Created by Yumeng Liu on 7/7/24.
//

import SwiftUI


struct ProfilePicView: View {
    var imageURL: String
    
    var width: CGFloat
    var height: CGFloat
    
    @Binding var isOnline: Bool
    @Binding var isLoading: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL), transaction: Transaction(animation: .spring(response: 1, dampingFraction: 0.6, blendDuration: 0.5))) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .scaledToFill()
                    .saturation(isOnline ? 1 : 0.3)
                    .clipShape(Circle())
                    .frame(width: width, height: width)
                    .overlay {
                        Circle()
                            .stroke(lineWidth: width * 0.05)
                            .frame(width: width * 1.12, height: width * 1.12)
                            .foregroundStyle(.linearGradient(Gradient(colors: [isOnline ? .pink : .gray, isOnline ? .orange : .secondary]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            
                    }
                
            case .failure:
                Image(systemName: "person.fill")
                    .scaledToFill()
                    .overlay {
                        Circle()
                            .stroke(lineWidth: width * 0.05)
                    }
                    .clipShape(Circle())
                    .frame(width: width, height: width)
                    .tint(Color.primary)
            
            case .empty:
                ProgressView()
                    .onAppear {
                        isLoading = true
                    }
                    .scaledToFill()
                    .frame(width: width, height: width)
                    .tint(Color.primary)
                    
                
            @unknown default:
                EmptyView()
                    .onAppear {
                        isLoading = false
                    }
            }}
    }
}

#Preview {
    ProfilePicView(imageURL: "https://img.decrypt.co/insecure/rs:fit:3840:0:0:0/plain/https://cdn.decrypt.co/wp-content/uploads/2024/05/doge-dogecoin-meme-kabosu-gID_7.jpg@webp", width: 100, height: 100, isOnline: .constant(true), isLoading: .constant(true))
        .preferredColorScheme(.dark)
}
