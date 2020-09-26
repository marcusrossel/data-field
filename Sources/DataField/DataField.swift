#if canImport(SwiftUI)

import SwiftUI

public struct DataField<Data>: View {
    
    /// The title of the text view, describing its purpose.
    private let title: String
    
    /// The underlying data that should *actually* be manipulated.
    /// When not being edited, the text field presents this data as a string with the help of a
    /// given `encode` function.
    /// When being actively edited, the text field does not show a representation of this data, but
    /// rather its own transient `buffer`.
    /// If editing ends in a state where `decode` can successfully decode the `buffer` into `Data`,
    /// this property is updated with that decoded value.
    @Binding private var data: Data
    
    /// An optional hook into the text field, to observe any buffer values that are not decodable
    /// into a `Data` value.
    /// If the buffer contains valid data, the wrapped value is `nil`.
    private let invalidText: Binding<String?>?
    
    /// A function that can turn values of the underlying data into string representations.
    private let display: (Data) -> String
    
    /// A function that can turn strings intro values of the underlying data, if possible.
    /// If this is not possible, `nil` should be returned.
    private let retrieve: (String) -> Data?
    
    /// A buffer that is used to hold the text field's string during editing.
    @State private var buffer: String
    
    /// An indicator for whether the text field is currently being edited.
    @State private var isEditing = false
    
    /// The binding that is given to the text field.
    ///
    /// This binding performs some of the important steps necessary for the behavior of the data
    /// field:
    /// * get: chooses whether the buffer or the underlying data should be shown by the text field
    /// * set: observes changes to the buffer and updates the `invalidBuffer` accordingly
    private var text: Binding<String> {
        Binding(
            get: { isEditing ? buffer : display(data) },
            set: {
                buffer = $0
                invalidText?.wrappedValue = (retrieve(buffer) == nil) ? buffer : nil
            }
        )
    }
    
    /// A data field is made up of just a single text field.
    public var body: TextField<Text> {
        TextField(title, text: text) { isEditing in
            self.isEditing = isEditing
            
            if !isEditing {
                invalidText?.wrappedValue = nil
                
                if let data = retrieve(buffer) {
                    self.data = data
                }
            }
        }
    }
    
    public init?(
        title: String,
        data: Binding<Data>,
        invalidText: Binding<String?>? = nil,
        display: @escaping (Data) -> String,
        retrieve: @escaping (String) -> Data?
    ) {
        self.title = title
        self._data = data
        self.invalidText = invalidText
        self.display = display
        self.retrieve = retrieve
        
        _buffer = State(initialValue: display(data.wrappedValue))
        
        guard retrieve(buffer) != nil else { return nil }
    }
}

// MARK: - Convenience Initializers

extension DataField {
    
    public init?(
        _ title: String,
        data: Binding<Data>,
        textIsValid: Binding<Bool>? = nil,
        display: @escaping (Data) -> String,
        retrieve: @escaping (String) -> Data?
    ) {
        let invalidText: Binding<String?>?
        
        if let textIsValid = textIsValid {
            invalidText = Binding<String?>(
                get: { textIsValid.wrappedValue ? nil : "" },
                set: { buffer in textIsValid.wrappedValue = (buffer == nil) }
            )
        } else {
            invalidText = nil
        }
        
        self.init(
            title: title,
            data: data,
            invalidText: invalidText,
            display: display,
            retrieve: retrieve
        )
    }
}

extension DataField where Data == String {
    
    /// Creates a data field that only accepts strings that satisfy a given constraint.
    public init?(
        title: String,
        data: Binding<Data>,
        invalidText: Binding<String?>? = nil,
        constraint: @escaping (String) -> Bool
    ) {
        self.init(
            title: title,
            data: data,
            invalidText: invalidText,
            // The display function is trivially the identity function on the string.
            display: { $0 },
            // The retrieving function passes the string along only if it meets the constraint.
            retrieve: { constraint($0) ? $0 : nil }
        )
    }
    
    /// Creates a data field that only accepts strings that satisfy a given constraint.
    public init?(
        _ title: String,
        data: Binding<Data>,
        textIsValid: Binding<Bool>? = nil,
        constraint: @escaping (String) -> Bool
    ) {
        self.init(
            title,
            data: data,
            textIsValid: textIsValid,
            // The display function is trivially the identity function on the string.
            display: { $0 },
            // The retrieving function passes the string along only if it meets the constraint.
            retrieve: { constraint($0) ? $0 : nil }
        )
    }
}

// MARK: - Previews

#if DEBUG

struct DataField_Previews: PreviewProvider {
    
    private struct PlainPreview: View {
    
        @State private var data = 11
    
        var body: some View {
            VStack {
                DataField("Plain", data: $data) {
                    "\($0)"
                } retrieve: {
                    guard let int = Int($0.trimmingCharacters(in: .whitespaces)) else { return nil }
                    return int > 10 ? int : nil
                }
            }
        }
    }

    private struct InvalidTextPreview: View {
    
        @State private var data = 11
        @State private var invalidText: String?
    
        var body: some View {
            VStack {
                DataField(title: "Invalid Text", data: $data, invalidText: $invalidText) {
                    "\($0)"
                } retrieve: {
                    guard let int = Int($0.trimmingCharacters(in: .whitespaces)) else { return nil }
                    return int > 10 ? int : nil
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
                DataField("Text Is Valid", data: $data, textIsValid: $textIsValid) {
                    "\($0)"
                } retrieve: {
                    guard let int = Int($0.trimmingCharacters(in: .whitespaces)) else { return nil }
                    return int > 10 ? int : nil
                }
                
                if !textIsValid {
                    Text("Please enter an integer greater than 10!")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private struct PlainStringPreview: View {
    
        @State private var data = "abcfed"
    
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
                DataField(title: "Invalid Text String", data: $data, invalidText: $invalidText) {
                    $0.count > 5
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
                DataField("Text Is Valid String", data: $data, textIsValid: $textIsValid) {
                    $0.count > 5
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

#endif /*DEBUG*/
#endif /*canImport(SwiftUI)*/
