//
//  STCenterCellFlowLayout.swift
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

// Class adapted from: http://blog.karmadust.com/centered-paging-with-preview-cells-on-uicollectionview/

class STCenterCellFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else {
            return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
        }
        
        let bounds = collectionView.bounds
        
        guard let attributesForVisibleCells = self.layoutAttributesForElementsInRect(bounds) else {
            return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
        }
        
        let halfCollectionViewWidth = bounds.width / 2.0;
        let proposedContentOffsetCenterX = proposedContentOffset.x + halfCollectionViewWidth;
        
        var currentAttributes: UICollectionViewLayoutAttributes?
        
        for newAttributes in attributesForVisibleCells {
            
            // Skip comparison with non-cell items (headers and footers)
            if newAttributes.representedElementCategory != UICollectionElementCategory.Cell {
                continue
            }
            
            if let attributes = currentAttributes {
                
                let newOffset = newAttributes.center.x - proposedContentOffsetCenterX
                let currentOffset = attributes.center.x - proposedContentOffsetCenterX
                
                if abs(newOffset) < abs(currentOffset) {
                    currentAttributes = newAttributes;
                }
                
            } else {
                // this is the first loop
                currentAttributes = newAttributes;
                continue;
            }
        }
        
        let midX = round(currentAttributes!.center.x - halfCollectionViewWidth)
        
        return CGPoint(x: midX, y: proposedContentOffset.y)
    }
}
