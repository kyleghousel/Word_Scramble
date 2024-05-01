//
//  Word_Scramble_model_logic.swift
//  Word_Scramble
//
//  Created by Kyle Housel on 4/30/24.
//

import Foundation
import SwiftUI

// include functions such as addNewWord, startGame, isOriginal, isPossible, isReal, and wordError, as well as the @State properties related to game state.

class WordScrambleGame: ObservableObject {
    @Published var usedWords = [String]()
    @Published var  rootWord = ""
    @Published var  score = 0
    @Published var newWord = ""
    
    var newWordBinding: Binding<String> {
            Binding<String>(
                get: { self.newWord },
                set: { self.newWord = $0 }
            )
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
        //errorTitle = title
        //errorMessage = message
        //showingError = true
    }
    
}
