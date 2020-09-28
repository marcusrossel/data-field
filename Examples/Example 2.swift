//
//  Example 2.swift
//
//  Created by Marcus Rossel on 28.09.20.
//

#if DEBUG && canImport(DataField)
import DataField
import SwiftUI

struct Example_2: PreviewProvider {
    
    struct HourView: View {

        @State var hour = 10

        var body: some View {
            DataField("Hour", data: $hour) { text in
                guard let validHour = Int(text), (0..<24).contains(validHour) else { return nil }
                return validHour
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

#endif /*DEBUG && canImport(DataField)*/
