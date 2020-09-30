//
//  Example 6.swift
//
//  Created by Marcus Rossel on 28.09.20.
//

#if DEBUG && canImport(SwiftUI)
import SwiftUI

struct Example_6: PreviewProvider {
    
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

#endif /*DEBUG && canImport(SwiftUI)*/
