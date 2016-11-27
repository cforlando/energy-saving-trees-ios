//
//  UIImageViewExtension.swift
//  Street Trees
//
//  Created by Tom Marks on 27/11/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit

public extension UIImageView {
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        
        set {
            self.layer.cornerRadius = newValue
        }
    }
}