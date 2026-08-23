//
//  FilmImageView.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 23/08/2026.
//

import SwiftUI

struct FilmImageView: View {
    let urlPath: String
    
    var body: some View {
        AsyncImage(url: URL(string: urlPath)){
            phase in
            switch(phase){
            case .empty:
                Color(white: 0.8)
                    .overlay{
                        ProgressView()
                            .controlSize(.large)
                    }
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure(let error):
                Text("Could not get image")
            @unknown default:
                fatalError()
            }
        }
    }
}

#Preview("Poster Image") {
    FilmImageView(urlPath: "https://image.tmdb.org/t/p/w600_and_h900_bestv2/npOnzAbLh6VOIu3naU5QaEcTepo.jpg").frame(height: 150)
}

#Preview("Banner Image") {
    FilmImageView(urlPath: "https://image.tmdb.org/t/p/w533_and_h300_bestv2/3cyjYtLWCBE1uvWINHFsFnE8LUK.jpg").frame(height: 300)
}
