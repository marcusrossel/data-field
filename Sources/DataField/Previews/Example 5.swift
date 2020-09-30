//
//  Example 5.swift
//
//  Created by Marcus Rossel on 28.09.20.
//

#if DEBUG && canImport(SwiftUI)
import SwiftUI

struct Example_5: PreviewProvider {
    
    struct HourView: View {

        @Binding var hour: Int

        var body: some View {
            DataField("Hour", initialData: hour) { text in
                guard let validHour = Int(text), (0..<24).contains(validHour) else { return nil }
                return validHour
            } dataToText: { data in
                if let data = data { return "\(data)" } else { return "" }
            } sink: { validData in
                hour = validData
            }
        }
    }

    struct TimeView: View {
        
        @State private var hour = 10
        
        var body: some View {
            HourView(hour: $hour)
        }
    }
    
    static var previews: some View {
        TimeView()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
}

#endif /*DEBUG && canImport(SwiftUI)*/
