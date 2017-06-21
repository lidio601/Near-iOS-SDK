//
//  NearManager.swift
//  NearITSDK
//
//  Created by Francesco Leoni on 27/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

import UIKit
import NearITSDK
import UserNotifications

public enum NearRecipeTracking : String {
    case notified = "notified"
    case engaged = "engaged"
}

public protocol NearManagerDelegate {
    func manager(_ manager: NearManager, eventWithContent content: Any, recipe: NITRecipe);
    func manager(_ manager: NearManager, eventFailureWithError error: Error, recipe: NITRecipe);
}

public final class NearManager: NSObject, NITManagerDelegate {
    
    private var manager: NITManager!
    public var delegate: NearManagerDelegate?
    public var profileId: String? {
        get {
            return manager.profileId()
        }
    }
    
    public init(apiKey: String) {
        super.init()
        manager = NITManager(apiKey: apiKey)
        manager.delegate = self
    }
    
    public init(suiteName: String) {
        super.init()
        manager = NITManager(suiteName: suiteName)
        manager.delegate = self
    }
    
    public func start() {
        manager.start()
    }
    
    public func stop() {
        manager.stop()
    }
    
    public func setDeviceToken(_ token: Data) {
        manager.setDeviceTokenWith(token)
    }
    
    public func refreshConfig(completionHandler: ((Error?) -> Void)?) {
        manager.refreshConfig(completionHandler: completionHandler)
    }
    
    public func processRecipeSimple(_ userInfo: [AnyHashable : Any]) {
        if let ui = userInfo as? [String : Any] {
            manager.processRecipeSimple(userInfo: ui)
        }
    }
    
    public func processRecipe(_ userInfo: [AnyHashable : Any], completion: ((Any?, NITRecipe?, Error?) -> Void)?) {
        if let ui = userInfo as? [String : Any] {
            manager.processRecipe(userInfo: ui, completion: { (content, recipe, error) in
                if completion != nil {
                    completion!(content, recipe, error)
                }
            })
        }
    }
    
    public func sendTracking(_ recipeId: String, event: NearRecipeTracking) {
        manager.sendTracking(withRecipeId: recipeId, event: event.rawValue)
    }
    
    public func setUserData(_ key: String, value: String?, completionHandler: ((Error?) -> Void)?) {
        manager.setUserDataWithKey(key, value: value, completionHandler: completionHandler)
    }
    
    public func setBatchUserData(_ valuesDictionary : [String : Any], completionHandler: ((Error?) -> Void)?) {
        manager.setBatchUserDataWith(valuesDictionary, completionHandler: completionHandler)
    }
    
    public func sendEvent(_ event: NITEvent, completionHandler: ((Error?) -> Void)?) {
        manager.sendEvent(with: event, completionHandler: completionHandler)
    }
    
    public func coupons(_ completionHandler: (([NITCoupon]?, Error?) -> Void)?) {
        manager.coupons(completionHandler: completionHandler)
    }
    
    public func resetProfile() {
        manager.resetProfile()
    }
    
    public func setProfile(id: String) {
        manager.setProfileId(id)
    }
    
    public func setSuiteName(_ name: String) {
        manager.setSuiteName(name)
    }
    
    public func createNewProfile(_ completionHandler: ((String?, Error?) -> Void)?) {
        manager.createNewProfile { (profileId, error) in
            if let handler = completionHandler {
                handler(profileId, error)
            }
        }
    }
    
    public func recipes() -> [NITRecipe] {
        return manager.recipes()
    }
    
    public func processRecipe(id: String) {
        manager.processRecipe(withId: id)
    }
    
    @available(iOS 10.0, *)
    public func handleLocalNotificationResponse(_ response: UNNotificationResponse, completionHandler:((Any?, String?, Error?) -> Void)?) -> Bool {
        return manager.handleLocalNotificationResponse(response) { (content, recipeId, error) in
            if let completionHandler = completionHandler {
                completionHandler(content, recipeId, error);
            }
        }
    }
    
    public func manager(_ manager: NITManager, eventWithContent content: Any, recipe: NITRecipe) {
        delegate?.manager(self, eventWithContent: content, recipe: recipe)
    }
    
    public func manager(_ manager: NITManager, eventFailureWithError error: Error, recipe: NITRecipe) {
        delegate?.manager(self, eventFailureWithError: error, recipe: recipe);
    }
}
