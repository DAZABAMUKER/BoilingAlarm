//
//  ContentView.swift
//  Boiling alarm
//
//  Created by 안병욱 on 2/16/24.
//

import SwiftUI
import CoreML
import SoundAnalysis

struct ContentView: View {
    
    @ObservedObject var manager = BoilManager()
    @State var temp = false
    @State var boiling = false
    var model = WCmodeliPhone()
    
    enum ColorTypes {
        case pot, kattle, fire
    }
    
    func boilPot(state: Bool = true, type: ColorTypes) -> [Color] {
        if type == .pot {
            return state ? [Color.red, .gray] : [Color.gray]
        } else if type == .fire {
            return state ? [Color.red, .orange] : [Color.gray.opacity(0.4)]
        } else if type == .kattle {
            return state ? [Color.red, .gray] : [Color.gray]
        } else {
            return [Color.gray]
        }
    }
    func boilLid(state: Bool = true) -> Angle{
        if state == true {
            return .degrees(10.0)
        } else {
            return .degrees(-10.0)
        }
    }
    func notify() {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "물이 끓고 있어요!")
        content.body = String(localized: "어서 불을 꺼주세요!")
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: "boiling", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }
    
    var body: some View {
        VStack {
            if manager.boil {
                ZStack{
                    Image("Steam")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary.opacity(0.5))
                        .frame(height: 50)
                        .offset(x: 120, y: -5)
//                        .scaleEffect(x: temp ? 1 : -1, y: 1)
                        .opacity(temp ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 0.3).repeatForever(), value: temp)
                    Image("Steam")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary.opacity(0.5))
                        .frame(height: 50)
                        .offset(x: 120, y: -5)
                        .scaleEffect(x: -1, y: 1)
                        .opacity(temp ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.3).repeatForever(), value: temp)
                    Image("Pot_lid")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .frame(width: 200)
                        .offset(y: -10)
                        .rotationEffect(boilLid(state: temp))
                        .onAppear() {
                            temp = true
                        }
                        .animation(.easeInOut(duration: 0.3).repeatForever(), value: temp)
                }
            } else {
                Image("Pot_lid")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray)
                    .frame(width: 200)
            }
            
            LinearGradient(colors: boilPot(state: temp, type: .pot), startPoint: .bottom, endPoint: .top)
                .mask {
                    Image("Pot_body")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .frame(width: 240)
                }
                .frame(height: 100)
            LinearGradient(colors: boilPot(state: manager.boil, type: .fire), startPoint: .bottom, endPoint: .top)
                .mask{
                    HStack{
                        Image(systemName: "flame.fill")
                            .resizable()
                            .foregroundStyle(.orange)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.tint)
                        Image(systemName: "flame.fill")
                            .resizable()
                            .foregroundStyle(.orange)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.tint)
                        Image(systemName: "flame.fill")
                            .resizable()
                            .foregroundStyle(.orange)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.tint)
                    }
                }
                .frame(height: 50)
//            ForEach(manager.result.map{$0.key}, id: \.self) { item in
//                HStack{
//                    Text(item)
//                    Text("\(manager.result[item] ?? 0.0) %")
//                }
//            }
//            Text("\(manager.boil_count)")
            Button{
                self.manager.boil = false
                self.temp = false
                self.manager.boil_count = 0
                
            } label: {
                HStack{
                    Text("Alarm Off")
                        .bold()
                        .font(.title3)
                    Circle()
                        .foregroundStyle(self.model.session.isReachable ? Color.green : Color.red)
                        .frame(height: 10)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!manager.boil)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("com.boiling")), perform: { data in
                print("!!!!!!!!!!!!")
                self.model.session.sendMessage(["message" : "Boiling"], replyHandler: nil) { (error) in
                                    print(error.localizedDescription)
                                }
            })
            .onAppear(){
//                UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
//                    if granted {
//                        print("알림 권한 허용됨")
//                    } else {
//                        print("알림 권한 거부됨", error?.localizedDescription ?? "")
//                    }
//                }
                NotificationHandler.shared.requestPermission()
            }
            .padding()
            Button(action: {
                    NotificationHandler.shared.addNotification(
                       id : "com.boiling",
                       title:"Your Notification" , subtitle: "Have a nice day!")
                }, label : {
                    Text("Send Notification")
                })
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
