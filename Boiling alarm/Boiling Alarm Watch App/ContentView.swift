//
//  ContentView.swift
//  Boiling Alarm Watch App
//
//  Created by 안병욱 on 2/20/24.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject var model = WCmodelWatch()
    var body: some View {
        if model.message == "Boiling" {
            NotificationView()
        } else {
            VStack{
                ZStack{
                    Image("Pot_lid")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .frame(width: 100)
                }
                        Image("Pot_body")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.gray)
                            .frame(width: 240, height: 50)
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
            }
        }
//            .task {
//                let center = UNUserNotificationCenter.current()
//                _ = try? await center.requestAuthorization(
//                    options: [.alert, .sound, .badge]
//                )
//            }
    }
}

#Preview {
    ContentView()
}
