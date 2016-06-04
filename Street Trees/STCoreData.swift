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
    
    public func insertNewTrees(jsonData: [[String: AnyObject]]) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else { return }
        
        context.performBlockAndWait { 
            for treeData in jsonData {
                let newTree = STPKTree.insertTree(context: context)
                //TODO: set data
            }
            
            do {
                try context.saveContextAndWait()
            } catch {
                
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
