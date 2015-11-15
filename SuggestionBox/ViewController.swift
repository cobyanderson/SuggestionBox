//
//  ViewController.swift
//  SuggestionBox
//
//  Created by Samuel Coby Anderson on 11/14/15.
//  Copyright © 2015 Samuel Coby Anderson. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    
    @IBOutlet weak var newSuggestion: UIButton!
    @IBOutlet weak var suggestionsTableView: UITableView!
    
    var suggestionList: [String] = []
    var suggestionSnapsList: [[String]] = []
    
    var myLat: Double = 0.0
    var myLon: Double = 0.0
    
    let locationManager = CLLocationManager()
    
    let loadingView = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewWillAppear(animated: Bool) {
        self.loadingView.center = self.view.center
        self.loadingView.frame = self.view.frame
        self.loadingView.backgroundColor = UIColor.blackColor()
        self.loadingView.alpha = 0.3
        self.view.addSubview(loadingView)
        
        
        activityIndicator.center = self.loadingView.center
        self.loadingView.addSubview(activityIndicator)
        
        self.view.bringSubviewToFront(activityIndicator)
        logIn()
    }
    func load() {
        self.view.addSubview(loadingView)
        self.view.bringSubviewToFront(loadingView)
        self.activityIndicator.startAnimating()
    }
    func stopLoad() {
        self.activityIndicator.stopAnimating()
        self.loadingView.removeFromSuperview()
        self.view.bringSubviewToFront(newSuggestion)
    }
    func logIn() {
        
        let identifier = UIDevice.currentDevice().identifierForVendor!.UUIDString
        self.load()
        
        PFUser.logInWithUsernameInBackground( identifier, password: identifier, block: { (user: PFUser?, error: NSError?) -> Void in
            if error == nil  {
                
                let installation = PFInstallation.currentInstallation()
                installation["user"] = user
                installation.saveInBackground()
                
                self.setValues() { result in
                    self.stopLoad()
                }
            }
            else {
                
                PFAnonymousUtils.logInWithBlock { (user: PFUser?, error: NSError?) -> Void in
                    
                    if error != nil || user == nil {
                        print("log in failed")
                        
                        let noConnection = UIAlertController(title: "No Internet Connection", message: "Please connect to the Internet", preferredStyle: UIAlertControllerStyle.Alert)
                        let yesAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
                            self.logIn()
                        }
                        noConnection.addAction(yesAction)
                        self.presentViewController(noConnection, animated: true, completion: { () -> Void in
                            
                        })
                    }
                    else {
                        user?.password = identifier
                        user?.username = identifier
                        user?.signUpInBackgroundWithBlock({ (bool: Bool, error: NSError?) -> Void in
                            
                            if error == nil {
                                
                                self.setValues() { result in
                                    self.stopLoad()
                                }
                            }
                            else {
                                self.logIn()
                            }
                            
                            
                        })
                        
                    }
                }
            }
        })
    }
    func setValues(callback: Bool -> Void)  {
        self.locationManager.requestLocation()
        if let here = locationManager.location {
            self.myLat = here.coordinate.latitude
            self.myLon = here.coordinate.longitude
            
        }
        else {
            print ("location services disabled")
        }
        let valueQuery = PFQuery(className: "Suggestions")
        //valueQuery.whereKey("User", equalTo: PFUser.currentUser()!)
        valueQuery.findObjectsInBackgroundWithBlock({ ( results:[PFObject]?, error: NSError?) -> Void in
            if results != nil {
                for data in results! {
                    print (data)
                    
                    if let suggString = (data["text"] as? String) {
                        if self.suggestionList.contains(suggString) == false {
                             self.suggestionList.append(suggString)
                            if let suggSnaps = (data["usersThatSnapped"] as? [String]) {
                                self.suggestionSnapsList.append(suggSnaps)
                            }
                        }
                    
                        
                        
                        
                        self.suggestionsTableView.reloadData()
                        
                    }
                    
               
                    
                }
            }
            callback(true)
            
        })
        
    }

        
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.suggestionsTableView.dataSource = self
        self.suggestionsTableView.delegate = self
        self.suggestionsTableView.estimatedRowHeight = 100.0
        self.suggestionsTableView.rowHeight = UITableViewAutomaticDimension
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        
      
//        refreshControl = UIRefreshControl()
//        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
//        self.notificationsTableView.addSubview(refreshControl!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func infoButtonPressed(sender: AnyObject) {
        let howMessage = "Snap Box lets you leave suggestions or interesting comments about the space in your proximity. Your feed will show comments others left 500 feet around your current location. If you agree with something, just snap it to let others know. Snap Box will never share any of your personal details with other users. If you see something offensive or inappropriate, please flag that suggestion. Happy Snap Boxing. Snap Box was created by Coby Anderson and Adrian Goedeckemeyer in November 2015."
        let alert = UIAlertController(title: "How it Works", message: howMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let yesAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            //self.pickerView.selectRow(<#T##row: Int##Int#>, inComponent: <#T##Int#>, animated: <#T##Bool#>)
        }
        alert.addAction(yesAction)
        self.presentViewController(alert, animated: true, completion: { () -> Void in
            
        })
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SuggestionCell?
        cell = self.suggestionsTableView.dequeueReusableCellWithIdentifier("suggestionCell")! as? SuggestionCell
        cell?.suggestionText.text = self.suggestionList[indexPath.row]
        cell?.likeCount.text = (String(self.suggestionSnapsList[indexPath.row].count))
    
        return cell!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.suggestionList.count
   
    }
  
    @IBAction func newSuggestionPressed(sender: AnyObject) {
        
        locationManager.requestLocation()
        if let here = locationManager.location {
            self.myLat = here.coordinate.latitude
            self.myLon = here.coordinate.longitude
        
        }
        else {
            print ("location services disabled")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      //  let x = locations[0]
       
//        self.myLat = x.coordinate.latitude
//        self.myLon = x.coordinate.longitude

        
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print ("error")
    }
    
    


}

