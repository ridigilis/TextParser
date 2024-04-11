//
//  main.swift
//  TextParser
//
//  Created by Ricky David Groner II on 4/11/24.
//

import Foundation
import NaturalLanguage

@main
struct App {
    static func main() {
        let text = CommandLine.arguments.dropFirst().joined(separator: " ")
        
        let language = NLLanguageRecognizer.dominantLanguage(for: text) ?? .undetermined
        print()
        print("Detected language: \(language.rawValue)")
        
        print()
        let sentiment = sentiment(for: text)
        print("Sentiment analysis: \(sentiment)")
        print()
        print("Found the following alternatives:")
        let lemma = lemmatize(string: text)
        for word in lemma {
            let embeddings = embeddings(for: word)
            print("\t\(word): ", embeddings.formatted(.list(type: .and)))
        }
    }
    
    static func sentiment(for string: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = string
        
        let (sentiment, _) = tagger.tag(at: string.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        return Double(sentiment?.rawValue ?? "0") ?? 0
    }
    
    static func embeddings(for word: String) -> [String] {
        var results = [String]()
        if let embedding = NLEmbedding.wordEmbedding(for: .english) {
            let similarWords = embedding.neighbors(for: word, maximumCount: 10)
            for word in similarWords {
                results.append("\(word.0) has a distance of \(word.1)")
            }
        }
        
        return results
    }
    
    static func lemmatize(string: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = string
        
        var results = [String]()
        
        tagger.enumerateTags(in: string.startIndex..<string.endIndex, unit: .word, scheme: .lemma) { tag, range in
            let stemForm = tag?.rawValue ?? String(string[range]).trimmingCharacters(in: .whitespaces)
            
            if stemForm.isEmpty == false {
                results.append(stemForm)
            }
            
            return true
        }
        
        return results
    }
}

