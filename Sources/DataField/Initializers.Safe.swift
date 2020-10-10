//
//  Initializers.Safe.swift
//  DataField
//
//  Created by Marcus Rossel on 08.10.20.
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - Safe Data Field

extension DataField {

    /// Creates a data field that emits valid data values into a given sink.
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
        let field = Safe(
            title,
            initialData: initialData,
            textToData: textToData,
            dataToText: dataToText,
            editableText: editableText,
            sink: sink,
            invalidText: invalidText
        )
        
        self.init(safe: field)
    }
}

// MARK: - Constrained Text Field

extension DataField where Data == String {
    
    // An initializer a là `init(_:data:constraint:invalidText:)` doesn't make sense for safe data
    // fields, as they have to be able to handle `nil` in their data-to-text function.
}

// MARK: - Custom String Convertible Data Field

extension DataField where Data: CustomStringConvertible {
    
    // An initializer a là `init(_:data:textToData:invalidText:)` doesn't make sense for safe data
    // fields, as they have to be able to handle `nil` in their data-to-text function.
}

// MARK: - Lossless String Convertible Data Field

extension DataField where Data: LosslessStringConvertible {
    
    // An initializer a là `init(_:data:invalidText:)` doesn't make sense for safe data fields, as
    // they have to be able to handle `nil` in their data-to-text function.
}
    
#endif /*canImport(SwiftUI)*/

