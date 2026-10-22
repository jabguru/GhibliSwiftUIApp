//
//  FilmImageView.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 23/08/2026.
//

import SwiftUI

struct FilmImageView: View {

    @Environment(\.theme) private var theme

    let url: URL?

    init(urlPath: String) {
        self.url = URL(string: urlPath)
    }

    init(url: URL?) {
        self.url = url
    }

    var body: some View {
        // Flutter: the `transaction` is like passing an `AnimatedSwitcher` around the
        // image builder. Every phase change (loading → loaded) is animated, and each
        // phase's `.transition` decides *how* it enters and leaves.
        AsyncImage(url: url, transaction: Transaction(animation: .smooth(duration: 0.5))) { phase in
            switch phase {
                case .empty:
                    Rectangle()
                        .fill(theme.skeleton)
                        .shimmer()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .transition(.blurReplace)
                case .failure(_):
                    ZStack {
                        Rectangle().fill(theme.skeleton)
                        Image(systemName: "photo.badge.exclamationmark")
                            .font(.title)
                            .foregroundStyle(theme.textSecondary)
                    }
                @unknown default:
                    Rectangle().fill(theme.skeleton)
            }
        }
        // Keeps scaledToFill images from spilling outside the frame callers give us.
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .clipped()
    }
}

#Preview("poster image") {
     FilmImageView(url: URL.convertAssetImage(named: "posterImage"))
        .frame(height: 150)
}

#Preview("banner image") {

    let name = "bannerImage"
    let url = URL.convertAssetImage(named: name)

   // FilmImageView(urlPath: "https://image.tmdb.org/t/p/w533_and_h300_bestv2/3cyjYtLWCBE1uvWINHFsFnE8LUK.jpg")
    FilmImageView(url: url)
        .frame(height: 300)

}
