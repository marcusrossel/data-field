//
//  Initializers.Unsafe.swift
//
//  Created by Marcus Rossel on 08.10.20.
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - Unsafe Data Field

extension DataField {
    
    /// Creates a data field to act upon a given binding.
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
    ///   - dataToText: A conversion function from a `Data` to a `String` value. This is directly
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
        let field = Unsafe(
            title,
            data: data,
            textToData: textToData,
            dataToText: dataToText,
            editableText: editableText,
            invalidText: invalidText
        )
        
        self.init(unsafe: field)
    }
}

// MARK: - Constrained Text Field

extension DataField where Data == String {
    
    /// Creates a data field to act upon a given string binding.
    /// This is a convenience initializer over
    /// `init(_:data:textToData:dataToText:editableText:invalidText)`.
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
            // The text-to-data function passes the string along only if it meets the constraint.
            textToData: { constraint($0) ? $0 : nil },
            // The data-to-text function is trivially the identity function on the string.
            dataToText: { $0 },
            invalidText: invalidText
        )
    }
}

// MARK: - Custom String Convertible Data Field

extension DataField where Data: CustomStringConvertible {
    
    /// Creates a data field to act upon a given binding of `CustomStringConvertible` data.
    /// This is a convenience initializer over
    /// `init(_:data:textToData:dataToText:editableText:invalidText)`.
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
        editableText: ((Data) -> String)? = nil,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.init(
            title,
            data: data,
            textToData: textToData,
            // The data-to-text function uses the `CustomStringConvertible` description.
            dataToText: { $0.description },
            editableText: editableText,
            invalidText: invalidText
        )
    }
}

// MARK: - Lossless String Convertible Data Field

extension DataField where Data: LosslessStringConvertible {
    
    /// Creates a data field to act upon a given binding of `LosslessStringConvertible` data.
    /// This is a convenience initializer over
    /// `init(_:data:textToData:dataToText:editableText:invalidText)`.
    ///
    /// - Parameters:
    ///
    ///   - title: The title of the text view, describing its purpose.
    ///
    ///   - data: The underlying data that should be set by the data field. When not editing, the
    ///           data field will reflect *any* values written to this binding.
    ///
    ///   - dataToText: A conversion function from a `Data` to a `String` value. This is directly
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
        dataToText: @escaping (Data) -> String,
        editableText: ((Data) -> String)? = nil,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.init(
            title,
            data: data,
            // The text-to-data function uses the `LosslessStringConvertible` initializer.
            textToData: { Data($0) },
            dataToText: dataToText,
            editableText: editableText,
            invalidText: invalidText
        )
    }
}

// MARK: - String Convertible Data Field

extension DataField where Data: CustomStringConvertible & LosslessStringConvertible {
    
    /// Creates a data field to act upon a given binding of bidirectionally string-convertible data.
    /// This is a convenience initializer over
    /// `init(_:data:textToData:dataToText:editableText:invalidText)`.
    ///
    /// - Parameters:
    ///
    ///   - title: The title of the text view, describing its purpose.
    ///
    ///   - data: The underlying data that should be set by the data field. When not editing, the
    ///           data field will reflect *any* values written to this binding.
    ///
    ///   - dataToText: A conversion function from a `Data` to a `String` value. This is directly
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
        editableText: ((Data) -> String)? = nil,
        invalidText: ((String?) -> Void)? = nil
    ) {
        self.init(
            title,
            data: data,
            // The text-to-data function uses the `LosslessStringConvertible` initializer.
            textToData: { Data($0) },
            // The data-to-text function uses the `CustomStringConvertible` description.
            dataToText: { $0.description },
            editableText: editableText,
            invalidText: invalidText
        )
    }
}

#endif /*canImport(SwiftUI)*/

