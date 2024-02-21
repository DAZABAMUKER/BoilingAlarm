//
//  Boiling_alarmApp.swift
//  Boiling alarm
//
//  Created by 안병욱 on 2/16/24.
//

// peter write test

import SwiftUI
import UserNotifications

@main
struct Boiling_alarmApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(watchOS)
        WKNotificationScene(controller: NotificationController.self, category: "boilNoti")
        #endif
    }
}


