//
//  PhotoViewController.swift
//  ArtSense
//
//  Created by Mahum Hashmi on 02/03/2020.
//  Copyright © 2020 Mahum Hashmi. All rights reserved.
//
// This PhotoViewController class corresponds to the second view page in the viewcontroller that is run when the user selects either takePhoto or uploadPhoto button in the first viewcontroller
//
// The image taken is processed by extracting pixel values, assigning coordinates and frequencies, adding these to a dictionary and passing it on to the next viewcontroller and viewcontroller class

import UIKit
import Foundation



class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var inputType: String = "" // Input type is taken from the previous ViewController class
    
    
    // Properties related to Image
    var myImage: UIImage! // The image that is either captured via camera or uploaded via gallery
    var pixels: [Pixel] = [] // An array holding values of Structure Pixel
    @IBOutlet weak var viewImage: UIImageView! // The imageView that displays the selected image
    
    
    // Properties related to conversion
    var resizedImage: UIImage! // Image after original image has been resized
    
    @IBOutlet weak var convertImage: DesignableButton!
    
    // Each colour is assigned a decimal RGBA value
    var crimson: Int = 14423100 //#DC143C // G
    var magenta: Int = 16711935//#FF00FF // F#
    var purple: Int = 6950317 //#6A0DAD // F
    var violet: Int = 8323327 //#7F00FF // E
    var indigoBlue: Int = 268847 //#041A2F // D#
    var blue: Int = 255 //#0000FF // D
    var cyan: Int = 65535 //#00FFFF // C#
    var green: Int = 65280 //#00FF00 // C
    var yellowGreen: Int = 10145074 //#9ACD32 // B
    var yellow: Int = 16776960 //#FFFF00 // A#
    var orange: Int = 16753920 //#FFA500 // A
    var red: Int = 16711680 //#FF0000 // G#
    
    // Dictionary where the key is a colour in its decimal form, and the value is its corresponding musical note
    var colorSound = [String : Int]()
    
    // Dictionary where they key is coordinates of Structure Point2D which is the local coordinates of pixels, and the value is the corresponding musical note
    var pixelSound = [Point2D: String]()
    
    // Each musical note is assigned a frequency
    var c: Double = 261.63
    var cSharp: Double = 277.18
    var d: Double = 293.66
    var dSharp: Double = 311.13
    var e: Double = 329.63
    var f: Double = 349.23
    var fSharp: Double = 369.99
    var g: Double = 392.00
    var gSharp: Double = 415.3
    var a: Double = 440
    var aSharp: Double = 466.16
    var b: Double = 493.88

    // Dictionary where they key is musical note name, and the value is its corresponding frequency
    var tones = [String: Double]()
    
    // Dictionary where the key is coordinates of Structure Point2D which is the global coordinates of pixels, and the value is the corresponding frequency it holds
    var finalFreqs = [Point2D : Double]()
    
    var rect = CGRect() // Rectangle for the resized image

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Center convertImage button
        convertImage.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 130)
        
        // Check what the input type is, and trigger corresponding functions accordingly
        if inputType == "capture" {
            takePhoto((Any).self)
        } else if inputType == "upload" {
            uploadPhoto((Any).self)
        }
        
        // Initialise colourSound dictionary
        colorSound = ["G": crimson, "F#": magenta, "F": purple, "E": violet, "D#": indigoBlue, "D": blue, "C#": cyan, "C": green, "B": yellowGreen, "A#": yellow, "A": orange, "G#": red]
         
        // Initialise tones dictionary
        tones = ["C": c, "C#": cSharp, "D": d, "D#": dSharp, "E": e, "F": f, "F#": fSharp, "G": g, "G#": gSharp, "A": a, "A#": aSharp, "B": b]
    }

    // This function checks if a camera is available, and displays it to user if it is
    // @param sender takes in Any object
    @IBAction func takePhoto(_ sender: Any) {
          // Check if device can pick a camera
          if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController() // Create instance of imagePickerController
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = UIImagePickerController.SourceType.camera // Make source type camera
            imagePicker.allowsEditing = false
              
            // show camera controller to user
            self.present(imagePicker, animated: true, completion: nil)
          }
      }
    
    // This function checks if a gallery is available for the user to select a photo from, and displays it to the user if it is
    // @param sender takes in Any object
    @IBAction func uploadPhoto(_ sender: Any) {
        // Check if gallery is available
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController() // Create instance of imagePickerController
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum // Make source type gallery
            imagePicker.allowsEditing = false
            
            // show gallery to user
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // This function selects the image (whether captured or uploaded) and saves it to global variable
    // After dismissing the picker, the image is set to a UIView to be displayed selected image to user
    // @param picker is a UIImagePickerController
    // @param didFinishPickingMediaWithInfo is the information the picker collects
    func imagePickerController( _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
           if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myImage = pickedImage
            picker.dismiss(animated: true, completion: nil)
            viewImage.image = myImage
            pixelData()
           } else {
            print("Something went wrong!")
        }
    }
    
    func toCGImage(image: UIImage) -> CGImage! {
        guard let ciimage = CIImage(image: image) else { return nil }
        let context = CIContext(options: nil)
        return context.createCGImage(ciimage, from: ciimage.extent)
    }


    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        resizedImage = newImage
        return newImage

    }
    
    func resizeImageView(resizedImage: UIImage) {
        viewImage.frame.size = CGSize(width: resizedImage.size.width, height: resizedImage.size.height)
        viewImage.center = CGPoint(x: view.frame.size.width / 2, y:view.frame.size.height / 2)
        
    }
    
    //https://gist.github.com/bpercevic/3046ffe2b90a6cea8cfd
    
    func pixelData() {
        print("pixelData()")
        let start = CFAbsoluteTimeGetCurrent()
        let resizedImage = self.resizeImage(image: myImage, newWidth: 280)
        self.resizeImageView(resizedImage: resizedImage)
        
        let cgimage = self.toCGImage(image: resizedImage)
        
        let bmp = cgimage!.dataProvider!.data
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(bmp)
        var r, g, b, a: UInt8
        
        
        
        for row in 0..<Int(cgimage!.height) {
            for col in 0..<Int(cgimage!.width) {
                r = data.pointee
                data = data.advanced(by: 1)
                g = data.pointee
                data = data.advanced(by: 1)
                b = data.pointee
                data = data.advanced(by: 1)
                a = data.pointee
                data = data.advanced(by: 1)
                
                pixels.append(Pixel(r: r, g: g, b: b, a: a, row: row, col: col))
                
                let color = Pixel(r: r, g: g, b: b, a: a, row: row, col: col).color
                let components: [CGFloat] = color.cgColor.components!
                // Convert colour to hexadecimal by using RGBA component values
                let hex = self.toHex(pixel: Pixel(r: r, g: g, b: b, a: a, row: row, col: col), components: components)
                let dec = Int(hex, radix: 16)
                
                // Convert points
                let point = CGPoint(x: row, y: col)
                let newPoint = view.convert(point, from: viewImage)
                // Convert hexadecimal values of each colour to corresponding decimal value
                
                self.compareDec(dec: dec!, point: newPoint)
                
            }
        }
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Took \(diff) seconds")
    }
    

    
    // Before comparison and assigning a note to each pixel, to test first simply create a list of which colour each pixel is closest to.
    // After assigning a colour, assign the note and test sound.
    // Refactor: If sound needs modulation, pick a scale and adjust each assigned note.
    
    func compareDec(dec: Int, point: CGPoint) {
        // create a 2D array with coordinates and which colour it is closest to.
        let closest = colorSound.min { abs($0.1 - dec) < abs($1.1 - dec) }
        
        
        let newPoint = Point2D(x: point.x, y: point.y)
        
        pixelSound.updateValue(closest!.key, forKey: newPoint)
    }
    
    func setClosestFreq() {
        print("setClosestFreq()")
        let start = CFAbsoluteTimeGetCurrent()
        for p in pixelSound {
            let sound = p.1
            let freq = Double(tones[sound]!)
            finalFreqs.updateValue(freq, forKey: p.0)

        }
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Took \(diff) seconds")
    }

    // Convert RGBA values to hexadecimal
    // This function takes in the pixel and its RGBA components
    // This function returns a type String of the converted hexadecimal
    // https://cocoacasts.com/from-hex-to-uicolor-and-back-in-swift
    func toHex(pixel: Pixel, components: [CGFloat]) -> String {
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a = Float(components[3])
        
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
    }
    
   
    struct Pixel {
            var r: Float
            var g: Float
            var b: Float
            var a: Float
            var row: Int
            var col: Int
            
            init(r: UInt8, g:UInt8, b: UInt8, a: UInt8, row: Int, col: Int) {
                self.r = Float(r)
                self.g = Float(g)
                self.b = Float(b)
                self.a = Float(a)
                self.row = row
                self.col = col
            }
            
            var color: UIColor {
                return UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: CGFloat(a/255.0))
            }
            
            var description: String {
                return "RGBA(\(r), \(g), \(b), \(a)"
            }
        }
    


    
    @IBAction func convertImage(_ sender: Any) {
        let soundCont = self.storyboard?.instantiateViewController(identifier: "soundCont") as! SoundController
        self.navigationController?.pushViewController(soundCont, animated: true)
        self.setClosestFreq()
        
        
        soundCont.myImage = resizedImage
        soundCont.imageCoordFreqs = finalFreqs
        
        
        
                
    
    }
}

struct Point2D: Hashable{
    var x : CGFloat = 0.0
    var y : CGFloat = 0.0

    var hashInto: Int {
        return "(\(x),\(y))".hashValue
    }

    static func == (lhs: Point2D, rhs: Point2D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

 

    
    
    

