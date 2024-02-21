//
//  NotificationView.swift
//  Boiling Alarm Watch App
//
//  Created by 안병욱 on 2/20/24.
//

import SwiftUI
import WatchKit
import UserNotifications

class NotificationController: WKUserNotificationHostingController<NotificationView> {

    override var body: NotificationView {
        NotificationView()
    }
    override func didReceive(_ notification: UNNotification) {
        super.didReceive(notification)

        let content = notification.request.content
        let title = content.title
        let body = content.body

        print("알림 받음 - 제목: \(title), 내용: \(body)")
        // 여기서 알림을 처리하거나 원하는 작업을 수행합니다.
    }
}

struct NotificationView: View {
    var body: some View {
        
        VStack{
            ZStack{
                Image("Steam")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary.opacity(0.5))
                    .frame(height: 30)
                    .offset(x: 70, y: -5)
                Image("Pot_lid")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray)
                    .frame(width: 100)
                    .offset(y: -5)
                    .rotationEffect(.degrees(-10))
            }
            LinearGradient(colors: [.red, .gray], startPoint: .bottom, endPoint: .top)
                .mask {
                    Image("Pot_body")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .frame(width: 240)
                }
                .frame(height: 50)
            LinearGradient(colors: [.red, .orange], startPoint: .bottom, endPoint: .top)
                .mask{
                    HStack{
                        Image(systemName: "flame.fill")
                            .resizable()
                            .foregroundStyle(.orange)
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.tint)
                        Image(systemName: "flame.fill")
                            .resizable()
                            .foregroundStyle(.orange)
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.tint)
                        Image(systemName: "flame.fill")
                            .resizable()
                            .foregroundStyle(.orange)
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.tint)
                    }
                }
                .frame(height: 25)
            Text("물이 끓고 있어요!")
                .bold()
                .padding()
        }
    }
}

#Preview {
    NotificationView()
}
