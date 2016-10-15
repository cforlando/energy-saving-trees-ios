//
//  STSelectTreeViewController.swift
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

import StreetTreesPersistentKit
import UIKit

private let STBorderCornerRadius: CGFloat = 4.0
private let STSelectedBorderWidth: CGFloat = 3.0
private let STUnselectedBorderWidth: CGFloat = 0.0
private let STDecimalPlaces: Double = 0.01

func average(numbers:Double...) -> Double {
    let initialValue: Double = 0
    let total = numbers.reduce(initialValue, combine:{ $0 + $1 })
    return total / Double(numbers.count)
}

func round(number:Double, toNearest nearest: Double) -> Double {
    return round(number / nearest) * nearest
}


protocol STSelectTreeViewControllerDelegate: NSObjectProtocol {
    func selectTreeViewController(selectTreeViewController: STSelectTreeViewController, didSelectTreeDescription aTreeDescription: STPKTreeDescription)
}

class STSelectTreeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var leaf: UILabel!
    @IBOutlet weak var shape: UILabel!
    @IBOutlet weak var width: UILabel!
    
    lazy var datasource: [STPKTreeDescription] = {
        return STPKTreeDescription.rightOfWayTrees().sort {$0.name < $1.name}
    }()
    
    weak var delegate: STSelectTreeViewControllerDelegate?
    
    var selectedTree: STPKTreeDescription?
    
    //******************************************************************************************************************
    // MARK: - Class Overrides
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        var insets = self.collectionView.contentInset
        let value = (self.view.frame.width - layout.itemSize.width) / 2.0
        insets.left = value
        insets.right = value
        
        self.collectionView.contentInset = insets
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let treeDescription = self.datasource.first {
            self.updateLabels(withTreeDescription: treeDescription)
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Actions
    
    @IBAction func nextButton(sender: UIButton) {
        
        guard let treeDescription = self.selectedTree else {
            self.showAlert("No Tree Selected", message: "Please tap on a tree before moving on.")
            return
        }
        
        self.delegate?.selectTreeViewController(self, didSelectTreeDescription: treeDescription)
    }
    
    //******************************************************************************************************************
    // MARK: - CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("treeCell", forIndexPath: indexPath) as? STTreeCollectionViewCell {
            
            let treeDescription = self.datasource[indexPath.row]
            cell.imageView.image = treeDescription.image()
            cell.nameLabel.text = treeDescription.name
            cell.layer.borderColor = UIColor.orlandoGreenColor().CGColor
            cell.layer.cornerRadius = STBorderCornerRadius
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if selectedTree == self.datasource[indexPath.row] {
            cell.layer.borderWidth = STSelectedBorderWidth
        } else {
            cell.layer.borderWidth = STUnselectedBorderWidth
        }
    }
    
    //******************************************************************************************************************
    // MARK: - CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.resetAllCells()
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        let selectedTree = self.datasource[indexPath.row]
        if self.selectedTree == selectedTree {
            cell?.layer.borderWidth = STUnselectedBorderWidth
            self.selectedTree = nil
        } else {
            cell?.layer.borderWidth = STSelectedBorderWidth
            self.selectedTree = selectedTree
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Scroll View Delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {

        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems()
        let itemIndex: Int
        
        if visibleIndexPaths.count == 2 {
            let lesserIndex = self.lesserIndex(visibleIndexPaths)
            
            if lesserIndex != 0 {
                itemIndex = self.greaterIndex(visibleIndexPaths)
            } else {
                itemIndex = lesserIndex
            }
            
        } else {
            itemIndex = self.mediumIndex(visibleIndexPaths)
        }
        
        self.updateLabels(withTreeDescription: self.datasource[itemIndex])
    }

    //******************************************************************************************************************
    // MARK: - Private Functions
    
    func greaterIndex(indexes: [NSIndexPath]) -> Int {
        
        let firstIndex = indexes.first?.item ?? 0
        
        return indexes.reduce(firstIndex, combine: { (result, indexPath) -> Int in
            if indexPath.item >= result {
                return indexPath.item
            } else {
                return result
            }
        })
    }
    
    func lesserIndex(indexes: [NSIndexPath]) -> Int {
        let firstIndex = indexes.first?.item ?? 0
        
        return indexes.reduce(firstIndex, combine: { (result, indexPath) -> Int in
            if indexPath.item <= result {
                return indexPath.item
            } else {
                return result
            }
        })
    }
    
    func localizedHeight(withTreeDescription treeDescription: STPKTreeDescription) -> String {
        guard let minimum = treeDescription.minHeight?.doubleValue else {
            return "Error"
        }
        guard let maximum = treeDescription.maxHeight?.doubleValue else {
            return "Error"
        }
        
        let avg = round(average(minimum, maximum), toNearest: STDecimalPlaces)
        return self.localizedLength(avg)
    }
    
    func localizedLength(average: Double) -> String {
        let formatter = NSLengthFormatter()
        formatter.forPersonHeightUse = true
        formatter.unitStyle = .Medium
        
        let unitType: NSLengthFormatterUnit
        let locale = NSLocale.autoupdatingCurrentLocale()
        let isMetric = locale.objectForKey(NSLocaleUsesMetricSystem) as? Bool
        if isMetric == true {
            unitType = .Meter
        } else {
            unitType = .Foot
        }
        
        return formatter.stringFromValue(average, unit: unitType)
    }
    
    func localizedWidth(withTreeDescription treeDescription: STPKTreeDescription) -> String {
        guard let minimum = treeDescription.minWidth?.doubleValue else {
            return "Error"
        }
        guard let maximum = treeDescription.maxWidth?.doubleValue else {
            return "Error"
        }
        
        let avg = round(average(minimum, maximum), toNearest: STDecimalPlaces)
        return self.localizedLength(avg)
    }
    
    func mediumIndex(indexes: [NSIndexPath]) -> Int {
        
        let total = indexes.reduce(0) { (result: Int, indexPath: NSIndexPath) -> Int in
            result + indexPath.row
        }
        
        return total / indexes.count
    }
    
    func resetAllCells() {
        for index in 0..<self.datasource.count {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) {
                cell.layer.borderWidth = STUnselectedBorderWidth
            }
        }
    }
    
    func updateLabels(withTreeDescription treeDescription: STPKTreeDescription) {
        self.height.text = self.localizedHeight(withTreeDescription: treeDescription)
        self.width.text = self.localizedWidth(withTreeDescription: treeDescription)
        self.leaf.text = treeDescription.leaf
        self.shape.text = treeDescription.shape
        self.view.setNeedsLayout()
    }
}
