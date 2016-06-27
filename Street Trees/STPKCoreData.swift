//
//  STCoreData.swift
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

import Foundation
import BNRCoreDataStack
import StreetTreesTransportKit

public typealias STPKCoreDataCompletionBlock = (anError: NSError?) -> Void

private let STPKPersistentStoreFileName = "streettrees.sqlite"

public class STPKCoreData: NSObject {
    
    private(set) var coreDataStack: STPKCoreDataStack?
    
    public static let sharedInstance = STPKCoreData()
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public func fetch(decriptionForName aName: String) -> STPKTreeDescription? {
        guard let context = self.coreDataStack?.mainQueueContext() else { return nil }
        var description: STPKTreeDescription?
        
        do {
            description = try STPKTreeDescription.fetch(descriptionForName: aName, context: context)
        } catch {
            description = nil
        }
        
        return description
    }
    
    public func fetch(treeForOrderNumber anOrderNumber: Int) -> STPKTree? {
        guard let context = self.coreDataStack?.mainQueueContext() else { return nil }
        
        var tree: STPKTree?
        
        do {
            tree = try STPKTree.fetch(byOrderNumber: anOrderNumber, inContext: context)
        } catch {
            tree = nil
        }
        
        return tree
    }
    
    public func fetchTreeDescriptions() -> [STPKTreeDescription] {
        guard let context = self.coreDataStack?.mainQueueContext() else { return [] }
        let treeDescriptions: [STPKTreeDescription]
        
        do {
            treeDescriptions = try STPKTreeDescription.fetch(context) as? [STPKTreeDescription] ?? []
        } catch {
            treeDescriptions = []
        }
        
        return treeDescriptions
    }
    
    public func fetchTrees() -> [STPKTree] {
        guard let context = self.coreDataStack?.mainQueueContext() else { return [] }
        let trees: [STPKTree]
        
        do {
            trees = try STPKTree.fetch(context) as? [STPKTree] ?? []
        } catch {
            trees = []
        }
        
        return trees
    }
    
    public func insert(descriptionData: [STTKTreeDescription], completion:STPKCoreDataStackCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else { return }
        let currentTreeDescriptions = self.fetchTreeDescriptions()
        
        context.performBlockAndWait {
            for descriptionItem in descriptionData {
                let containsDescription = currentTreeDescriptions.contains { (description: STPKTreeDescription) -> Bool in
                    description.name == descriptionItem.name
                }
                
                if !containsDescription {
                    let newDescription = STPKTreeDescription.insert(context: context)
                    newDescription.additional = descriptionItem.additional
                    newDescription.treeDescription = descriptionItem.description
                    newDescription.fullSun = descriptionItem.fullSun
                    newDescription.leaf = descriptionItem.leaf
                    newDescription.maxHeight = descriptionItem.maxHeight
                    newDescription.maxWidth = descriptionItem.maxWidth
                    newDescription.minHeight = descriptionItem.minHeight
                    newDescription.minWidth = descriptionItem.minWidth
                    newDescription.moisture = descriptionItem.moisture
                    newDescription.name = descriptionItem.name
                    newDescription.partialShade = descriptionItem.partialShade
                    newDescription.partialSun = descriptionItem.partialSun
                    newDescription.shape  = descriptionItem.shape
                    newDescription.soil = descriptionItem.soil
                    
                }
            }
            
            self.save(context, completion: completion)
        }
    }
    
    public func insert(treesData: [STTKStreetTree], completion: STPKCoreDataStackCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else { return }
        let currentTrees = self.fetchTrees()
        
        context.performBlockAndWait { 
            
            for treeData in treesData {
                let containsTree = currentTrees.contains { (tree: STPKTree) -> Bool in
                    tree.order == treeData.order
                }
                
                if !containsTree {
                    let newTree = STPKTree.insert(context: context)
                    newTree.order = treeData.order
                    newTree.carbon = treeData.carbon
                    newTree.air = treeData.air
                    newTree.kiloWattHours = treeData.kWh
                    newTree.savings = NSDecimalNumber(double: treeData.savings)
                    newTree.stormWater = treeData.stormwater
                    newTree.therms = treeData.therms
                    newTree.speciesName = treeData.name
                    newTree.longitude = treeData.long
                    newTree.latitude = treeData.lat
                }
            }
            
            self.save(context, completion: completion)
        }
    }
    
    public func refreshAll(completion: STPKCoreDataCompletionBlock) {
        STTKDownloadManager.fetchAllTrees { (trees: [STTKStreetTree]) in
            // Download all descriptions
            
            self.insert(trees, completion: { (anError) in
                // Insert all descriptions
                // join descriptions and trees
                
                completion(anError: anError)
            })
        }
    }
    
    /**
     This function must be run a the beginning of the applications life.
     */
    public func setupCoreData(aSuccessBlock: STPKCoreDataStackSetupSuccessBlock, aFailureBlock: STPKCoreDataStackSetupFailureBlock) {
        let storePath = self.defaultPersistentStorePath()
        
        let url = NSURL(fileURLWithPath: storePath).URLByAppendingPathComponent(STPKPersistentStoreFileName)
        
        let successBlock: STPKCoreDataStackSetupSuccessBlock = { (aCoreDataStack) -> Void in
            self.coreDataStack = aCoreDataStack
            aSuccessBlock(coreDataStack: aCoreDataStack)
        }
        
        let failureBlock: STPKCoreDataStackSetupFailureBlock = { (anError) -> Void in
            aFailureBlock(error: anError)
        }
        
        STPKCoreDataStack.constructStack(url: url, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    private func defaultPersistentStorePath() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    }
    
    private func save(context: NSManagedObjectContext, completion:STPKCoreDataStackCompletionBlock) {
        do {
            try context.saveContextAndWait()
            completion(anError: nil)
        } catch {
            completion(anError: NSError(domain: "com.codefororlando.streettrees.inserttrees", code: -1, userInfo: nil))
        }
        
    }

}
