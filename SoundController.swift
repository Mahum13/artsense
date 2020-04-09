//
//  SoundController.swift
//  ArtSense
//
//  Created by Mahum Hashmi on 08/04/2020.
//  Copyright © 2020 Mahum Hashmi. All rights reserved.
//

import Foundation
import UIKit

class SoundController: UIViewController, UINavigationControllerDelegate {
    var pixelSound: [(Int, Int, String)] = []
   
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        print(pixelSound[0], pixelSound[1], pixelSound[2])
        let myUnit = ToneOutputUnit()
        
        let vol = AVAudioSession.sharedInstance().outputVolume
        myUnit.setFrequency(freq: 10000)
        myUnit.setToneVolume(vol: Double(vol))
        myUnit.enableSpeaker()
        myUnit.setToneTime(t: 20000)
        
        
    }
    
}

import AudioUnit
import AVFoundation

final class ToneOutputUnit: NSObject {
    var auAudioUnit: AUAudioUnit? = nil
    
    var avActive = false // AVAudioSessionn active flag
    var audioRunning = false // RemoteIO Audio Unit running flag
    
    var sampleRate: Double = 44100.0 // Typical audio sample rate
    
    var f0 = 880.0 // default frequency of tone "A"
    var v0 = 16383.0 // default volume of tone: hhalf full scale
    
    var toneCount: Int32 = 0 // number of samples of tones to play. 0 for silence
    
    private var phY = 0.0 // save phase of sine wave to prevent clicking
    private var interrupted = false // for restart from audio interruption notification
    
    // Audio frequencies below 500 Hz may be hahrd to hear from iPhone speaker
    func setFrequency(freq: Double) {
        f0 = freq
    }
    
    func setToneVolume(vol: Double) {
        v0 = vol * 32766.0 // 0.0 to 1.0
    }
    
    func setToneTime(t: Double) {
        toneCount = Int32(t * sampleRate)
    }
    
    func enableSpeaker() {
        if audioRunning {
            print("returned")
            return // return if RemoteIO is already running
        }
        
        do { // not running, so start hardware
            let audioComponentDescription = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_RemoteIO, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
            
            if auAudioUnit == nil {
                try auAudioUnit = AUAudioUnit(componentDescription: audioComponentDescription)
                
                let bus0 = auAudioUnit?.inputBusses[0]
                
                // short int samples
                // interleaved stereo
                let audioFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: Double(sampleRate), channels: AVAudioChannelCount(2), interleaved: true)
                
                try bus0?.setFormat(audioFormat ?? AVAudioFormat()) // for speaker bus
                
                // AURenderPullInputBlock?
                auAudioUnit?.outputProvider = { (actionFlags, timestamp, frameCount, inputBusNumber, inputDataList) -> AUAudioUnitStatus in self.fillSpeakerBuffer(inputDataList: inputDataList, frameCount: frameCount)
                    return 0
            }
        }
        
            auAudioUnit?.isOutputEnabled = true
            toneCount = 0
            
            try auAudioUnit?.allocateRenderResources() // v2 AudioUnitInitialize()
            try auAudioUnit?.startHardware() // v2 AudioOutputUnitStart()
            audioRunning = true
        } catch {
            print("error 2 \(error)")
        }
    
    }

    // Process RemoteIO Buffer for output
    private func fillSpeakerBuffer(inputDataList: UnsafeMutablePointer<AudioBufferList>, frameCount: UInt32) {
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let nBuffers = inputDataPtr.count
        
        if nBuffers > 0 {
            let mBuffers: AudioBuffer = inputDataPtr[0]
            let count = Int(frameCount)
            
            // Speaker Output == play tone at frequency f0
            if (self.v0 > 0) && (self.toneCount > 0) {
                // audioStalled = false
                var v = self.v0
                if v > 32767 {
                    v = 32767
                }
                
                let sz = Int(mBuffers.mDataByteSize)
                
                var a = self.phY // capture from object for use inside block
                let d = 2.0 * Double.pi * self.f0 / self.sampleRate // phase delta
                
                let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
                if var bptr = bufferPointer {
                    for i in 0..<(count) {
                        let u = sin(a) // create a sine wave
                        a += d
                        if (a > 2.0 * Double.pi) {
                            a -= 2.0 * Double.pi
                        }
                        let x = Int16(v * u + 0.5) // scale and round
                        
                        if (i < (sz/2)) {
                            bptr.assumingMemoryBound(to: Int16.self).pointee = x
                            bptr += 2 // increment by 2 bytes for nnext Int16 item
                            bptr.assumingMemoryBound(to: Int16.self).pointee = x
                            bptr += 2 // stereo, so fill both Left and Right channels
                        }
                    }
                }
                
                self.phY = a // save sine wave
                self.toneCount -= Int32(frameCount) // decrement time remaining
            } else {
                // audioStalled = true
                memset(mBuffers.mData, 0, Int(mBuffers.mDataByteSize)) // silence
            }
        }
        
    }


    func stop() {
        if (audioRunning) {
            auAudioUnit?.stopHardware()
            audioRunning = false
        }
    }
}
