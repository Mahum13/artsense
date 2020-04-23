//
//  SoundController.swift
//  ArtSense
//
//  Created by Mahum Hashmi on 08/04/2020.
//  Copyright © 2020 Mahum Hashmi. All rights reserved.
//
// This SoundController class corresponds to the third view page in the viewcontroller that that is run when the user selects 'Convert' in the second viewcontroller
//
// The processed image is displayed back to the user, and has a synthesiser imposed on top of it, to allow tactile interaction
// Every point that is tapped outputs the corresponding frequency
//
// This file also contains Synthesiser class which deals with outputting audio
// There are controls to change the type of audio that is being heard by alternating between five types of Oscillators

import Foundation
import UIKit
import AVFoundation



class SoundController: UIViewController, UINavigationControllerDelegate {
    var myImage: UIImage! // The resized image from the previous viewcontroller

    @IBOutlet weak var home: DesignableButton! // Home button to redirect to main page
    @IBOutlet weak var imageView: UIImageView! // UIImage view that holds resized image
    
    // Dictionary where the key is a coordinate of a pixel in the global reference frame, and value is the corresponding frequency
    var imageCoordFreqs = [Point2D: Double]()
    
    
    // The label which displays the current frequency and amplitude being outputted
    private lazy var parameterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Frequency: 0 Hz   Amplitude: 0%"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // A selector to choose between the five different types of oscillations
    private lazy var waveformSelectorSegmentedControl: UISegmentedControl = {
        var images = [ #imageLiteral(resourceName: "icons8-sine-26.png"), #imageLiteral(resourceName: "icons8-triangle-24.png"), #imageLiteral(resourceName: "icons8-audio-wave-24"), #imageLiteral(resourceName: "icons8-square-24"), #imageLiteral(resourceName: "icons8-cleanup-noise-80")] // Add images for each corresponding waveform
        var offset = UIOffset(horizontal: 30, vertical: 40)
        
        images = images.map { $0.resizableImage(withCapInsets: .init(top: 0, left: 10, bottom: 0, right: 10), resizingMode: .stretch) }
        
        let segmentedControl = UISegmentedControl(items: images) // Create UISegmentedControl holding the images of waveforms
        segmentedControl.setContentPositionAdjustment(.zero, forSegmentType: .any, barMetrics: .default)
        segmentedControl.addTarget(self, action: #selector(updateOscillatorWaveform), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor =  UIColor(red: 0.1176470588, green: 0.5647058824, blue: 1, alpha: 1)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        return segmentedControl
    }()
    
    

    override func viewDidLoad() {
        home.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 130) // Center Home button
        
        setUpView()
        setUpSubviews()
        
        self.resizeImageView() // Resize UIImageView holding image
        imageView.image = myImage
    }
    
    // This function resizes the UIImageView according to the image it holds
    func resizeImageView() {
        imageView.frame.size = CGSize(width: myImage.size.width, height: myImage.size.height)
        imageView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2) // Center UIImageView
    }
    
    
    // This function sets up main view
    private func setUpView() {
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.isMultipleTouchEnabled = false
    }
    
    // This function adds subviews to main view and adjusts its layout
    private func setUpSubviews() {
        view.addSubview(waveformSelectorSegmentedControl)
        view.addSubview(parameterLabel)
        
        NSLayoutConstraint.activate([ waveformSelectorSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), waveformSelectorSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10), waveformSelectorSegmentedControl.widthAnchor.constraint(equalToConstant: 250), parameterLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20), parameterLabel.centerYAnchor.constraint(equalTo: waveformSelectorSegmentedControl.centerYAnchor, constant: 30)])
    }
    
    // This function sets up a scene according to the window
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window.windowScene = windowScene
        window.rootViewController = PhotoViewController()
        window.makeKeyAndVisible()
    }
    
    // This function updates which waveform is currently being used according to a UISegmentedControl selection
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
    
    // This functions allows the synthesiser to be switched on and off
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
    
   
    // This function iterates through the dictionary imageCoordFreqs and retrieves corresponding frequency of the coordinate that is being looked at
    // Since the tapped coordinate is specific to several decimal points, a range of +1 and -1 floating point to coordinate in consideration is created , and if any value from this range is in imageCoordFreqs, get the corresponding frequency
    // @param point is the coordinate in consideration
    // @return Double is the frequency to be outputted
    func getFrequency(point: CGPoint) -> Double {
        let rangeX = (point.x-1.0) ... (point.x+1.0) // Look in +1 and -1 direction from x coordinate
        let rangeY = (point.y-1.0) ... (point.y+1.0) // Look in +1 and -1 direction from y coordinate
    
        var freq: Double = 0.0
     
        // For each coordiante in imageCoordFreq, get frequency
        for coord in imageCoordFreqs.keys {
            if rangeX.contains(coord.x) {
                if rangeY.contains(coord.y) {
                    freq = imageCoordFreqs[Point2D(x: coord.x, y: coord.y)]!
                }
            } 
        }
        return freq
    }
            
    // This function sets the parameters for the Synthesiser
    // @param coord is the coordinate in consideration
    private func setSynthParametersFrom(_ coord: CGPoint) {
        Oscillator.amplitude = Float((view.bounds.height - coord.y) / view.bounds.height) // Calculate amplitude
        Oscillator.frequency = Float(self.getFrequency(point: coord)) // Get frequency of coordinate
        let amplitudePercent = Int(Oscillator.amplitude * 100) // Convert amplitude to percentage
        let frequencyHertz = Int(Oscillator.frequency) // Get frequency in Hz
        parameterLabel.text = "Frequency: \(frequencyHertz) Hz  Amplitude: \(amplitudePercent)%" // Display information in label
        
    }
    
    // When the Home button is tapped, redirect user to main page of application
    @IBAction func home(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "mainController") as! ViewController // Create instance of ViewController
        self.navigationController?.pushViewController(vc, animated: true) // Push ViewController onto Navigation Controller stack
    }
}

// This Synth class creates a synthesiser which is imposed onto the image, allowing tactile interaction and creating audio output
// The basic mechanism is: sourceNode -> mainMixer -> outputNode
//
// https://medium.com/better-programming/building-a-synthesizer-in-swift-866cd15b731
class Synth {
    public static let shared = Synth() // Create a shared instance of Synth class
    
    // Get or set volume for output
    public var volume: Float {
        set {
            audioEngine.mainMixerNode.outputVolume = newValue
        }
        get {
            return audioEngine.mainMixerNode.outputVolume
        }
    }
    
    private var audioEngine: AVAudioEngine // Instance of Audio Engine
    private var time: Float = 0
    private let sampleRate: Double
    private let deltaTime: Float // Change in time
    
    // Source node for the output
    private lazy var sourceNode = AVAudioSourceNode { (_, _, frameCount, audioBufferList) -> OSStatus in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList) // Pointer to Audio Buffer List
        for frame in 0..<Int(frameCount) { // For each frame
            let sampleVal = self.signal(self.time)
            self.time += self.deltaTime
            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = sampleVal
            }
        }
        return noErr
    }
    
    private var signal: Signal // Create instance of Signal
    
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

// All the cases of waverforms
enum Waveform: Int {
    case sine, triangle, sawtooth, square, whiteNoise
}

// Structure Oscillator which calculates waves for different types of waveforms: Sine, Sawtooth, Triange, Square, White Noise 
struct Oscillator {
    static var amplitude: Float = 1
    static var frequency: Float = 440
    
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

 
