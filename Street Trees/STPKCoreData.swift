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
public typealias STPKCoreDataUserCompletionBlock = (user: STPKUser?, anError: NSError?) -> Void

private let STPKPersistentStoreFileName = "streettrees.sqlite"
private let STPKUpdateFrequency: NSTimeInterval = 1209600 // 2 weeks

public class STPKCoreData: NSObject {
    
    public private(set) var coreDataStack: STPKCoreDataStack?
    
    public static let sharedInstance = STPKCoreData()
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public func createUser(completion: STPKCoreDataUserCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.CreateUser", code: 3, userInfo: nil)
            completion(user: nil, anError: error)
            return
        }
        
        context.performBlockAndWait {
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
                completion(user: nil, anError: error)
            }
        }
    }
    
    public func fetchCityBounds(handler: STPKFetchCityBoundsHandler) {
        guard let context = self.coreDataStack?.mainQueueContext() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.MainContext", code: 7, userInfo: nil)
            handler(cityBounds: nil, error: error)
            return
        }
        
        STPKCityBounds.fetch(context, handler: handler)
    }
    
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
    
    public func fetchUser() -> STPKUser? {
        guard let context = self.coreDataStack?.mainQueueContext() else { return nil }
        do {
            return try STPKUser.fetch(context).first as? STPKUser
        } catch {
            
        }
        
        return nil
    }
    
    public func insert(citybounds: [NSObject: AnyObject], completion: STPKCoreDataCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertCityBounds", code: 3, userInfo: nil)
            completion(anError: error)
            return
        }
        
        context.performBlockAndWait { [unowned self] in
            
            let jsonData: NSData
            
            do {
                jsonData = try NSJSONSerialization.dataWithJSONObject(citybounds, options: [])
            } catch {
                let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertCityBounds.JSON", code: 4, userInfo: nil)
                completion(anError: error)
                return
            }
            
            let newBounds = STPKCityBounds.insert(context: context)
            newBounds.timestamp = NSDate()
            newBounds.json = jsonData
            
            self.save(context, completion: completion)
        }
    }
    
    public func insert(descriptionData: [STTKTreeDescription], completion:STPKCoreDataStackCompletionBlock) {
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertDescriptions", code: 1, userInfo: nil)
            completion(anError: error)
            return
        }
        let currentTreeDescriptions = self.fetchTreeDescriptions()
        
        context.performBlockAndWait { [unowned self] in
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
        guard let context = self.coreDataStack?.newBackgroundWorkerMOC() else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertTrees", code: 2, userInfo: nil)
            completion(anError: error)
            return
        }
        let currentTrees = self.fetchTrees()
        
        context.performBlockAndWait { [unowned self] in
            
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
                    newTree.date = treeData.date
                }
            }
            
            self.save(context, completion: completion)
        }
    }
    
    public func refreshAll(completion: STPKCoreDataCompletionBlock) {
        
        if let user = self.fetchUser() {
            let updateDate = user.lastestUpdate ?? NSDate()
            
            let isTimeToUpdate = NSDate().timeIntervalSinceDate(updateDate) >= STPKUpdateFrequency
            if !isTimeToUpdate && user.lastestUpdate != nil {
                completion(anError: nil)
                return
            }
            guard let backgroundContext = self.coreDataStack?.newBackgroundWorkerMOC() else {
                let error = NSError(domain: "com.CodeForOrlando.StreeTrees.UpdateUserTime", code: 1, userInfo: nil)
                completion(anError: error)
                return
            }
            
            if let backgroundUser = try? STPKUser.fetch(backgroundContext).first as? STPKUser {
                backgroundUser?.lastestUpdate = NSDate()
                self.save(backgroundContext, completion: { (anError) in
                    // nothing to do here
                })
            }
        } else {
            let error = NSError(domain: "com.CodeForOrlando.StreeTrees.NoUserInDB", code: 5, userInfo: nil)
            completion(anError: error)
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
    
    private func updateDescriptionForTree(tree aTree: STPKTree) {
        guard let context = self.coreDataStack?.mainQueueContext() else { return }
        guard let name = aTree.speciesName else { return }
        
        do {
            let description = try STPKTreeDescription.fetch(descriptionForName: name, context: context)
            aTree.treeDescription = description
            description?.trees = description?.trees?.setByAddingObject(aTree)
        } catch {
            // Throw error
            print("Unable to fetch tree description for species \(aTree.speciesName ?? "No species name") ")
        }
    }
    
    private func defaultPersistentStorePath() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    }
    
    private func save(context: NSManagedObjectContext, completion:STPKCoreDataStackCompletionBlock) {
        do {
            try context.saveContextAndWait()
            completion(anError: nil)
        } catch {
            completion(anError: NSError(domain: "com.CodeForOrlando.StreetTrees.FailedToSaveContext", code: -1, userInfo: nil))
        }
        
    }

}
