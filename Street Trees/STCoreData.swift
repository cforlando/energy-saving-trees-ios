//
//  STCoreData.swift
//  Street Trees
//
//  Created by Tom Marks on 4/06/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import Foundation
import BNRCoreDataStack
import StreetTreesPersistentKit
import StreetTreesTransportKit

private let STPKPersistentStoreFileName = "streettrees.sqlite"

public class STCoreData: NSObject {
    
    private(set) var coreDataStack: STPKCoreDataStack?
    
    static let sharedInstance = STCoreData()
    
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
    
    public func insertNewTrees(treesData: [STTKStreetTree], completion: STPKCoreDataStackCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else { return }
        let currentTrees = self.fetchTrees()
        
        context.performBlockAndWait { 
            
            for treeData in treesData {
                let containsTree = currentTrees.contains { (tree: STPKTree) -> Bool in
                    tree.order == treeData.order
                }
                
                if !containsTree {
                    let newTree = STPKTree.insertTree(context: context)
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
            
            do {
                try context.saveContextAndWait()
                completion(anError: nil)
            } catch {
                completion(anError: NSError(domain: "com.codefororlando.streettrees.inserttrees", code: -1, userInfo: nil))
            }
            
        }
    }
    
    public func fetchTrees() -> [STPKTree] {
        guard let context = self.coreDataStack?.mainQueueContext() else { return [] }
        let trees: [STPKTree]
        
        do {
            trees = try STPKTree.fetchTrees(context)
        } catch {
            trees = []
        }
        
        return trees
    }
    
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    private func defaultPersistentStorePath() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    }

}
