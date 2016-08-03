//
//  HeightCalculatable.swift
//  Cillo
//
//  Created by Andrew Daley on 8/2/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

/// Objects conforming to this protocol have large pieces of text tied to them 
/// that need to have their height calculated for display.
protocol HeightCalculatable {
    
    /// A long string that's height can be calculated
    var textToCalculate: String { get }
}
