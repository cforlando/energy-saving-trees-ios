//
//  STFKEmitter.swift
//  Street Trees
//
//  Created by Tom Marks on 27/11/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import Foundation
import SpriteKit

//**********************************************************************************************************************
// MARK: - Constants

private let STEmitterName = "peace"
private let STPeaceFile = "PeaceEmitter.sks"
private let STPeaceHeight: CGFloat = 18.0

//**********************************************************************************************************************
// MARK: - Class Implementation

public class STPeaceEmitter: SKScene {
    
    private(set) var playing = false
    private var treeEmitter: SKEmitterNode?
    
    //******************************************************************************************************************
    // MARK: - Class Overrides
    
    override public func didMoveToView(view: SKView) {
        self.scaleMode = .ResizeFill
        self.backgroundColor = UIColor.clearColor()
    }
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public func beginAnimation() {
        
        if self.playing {
            return
        }
        
        self.playing = true
        
        if let _ = self.treeEmitter {
            self.treeEmitter?.resetSimulation()
        } else {
            guard let emitter = SKEmitterNode(fileNamed: STPeaceFile) else { return }
            
            let x = floor(self.size.width / 2.0)
            let y = STPeaceHeight
            
            emitter.position = CGPointMake(x, y)
            
            emitter.name = STEmitterName
            emitter.targetNode = self
            
            self.addChild(emitter)
            self.treeEmitter = emitter
        }
    }
    
    public func endAnimation() {
        self.playing = false
    }
}
