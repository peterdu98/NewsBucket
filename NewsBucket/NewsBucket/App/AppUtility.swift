//
//  AppUtility.swift
//  NewsBucket
//
//  Created by Peter Du on 12/5/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit

struct AppUtility {    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
}
