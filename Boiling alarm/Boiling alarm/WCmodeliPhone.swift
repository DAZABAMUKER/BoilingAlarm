//
//  WCmodeliPhone.swift
//  Boiling alarm
//
//  Created by 안병욱 on 2/20/24.
//

import Foundation
import WatchConnectivity

class WCmodeliPhone: NSObject, WCSessionDelegate {
    var session: WCSession
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
}
