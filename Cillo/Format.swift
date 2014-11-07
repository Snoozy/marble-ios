//
//  Format.swift
//  Cillo
//
//  Created by Andrew Daley on 11/7/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class Format: NSObject {
   
    ///Converts Int to formatted #.#k String
    class func convertToThousands(number: Int) -> String {
        var thousands : Double = Double(number / 1000)
        if thousands < 0 {
            thousands -= Double(number % 1000 / 100) * 0.1
        } else {
            thousands += Double(number % 1000 / 100) * 0.1
        }
        return "\(thousands)k"
    }
    
    ///Returns the Cillo Blue Color
    class func cilloBlue() -> UIColor {
        return UIColor(red: 0.0627, green: 0.396, blue: 0.768, alpha: 0.87)
    }
    
    ///Returns standard UITableView divider color
    class func defaultTableViewDividerColor() -> UIColor {
        return UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    }
    
}
