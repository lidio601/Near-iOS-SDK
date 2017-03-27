//
//  NearManager.swift
//  NearITSDK
//
//  Created by Francesco Leoni on 27/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

import UIKit
import NearITSDK

protocol NearManagerDelegate {
    func manager(_ manager: NearManager, eventWithContent content: Any);
    func manager(_ manager: NearManager, eventFailureWithError error: Error);
}

class NearManager: NSObject, NITManagerDelegate {
    
    private var manager: NITManager!
    public var delegate: NearManagerDelegate?
    
    init(apiKey: String) {
        super.init()
        manager = NITManager(apiKey: apiKey)
        manager.delegate = self
    }
    
    func setDeviceToken(_ token: String) {
        manager.setDeviceToken(token)
    }
    
    func refreshConfig() {
        manager.refreshConfig()
    }
    
    func manager(_ manager: NITManager, eventWithContent content: Any) {
        delegate?.manager(self, eventWithContent: content)
    }

    func manager(_ manager: NITManager, eventFailureWithError error: Error) {
        delegate?.manager(self, eventFailureWithError: error);
    }
}
