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
    
    @IBOutlet weak var check: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var orangeView: UIView!
    
    var lat: Double = 0
    var lon: Double = 0
    
    let savedView = SpringImageView()

    
    override func viewDidLoad() {
        self.check.hidden = false
        self.cancel.hidden = false
        print (lat)
        print (lon)
        
    }
    override func viewWillAppear(animated: Bool) {
        textView.layer.cornerRadius = 10
        orangeView.layer.cornerRadius = 10
        
        let savedImage = UIImage(named: "check")
        self.savedView.image = savedImage
        self.savedView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.savedView.frame = CGRectMake(self.view.center.x, self.view.center.y, 200, 200)
        self.savedView.center = self.view.center
    }
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
        
        }
    }
    @IBAction func checkPressed(sender: AnyObject) {
       // if count(self.textView.text) > 300 {
            
       // }
        view.endEditing(true)
        self.cancel.hidden = true
        self.check.hidden = true
        self.view.addSubview(self.savedView)
        self.view.bringSubviewToFront(self.savedView)
        self.savedView.animation = "zoomIn"
        self.savedView.curve = "easeIn"
        self.savedView.force = 2.9
        self.savedView.duration = 0.7
        self.savedView.animateNext({ () -> () in
            
            let newSugg = PFObject(className: "Suggestions")
            newSugg["text"] = self.textView.text
            newSugg["usersThatSnapped"] = []
            newSugg["location"] = PFGeoPoint(latitude: self.lat, longitude: self.lon)
            newSugg["flag"] = []
            newSugg.saveInBackgroundWithBlock { (Bool, NSError) -> Void in
                
                self.savedView.animateTo()
                
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            }
        })
        
        
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
  
        
    
    
    
}