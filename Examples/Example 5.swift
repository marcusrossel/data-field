//
//  Example 5.swift
//
//  Created by Marcus Rossel on 28.09.20.
//

#if DEBUG && canImport(DataField)
import DataField
import SwiftUI

struct Example_5: PreviewProvider {
    
    struct NameView: View {

        @State var name = "marcus"

        var body: some View {
            VStack {
                DataField("Hour", data: $name) { text in
                    !text.isEmpty
                }
            }
        }
    }
    
    static var previews: some View {
        NameView()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
}

#endif /*DEBUG && canImport(DataField)*/
