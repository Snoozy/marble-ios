//
//  Identifiable.swift
//  Cillo
//
//  Created by Andrew Daley on 8/2/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

/// Objects conforming to this protocol have unique identifiers on the Cillo servers
protocol Identifiable {
    
    /// Unique identifier on Cillo Servers
    var id: Int { get set }
}

extension Identifiable {
    
    /// Tells if the id is valid (>= 0)
    var hasValidId: Bool {
        return id >= 0
    }
}
