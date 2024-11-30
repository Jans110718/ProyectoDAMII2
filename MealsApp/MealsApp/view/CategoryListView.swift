//
//  MovieListView.swift
//  MoviesApp
//
//  Created by DAMII on 19/11/24.
//
import SwiftUI

struct MovieListView: View {
    @StateObject var viewModel: MovieListViewModel = MovieListViewModel()
    @State private var currentIndex: Int = 0
    @State private var offset: CGSize = .zero
    @State private var isDragging: Bool = false // Controlar si estamos arrastrando o no
    
    // Base URL de las imágenes
    let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    var body: some View {
        VStack {
            Text("Películas")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            // Mostramos las películas solo si hay datos
            if viewModel.movies.isEmpty {
                ProgressView("Cargando películas...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                ZStack {
                    ForEach(viewModel.movies.indices, id: \.self) { index in
                        if index == currentIndex {
                            MovieCardView(movie: viewModel.movies[index])
                                .offset(x: offset.width)
                                .rotationEffect(.degrees(Double(offset.width / 10)))  // Rotación para dar un efecto
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            // Actualiza la posición del gesto mientras se desliza
                                            offset = value.translation
                                            isDragging = true
                                        }
                                        .onEnded { value in
                                            // Cuando el gesto termina
                                            isDragging = false
                                            
                                            if abs(offset.width) > 150 {
                                                // Si el deslizamiento es mayor a 150 puntos, eliminamos la película
                                                withAnimation(.spring()) {
                                                    currentIndex += 1
                                                    offset = .zero
                                                }
                                            } else {
                                                // Si no se desliza lo suficiente, volvemos a la posición original
                                                withAnimation(.spring()) {
                                                    offset = .zero
                                                }
                                            }
                                        }
                                )
                                .animation(.spring(), value: offset)
                        }
                    }
                    
                    // Botón "Me gusta" (Corazón) - En la esquina derecha
                    Button(action: {
                        // Acción al hacer clic en el corazón: Marcar "Me gusta" y pasar a la siguiente película
                        withAnimation {
                            currentIndex += 1
                        }
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                            .padding()
                    }
                    .position(x: UIScreen.main.bounds.width - 50, y: 350)
                    
                    // Botón "No me gusta" (X) - En la esquina izquierda
                    Button(action: {
                        // Acción al hacer clic en la X: Marcar "No me gusta" y pasar a la siguiente película
                        withAnimation {
                            currentIndex += 1
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                            .padding()
                    }
                    .position(x: 60, y: 350)
                    
                }
                .frame(height: 500) // Altura de la tarjeta
            }
        }
        .onAppear {
            viewModel.getPopularMovies()
        }
    }
}

struct MovieCardView: View {
    let movie: Movie
    
    // Base URL de las imágenes
    let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    var body: some View {
        VStack {
            if let posterURL = URL(string: baseImageURL + movie.poster) {
                AsyncImage(url: posterURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 375)  // Ajusta el tamaño de la imagen
                    } else if phase.error != nil {
                        Text("Error al cargar la imagen")
                            .foregroundColor(.red)
                    } else {
                        ProgressView()
                    }
                }
                .cornerRadius(16)
                .shadow(radius: 10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(movie.overview)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}
