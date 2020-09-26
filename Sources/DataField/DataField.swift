//
//  DataField.swift
//
//  Created by Marcus Rossel on 25.09.20.
//

#if canImport(SwiftUI)

import SwiftUI

// MARK: - Data Field

public struct DataField<Data>: View {
    
    /// The title of the text view, describing its purpose.
    private let title: String
    
    /// The underlying data that should *actually* be manipulated.
    /// When not being edited, the text field presents this data as a string with the help of a
    /// given `dataToText` function.
    /// When being actively edited, the text field does not show a representation of this data, but
    /// rather its own transient `buffer`.
    /// If editing ends in a state where `textToData` can successfully decode the `buffer` into
    /// `Data`, this property is updated with that decoded value.
    @Binding private var data: Data
    
    /// A function that can turn strings intro values of the underlying data, if possible.
    /// If this is not possible, `nil` should be returned.
    private let textToData: (String) -> Data?
    
    /// A function that can turn values of the underlying data into string representations.
    private let dataToText: (Data) -> String
    
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
            get: { isEditing ? buffer : dataToText(data) },
            set: {
                buffer = $0
                invalidText?(textToData(buffer) == nil ? buffer : nil)
            }
        )
    }
    
    /// A data field is made up of just a single text field.
    public var body: TextField<Text> {
        TextField(title, text: text) { isEditing in
            self.isEditing = isEditing
            
            if !isEditing {
                if let data = textToData(buffer) { self.data = data }
                invalidText?(nil)
            }
        }
    }
    
    public init?(
        _ title: String,
        data: Binding<Data>,
        textToData: @escaping (String) -> Data?,
        dataToText: @escaping (Data) -> String,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.title = title
        self._data = data
        self.textToData = textToData
        self.dataToText = dataToText
        self.invalidText = invalidText
        
        _buffer = State(initialValue: dataToText(data.wrappedValue))
        
        guard textToData(buffer) != nil else { return nil }
    }
}

// MARK: - Safe Field

extension DataField {
    
    public init(
        _ title: String,
        initialData: Data? = nil,
        textToData: @escaping (String) -> Data?,
        dataToText: @escaping (Data?) -> String,
        sink: @escaping (Data) -> Void,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.title = title
        self.textToData = textToData
        self.dataToText = dataToText
        self.invalidText = invalidText

        _buffer = State(initialValue: dataToText(initialData))
        
        _data = Binding<Data>(
            get: { fatalError("Unreachable") },
            set: { sink($0) }
        )
    }
}

// MARK: - Constrained Text Field

extension DataField where Data == String {
    
    public init?(
        _ title: String,
        data: Binding<Data>,
        constraint: @escaping (Data) -> Bool,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.init(
            title,
            data: data,
            // The retrieving function passes the string along only if it meets the constraint.
            textToData: { constraint($0) ? $0 : nil },
            // The display function is trivially the identity function on the string.
            dataToText: { $0 },
            invalidText: invalidText
        )
    }
}
    
// MARK: - Safe Constrained Text Field

extension DataField where Data == String {
    
    public init(
        _ title: String,
        initialData: Data? = nil,
        constraint: @escaping (Data) -> Bool,
        dataToText: @escaping (Data?) -> String,
        sink: @escaping (Data) -> Void,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.init(
            title,
            initialData: initialData,
            // The retrieving function passes the string along only if it meets the constraint.
            textToData: { constraint($0) ? $0 : nil },
            dataToText: dataToText,
            sink: sink,
            invalidText: invalidText
        )
    }
}

#endif /*canImport(SwiftUI)*/
