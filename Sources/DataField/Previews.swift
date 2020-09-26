//
//  Previews.swift
//
//  Created by Marcus Rossel on 26.09.20.
//

#if DEBUG && canImport(SwiftUI)

import SwiftUI

struct DataField_Previews: PreviewProvider {
    
    private struct PlainPreview: View {
    
        @State private var data = 11
    
        var body: some View {
            VStack {
                DataField("Plain", data: $data) {
                    guard let int = Int($0.trimmingCharacters(in: .whitespaces)) else { return nil }
                    return int > 10 ? int : nil
                } asText: {
                    "\($0)"
                }
            }
        }
    }

    private struct InvalidTextPreview: View {
    
        @State private var data = 11
        @State private var invalidText: String?
    
        var body: some View {
            VStack {
                DataField("Invalid Text", data: $data) {
                    guard let int = Int($0.trimmingCharacters(in: .whitespaces)) else { return nil }
                    return int > 10 ? int : nil
                } asText: {
                    "\($0)"
                } invalidText: {
                    invalidText = $0
                }
                
                if let invalidText = invalidText {
                    Text("'\(invalidText)' is not an integer greater than 10!")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private struct TextIsValidPreview: View {
    
        @State private var data = 11
        @State private var textIsValid = true
    
        var body: some View {
            VStack {
                DataField("Text Is Valid", data: $data) {
                    guard let int = Int($0.trimmingCharacters(in: .whitespaces)) else { return nil }
                    return int > 10 ? int : nil
                } asText: {
                    "\($0)"
                } textIsValid: {
                    textIsValid = $0
                }
                
                if !textIsValid {
                    Text("Please enter an integer greater than 10!")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private struct PlainStringPreview: View {
    
        @State private var data = "abcdef"
    
        var body: some View {
            VStack {
                DataField("Plain String", data: $data) { $0.count > 5 }
            }
        }
    }
    
    private struct InvalidTextStringPreview: View {
    
        @State private var data = "abcdef"
        @State private var invalidText: String?
    
        var body: some View {
            VStack {
                DataField("Invalid Text String", data: $data) {
                    $0.count > 5
                } invalidText: {
                    invalidText = $0
                }
                
                if let invalidText = invalidText {
                    Text("'\(invalidText)' does not have more than 5 characters!")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private struct TextIsValidStringPreview: View {
    
        @State private var data = "abcdef"
        @State private var textIsValid = true
    
        var body: some View {
            VStack {
                DataField("Text Is Valid String", data: $data) {
                    $0.count > 5
                } textIsValid: {
                    textIsValid = $0
                }
                
                if !textIsValid {
                    Text("Please enter a string with more than 5 characters!")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    static var previews: some View {
        Form {
            Section(header: Text("Integers").font(.headline)) {
                HStack {
                    Text("Plain: ")
                    PlainPreview()
                }
                HStack {
                    Text("Text Is Valid: ")
                    TextIsValidPreview()
                }
                HStack {
                    Text("Invalid Text: ")
                    InvalidTextPreview()
                }
            }
            
            Section(header: Text("Strings").font(.headline)) {
                HStack {
                    Text("Plain: ")
                    PlainStringPreview()
                }
                HStack {
                    Text("Text Is Valid: ")
                    TextIsValidStringPreview()
                }
                HStack {
                    Text("Invalid Text: ")
                    InvalidTextStringPreview()
                }
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

#endif /*DEBUG && canImport(SwiftUI)*/
