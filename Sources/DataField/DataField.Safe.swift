//
//  DataField.Safe.swift
//  
//  Created by Marcus Rossel on 28.09.20.
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - Safe Data Field

extension DataField {
    
    /// A `DataField.Safe` is one of the views that can represent a `DataField`.
    /// Its "safety" is given by the fact that it does not operate upon a binding to the data, but
    /// rather passes all of its valid data into a `sink` closure. It can therefore be assured that
    /// the only data ever shown by the data field are valid data values (if no initial value is
    /// given `nil` may also be shown).
    struct Safe<Data>: View {
        
        /// The title of the text view, describing its purpose.
        private let title: String
        
        /// A container for the last valid data value entered into the text field, if present.
        @State private var latest: Data?
        
        /// A sink for any valid data values that are committed by ending an "editing session".
        private let sink: (Data) -> Void
        
        /// A cache for the result of `textToData(buffer)`. This value is computed on every change
        /// of the text field's text, but would also be recomputed when it ends editing. To avoid
        /// that last computation the result is cached in this property.
        ///
        /// Whether this is worth it can be questioned, since it only saves a single computation of
        /// `textToData` per "editing session".
        @State private var cache: Data?
        
        /// A function that can turn strings intro values of the underlying data, if possible.
        /// If this is not possible, `nil` should be returned.
        private let textToData: (String) -> Data?
        
        /// A function that can turn values of the underlying data, or the absence thereof, into
        /// string representations.
        private let dataToText: (Data?) -> String
        
        /// An optional hook into the text field, to observe any buffer values that are not
        /// decodable into a `Data` value.
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
        /// * get: chooses whether the buffer or latest data should be shown by the text field
        /// * set: observes changes to the buffer, caches the data-analog and updates the
        ///        `invalidText` accordingly
        private var text: Binding<String> {
            Binding(
                get: { isEditing ? buffer : dataToText(latest) },
                set: {
                    buffer = $0
                    cache = textToData(buffer)
                    invalidText?(cache == nil ? buffer : nil)
                }
            )
        }
     
        /// A data field is made up of just a single text field.
        var body: some View {
            TextField(title, text: text) { isEditing in
                self.isEditing = isEditing
                
                // When editing starts, the buffer has to be updated to represent the latest data
                // and the invalid text has to be updated accordingly.
                // When editing editing ends, the latest data has to be set if there is any, and the
                // invalid text has to be declared gone (because there can be none while not
                // editing).
                if isEditing {
                    buffer = dataToText(latest)
                    invalidText?(textToData(buffer) == nil ? buffer : nil)
                } else {
                    if let data = cache { latest = data }
                    invalidText?(nil)
                }
            }
        }
        
        /// Creates a safe data field.
        ///
        /// - Parameters:
        /// * `title`: The title of the text view, describing its purpose.
        /// * `initialData`: An initial data value to be shown when the data field has not yet had
        ///                  other valid data committed to it. If the given value does not meet the
        ///                  requirements given by `textToData`, it will be treated as a `nil`
        ///                  value. Since this value is optional, you also have to handle `nil` in
        ///                  `dataToText`.
        /// * `textToData`: A conversion function from a `String` to a `Data` value. If there is no
        ///                 sensible conversion, return `nil` to indicate that the text is not valid
        ///                 data.
        /// * `dataToText`: A conversion function from a `Data?` to a `String` value. This is
        ///                 directly responsible for the representation of the data values in the
        ///                 data field.
        /// * `sink`: A sink for any valid data values that are committed to the data field.
        /// * `invalidText`: A hook into the data field, to observe any text values that do not
        ///                  correspond to valid data. When the data field stops editing, a `nil` value
        ///                  is always passed.
        init(
            _ title: String,
            initialData: Data? = nil,
            textToData: @escaping (String) -> Data?,
            dataToText: @escaping (Data?) -> String,
            sink: @escaping (Data) -> Void,
            invalidText: ((String?) -> Void)?
        ) {
            self.title = title
            self.textToData = textToData
            self.dataToText = dataToText
            self.sink = sink
            self.invalidText = invalidText
            
            _latest = State(initialValue: initialData)
            _buffer = State(initialValue: dataToText(textToData(dataToText(initialData))))
        }
    }
}

#endif /*canImport(SwiftUI)*/
