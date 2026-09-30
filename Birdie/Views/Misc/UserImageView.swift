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
        if let imageURL {
            remoteImage(imageURL)
        } else {
            placeholder(systemName: "person.crop.circle.fill")
        }
    }

    private func placeholder(systemName: String) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(.gray)
    }

    private func remoteImage(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
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
                placeholder(systemName: "person.crop.circle.fill.badge.exclamationmark")
            @unknown default:
                EmptyView()
            }
        }
    }
}
