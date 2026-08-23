//
//  FilmDetailScreen.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 08/08/2026.
//

import SwiftUI

struct FilmDetailScreen: View {
    
    let film: Film
    
    @State private var viewModel = FilmDetailViewModel()
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                FilmImageView(urlPath: film.bannerImage).frame(height: 300)
                    .clipped()
                    .containerRelativeFrame(.horizontal)
                VStack(alignment: .leading){
                    Text(film.title)
                    Divider()
                    Text("Characters").font(.title3)
                    switch viewModel.state {
                    case .idle: EmptyView()
                    case .loading: ProgressView()
                    case .loaded(let people):
                        ForEach(people){
                            person in Text(person.name)
                        }
                    case .error(let error): Text(error).foregroundStyle(.pink)
                    }
                }.padding()
            }
            .task(id: film) {
                await viewModel.fetch(for: film)
            }
        }
    }
}

#Preview {
    FilmDetailScreen(film: Film.example)
}
