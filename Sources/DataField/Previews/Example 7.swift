//
//  Example 7.swift
//
//  Created by Marcus Rossel on 08.10.20.
//

#if DEBUG && canImport(SwiftUI)
import SwiftUI

enum CoinSide: String, CustomStringConvertible, LosslessStringConvertible {
    
    case heads
    case tails
    
    var description: String { rawValue }
    init?(_ string: String) { self.init(rawValue: string) }
}

struct Example_7: PreviewProvider {
    
    struct CoinView: View {

        @State var coinSide: CoinSide = .heads

        var body: some View {
            VStack {
                DataField("Coin Side", data: $coinSide)
            }
        }
    }
    
    static var previews: some View {
        CoinView()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
}

#endif /*DEBUG && canImport(SwiftUI)*/
