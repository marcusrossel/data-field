//
//  Example 1.swift
//
//  Created by Marcus Rossel on 28.09.20.
//

#if DEBUG && canImport(SwiftUI)
import SwiftUI

struct Example_1: PreviewProvider {
    
    struct HourView: View {
        
        @State var hour = 10

        var body: some View {
            DataField("Hour", data: $hour) { text in
                Int(text)
            } dataToText: { data in
                "\(data)"
            }
        }
    }
    
    static var previews: some View {
        HourView()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
}

#endif /*DEBUG && canImport(SwiftUI)*/
