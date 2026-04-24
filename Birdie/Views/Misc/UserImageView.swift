//
//  UserImageView.swift
//  Birdie
//
//  Created by dmu mac 33 on 15/05/2025.
//

import SwiftUI

struct UserImageView: View {
    let imageURL: URL?
    var size: CGFloat
    

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: size, height: size)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            case .failure:
                Image(systemName: "person.crop.circle.fill.badge.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}
