//
//  SoundController.swift
//  ArtSense
//
//  Created by Mahum Hashmi on 08/04/2020.
//  Copyright © 2020 Mahum Hashmi/Users/mahumhashmi/Documents/YEAR3/PROJECT/ArtSense/ArtSense/AudioKit/iOS/AudioKit For iOS.xcodeproj. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
//import AudioUnit




// https://stackoverflow.com/questions/55572894/produce-sounds-of-different-frequencies-in-swift
class SoundController: UIViewController, UINavigationControllerDelegate {
    var myImage: UIImage!

    @IBOutlet weak var home: DesignableButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    var imageCoordFreqs = [Point2D: Double]()
    
    
    
    private lazy var parameterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Frequency: 0 Hz   Amplitude: 0%"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var waveformSelectorSegmentedControl: UISegmentedControl = {
        var images = [ #imageLiteral(resourceName: "icons8-sine-26.png"), #imageLiteral(resourceName: "icons8-triangle-24.png"), #imageLiteral(resourceName: "icons8-audio-wave-24"), #imageLiteral(resourceName: "icons8-square-24"), #imageLiteral(resourceName: "icons8-cleanup-noise-80")]
        var offset = UIOffset(horizontal: 30, vertical: 40)
        
        images = images.map { $0.resizableImage(withCapInsets: .init(top: 0, left: 10, bottom: 0, right: 10), resizingMode: .stretch) }
        let segmentedControl = UISegmentedControl(items: images)
        segmentedControl.setContentPositionAdjustment(.zero, forSegmentType: .any, barMetrics: .default)
        segmentedControl.addTarget(self, action: #selector(updateOscillatorWaveform), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor =  UIColor(red: 0.1176470588, green: 0.5647058824, blue: 1, alpha: 1)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        return segmentedControl
    }()
    
    

    override func viewDidLoad() {
        //myImage.accessibilityTraits = accessibilityRespondsToUserInteraction
        
        home.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 130)
        
        
        self.resizeImageView()
        
        
        //super.viewDidLoad()
        setUpView()
        setUpSubviews()
        imageView.image = myImage
        
    }
    
    func resizeImageView() {
        imageView.frame.size = CGSize(width: myImage.size.width, height: myImage.size.height)
    
        imageView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        
        
    }
    
    
  
    private func setUpView() {
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.isMultipleTouchEnabled = false
    }
    
    private func setUpSubviews() {
        view.addSubview(waveformSelectorSegmentedControl)
        view.addSubview(parameterLabel)
        
        NSLayoutConstraint.activate([ waveformSelectorSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), waveformSelectorSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10), waveformSelectorSegmentedControl.widthAnchor.constraint(equalToConstant: 250), parameterLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20), parameterLabel.centerYAnchor.constraint(equalTo: waveformSelectorSegmentedControl.centerYAnchor, constant: 30)])
        
        
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window.windowScene = windowScene
        window.rootViewController = PhotoViewController()
        window.makeKeyAndVisible()
    }
    
    @objc private func updateOscillatorWaveform() {
        let waveform = Waveform(rawValue: waveformSelectorSegmentedControl.selectedSegmentIndex)
        switch waveform {
            case .sine: Synth.shared.setWaveformTo(Oscillator.sine)
            case .triangle: Synth.shared.setWaveformTo(Oscillator.triangle)
            case .sawtooth: Synth.shared.setWaveformTo(Oscillator.sawtooth)
            case .square: Synth.shared.setWaveformTo(Oscillator.square)
            case .whiteNoise: Synth.shared.setWaveformTo(Oscillator.whiteNoise)
            default: break
        }
    }
    
    @objc private func setPlaybackStateTo(_ state: Bool) {
        Synth.shared.volume = state ? 0.5: 0
    }
    
    // Implement Touches Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setPlaybackStateTo(true)
        guard let touch = touches.first else { return }
        let coord = touch.location(in: view)
        setSynthParametersFrom(coord)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let coord = touch.location(in: view)
        setSynthParametersFrom(coord)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setPlaybackStateTo(false)
        parameterLabel.text = "Frequency: 0 Hz  Amplitude: 0%"
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        setPlaybackStateTo(false)
        parameterLabel.text = "Frequency: 0 Hz  Amplitude: 0%"
    }
    
   
    
    func getFrequency(point: CGPoint) -> Double {
        let rangeX = (point.x-1.0) ... (point.x+1.0)
        let rangeY = (point.y-1.0) ... (point.y+1.0)
        
        var freq: Double = 0.0
        
        for coord in imageCoordFreqs.keys {
            //print(coord.x)
            if rangeX.contains(coord.x) {
                if rangeY.contains(coord.y) {
                    freq = imageCoordFreqs[Point2D(x: coord.x, y: coord.y)]!
                }
            } 
        }
        return freq
    }
            
    private func setSynthParametersFrom(_ coord: CGPoint) {
        Oscillator.amplitude = Float((view.bounds.height - coord.y) / view.bounds.height)
        Oscillator.frequency = Float(self.getFrequency(point: coord))
        let amplitudePercent = Int(Oscillator.amplitude * 100)
        let frequencyHertz = Int(Oscillator.frequency)
        parameterLabel.text = "Frequency: \(frequencyHertz) Hz  Amplitude: \(amplitudePercent)%"
        
    }
    
//    @IBAction func backToCam(_ sender: Any) {
//        let photoView = self.storyboard?.instantiateViewController(identifier: "photoView") as! PhotoViewController
//        
//        self.navigationController?.pushViewController(photoView, animated: true)
//    
//    }
    
    @IBAction func home(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "mainController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


class Synth {
    public static let shared = Synth()
    //shared.accessabilityTraits = UIAccessabilityTraitAllowsDirectInteraction
    
    public var volume: Float {
        set {
            audioEngine.mainMixerNode.outputVolume = newValue
        }
        get {
            return audioEngine.mainMixerNode.outputVolume
        }
    }
    
    private var audioEngine: AVAudioEngine
    private var time: Float = 0
    private let sampleRate: Double
    private let deltaTime: Float
    
    private lazy var sourceNode = AVAudioSourceNode { (_, _, frameCount, audioBufferList) -> OSStatus in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
        for frame in 0..<Int(frameCount) {
            let sampleVal = self.signal(self.time)
            self.time += self.deltaTime
            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = sampleVal
            }
        }
        return noErr
    }
    
    private var signal: Signal
    
    init(signal: @escaping Signal = Oscillator.sine) {
        
        audioEngine = AVAudioEngine()
        
        let mainMixer = audioEngine.mainMixerNode
        let outputNode = audioEngine.outputNode
        let format = outputNode.inputFormat(forBus: 0)
        
        sampleRate = format.sampleRate
        deltaTime = 1 / Float(sampleRate)
        
        self.signal = signal
        
        let inputFormat = AVAudioFormat(commonFormat: format.commonFormat, sampleRate: sampleRate, channels: 1, interleaved: format.isInterleaved)
        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 0
        do {
            try audioEngine.start()
        } catch {
            print("Count not start engine: \(error.localizedDescription)")
        }
    }
    
    public func setWaveformTo(_ signal: @escaping Signal) {
        self.signal = signal
    }
}

enum Waveform: Int {
    case sine, triangle, sawtooth, square, whiteNoise
}

struct Oscillator {
    static var amplitude: Float = 1
    static var frequency: Float = 440 // 261.63
    
    static let sine = { (time: Float) -> Float in
        return Oscillator.amplitude * sin(2.0 * Float.pi * Oscillator.frequency * time)
    }
    
    static let triangle = { (time: Float) -> Float in
        let period = 1.0 / Double(Oscillator.frequency)
        let currentTime = fmod(Double(time), period)
        let value = currentTime / period
        
        var result = 0.0
        if value < 0.25 {
            result = value * 4
        } else if value < 0.75 {
            result = 2.0 - (value * 4.0)
        } else {
            result = value * 4 - 4.0
        }
        return Oscillator.amplitude * Float(result)
    }
    
    static let sawtooth = { (time: Float) -> Float in
        let period = 1.0 / Oscillator.frequency
        let currentTime = fmod(Double(time), Double(period))
        return Oscillator.amplitude * ((Float(currentTime) / period) * 2 - 1.0)
    }
    
    static let square = { (time: Float) -> Float in
        let period = 1.0 / Double(Oscillator.frequency)
        let currentTime = fmod(Double(time), period)
        return ((currentTime / period) < 0.5) ? Oscillator.amplitude : -1.0 * Oscillator.amplitude
    }
    
    static let whiteNoise = { (time: Float) -> Float in
        return Oscillator.amplitude * Float.random(in: -1...1)
    }
}

typealias Signal = (Float) -> (Float)

 
