//
//  NearManager.swift
//  NearITSDK
//
//  Created by Francesco Leoni on 27/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

import UIKit
import NearITSDK

public protocol NearManagerDelegate {
    func manager(_ manager: NearManager, eventWithContent content: Any, recipe: NITRecipe);
    func manager(_ manager: NearManager, eventFailureWithError error: Error, recipe: NITRecipe);
}

public final class NearManager: NSObject, NITManagerDelegate {
    
    private var manager: NITManager!
    public var delegate: NearManagerDelegate?
    
    public init(apiKey: String) {
        super.init()
        manager = NITManager(apiKey: apiKey)
        manager.delegate = self
    }
    
    public func start() {
        manager.start()
    }
    
    public func stop() {
        manager.stop()
    }
    
    public func setDeviceToken(_ token: String) {
        manager.setDeviceToken(token)
    }
    
    public func refreshConfig() {
        manager.refreshConfig()
    }
    
    public func processRecipe(_ userInfo: [AnyHashable : Any]) {
        if let ui = userInfo as? [String : Any] {
            manager.processRecipe(userInfo: ui)
        }
    }
    
    public func sendTracking(_ recipeId: String, event: String) {
        manager.sendTracking(withRecipeId: recipeId, event: event)
    }
    
    public func manager(_ manager: NITManager, eventWithContent content: Any, recipe: NITRecipe) {
        delegate?.manager(self, eventWithContent: content, recipe: recipe)
    }
    
    public func manager(_ manager: NITManager, eventFailureWithError error: Error, recipe: NITRecipe) {
        delegate?.manager(self, eventFailureWithError: error, recipe: recipe);
    }
}
