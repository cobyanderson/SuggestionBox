//
//  NewViewController.swift
//  SuggestionBox
//
//  Created by Samuel Coby Anderson on 11/15/15.
//  Copyright © 2015 Samuel Coby Anderson. All rights reserved.
//
import Parse
import Foundation
import UIKit

class newViewController: UIViewController {
    
    @IBOutlet weak var cancel: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    var lat: Double = 0
    var lon: Double = 0
    
    override func viewDidLoad() {
        print (lat)
        print (lon)
    }
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
        
        }
    }
    @IBAction func checkPressed(sender: AnyObject) {
        //if self.textView.text.rang
        let newSugg = PFObject(className: "Suggestions")
        newSugg["text"] = self.textView.text
        newSugg["usersThatSnapped"] = []
        newSugg["location"] = PFGeoPoint(latitude: lat, longitude: lon)
        newSugg.saveInBackgroundWithBlock { (Bool, NSError) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
    
    
    }
    
        
    
    
    
}