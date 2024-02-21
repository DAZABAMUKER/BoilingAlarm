//
//  NotificationHandler.swift
//  Boiling alarm
//
//  Created by 안병욱 on 2/20/24.
//

import SwiftUI
import UserNotifications

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationHandler()
    
    // background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notificationName = Notification.Name(response.notification.request.identifier)
        NotificationCenter.default.post(name: notificationName, object: response.notification.request.content)
        completionHandler()
    }
    
    //foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationName = Notification.Name(notification.request.identifier)
        NotificationCenter.default.post(name: notificationName, object: notification.request.content)
        completionHandler(.sound)
    }
}

extension NotificationHandler  {
    func requestPermission(_ delegate : UNUserNotificationCenterDelegate? = nil ,
        onDeny handler :  (()-> Void)? = nil){  // an optional onDeny handler is better here,
                                                // so there is an option not to provide one, have one only when needed
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings(completionHandler: { settings in
        
            if settings.authorizationStatus == .denied {
                if let handler = handler {
                    handler()
                }
                return
            }
            
            if settings.authorizationStatus != .authorized  {
                center.requestAuthorization(options: [.alert, .sound, .badge]) {
                    _ , error in
                    
                    if let error = error {
                        print("error handling \(error)")
                    }
                }
            }
            
        })
        center.delegate = delegate ?? self
    }
}

extension NotificationHandler {
    func addNotification(id : String, title : String, subtitle : String ,
    sound : UNNotificationSound = UNNotificationSound.default,
    trigger : UNNotificationTrigger =
    UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        
        content.sound = sound

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func removeNotifications(_ ids : [String]){
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

}
