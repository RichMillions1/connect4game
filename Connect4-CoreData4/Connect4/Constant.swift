//
//  Constant.swift
//  Connect4
//
//  Created by Weimin Sun on 05/12/2022.
//

import Foundation
import UIKit

//Screen width and height
var KscreenW = UIScreen.main.bounds.size.width
var KscreenH = UIScreen.main.bounds.size.height
//Disc width and height
let discsWH = KscreenW/7.0
//Hollow width and height
let holeWH = KscreenW/7.0 - 10
let yellowColor1 = UIColor.init(0xFFFF00FF)
let yellowColor2 = UIColor.init(0xB8860BFF)//Borders
let redColor1 = UIColor.init(0xFF0000FF)
let redColor2 = UIColor.init(0xCD2626FF)//Borders

struct Constants {
    static let bubbleSize = CGSize.init(width: discsWH, height: discsWH)
}

//Get the program's main window
func getRootWindow() -> UIWindow {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return UIWindow() }
    return window
    
}

//Alert pop-ups
func showAlertVC(title: String, message: String)  {
    //Creating a pop-up controller
    let  alertController = UIAlertController.init(title: title, message:message , preferredStyle: .alert);
    // Creating actions
    let actionOne = UIAlertAction.init(title: "Cancel", style: .default)

    // Adding confirmation actions to pop-up controllers
    alertController.addAction(actionOne)
    // Main window display (modal) pop-up controller
    getRootWindow().rootViewController?.present(alertController, animated: true, completion: nil)
}
//Alert pop-ups
func showAlertVC(title: String, message: String, handler: (()->())?)  {
    //Creating a pop-up controller
    let  alertController = UIAlertController.init(title: title, message:message , preferredStyle: .alert);
    // Creating actions
    let actionOne = UIAlertAction.init(title: "Cancel", style: .cancel)
    
    let actionTwo = UIAlertAction.init(title: "Sure", style: .default){
      _ in
        handler?()
    }
    // Adding confirmation actions to pop-up controllers
    alertController.addAction(actionOne)
    alertController.addAction(actionTwo)
    // Main window display (modal) pop-up controller
    getRootWindow().rootViewController?.present(alertController, animated: true, completion: nil)
}

//show Alert viewController
func showAlertVC(message:String,handler: ((_ index:Int)->())?)  {
    //Creating a pop-up controller
    let  alertController = UIAlertController.init(title: "", message:message , preferredStyle: .alert);
    // Creating actions
    let actionOne = UIAlertAction.init(title: "You", style: .default){
      _ in
        handler?(1)
    }
    
    let actionTwo = UIAlertAction.init(title: "α-C4 Bot", style: .default){
      _ in
        handler?(2)
    }
    // Adding confirmation actions to pop-up controllers
    alertController.addAction(actionOne)
    alertController.addAction(actionTwo)
    // Main window display (modal) pop-up controller
    getRootWindow().rootViewController?.present(alertController, animated: true, completion: nil)
}


extension UIColor {
    static var randomColor: UIColor {
        let randomHue = CGFloat.random(in: 0..<1)
        return UIColor(hue: randomHue, saturation: 1.0, brightness: 1.0, alpha: 0.5)
    }
}


extension UIColor {
    
    public convenience init(_ rgba: UInt32) {
        self.init(red: CGFloat(Int(rgba >> 24) & 0xFF) / 255.0,
                  green: CGFloat(Int(rgba >> 16) & 0xFF) / 255.0,
                  blue: CGFloat(Int(rgba >> 8) & 0xFF) / 255.0,
                  alpha: CGFloat(rgba & 0xFF) / 255.0)
    }
}
