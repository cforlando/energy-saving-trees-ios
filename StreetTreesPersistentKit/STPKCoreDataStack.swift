//
//  STPKCoreDataStack.swift
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
