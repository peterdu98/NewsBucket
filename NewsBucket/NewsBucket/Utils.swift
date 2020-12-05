//
//  Utils.swift
//  NewsBucket
//
//  Created by Peter Du on 14/4/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import Foundation
import UIKit

struct Utils {
    static func htmlToString(_ htmlText: String) -> String {
        // First layer for tags
        var text = htmlText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        // Second layer for special character
        text = text.replacingOccurrences(of: "&[^;]+;", with: "", options: .regularExpression, range: nil)
        
        return text
    }
    
    static func reformatDate(from currentDate: String, with platform: String) -> String {
        let dateFormatterGet = DateFormatter()
        if platform == K.Platform.trad {
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        } else if platform == K.Platform.dev {
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        }
        
        let date = dateFormatterGet.date(from: currentDate)!
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yyyy"
        
        return dateFormatterPrint.string(from: date)
    }
    
    static func convertDate(valueOf currentDate: Any) -> Any? {
        var result: Any?
        let dateFormatterGet = DateFormatter()
        
        
        if let date = currentDate as? String {
            dateFormatterGet.dateFormat = "dd/MM/yyyy"
            let newDate = dateFormatterGet.date(from: date)
            result = Double(newDate!.timeIntervalSince1970)
        } else if let date = currentDate as? Double {
            let newDate = Date(timeIntervalSince1970: date)
            dateFormatterGet.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatterGet.locale = NSLocale.current
            dateFormatterGet.dateFormat = "dd/MM/yyyy"
            result = dateFormatterGet.string(from: newDate)
        }
        
        return result
    }
    
    static func layoutAlert(with message:String, handle action: UIAlertAction? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        let alertAction = action ?? UIAlertAction(title: "Go back", style: .default, handler: nil)
        alert.addAction(alertAction)
        return alert
    }
}
