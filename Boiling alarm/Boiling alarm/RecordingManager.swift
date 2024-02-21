//
//  RecordingManager.swift
//  Boiling alarm
//
//  Created by 안병욱 on 2/16/24.
//

import Foundation
import AVFoundation
import SoundAnalysis

import AVFoundation

//class AudioProcessor {
//    let audioEngine = AVAudioEngine()
//    let audioInputNode = AVAudioInputNode()
//    
//    var bufferSize: AVAudioFrameCount = 512
//    var audioFormat: AVAudioFormat!
//    
//    init() {
//        audioFormat = audioInputNode.inputFormat(forBus: 0)
//        audioEngine.attach(audioInputNode)
//        let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
//        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)!
//        
//        audioEngine.connect(audioInputNode, to: audioEngine.mainMixerNode, format: format)
//        audioInputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { (buffer, time) in
//            // Process audio buffer here
//            self.processAudioBuffer(buffer)
//        }
//        
//        try! audioEngine.start()
//    }
//    
//    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
//        guard let floatChannelData = buffer.floatChannelData else {
//            return
//        }
//        
//        let channelData = UnsafeBufferPointer(start: floatChannelData[0], count: Int(buffer.frameLength))
//        let audioSum = channelData.reduce(0.0) { $0 + abs($1) }
//        let averageVolume = audioSum / Float(buffer.frameLength)
//        
//        // Check if average volume is above a certain threshold
//        let threshold: Float = 0.5
//        if averageVolume > threshold {
//            // Do something with the buffer
//            print("Detected audio above threshold")
//        }
//    }
//}

// Usage
//let audioProcessor = AudioProcessor()




class RecordingManager: NSObject, SNResultsObserving, ObservableObject{
    
    @Published var result: [String] = []
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }
        let topClasification = classificationResult.classifications.map{$0.description}
        let timeRange = classificationResult.timeRange
        self.result = topClasification
    }
    
    override init() { }
    
    /// A dispatch queue to asynchronously perform analysis on.
    private let analysisQueue = DispatchQueue(label: "com.example.apple-samplecode.classifying-sounds.AnalysisQueue")

    /// An audio engine the app uses to record system input.
    private var audioEngine: AVAudioEngine?

    /// An analyzer that performs sound classification.
    private var analyzer: SNAudioStreamAnalyzer?
    
    enum SystemAudioClassificationError: Error {

        /// The app encounters an interruption during audio recording.
        case audioStreamInterrupted

        /// The app doesn't have permission to access microphone input.
        case noMicrophoneAccess
    }
    
    private var retainedObservers: [SNResultsObserving]?
    /// Requests permission to access microphone input, throwing an error if the user denies access.
    private func ensureMicrophoneAccess() throws {
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
            throw SystemAudioClassificationError.noMicrophoneAccess
        }
    }

    /// Configures and activates an AVAudioSession.
    ///
    /// If this method throws an error, it calls `stopAudioSession` to reverse its effects.
    private func startAudioSession() throws {
        stopAudioSession()
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            stopAudioSession()
            throw error
        }
    }

    /// Deactivates the app's AVAudioSession.
    private func stopAudioSession() {
        autoreleasepool {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setActive(false)
        }
    }
    /// Stops observing for audio recording interruptions.
    private func stopListeningForAudioSessionInterruptions() {
        NotificationCenter.default.removeObserver(
          self,
          name: AVAudioSession.interruptionNotification,
          object: nil)
        NotificationCenter.default.removeObserver(
          self,
          name: AVAudioSession.mediaServicesWereLostNotification,
          object: nil)
    }

    private func startAnalyzing(_ requestsAndObservers: [(SNRequest, SNResultsObserving)]) throws {
        stopAnalyzing()

        do {
            try startAudioSession()

            try ensureMicrophoneAccess()

            let newAudioEngine = AVAudioEngine()
            audioEngine = newAudioEngine

            let busIndex = AVAudioNodeBus(0)
            let bufferSize = AVAudioFrameCount(4096)
            let audioFormat = newAudioEngine.inputNode.outputFormat(forBus: busIndex)

            let newAnalyzer = SNAudioStreamAnalyzer(format: audioFormat)
            analyzer = newAnalyzer
            let request = try SNClassifySoundRequest(mlModel: BoilingML().model)
            try analyzer?.add(request, withObserver: self)

            try requestsAndObservers.forEach { try newAnalyzer.add($0.0, withObserver: $0.1) }
            retainedObservers = requestsAndObservers.map { $0.1 }

            newAudioEngine.inputNode.installTap(
              onBus: busIndex,
              bufferSize: bufferSize,
              format: audioFormat,
              block: { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                  self.analysisQueue.async {
                      newAnalyzer.analyze(buffer, atAudioFramePosition: when.sampleTime)
                  }
              })

            try newAudioEngine.start()
        } catch {
            stopAnalyzing()
            throw error
        }
    }
    /// Stops the active sound analysis and resets the state of the class.
    private func stopAnalyzing() {
        autoreleasepool {
            if let audioEngine = audioEngine {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
            }

            if let analyzer = analyzer {
                analyzer.removeAllRequests()
            }

            analyzer = nil
            retainedObservers = nil
            audioEngine = nil
        }
        stopAudioSession()
    }
    
    /// Stops any active sound classification task.
    func stopSoundClassification() {
        stopAnalyzing()
        stopListeningForAudioSessionInterruptions()
    }

    func start() {
        
    }
}
