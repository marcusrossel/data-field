//
//  Example 3.swift
//
//  Created by Marcus Rossel on 28.09.20.
//

#if DEBUG && canImport(DataField)
import DataField
import SwiftUI

struct Example_3: PreviewProvider {
    
    struct HourView: View {

        @State var hour = 10
        @State var textIsInvalid = false

        var body: some View {
            VStack {
                DataField("Hour", data: $hour) { text in
                    guard let validHour = Int(text), (0..<24).contains(validHour) else { return nil }
                    return validHour
                } dataToText: { data in
                    "\(data)"
                } invalidText: { text in
                    textIsInvalid = (text != nil)
                }

                if textIsInvalid {
                    Text("Please enter a number between 0 and 23!")
                }
            }
        }
    }
    
    static var previews: some View {
        HourView()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
}

#endif /*DEBUG && canImport(DataField)*/
