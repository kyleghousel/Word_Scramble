//
//  ContentView.swift
//  Word_Scramble
//
//  Created by Kyle Housel on 4/23/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = WordScrambleGame()
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                   Rectangle()
                        .foregroundColor(.black)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    
                    Text("Word Scramble")
                        .font(.custom("Verdana", size: 30.0))
                        .fontWeight(.bold)
                        .foregroundColor(.mint)
            }
            
            NavigationStack {
                
                List {
                    
                    Section {
                        
                        TextField("Enter your word", text: game.newWordBinding)
                            .textInputAutocapitalization(.never)
                            .focused($isTextFieldFocused)
                            .onAppear {
                                isTextFieldFocused = true
                            }
                            .onDisappear {
                                isTextFieldFocused = false
                            }
                    }
                    
                    Section {
                        
                        ForEach(game.usedWords, id: \.self ) { word in
                            
                            HStack{
                                
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                    
                }
                .navigationTitle(game.rootWord)
                .onSubmit(game.addNewWord)
                .onAppear(perform: game.startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK") {}
                } message:  {
                    Text(errorMessage)
                }
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            HStack {
                                Text("Score: \(game.score)")
                                    .font(.title)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("New Game") {
                                    game.usedWords = [String]()
                                    game.newWord = ""
                                    game.score = 0
                                    game.startGame()
                                }
                                .buttonStyle(CustomToolbarButtonStyle())
                            }
                            .padding()
                        }
                        
                    }
            }
            
        }
        
    }
    
}

struct CustomToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .foregroundColor(.black)
            .background(configuration.isPressed ? Color.mint.opacity(0.8) : Color.mint)
            .cornerRadius(8)
            .fontWeight(.heavy)
            .font(.custom("Verdana", size: 20.0))
    }
}

//#Preview {
//    ContentView()
//}
