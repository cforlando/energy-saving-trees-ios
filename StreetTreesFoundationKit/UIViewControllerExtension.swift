//
//  UIViewControllerExtension.swift
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

public extension UIViewController {
    
    public func add(motionToView aView: UIView, movement travelDistance: CGFloat) {
        // Set vertical effect
        let vMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                        type: .TiltAlongVerticalAxis)
        vMotionEffect.minimumRelativeValue = -travelDistance
        vMotionEffect.maximumRelativeValue = travelDistance
        
        // Set horizontal effect
        let hMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                        type: .TiltAlongHorizontalAxis)
        hMotionEffect.minimumRelativeValue = -travelDistance
        hMotionEffect.maximumRelativeValue = travelDistance
        
        // Create group to combine both
        let motionGroup = UIMotionEffectGroup()
        motionGroup.motionEffects = [hMotionEffect, vMotionEffect]
        
        aView.addMotionEffect(motionGroup)
    }
    
    public func intersectAmount(betweenView aView: UIView, andRect aRect: CGRect) -> CGPoint {
        
        if !self.view(intersects: aView, rect: aRect) {
            return CGPoint.zero
        }
        
        let viewFrame = self.view.convertRect(aView.frame, fromView: aView.superview)
        
        let xDifference = abs(viewFrame.minX - aRect.minX)
        let yDifference = abs(viewFrame.maxY - aRect.minY)
        
        return CGPoint(x: xDifference, y: yDifference)
    }
    
    public func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertViewController.addAction(cancelAction)
        self.presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    public func view(intersects aView: UIView, rect aRect: CGRect) -> Bool {
        let viewRect = self.view.convertRect(aView.frame, fromView: aView.superview)
        return CGRectIntersectsRect(aRect, viewRect)
    }
}
