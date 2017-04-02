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

public typealias STPKCoreDataCompletionBlock = (_ anError: NSError?) -> Void
public typealias STPKCoreDataUserCompletionBlock = (_ user: STPKUser?, _ anError: NSError?) -> Void

private let STPKPersistentStoreFileName = "streettrees.sqlite"
private let STPKUpdateFrequency: TimeInterval = 1209600 // 2 weeks

open class STPKCoreData: NSObject {
    
    open fileprivate(set) var coreDataStack: STPKCoreDataStack?
    
    open static let sharedInstance = STPKCoreData()
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    open func createUser(_ completion: @escaping STPKCoreDataUserCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.CreateUser", code: 3, userInfo: nil)
            completion(nil, error)
            return
        }
        
        context.performAndWait {
            if self.fetchUser() == nil {
                STPKUser.insert(context: context)
                self.save(context) { error in
                    if let _ = error {
                        completion(user: nil, anError: error)
                    }
                    completion(user: self.fetchUser(), anError: error)
                }
            } else {
                let error = NSError(domain: "com.CodeForOrlando.StreeTrees.UserExists", code: 4, userInfo: nil)
                completion(nil, error)
            }
        }
    }
    
    open func fetchCityBounds(_ handler: STPKFetchCityBoundsHandler) {
        guard let context = self.coreDataStack?.mainQueueContext() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.MainContext", code: 7, userInfo: nil)
            handler(nil, error)
            return
        }
        
        STPKCityBounds.fetch(context, handler: handler)
    }
    
    open func fetch(decriptionForName aName: String) -> STPKTreeDescription? {
        guard let context = self.coreDataStack?.mainQueueContext() else { return nil }
        var description: STPKTreeDescription?
        
        do {
            description = try STPKTreeDescription.fetch(descriptionForName: aName, context: context)
        } catch {
            description = nil
        }
        
        return description
    }
    
    open func fetch(treeForOrderNumber anOrderNumber: Int) -> STPKTree? {
        guard let context = self.coreDataStack?.mainQueueContext() else { return nil }
        
        var tree: STPKTree?
        
        do {
            tree = try STPKTree.fetch(byOrderNumber: anOrderNumber, inContext: context)
        } catch {
            tree = nil
        }
        
        return tree
    }
    
    open func fetchTreeDescriptions() -> [STPKTreeDescription] {
        guard let context = self.coreDataStack?.mainQueueContext() else { return [] }
        let treeDescriptions: [STPKTreeDescription]
        
        do {
            treeDescriptions = try STPKTreeDescription.fetch(context) as? [STPKTreeDescription] ?? []
        } catch {
            treeDescriptions = []
        }
        
        return treeDescriptions
    }
    
    open func fetchTrees() -> [STPKTree] {
        guard let context = self.coreDataStack?.mainQueueContext() else { return [] }
        let trees: [STPKTree]
        
        do {
            trees = try STPKTree.fetch(context) as? [STPKTree] ?? []
        } catch {
            trees = []
        }
        
        return trees
    }
    
    open func fetchUser() -> STPKUser? {
        guard let context = self.coreDataStack?.mainQueueContext() else { return nil }
        do {
            return try STPKUser.fetch(context).first as? STPKUser
        } catch {
            
        }
        
        return nil
    }
    
    open func insert(_ citybounds: [AnyHashable: Any], completion: @escaping STPKCoreDataCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertCityBounds", code: 3, userInfo: nil)
            completion(error)
            return
        }
        
        context.performAndWait { [unowned self] in
            
            let jsonData: Data
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: citybounds, options: [])
            } catch {
                let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertCityBounds.JSON", code: 4, userInfo: nil)
                completion(error)
                return
            }
            
            let newBounds = STPKCityBounds.insert(context: context)
            newBounds.timestamp = Date()
            newBounds.json = jsonData
            
            self.save(context, completion: completion)
        }
    }
    
    open func insert(_ descriptionData: [STTKTreeDescription], completion:@escaping STPKCoreDataStackCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertDescriptions", code: 1, userInfo: nil)
            completion(error)
            return
        }
        let currentTreeDescriptions = self.fetchTreeDescriptions()
        
        context.performAndWait { [unowned self] in
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
    
    open func insert(_ treesData: [STTKStreetTree], completion: @escaping STPKCoreDataStackCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertTrees", code: 2, userInfo: nil)
            completion(error)
            return
        }
        let currentTrees = self.fetchTrees()
        
        context.performAndWait { [unowned self] in
            
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
                    newTree.savings = NSDecimalNumber(value: treeData.savings as Double)
                    newTree.stormWater = treeData.stormwater
                    newTree.therms = treeData.therms
                    newTree.speciesName = treeData.name
                    newTree.longitude = treeData.long
                    newTree.latitude = treeData.lat
                    newTree.date = treeData.date
                }
            }
            
            self.save(context, completion: completion)
        }
    }
    
    open func refreshAll(_ completion: @escaping STPKCoreDataCompletionBlock) {
        
        if let user = self.fetchUser() {
            let updateDate = user.lastestUpdate ?? Date()
            
            let isTimeToUpdate = Date().timeIntervalSince(updateDate) >= STPKUpdateFrequency
            if !isTimeToUpdate && user.lastestUpdate != nil {
                completion(nil)
                return
            }
            guard let backgroundContext = self.coreDataStack?.newBackgroundWorkerMOC() else {
                let error = NSError(domain: "com.CodeForOrlando.StreeTrees.UpdateUserTime", code: 1, userInfo: nil)
                completion(error)
                return
            }
            
            if let backgroundUser = try? STPKUser.fetch(backgroundContext).first as? STPKUser {
                backgroundUser?.lastestUpdate = Date()
                self.save(backgroundContext, completion: { (anError) in
                    // nothing to do here
                })
            }
        } else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.NoUserInDB", code: 5, userInfo: nil)
            completion(error)
            return
        }
        
        STTKDownloadManager.fetch(treeDescriptionsWithcompletion:  { (descriptions:[STTKTreeDescription]) in
            
            self.insert(descriptions, completion: { (anError) in
                
                if anError != nil {
                    completion(anError: anError)
                    return
                }
                
                STTKDownloadManager.fetch(treesWithCompletion: { (trees: [STTKStreetTree]) in
                    // Download all descriptions
                    
                    self.insert(trees, completion: { (anError) in
                        // Insert all descriptions
                        // join descriptions and trees
                        guard let context = self.coreDataStack?.mainQueueContext() else {
                            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.FetchTreesMainQueueContext", code: 1, userInfo: nil)
                            completion(anError: error)
                            return
                        }
                        if let allTrees = try? STPKTree.fetch(context) as? [STPKTree] {
                            for tree in allTrees ?? [] {
                                self.updateDescriptionForTree(tree: tree)
                            }
                        }
                        completion(anError: anError)
                    })
                })
            })
        })
    }
    
    /**
     This function must be run at the beginning of the applications life cycle.
     */
    open func setupCoreData(_ aSuccessBlock: @escaping STPKCoreDataStackSetupSuccessBlock, aFailureBlock: @escaping STPKCoreDataStackSetupFailureBlock) {
        let storePath = self.defaultPersistentStorePath()
        
        let url = URL(fileURLWithPath: storePath).appendingPathComponent(STPKPersistentStoreFileName)
        
        let successBlock: STPKCoreDataStackSetupSuccessBlock = { (aCoreDataStack) -> Void in
            self.coreDataStack = aCoreDataStack
            aSuccessBlock(aCoreDataStack)
        }
        
        let failureBlock: STPKCoreDataStackSetupFailureBlock = { (anError) -> Void in
            aFailureBlock(anError)
        }
        
        STPKCoreDataStack.constructStack(url: url, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    fileprivate func updateDescriptionForTree(tree aTree: STPKTree) {
        guard let context = self.coreDataStack?.mainQueueContext() else { return }
        guard let name = aTree.speciesName else { return }
        
        do {
            let description = try STPKTreeDescription.fetch(descriptionForName: name, context: context)
            aTree.treeDescription = description
            description?.trees = description?.trees?.adding(aTree) as NSSet?
        } catch {
            // Throw error
            print("Unable to fetch tree description for species \(aTree.speciesName ?? "No species name") ")
        }
    }
    
    fileprivate func defaultPersistentStorePath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    fileprivate func save(_ context: NSManagedObjectContext, completion:STPKCoreDataStackCompletionBlock) {
        do {
            try context.saveContextAndWait()
            completion(nil)
        } catch {
            completion(NSError(domain: "com.CodeForOrlando.StreetTrees.FailedToSaveContext", code: -1, userInfo: nil))
        }
        
    }

}
