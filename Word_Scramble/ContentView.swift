//
//  ContentView.swift
//  Word_Scramble
//
//  Created by Kyle Housel on 4/23/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
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
                        
                        TextField("Enter your word", text: $newWord)
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
                        
                        ForEach(usedWords, id: \.self ) { word in
                            
                            HStack{
                                
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                    
                }
                .navigationTitle(rootWord)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK") {}
                } message:  {
                    Text(errorMessage)
                }
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            HStack {
                                Text("Score: \(score)")
                                    .font(.title)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("New Game") {
                                    usedWords = [String]()
                                    newWord = ""
                                    score = 0
                                    startGame()
                                }
                                .buttonStyle(CustomToolbarButtonStyle())
                            }
                            .padding()
                        }
                        
                    }
            }
            
        }
        
    }
    func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original.")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible.", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized.", message: "You can't just make them up, you know.")
            return
        }
        
        func isValid(word: String) -> Bool {
            if word.count < 3 || word == rootWord {
                return false
            } else {
                withAnimation {
                    usedWords.insert(answer, at: 0)
                }
                return true
            }
        }

        guard isValid(word: answer) else {
            wordError(title: "Word not valid.", message: "Your word is either too short or the same as the given word.")
            return
        }
        
        score += answer.count + usedWords.count
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
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

#Preview {
    ContentView()
}
