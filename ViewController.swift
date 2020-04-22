//
//  ViewController.swift
//  ArtSense
//
//  Created by Mahum Hashmi on 13/01/2020.
//  Copyright © 2020 Mahum Hashmi. All rights reserved.
//
// This ViewController class corresponds to the first view page and viewcontroller that is run when the application is launched

import UIKit


class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var takePhoto: DesignableButton! // Button to take a photo
    
    @IBOutlet weak var titleImage: UIImageView! // Image view to display the icon image
    @IBOutlet weak var titleLabel: UILabel! // Label to hold the title 'Welcome to Art Sense'
    
    @IBOutlet weak var uploadPhoto: DesignableButton! // Button to upload a photo
    
    var inputType: String = "" // Variable to check whether input is in the form of capturing an image or uploading one
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Center all the buttons, labels and images on the page
        takePhoto.center = CGPoint(x: view.frame.size.width / 4, y: view.frame.size.height - 130)
        uploadPhoto.center = CGPoint(x: (view.frame.size.width / 2 + view.frame.size.width / 4), y: view.frame.size.height - 130)
        titleLabel.center = CGPoint(x: view.frame.size.width / 2, y: 170)
        titleImage.center = CGPoint(x: view.frame.size.width / 2, y: 370)
        titleImage.image = #imageLiteral(resourceName: "Untitled Diagram (2)")
        
    }
    
    // If the button to take a photo is selected, user is redirected to the second view controller
    // @param sender takes in Any object
    @IBAction func takePhoto(_ sender: Any) {
        inputType = "capture"
        
        // Create an instance of PhotoViewController class and push it onto the Navigation Controller stack
        let photoView = storyboard?.instantiateViewController(identifier: "photoView") as! PhotoViewController
        self.navigationController?.pushViewController(photoView, animated: true)
        
        // set the variable inputType in PhotoViewController class to the value of inputType in this class
        photoView.inputType = inputType
    }
    
    // If the button to upload a photo is selected, user is redirected to the second view controller
    // @param sender takes in Any object
    @IBAction func uploadPhoto(_ sender: Any) {
        inputType = "upload"
        
        // Create an instance of PhotoViewController class and push it onto the Navigation Controller stack
        let photoView = storyboard?.instantiateViewController(identifier: "photoView") as! PhotoViewController
        self.navigationController?.pushViewController(photoView, animated: true)
        
        // set the variable inputType in PhotoViewController class to the value of inputType in this class
        photoView.inputType = inputType
    }
}

// Make the UIView designable in order to make changes to layout
@IBDesignable
class DesignableView: UIView {
    
}

// Make the UIButton designable in order to make changes to layout
@IBDesignable
class DesignableButton: UIButton {
}

// Make the UILabel designable in order to make changes to layout
@IBDesignable
class DesignableLabel: UILabel {
    
}

// Add following extensions to the UIView class
extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                
            }
        }
    }
}

    
    

