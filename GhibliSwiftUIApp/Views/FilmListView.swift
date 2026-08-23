//
//  FilmListView.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 01/08/2026.
//

import SwiftUI

struct FilmListView: View {
    var filmsViewModel: FilmsViewModel
    
    var body: some View {
        NavigationStack {
            switch filmsViewModel.state {
            case .idle:
                Text("No films yet")
            case .loading:
                ProgressView{Text("Loading...")}
            case .loaded(let films):
                List(films){
                    film in NavigationLink(value: film){
                        HStack{
                            FilmImageView(urlPath: film.image).frame(width: 100, height: 150)
                            Text(film.title)
                        }
                        
                    }
                }.navigationDestination(for: Film.self){
                    film in FilmDetailScreen(film: film)
                }
            case .error(let error):
                Text(error).foregroundStyle(.pink)
            }
        } .task {
            await filmsViewModel.fetch()
        }
    }
}

#Preview {
    @State @Previewable var vm = FilmsViewModel(service: MockGhibliService())
    FilmListView(filmsViewModel: vm)
}
