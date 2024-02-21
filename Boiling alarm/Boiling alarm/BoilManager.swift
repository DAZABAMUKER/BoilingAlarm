//
//  BoilManager.swift
//  Boiling alarm
//
//  Created by 안병욱 on 2/16/24.
//

import SwiftUI
import AVFoundation
import SoundAnalysis
import UserNotifications

class BoilManager: NSObject, SNResultsObserving, ObservableObject {
    @Published var result: [String: Double] = [:]
    @Published var boil: Bool = false
    private let audioEngine = AVAudioEngine()
    var analyzer: SNAudioStreamAnalyzer?
    let queue = DispatchQueue(label: "com.dazaba.boiling")
    @Published var boil_count = 0
    
    override init() {
        super.init()
        self.prepareForRecord()
        self.createRequest()
    }
    
    
    
    func notify() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
//            if granted {
//                print("알림 권한 허용됨")
//            } else {
//                print("알림 권한 거부됨", error?.localizedDescription ?? "")
//            }
//        }
        print("notify sended")
        let content = UNMutableNotificationContent()
        content.title = String(localized: "물이 끓고 있어요!")
        content.body = String(localized: "어서 불을 꺼주세요!")
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: "boiling", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let results = result as? SNClassificationResult else { return }
        let confidence_apple: Double
        let confidence_model_kattle: Double
        let confidence_model_water: Double
        let confidence_model_soup: Double
        if let classification = results.classification(forIdentifier: "Boiling") {
            confidence_apple = classification.confidence*100
        } else {
            confidence_apple = 0
        }
        if let classification = results.classification(forIdentifier: "Boiling kattle") {
            confidence_model_kattle = classification.confidence*100
        } else {
            confidence_model_kattle = 0
        }
        if let classification = results.classification(forIdentifier: "Boiling water") {
            confidence_model_water = classification.confidence*100
        } else {
            confidence_model_water = 0
        }
        if let classification = results.classification(forIdentifier: "Boiling soup") {
            confidence_model_soup = classification.confidence*100
        } else {
            confidence_model_soup = 0
        }
//        var temp = [(label: String, confidence: Float)]()
//                let sorted = results.classifications.sorted { (first, second) -> Bool in
//                    return first.confidence > second.confidence
//                }
//                for classification in sorted {
//                    let confidence = classification.confidence * 100
//                    if confidence > 5 {
//                        temp.append((label: classification.identifier, confidence: Float(confidence)))
//                    }
//                }
        DispatchQueue.main.async {
            self.result = [:]
            if confidence_apple > 0 || confidence_model_kattle > 80 || confidence_model_water > 80 || confidence_model_soup > 80  {
                //self.boil = true
                self.boil_count += 1
            } else {
                //self.boil = false
                self.boil_count = 0
            }
//            for item in temp {
//                self.result[item.label] = item.confidence
//                
//            }
            if self.boil_count > 2 {
                self.boil = true
                self.notify()
            }
            self.result["Boiling"] = confidence_apple
            self.result["Boiling kattle"] = confidence_model_kattle
            self.result["Boiling soup"] = confidence_model_soup
            self.result["Boiling water"] = confidence_model_water
        }
        
    }
    
    private func ensureMicrophoneAccess() {
        var hasMicrophoneAccess = false
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            let sem = DispatchSemaphore(value: 0)
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { success in
                hasMicrophoneAccess = success
                sem.signal()
            })
            _ = sem.wait(timeout: DispatchTime.distantFuture)
        case .denied, .restricted:
            break
        case .authorized:
            hasMicrophoneAccess = true
        @unknown default:
            fatalError("unknown authorization status for microphone access")
        }

        if !hasMicrophoneAccess {
            print("No microphone Access")
        }
    }
    
    func prepareForRecord() {
//        let busIndex = AVAudioNodeBus(0)
//        let bufferSize = AVAudioFrameCount(4096)
//        let audioFormat = audioEngine.inputNode.outputFormat(forBus: busIndex)
//        let analyzer = SNAudioStreamAnalyzer(format: audioFormat)
//        
//        self.analyzer = analyzer
//        audioEngine.inputNode.installTap(onBus: busIndex, bufferSize: bufferSize, format: audioFormat) {
//                    [unowned self] (buffer, when) in
//                    self.queue.async {
//                        self.processAudioBuffer(buffer, when: when)
//                    }
//                }
//        startAudioEngine()
    }
    
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer, when: AVAudioTime) {
        guard let floatChannelData = buffer.floatChannelData else {
            return
        }
        
        let channelData = UnsafeBufferPointer(start: floatChannelData[0], count: Int(buffer.frameLength))
        let audioSum = channelData.reduce(0.0) { $0 + abs($1) }
        let averageVolume = audioSum / Float(buffer.frameLength)
        
        // Check if average volume is above a certain threshold
        let threshold: Float = 0.003
        if averageVolume > threshold {
            self.analyzer?.analyze(buffer, atAudioFramePosition: when.sampleTime)
        }
    }
    
    func createRequest() {
        do {
            //let request = try SNClassifySoundRequest(mlModel: BoilingML().model)
            let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
            try analyzer?.add(request, withObserver: self)
            let request1 = try SNClassifySoundRequest(mlModel: BoilingML().model)
            try analyzer?.add(request1, withObserver: self)
        }
        catch {
            print("SN Request Error Occur!")
            print(error.localizedDescription)
        }
    }
    
    private func startAudioEngine() {
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                print("AudioEngine error occur!")
                print(error.localizedDescription)
            }
        }
}
