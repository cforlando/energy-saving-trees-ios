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

public typealias STPKCoreDataStackCompletionBlock = (_ anError: NSError?) -> Void

public typealias STPKCoreDataStackResetFailureBlock = (_ error: NSError) -> Void
public typealias STPKCoreDataStackResetSuccessBlock = () -> Void

public typealias STPKCoreDataStackSetupFailureBlock = (_ error: NSError) -> Void
public typealias STPKCoreDataStackSetupSuccessBlock = (_ coreDataStack: STPKCoreDataStack) -> Void

//**********************************************************************************************************************
// MARK: - Class Implementation

open class STPKCoreDataStack: NSObject {
    
    fileprivate let coreDataStack: CoreDataStack
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public init(coreDataStack aCoreDataStack: CoreDataStack) {
        self.coreDataStack = aCoreDataStack
        super.init()
    }
    
    open class func constructStack(url aURL: URL,
                                         successBlock aSuccessBlock: @escaping STPKCoreDataStackSetupSuccessBlock,
                                                      failureBlock aFailureBlock: @escaping STPKCoreDataStackSetupFailureBlock) {
        let modelName = "STPKModel"
        let bundle = Bundle.init(for: self)
        
        let callback: SetupCallback = {(aResult: CoreDataStack.SetupResult) in
        
            switch aResult {
            case .success(let aStack):
                let upkStack = STPKCoreDataStack(coreDataStack: aStack)
                aSuccessBlock(upkStack)
            case .failure(let anError as NSError):
                aFailureBlock(anError)
            default:
                print("Unhandled case")
            }
        }
        
        CoreDataStack.constructSQLiteStack(modelName: modelName,
                                           in: bundle,
                                           at: aURL,
                                           persistentStoreOptions: nil,
                                           on: nil,
                                           callback: callback)
    }
    
    
    open func mainQueueContext() -> NSManagedObjectContext {
        return self.coreDataStack.mainQueueContext
    }
    
    
    open func newBackgroundWorkerMOC() -> NSManagedObjectContext {
        return self.coreDataStack.newChildContext(type: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType, name: "com.streettrees.context")
    }
    
    
    open func resetStore(successBlock aSuccessBlock: @escaping STPKCoreDataStackResetSuccessBlock,
                                        failureBlock aFailureBlock: @escaping STPKCoreDataStackResetFailureBlock) {
        
        let callback: StoreResetCallback = {(aResult: CoreDataStack.ResetResult) in
            switch aResult {
            case .success():
                aSuccessBlock()
            case .failure(let anError as NSError):
                aFailureBlock(anError)
            default:
                print("Unhandled case")
            }
        }
        self.coreDataStack.resetStore(callback: callback)
    }
}
