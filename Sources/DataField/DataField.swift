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
    
    /// A function that can turn strings intro values of the underlying data, if possible.
    /// If this is not possible, `nil` should be returned.
    private let fromText: (String) -> Data?
    
    /// A function that can turn values of the underlying data into string representations.
    private let asText: (Data) -> String
    
    #warning("!= correct comment")
    /// An optional hook into the text field, to observe any buffer values that are not decodable
    /// into a `Data` value.
    /// If the buffer contains valid data, the wrapped value is `nil`.
    private let invalidText: ((String?) -> Void)?
    
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
            get: { isEditing ? buffer : asText(data) },
            set: {
                buffer = $0
                invalidText?(fromText(buffer) == nil ? buffer : nil)
            }
        )
    }
    
    /// A data field is made up of just a single text field.
    public var body: TextField<Text> {
        TextField(title, text: text) { isEditing in
            self.isEditing = isEditing
            
            if !isEditing {
                if let data = fromText(buffer) { self.data = data }
                invalidText?(nil)
            }
        }
    }
    
    public init?(
        _ title: String,
        data: Binding<Data>,
        fromText: @escaping (String) -> Data?,
        asText: @escaping (Data) -> String,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.title = title
        self._data = data
        self.fromText = fromText
        self.asText = asText
        self.invalidText = invalidText
        
        _buffer = State(initialValue: asText(data.wrappedValue))
        
        guard fromText(buffer) != nil else { return nil }
    }
    
    public init?(
        _ title: String,
        data: Binding<Data>,
        fromText: @escaping (String) -> Data?,
        asText: @escaping (Data) -> String,
        textIsValid: @escaping (Bool) -> Void
    ) {
        self.init(
            title,
            data: data,
            fromText: fromText,
            asText: asText,
            invalidText: { textIsValid($0 == nil) }
        )
    }
}

// MARK: - Constrained Text Field

extension DataField where Data == String {
    
    /// Creates a data field that only accepts strings that satisfy a given constraint.
    public init?(
        _ title: String,
        data: Binding<Data>,
        constraint: @escaping (String) -> Bool,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.init(
            title,
            data: data,
            // The retrieving function passes the string along only if it meets the constraint.
            fromText: { constraint($0) ? $0 : nil },
            // The display function is trivially the identity function on the string.
            asText: { $0 },
            invalidText: invalidText
        )
    }
    
    /// Creates a data field that only accepts strings that satisfy a given constraint.
    public init?(
        _ title: String,
        data: Binding<Data>,
        constraint: @escaping (String) -> Bool,
        textIsValid: @escaping (Bool) -> Void
    ) {
        self.init(
            title,
            data: data,
            constraint: constraint,
            invalidText: { textIsValid($0 == nil) }
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

#endif /*DEBUG*/
#endif /*canImport(SwiftUI)*/
