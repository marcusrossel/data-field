//
//  DataField.Unsafe.swift
//  
//
//  Created by Marcus Rossel on 28.09.20.
//

#if canImport(SwiftUI)

import SwiftUI

extension DataField {
    
    struct Unsafe<Data>: View {
        
        /// The title of the text view, describing its purpose.
        private let title: String
        
        /// A handle on the binding to external data.
        ///
        /// This handle is really only required to assure that the view gets updated when this binding
        /// gets set. The `source` and `sink` functions capture their own reference to the binding,
        /// because if they captured *this one*, they would have to capture `self`.
        ///
        /// If an initializer was used, that does not require this binding to be passed in, it is set to
        /// an artificial binding that returns meaningless values.
        /// Settings this property as `Binding<Data>?` is unfortunately not an option, because then the
        /// view updates don't trigger.
        @Binding private var external: Data
        
        /// A container for the last valid data value that was entered into the text field.
        ///
        /// This is not used when an initializer was used where an `external` binding was passed. Hence
        /// this property is optional an always `nil` in that case.
        ///
        /// Settings this property as `State<Data>?` is unfortunately not an option, because then the
        /// view updates don't trigger when this property is set. And they have to be triggered,
        /// otherwise setting this value at the end of an "editing session" won't be reflected in the
        /// text shown by the text field.
        @State private var latest: Data?
        
        /// A cache for the result of `textToData(buffer)`. This value is computed on every change of
        /// the text field's text, but would also be recomputed when it ends editing. To avoid that last
        /// computation the result is cached in this property.
        ///
        /// Whether this is worth it can be questioned, since it only saves a single computation of
        /// `textToData` per "editing session".
        @State private var cache: Data?
        
        private let source: () -> Data
        
        private let sink: (Data) -> Void
        
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
                get: { isEditing ? buffer : dataToText(source()) },
                set: {
                    buffer = $0
                    
                    cache = textToData(buffer)
                    
                    invalidText?(cache == nil ? buffer : nil)
                }
            )
        }
        
        /// A data field is made up of just a single text field.
        var body: TextField<Text> {
            TextField(title, text: text) { isEditing in
                self.isEditing = isEditing
                
                if isEditing {
                    buffer = dataToText(source())
                } else {
                    
                    if let data = cache {
                        sink(data)
                    }
                    invalidText?(nil)
                }
            }
        }
        
        init?(
            _ title: String,
            data: Binding<Data>,
            textToData: @escaping (String) -> Data?,
            dataToText: @escaping (Data) -> String,
            invalidText: ((String?) -> Void)? = nil
        ) {
            self.title = title
            self._external = data
            self.textToData = textToData
            self.dataToText = dataToText
            self.invalidText = invalidText
            
            source = { data.wrappedValue }
            sink = { data.wrappedValue = $0 }
            
            _buffer = State(initialValue: dataToText(data.wrappedValue))
            
            guard textToData(buffer) != nil else { return nil }
        }
        
        init<Safe>(
            _ title: String,
            initialData: Safe? = nil,
            textToData: @escaping (String) -> Safe?,
            dataToText: @escaping (Safe?) -> String,
            sink: @escaping (Safe) -> Void,
            invalidText: ((String?) -> Void)? = nil
        ) where Data == Safe? {
            self.title = title
            self.textToData = textToData
            self.dataToText = dataToText
            self.invalidText = invalidText
            
            let latest = State(initialValue: initialData as Data?)
            self._latest = latest
            
            // The only place `latest` is set is in the line above and in the `sink` function below. The
            // value is obivously set above and is only ever set to a non-nil value in `sink`. So it is
            // safe to force-unwrap it.
            // Note, there are two levels of optionality going on here. Since `Data == Safe?`, the type
            // of `latest` is `Safe??`. It would only be problematic if the "outer optional" were `nil`,
            // which the statements above show it can never be.
            source = {
                latest.wrappedValue!
            }
            
            // Aside from passing the data on to the user-defined `sink`, `self.sink` also makes sure
            // the value is captured in `latest`.
            // Since the sink only ever receives valid data values, it is safe to unwrap
            self.sink = { data in
                latest.wrappedValue = data
                sink(data!)
            }
            
            _buffer = State(initialValue: dataToText(textToData(dataToText(initialData))))
            
            // The implementation of `DataField` itself doesn't make any accesses to the external
            // binding. The only places they occur are when the view recalculates `body` and therefore
            // accesses all state-properties. In this case the value of this binding isn't actually used
            // though, so it is sufficient to return `nil`. The setter of this binding is never called.
            _external = Binding<Data>(
                get: {
                    nil
                },
                set: { _ in
                    
                }
            )
        }
    }
}

#endif /*canImport(SwiftUI)*/
