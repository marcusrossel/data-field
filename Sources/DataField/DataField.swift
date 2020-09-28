//
//  DataField.swift
//
//  Created by Marcus Rossel on 25.09.20.
//

#if canImport(SwiftUI)

import SwiftUI

// MARK: - Data Field

public struct DataField<Data>: View {
    
    /// Data fields come in different styles, which unfortunately seem to require seperate
    /// implementations. This property captures the underlying view which will represent the data
    /// field (which is chosen during initialization). 
    private let view: AnyView
    
    public var body: some View {
        view
    }
    
    public init?(
        _ title: String,
        data: Binding<Data>,
        textToData: @escaping (String) -> Data?,
        dataToText: @escaping (Data) -> String,
        invalidText: ((String?) -> Void)? = nil
    ) {
        let view = Unsafe(
            title,
            data: data,
            textToData: textToData,
            dataToText: dataToText,
            invalidText: invalidText
        )
        
        if let view = view {
            self.view = AnyView(view)
        } else {
            return nil
        }
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

/*extension DataField where Data == String? {
    
    public typealias Safe = String
    
    public init(
        _ title: String,
        initialData: Safe? = nil,
        constraint: @escaping (Safe) -> Bool,
        dataToText: @escaping (Safe?) -> String,
        sink: @escaping (Safe) -> Void,
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
}*/

#endif /*canImport(SwiftUI)*/
