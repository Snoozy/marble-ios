//
//  IntExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

extension Int {
    
    // MARK: - Properties
    
    /// Used to display large numbers in a compact 1-5 character String.
    ///
    /// String is formatted in one of following formats:
    ///
    /// * 100 - any number less than 1000.
    /// * 1.3k - any number in the order of thousands.
    /// * 2.6m - any number in the order of millions.
    /// * 6.8b - any number in the order of billions.
    var fiveCharacterDisplay: String {
        switch self {
        case -999...999:
            return "\(self)"
        case 1_000...9_999:
            var thousands = Double(self / 1_000)
            thousands += Double(self % 1_000 / 100) * 0.1
            return "\(thousands)k"
        case -9_999...(-1_000):
            var thousands = Double(self / 1_000)
            thousands -= Double(self % 1_000 / 100) * 0.1
            return "\(thousands)k"
        case 10_000...999_999, -999_999...(-10_000):
            return "\(self / 1_000)k"
        case 1_000_000...9_999_999:
            var millions = Double(self / 1_000_000)
            millions += Double(self % 1_000_000 / 100_000) * 0.1
            return "\(millions)m"
        case -9_999_999...(-1_000_000):
            var millions = Double(self / 1_000_000)
            millions -= Double(self % 1_000_000 / 100_000) * 0.1
            return "\(millions)m"
        case 10_000_000...999_999_999, -999_999_999...(-10_000_000):
            return "\(self / 1_000_000)m"
        case 1_000_000_000...Int.max:
            var billions = Double(self / 1_000_000_000)
            billions += Double(self % 1_000_000_000 / 100_000_000) * 0.1
            return "\(billions)b"
        case Int.min...(-1_000_000_000):
            var billions = Double(self / 1_000_000_000)
            billions -= Double(self % 1_000_000_000 / 100_000_000) * 0.1
            return "\(billions)b"
        default:
            return ""
        }
    }
}
