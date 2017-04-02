//
//  CoreDataStack.swift
//  CoreDataSMS
//
//  Created by Robert Edwards on 12/8/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Action callbacks
public typealias CoreDataStackSetupCallback = (CoreDataStack.SetupResult) -> Void
public typealias CoreDataStackStoreResetCallback = (CoreDataStack.ResetResult) -> Void
public typealias CoreDataStackBatchMOCCallback = (CoreDataStack.BatchContextResult) -> Void

// MARK: - Error Handling

/**
 Three layer Core Data stack comprised of:

 * A primary background queue context with an `NSPersistentStoreCoordinator`
 * A main queue context that is a child of the primary queue
 * A method for spawning many background worker contexts that are children of the main queue context

 Calling `save()` on any `NSMangedObjectContext` belonging to the stack will automatically bubble the changes all the way to the `NSPersistentStore`
 */
public final class CoreDataStack {

    /// CoreDataStack specific ErrorTypes
    public enum Error: Error {
        /// Case when an `NSPersistentStore` is not found for the supplied store URL
        case storeNotFoundAt(url: URL)
        /// Case when an In-Memory store is not found
        case inMemoryStoreMissing
        /// Case when the store URL supplied to contruct function cannot be used
        case unableToCreateStoreAt(url: URL)
    }

    /**
     Primary persisting background managed object context. This is the top level context that possess an
     `NSPersistentStoreCoordinator` and saves changes to disk on a background queue.

     Fetching, Inserting, Deleting or Updating managed objects should occur on a child of this context rather than directly.

     note: `NSBatchUpdateRequest` and `NSAsynchronousFetchRequest` require a context with a persistent store connected directly.
     */
    public fileprivate(set) lazy var privateQueueContext: NSManagedObjectContext = {
        return self.constructPersistingContext()
    }()
    fileprivate func constructPersistingContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        managedObjectContext.name = "Primary Private Queue Context (Persisting Context)"
        return managedObjectContext
    }

    /**
     The main queue context for any work that will be performed on the main queue.
     Its parent context is the primary private queue context that persist the data to disk.
     Making a `save()` call on this context will automatically trigger a save on its parent via `NSNotification`.
     */
    public fileprivate(set) lazy var mainQueueContext: NSManagedObjectContext = {
        return self.constructMainQueueContext()
    }()
    fileprivate func constructMainQueueContext() -> NSManagedObjectContext {
        var managedObjectContext: NSManagedObjectContext!
        let setup: () -> Void = {
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
            managedObjectContext.parent = self.privateQueueContext

            NotificationCenter.default.addObserver(self,
                                                             selector: #selector(CoreDataStack.stackMemberContextDidSaveNotification(_:)),
                                                             name: NSNotification.Name.NSManagedObjectContextDidSave,
                                                             object: managedObjectContext)
        }
        // Always create the main-queue ManagedObjectContext on the main queue.
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                setup()
            }
        } else {
            setup()
        }
        return managedObjectContext
    }

    // MARK: - Lifecycle

    /**
     Creates a `SQLite` backed Core Data stack for a given model in the supplied `NSBundle`.

     - parameter modelName: Base name of the `XCDataModel` file.
     - parameter inBundle: NSBundle that contains the `XCDataModel`. Default value is mainBundle()
     - parameter withStoreURL: Optional URL to use for storing the `SQLite` file. Defaults to "(modelName).sqlite" in the Documents directory.
     - parameter callbackQueue: Optional GCD queue that will be used to dispatch your callback closure. Defaults to background queue used to create the stack.
     - parameter callback: The `SQLite` persistent store coordinator will be setup asynchronously. This callback will be passed either an initialized `CoreDataStack` object or an `ErrorType` value.
     */
    public static func constructSQLiteStack(withModelName
        modelName: String,
        inBundle bundle: Bundle = Bundle.main,
                 withStoreURL desiredStoreURL: URL? = nil,
                              callbackQueue: DispatchQueue? = nil,
                              callback: @escaping CoreDataStackSetupCallback) {

        let model = bundle.managedObjectModel(modelName: modelName)
        let storeFileURL = desiredStoreURL ?? URL(string: "\(modelName).sqlite", relativeTo: documentsDirectory)!
        do {
            try createDirectoryIfNecessary(storeFileURL)
        } catch {
            callback(.failure(Error.unableToCreateStoreAt(url: storeFileURL)))
            return
        }

        let backgroundQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        let callbackQueue: DispatchQueue = callbackQueue ?? backgroundQueue
        NSPersistentStoreCoordinator.setupSQLiteBackedCoordinator(
            model,
            storeFileURL: storeFileURL) { coordinatorResult in
                switch coordinatorResult {
                case .success(let coordinator):
                    let stack = CoreDataStack(modelName : modelName,
                                              bundle: bundle,
                                              persistentStoreCoordinator: coordinator,
                                              storeType: .sqLite(storeURL: storeFileURL))
                    callbackQueue.async {
                        callback(.success(stack))
                    }
                case .failure(let error):
                    callbackQueue.async {
                        callback(.failure(error))
                    }
                }
        }
    }

    fileprivate static func createDirectoryIfNecessary(_ url: URL) throws {
        let fileManager = FileManager.default
        guard let directory = url.deletingLastPathComponent() else {
            throw Error.unableToCreateStoreAt(url: url)
        }
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    }

    /**
     Creates an in-memory Core Data stack for a given model in the supplied `NSBundle`.

     This stack is configured with the same concurrency and persistence model as the `SQLite` stack, but everything is in-memory.

     - parameter modelName: Base name of the `XCDataModel` file.
     - parameter inBundle: `NSBundle` that contains the `XCDataModel`. Default value is `mainBundle()`

     - throws: Any error produced from `NSPersistentStoreCoordinator`'s `addPersistentStoreWithType`

     - returns: CoreDataStack: Newly created In-Memory `CoreDataStack`
     */
    public static func constructInMemoryStack(withModelName modelName: String,
                                                            inBundle bundle: Bundle = Bundle.main) throws -> CoreDataStack {
        let model = bundle.managedObjectModel(modelName: modelName)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        let stack = CoreDataStack(modelName: modelName, bundle: bundle, persistentStoreCoordinator: coordinator, storeType: .inMemory)
        return stack
    }

    // MARK: - Private Implementation

    fileprivate enum StoreType {
        case inMemory
        case sqLite(storeURL: URL)
    }

    fileprivate let managedObjectModelName: String
    fileprivate let storeType: StoreType
    fileprivate let bundle: Bundle
    fileprivate var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        didSet {
            privateQueueContext = constructPersistingContext()
            privateQueueContext.persistentStoreCoordinator = persistentStoreCoordinator
            mainQueueContext = constructMainQueueContext()
        }
    }
    fileprivate var managedObjectModel: NSManagedObjectModel {
        get {
            return bundle.managedObjectModel(modelName: managedObjectModelName)
        }
    }

    fileprivate init(modelName: String, bundle: Bundle, persistentStoreCoordinator: NSPersistentStoreCoordinator, storeType: StoreType) {
        self.bundle = bundle
        self.storeType = storeType
        managedObjectModelName = modelName

        self.persistentStoreCoordinator = persistentStoreCoordinator
        privateQueueContext.persistentStoreCoordinator = persistentStoreCoordinator
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate let saveBubbleDispatchGroup = DispatchGroup()
}

public extension CoreDataStack {
    // TODO: rcedwards These will be replaced with Box/Either or something native to Swift (fingers crossed) https://github.com/bignerdranch/CoreDataStack/issues/10

    // MARK: - Operation Result Types

    /// Result containing either an instance of `NSPersistentStoreCoordinator` or `ErrorType`
    public enum CoordinatorResult {
        /// A success case with associated `NSPersistentStoreCoordinator` instance
        case success(NSPersistentStoreCoordinator)
        /// A failure case with associated `ErrorType` instance
        case failure(Error)
    }
    /// Result containing either an instance of `NSManagedObjectContext` or `ErrorType`
    public enum BatchContextResult {
        /// A success case with associated `NSManagedObjectContext` instance
        case success(NSManagedObjectContext)
        /// A failure case with associated `ErrorType` instance
        case failure(Error)
    }
    /// Result containing either an instance of `CoreDataStack` or `ErrorType`
    public enum SetupResult {
        /// A success case with associated `CoreDataStack` instance
        case success(CoreDataStack)
        /// A failure case with associated `ErrorType` instance
        case failure(Error)
    }
    /// Result of void representing `Success` or an instance of `ErrorType`
    public enum SuccessResult {
        /// A success case
        case success
        /// A failure case with associated ErrorType instance
        case failure(Error)
    }
    public typealias SaveResult = SuccessResult
    public typealias ResetResult = SuccessResult
}

public extension CoreDataStack {
    /**
     This function resets the `NSPersistentStore` connected to the `NSPersistentStoreCoordinator`.
     For `SQLite` based stacks, this function will also remove the `SQLite` store from disk.

     - parameter callbackQueue: Optional GCD queue that will be used to dispatch your callback closure. Defaults to background queue used to create the stack.
     - parameter resetCallback: A callback with a `Success` or an `ErrorType` value with the error
     */
    public func resetStore(_ callbackQueue: DispatchQueue? = nil, resetCallback: @escaping CoreDataStackStoreResetCallback) {
        let backgroundQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        let callbackQueue: DispatchQueue = callbackQueue ?? backgroundQueue
        self.saveBubbleDispatchGroup.notify(queue: backgroundQueue) {
            switch self.storeType {
            case .inMemory:
                do {
                    guard let store = self.persistentStoreCoordinator.persistentStores.first else {
                        resetCallback(.failure(Error.inMemoryStoreMissing))
                        break
                    }
                    try self.persistentStoreCoordinator.performAndWaitOrThrow {
                        try self.persistentStoreCoordinator.remove(store)
                        try self.persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
                    }
                    callbackQueue.async {
                        resetCallback(.success)
                    }
                } catch {
                    callbackQueue.async {
                        resetCallback(.failure(error as! CoreDataStack.Error))
                    }
                }
                break

            case .sqLite(let storeURL):
                let coordinator = self.persistentStoreCoordinator
                let mom = self.managedObjectModel

                guard let store = coordinator.persistentStore(for: storeURL) else {
                    let error = Error.storeNotFoundAt(url: storeURL)
                    resetCallback(.failure(error))
                    break
                }

                do {
                    if #available(iOS 9, OSX 10.11, *) {
                        try coordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
                    } else {
                        let fm = FileManager()
                        try coordinator.performAndWaitOrThrow {
                            try coordinator.remove(store)
                            try fm.removeItem(at: storeURL)

                            // Remove journal files if present
                            // Eat the error because different versions of SQLite might have different journal files
                            let _ = try? fm.removeItem(at: storeURL.appendingPathComponent("-shm"))
                            let _ = try? fm.removeItem(at: storeURL.appendingPathComponent("-wal"))
                        }
                    }
                } catch let resetError {
                    callbackQueue.async {
                        resetCallback(.failure(resetError as! CoreDataStack.Error))
                    }
                    return
                }

                // Setup a new stack
                NSPersistentStoreCoordinator.setupSQLiteBackedCoordinator(mom, storeFileURL: storeURL) { result in
                    switch result {
                    case .success (let coordinator):
                        self.persistentStoreCoordinator = coordinator
                        callbackQueue.async {
                            resetCallback(.success)
                        }

                    case .failure (let error):
                        callbackQueue.async {
                            resetCallback(.failure(error))
                        }
                    }
                }
            }
        }
    }
}

public extension CoreDataStack {
    /**
     Returns a new background worker `NSManagedObjectContext` as a child of the main queue context.

     Calling `save()` on this managed object context will automatically trigger a save on its parent context via `NSNotification` observing.

     - returns: `NSManagedObjectContext` The new worker context.
     */
    @available(*, deprecated, message: "Use 'newChildContext(concurrencyType:name:)'")
    public func newBackgroundWorkerMOC() -> NSManagedObjectContext {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        moc.parent = self.mainQueueContext
        moc.name = "Background Worker Context"

        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(stackMemberContextDidSaveNotification(_:)),
                                                         name: NSNotification.Name.NSManagedObjectContextDidSave,
                                                         object: moc)

        return moc
    }

    /**
     Returns a new `NSManagedObjectContext` as a child of the main queue context.

     Calling `save()` on this managed object context will automatically trigger a save on its parent context via `NSNotification` observing.

     - parameter concurrencyType: The NSManagedObjectContextConcurrencyType of the new context.
     **Note** this function will trap on a preconditionFailure if you attempt to create a MainQueueConcurrencyType context from a background thread.
     Default value is .PrivateQueueConcurrencyType
     - parameter name: A name for the new context for debugging purposes. Defaults to *Main Queue Context Child*

     - returns: `NSManagedObjectContext` The new worker context.
     */
    public func newChildContext(concurrencyType: NSManagedObjectContextConcurrencyType = .privateQueueConcurrencyType,
                                                name: String? = "Main Queue Context Child") -> NSManagedObjectContext {
        if concurrencyType == .mainQueueConcurrencyType && !Thread.isMainThread {
            preconditionFailure("Main thread MOCs must be created on the main thread")
        }

        let moc = NSManagedObjectContext(concurrencyType: concurrencyType)
        moc.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        moc.parent = mainQueueContext
        moc.name = name

        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(stackMemberContextDidSaveNotification(_:)),
                                                         name: NSNotification.Name.NSManagedObjectContextDidSave,
                                                         object: moc)
        return moc
    }

    /**
     Creates a new background `NSManagedObjectContext` connected to
     a discrete `NSPersistentStoreCoordinator` created with the same store used by the stack in construction.

     - parameter callbackQueue: Optional GCD queue that will be used to dispatch your callback closure. Defaults to background queue used to create the stack.
     - parameter setupCallback: A callback with either the new `NSManagedObjectContext` or an `ErrorType` value with the error
     */
    public func newBatchOperationContext(_ callbackQueue: DispatchQueue? = nil, setupCallback: @escaping CoreDataStackBatchMOCCallback) {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        moc.name = "Batch Operation Context"

        switch storeType {
        case .inMemory:
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            do {
                try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
                moc.persistentStoreCoordinator = coordinator
                setupCallback(.success(moc))
            } catch {
                setupCallback(.failure(error as! CoreDataStack.Error))
            }
        case .sqLite(let storeURL):
            let backgroundQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
            let callbackQueue: DispatchQueue = callbackQueue ?? backgroundQueue
            NSPersistentStoreCoordinator.setupSQLiteBackedCoordinator(managedObjectModel, storeFileURL: storeURL) { result in
                switch result {
                case .success(let coordinator):
                    moc.persistentStoreCoordinator = coordinator
                    callbackQueue.async {
                        setupCallback(.success(moc))
                    }
                case .failure(let error):
                    callbackQueue.async {
                        setupCallback(.failure(error))
                    }
                }
            }
        }
    }
}

private extension CoreDataStack {
    @objc func stackMemberContextDidSaveNotification(_ notification: Notification) {
        guard let notificationMOC = notification.object as? NSManagedObjectContext else {
            assertionFailure("Notification posted from an object other than an NSManagedObjectContext")
            return
        }
        guard let parentContext = notificationMOC.parent else {
            return
        }

        saveBubbleDispatchGroup.enter()
        parentContext.saveContext() { _ in
            self.saveBubbleDispatchGroup.leave()
        }
    }
}

private extension CoreDataStack {
    static var documentsDirectory: URL? {
        get {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return urls.first
        }
    }
}

private extension Bundle {
    static let modelExtension = "momd"
    func managedObjectModel(modelName: String) -> NSManagedObjectModel {
        guard let URL = url(forResource: modelName, withExtension: Bundle.modelExtension),
            let model = NSManagedObjectModel(contentsOf: URL) else {
                preconditionFailure("Model not found or corrupted with name: \(modelName) in bundle: \(self)")
        }
        return model
    }
}
