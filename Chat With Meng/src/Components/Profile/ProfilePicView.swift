//
//  OnlineImageView.swift
//  Weather
//
//  Created by Yumeng Liu on 7/7/24.
//

import SwiftUI
import CachedAsyncImage


struct ProfilePicView: View {
    var imageURL: String
    var imageOverlayData: [CGFloat]
    
    var width: CGFloat
    var height: CGFloat
    
    @Binding var isOnline: Bool
    @Binding var isLoading: Bool
    
    
    var body: some View {
        CachedAsyncImage(url: URL(string: imageURL), urlCache: .imageCache, transaction: Transaction(animation: .spring(response: 1, dampingFraction: 0.6, blendDuration: 0.5))) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .scaledToFill()
                    .saturation(isOnline ? 1 : 0.3)
                    .clipShape(Circle())
                    .frame(width: width, height: width)
                    .overlay {
                        Circle()
                            .stroke(isOnline ? Color(.init(red: imageOverlayData[0], green: imageOverlayData[1], blue: imageOverlayData[2], alpha: 1)) : .gray, lineWidth: width * 0.04)
                            .frame(width: width * 1.1, height: width * 1.1)
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

extension URLCache {
    
    static let imageCache = URLCache(memoryCapacity: 5_000_000, diskCapacity: 10_000_000_000)
}

extension UIImage {
    var averageColor: [CGFloat] {
           guard let inputImage = CIImage(image: self) else { return [] }
           let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

           guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return [] }
           guard let outputImage = filter.outputImage else { return [] }

           var bitmap = [UInt8](repeating: 0, count: 4)
           let context = CIContext(options: [.workingColorSpace: kCFNull!])
           context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

           return [CGFloat(bitmap[0]) / 255, CGFloat(bitmap[1]) / 255, CGFloat(bitmap[2]) / 255]
       }
}

#Preview {
    ProfilePicView(imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTenTVwBIhhGirjghoRBko0CgRmfXiapbz1Q&s", imageOverlayData: [50, 50, 50], width: 100, height: 100, isOnline: .constant(true), isLoading: .constant(true))
        .preferredColorScheme(.light)
}
