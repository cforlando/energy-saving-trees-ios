//: Playground - noun: a place where people can play

import UIKit

let viewA = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
viewA.backgroundColor = UIColor.grayColor()

let viewB = UIView(frame: CGRect(x: 0, y: 280, width: 320, height: 200))
viewB.backgroundColor = UIColor.blackColor()

let viewC = UIView(frame: CGRect(x: 20, y: 20, width: 200, height: 44))
viewC.backgroundColor = UIColor.redColor()

let viewD = UIView(frame: CGRect(x: 0, y: 240, width: 320, height: 100))
viewD.backgroundColor = UIColor(white: 0.6, alpha: 0.6)

viewA.addSubview(viewB)
viewA.addSubview(viewD)
viewD.addSubview(viewC)

viewA

let rect = viewA.convertRect(viewC.frame, fromView: viewC.superview)

let intersect = CGRectIntersectsRect(viewB.frame, rect)


func intersectAmount(betweenView aView: UIView, andFrame aFrame: CGRect) -> CGPoint {
    let viewFrame = viewA.convertRect(aView.frame, fromView: aView.superview)
    
    let xDifference = abs(viewFrame.minX - aFrame.minX)
    let yDifference = abs(viewFrame.maxY - aFrame.minY)
    
    return CGPoint(x: xDifference, y: yDifference)
}

let diff = intersectAmount(betweenView: viewC, andFrame: viewB.frame)










