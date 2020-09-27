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
                } dataToText: {
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
                } dataToText: {
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
    
    /*private struct SafeInvalidTextPreview: View {
    
        @State private var data: Int? = nil
        @State private var invalidText: String?
    
        var body: some View {
            VStack {
                DataField("Safe Invalid Text", initialData: data) {
                    guard let int = Int($0.trimmingCharacters(in: .whitespaces)) else { return nil }
                    return int > 10 ? int : nil
                } dataToText: {
                    if let data = $0 { return "\(data)" } else { return "" }
                } sink: {
                    data = $0
                } invalidText: {
                    invalidText = $0
                }
                
                if let invalidText = invalidText {
                    Text("'\(invalidText)' is not an integer greater than 10!")
                        .foregroundColor(.red)
                }
            }
        }
    }*/
    
    private struct PlainStringPreview: View {
    
        @State private var data = "abcdef"
    
        var body: some View {
            VStack {
                DataField("Plain String", data: $data) {
                    $0.count > 5
                }
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
    
    /*private struct SafeInvalidTextStringPreview: View {
    
        @State private var data: String? = nil
        @State private var invalidText: String?
    
        var body: some View {
            VStack {
                DataField("Safe Invalid Text String", initialData: data) {
                    $0.count > 5
                } dataToText: {
                    $0 ?? ""
                } sink: {
                    data = $0
                } invalidText: {
                    invalidText = $0
                }
                
                if let invalidText = invalidText {
                    Text("'\(invalidText)' is not an integer greater than 10!")
                        .foregroundColor(.red)
                }
            }
        }
    }*/
    
    static var previews: some View {
        Form {
            Section(header: Text("Integers").font(.headline)) {
                HStack {
                    Text("Plain: ")
                    PlainPreview()
                }
                HStack {
                    Text("Invalid Text: ")
                    InvalidTextPreview()
                }
                /*HStack {
                    Text("Safe Invalid Text: ")
                    SafeInvalidTextPreview()
                }*/
            }
            
            Section(header: Text("Strings").font(.headline)) {
                HStack {
                    Text("Plain: ")
                    PlainStringPreview()
                }
                HStack {
                    Text("Invalid Text: ")
                    InvalidTextStringPreview()
                }
                /*HStack {
                    Text("Safe Invalid Text: ")
                    SafeInvalidTextStringPreview()
                }*/
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

#endif /*DEBUG && canImport(SwiftUI)*/
