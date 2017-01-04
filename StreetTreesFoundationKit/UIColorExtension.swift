//
//  UIColorExtension.swift
//  Street Trees
//
//  Copyright © 2016 Code for Orlando.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

public extension UIColor {
    public class func orlandoBlueColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: 31.colorValue(), green: 41.colorValue(), blue: 63.colorValue(), alpha: alpha)
    }
    
    public class func orlandoGrayColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: 88.colorValue(), green: 89.colorValue(), blue: 91.colorValue(), alpha: alpha)
    }
    
    public class func orlandoGreenColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: 135.colorValue(), green: 186.colorValue(), blue: 101.colorValue(), alpha: alpha)
    }
    
    public class func codeForOrlandoOrange(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: 237.colorValue(), green: 131.colorValue(), blue: 35.colorValue(), alpha: alpha)
    }
    
}

extension Int {
    func colorValue() -> CGFloat {
        return CGFloat(self) / 255.0
    }
}
