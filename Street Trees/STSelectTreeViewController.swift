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

protocol STSelectTreeViewControllerDelegate: NSObjectProtocol {
    func selectTreeViewController(selectTreeViewController: STSelectTreeViewController, didSelectTreeDescription aTreeDescription: STPKTreeDescription)
}

class STSelectTreeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var treeDescription: UILabel!
    
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
        self.treeDescription.text = self.datasource.first?.treeDescription
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
        
        self.treeDescription.text = self.datasource[itemIndex].treeDescription
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
}
