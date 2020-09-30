//
//  DataField.swift
//
//  Created by Marcus Rossel on 25.09.20.
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - Data Field

/// A view that wraps a `TextField` to only accept specific data.
///
/// SwiftUI's native `TextField` is a great tool to allow users to edit **text** in your app.
/// Oftentimes what we *actually* want to edit though is data that is not text. And further, it's
/// usually required that the data fulfills certain requirements.
/// `DataField` provides a text field to edit any kind of data, declare constraints on the user's
/// inputs and gives you options for handling invalid inputs.
/// 
/// For more information check out the [repository](https://github.com/marcusrossel/data-field).
public struct DataField<Data>: View {
    
    /// Data fields come in different styles, which unfortunately seem to require seperate
    /// implementations. This property captures the underlying view which will represent the data
    /// field (which is chosen during initialization). 
    private let view: AnyView
    
    public var body: some View {
        view
    }
    
    /// Creates an data field to act upon a given binding.
    ///
    /// - Parameters:
    ///
    ///   - title: The title of the text view, describing its purpose.
    ///
    ///   - data: The underlying data that should be set by the data field. When not editing, the
    ///           data field will reflect *any* values written to this binding.
    ///
    ///   - textToData: A conversion function from a `String` to a `Data` value. If there is no
    ///                 sensible conversion, return `nil` to indicate that the text is not valid
    ///                 data.
    ///
    ///   - dataToText: A conversion function from a `Data?` to a `String` value. This is directly
    ///                 responsible for the representation of the data values in the data field.
    ///
    ///   - editableText: An optional conversion function from a `Data` to a `String` value for
    ///                   finer grained control. It is sometimes desirable to have the
    ///                   representations of data be different when a user is editing it vs. when
    ///                   the data field is not being edited. In that case you can specify the
    ///                   editable version of the text with this closure and the non-editable
    ///                   version with `dataToText`.
    ///                   An example use case could be to show grouping-seperators of a number when
    ///                   not editing (`1.234.000`) but remove them when editing (`1234000`).
    ///
    ///   - invalidText: A hook into the data field, to observe any text values that do not
    ///                  correspond to valid data. When the data field stops editing, a `nil` value
    ///                  is always passed.
    public init(
        _ title: String,
        data: Binding<Data>,
        textToData: @escaping (String) -> Data?,
        dataToText: @escaping (Data) -> String,
        editableText: ((Data) -> String)? = nil,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.view = AnyView(Unsafe(
            title,
            data: data,
            textToData: textToData,
            dataToText: dataToText,
            editableText: editableText,
            invalidText: invalidText
        ))
    }
    
    /// Creates an data field that emits valid data values into a given sink.
    ///
    /// - Parameters:
    ///
    ///   - title: The title of the text view, describing its purpose.
    ///
    ///   - initialData: An initial data value to be shown when the data field has not yet had
    ///                  other valid data committed to it. If the given value does not meet the
    ///                  requirements given by `textToData`, it will be treated as a `nil` value.
    ///                  Since this value is optional, you also have to handle `nil` in
    ///                  `dataToText` and `editableText`.
    ///
    ///   - textToData: A conversion function from a `String` to a `Data?` value. If there is no
    ///                 sensible conversion, return `nil` to indicate that the text is not valid
    ///                 data.
    ///
    ///   - dataToText: A conversion function from a `Data?` to a `String` value. This is directly
    ///                 responsible for the representation of the data values in the data field.
    ///
    ///   - editableText: An optional conversion function from a `Data` to a `String` value for
    ///                   finer grained control. It is sometimes desirable to have the
    ///                   representations of data be different when a user is editing it vs. when
    ///                   the data field is not being edited. In that case you can specify the
    ///                   editable version of the text with this closure and the non-editable
    ///                   version with `dataToText`.
    ///                   An example use case could be to show grouping-seperators of a number when
    ///                   not editing (`1.234.000`) but remove them when editing (`1234000`).
    ///
    ///   - sink: A sink for any valid data values that are committed to the data field.
    ///
    ///   - invalidText: A hook into the data field, to observe any text values that do not
    ///                  correspond to valid data. When the data field stops editing, a `nil` value
    ///                  is always passed.
    public init(
        _ title: String,
        initialData: Data? = nil,
        textToData: @escaping (String) -> Data?,
        dataToText: @escaping (Data?) -> String,
        editableText: ((Data?) -> String)? = nil,
        sink: @escaping (Data) -> Void,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.view = AnyView(Safe(
            title,
            initialData: initialData,
            textToData: textToData,
            dataToText: dataToText,
            editableText: editableText,
            sink: sink,
            invalidText: invalidText
        ))
    }
}

// MARK: - Constrained Text Field

extension DataField where Data == String {
    
    /// Creates an data field to act upon a given string binding. This is a convenience initializer
    /// over `init(_:data:textToData:dataToText:invalidText)`, when working with `String` data.
    ///
    /// - Parameters:
    ///
    ///   - title: The title of the text view, describing its purpose.
    ///
    ///   - data: The underlying data that should be set by the data field. When not editing, the
    ///           data field will reflect *any* values written to this binding.
    ///
    ///   - constraint: A filter function that specifies which strings are considered valid by
    ///                 returning a corresponding boolean.
    ///
    ///   - invalidText: A hook into the data field, to observe any text values that do not
    ///                  correspond to valid data. When the data field stops editing, a `nil` value
    ///                  is always passed.
    public init(
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

#endif /*canImport(SwiftUI)*/
