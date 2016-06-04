//
//  STPKCoreDataStack.swift
//  Street Trees
//
//  Created by Tom Marks on 4/06/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit
import CoreData
import BNRCoreDataStack

//**********************************************************************************************************************
// MARK: - Type Aliases

public typealias STPKCoreDataStackCompletionBlock = (anError: NSError?) -> Void

public typealias STPKCoreDataStackResetFailureBlock = (error: NSError) -> Void
public typealias STPKCoreDataStackResetSuccessBlock = () -> Void

public typealias STPKCoreDataStackSetupFailureBlock = (error: NSError) -> Void
public typealias STPKCoreDataStackSetupSuccessBlock = (coreDataStack: STPKCoreDataStack) -> Void

//**********************************************************************************************************************
// MARK: - Class Implementation

public class STPKCoreDataStack: NSObject {
    
    private let coreDataStack: CoreDataStack
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public init(coreDataStack aCoreDataStack: CoreDataStack) {
        self.coreDataStack = aCoreDataStack
        super.init()
    }
    
    public class func constructStack(url aURL: NSURL,
                                         successBlock aSuccessBlock: STPKCoreDataStackSetupSuccessBlock,
                                                      failureBlock aFailureBlock: STPKCoreDataStackSetupFailureBlock) {
        let modelName = "STPKModel"
        let bundle = NSBundle.init(forClass: self)
        
        let callback: CoreDataStackSetupCallback = {(aResult: CoreDataStack.SetupResult) in
            switch aResult {
            case .Success(let aStack):
                let upkStack = STPKCoreDataStack(coreDataStack: aStack)
                aSuccessBlock(coreDataStack: upkStack)
            case .Failure(let anError as NSError):
                aFailureBlock(error: anError)
            default:
                print("Unhandled case")
            }
        }
        
        CoreDataStack.constructSQLiteStack(withModelName: modelName,
                                           inBundle: bundle,
                                           withStoreURL: aURL,
                                           callback: callback)
    }
    
    
    public func mainQueueContext() -> NSManagedObjectContext {
        return self.coreDataStack.mainQueueContext
    }
    
    
    public func newBackgroundWorkerMOC() -> NSManagedObjectContext {
        return self.coreDataStack.newChildContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, name: "com.streettrees.context")
    }
    
    
    public func resetStore(successBlock aSuccessBlock: STPKCoreDataStackResetSuccessBlock,
                                        failureBlock aFailureBlock: STPKCoreDataStackResetFailureBlock) {
        
        let callback: CoreDataStackStoreResetCallback = {(aResult: CoreDataStack.ResetResult) in
            switch aResult {
            case .Success():
                aSuccessBlock()
            case .Failure(let anError as NSError):
                aFailureBlock(error: anError)
            default:
                print("Unhandled case")
            }
        }
        
        self.coreDataStack.resetStore(resetCallback: callback)
    }
}
