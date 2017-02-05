//
//  Extensions.swift
//  WaveTalk
//
//  Created by Anton Makarov on 28.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit


//////////////////////////////////////////////
// Text Field

extension UITextField {
    func setBorderBottom() {
        let borderBottom = CALayer()
        let borderWidth = CGFloat(2.0)
        borderBottom.borderColor = UIColor(red: 80/255.0, green: 114/255.0, blue: 153/255.0, alpha: 100.0/100.0).cgColor
        borderBottom.frame = CGRect(x: 0, y: self.frame.height - 1.0, width: self.frame.width , height: self.frame.height - 1.0)
        borderBottom.borderWidth = borderWidth
        self.layer.addSublayer(borderBottom)
        self.layer.masksToBounds = true
    }
}

//////////////////////////////////////////////
// View Controller

extension UIViewController {
    func hideKeyboard() {
        
        //FIXME: Fix hiding the keyboard by pressing the screen
        //Now this is done in part, because lost access to the cells of the table
        //Only by pressing "Return"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        
        //view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
