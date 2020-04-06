//
//  PhotoViewController.swift
//  ArtSense
//
//  Created by Mahum Hashmi on 02/03/2020.
//  Copyright © 2020 Mahum Hashmi. All rights reserved.
//

import UIKit
import Foundation



class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Properties related to Image
    var myImage: UIImage!
    var pixels: [Pixel] = []
    @IBOutlet weak var viewImage: UIImageView!
    
    // Properties related to conversion
    
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
    
    var colorSound = [String : Int]() // Dictionary where the key is a colour in its decimal form, and the value is its corresponding musical note
    
    var pixelSound: [(Int, Int, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takePhoto((Any).self)
        colorSound = ["G": crimson, "F#": magenta, "F": purple, "E": violet, "D#": indigoBlue, "D": blue, "C#": cyan, "C": green, "B": yellowGreen, "A#": yellow, "A": orange, "G#": red]
                
    }

    @IBAction func takePhoto(_ sender: Any) {
          // Check if device can pick a camera
          if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
              let imagePicker = UIImagePickerController()
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
              imagePicker.sourceType = UIImagePickerController.SourceType.camera
              imagePicker.allowsEditing = false
              // show camera controller to user
              self.present(imagePicker, animated: true, completion: nil)
          }
      }
    
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
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage

    }
    
    //https://gist.github.com/bpercevic/3046ffe2b90a6cea8cfd
    
    func pixelData() {
        let resizedImage = self.resizeImage(image: myImage, newWidth: 200)
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
                
                // Convert hexadecimal values of each colour to corresponding decimal value
                let dec = Int(hex, radix: 16)
                self.compareDec(dec: dec!, row: row, col: col)
                
            }
        }
    }
    
    // Before comparison and assigning a note to each pixel, to test first simply create a list of which colour each pixel is closest to.
    // After assigning a colour, assign the note and test sound.
    // Refactor: If sound needs modulation, pick a scale and adjust each assigned note.
    
    func compareDec(dec: Int, row: Int, col: Int) {
        // create a 2D array with coordinates and which colour it is closest to.
        print("dec", dec)
        let closest = colorSound.min { abs($0.1 - dec) < abs($1.1 - dec) }
        pixelSound.append((row, col, closest!.key))
    }
    
    

    
    func toHex(pixel: Pixel, components: [CGFloat]) -> String {
        //https://cocoacasts.com/from-hex-to-uicolor-and-back-in-swift
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
       print(pixels[0])
        
    }
    
}
    


    
    
    

