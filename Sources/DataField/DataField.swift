//
//  DataField.swift
//
//  Created by Marcus Rossel on 25.09.20.
//

#if canImport(SwiftUI)

import SwiftUI

public struct DataField<Data>: View {
    
    /// The title of the text view, describing its purpose.
    private let title: String
    
    /// The underlying data that should *actually* be manipulated.
    /// When not being edited, the text field presents this data as a string with the help of a
    /// given `asText` function.
    /// When being actively edited, the text field does not show a representation of this data, but
    /// rather its own transient `buffer`.
    /// If editing ends in a state where `fromText` can successfully decode the `buffer` into
    /// `Data`, this property is updated with that decoded value.
    @Binding private var data: Data
    
    /// A function that can turn strings intro values of the underlying data, if possible.
    /// If this is not possible, `nil` should be returned.
    private let fromText: (String) -> Data?
    
    /// A function that can turn values of the underlying data into string representations.
    private let asText: (Data) -> String
    
    /// An optional hook into the text field, to observe any buffer values that are not decodable
    /// into a `Data` value.
    /// If the buffer contains invalid data, its text is passed.
    /// If the buffer contains valid data, `nil` is passed.
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

// MARK: - Optional Data

extension DataField {
    
    /*public init?(
        _ title: String,
        data: Binding<Data?>,
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
    }*/
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

#endif /*canImport(SwiftUI)*/
