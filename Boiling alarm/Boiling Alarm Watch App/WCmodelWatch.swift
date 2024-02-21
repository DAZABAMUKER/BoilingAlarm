//
//  WCmodelWatch.swift
//  Boiling Alarm Watch App
//
//  Created by 안병욱 on 2/20/24.
//

import Foundation
import WatchConnectivity

class WCmodelWatch: NSObject, WCSessionDelegate, ObservableObject {
    @Published var message: String = ""
    var session: WCSession
    init(session: WCSession = .default){
        self.session = session
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.message = message["message"] as? String ?? ""
        }
    }
    
    
}
