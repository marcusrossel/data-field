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
    
    /// Creates a data field from an unsafe data field.
    /// This initializer is intended for internal use only.
    internal init(unsafe: DataField.Unsafe<Data>) {
        self.view = AnyView(unsafe)
    }
    
    /// Creates a data field from an safe data field.
    /// This initializer is intended for internal use only.
    internal init(safe: DataField.Safe<Data>) {
        self.view = AnyView(safe)
    }
}

#endif /*canImport(SwiftUI)*/
