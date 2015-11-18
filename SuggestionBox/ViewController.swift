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
    
    var coordinates: [Double] = [0.0,0.0]
    var parseSetMiles: Double = 0.1
    var parseMessage: String = "These are SnapBox's only instructions, they will update when connected to the internet."

    
    let locationManager = CLLocationManager()
    
    var refreshControl:UIRefreshControl?
    
    let loadingView = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateGUI", name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        
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
    func refresh() {
        self.setValues() { result in
            if result == true {
                self.refreshControl?.endRefreshing()
                self.animateTable()
            }
        }
        
    }
    func animateTable() {
        
        self.suggestionsTableView.reloadData()
        
        if self.suggestionList.count > 0 {
            let cells = suggestionsTableView.visibleCells
            let tableHeight: CGFloat = suggestionsTableView.bounds.size.height
            
            for i in cells {
                let cell: UITableViewCell = i as! SuggestionCell
                cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
            }
            
            var index = 0
            
            for a in cells {
                let cell: UITableViewCell = a as! SuggestionCell
                UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                    cell.transform = CGAffineTransformMakeTranslation(0, 0);
                    }, completion: nil)
                
                index += 1
                
            }
        }
        
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
        let mileQuery = PFQuery(className: "Miles")
        mileQuery.findObjectsInBackgroundWithBlock({ ( results:[PFObject]?, error: NSError?) -> Void in
            if results != nil {
                for data in results! {
                    if let theMiles = data["miles"] as? Double {
                        self.parseSetMiles = theMiles
                    }
                    if let theMessage = data["message"] as? String {
                        self.parseMessage = theMessage
                    }
                }
            }
            })
    

    
        self.locationManager.requestLocation()
        if let here = locationManager.location {
          self.coordinates = [here.coordinate.latitude, here.coordinate.longitude]
            
        }
        else {
            locationWarning()
        }
        let valueQuery = PFQuery(className: "Suggestions")
        let userGeoPoint = PFGeoPoint(latitude: self.coordinates[0], longitude: self.coordinates[1])
        
        valueQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinMiles: self.parseSetMiles)
        
   
        valueQuery.limit = 20
        
        valueQuery.orderByDescending("createdAt")
        
        valueQuery.findObjectsInBackgroundWithBlock({ ( results:[PFObject]?, error: NSError?) -> Void in
            if results != nil {
                self.suggestionList.removeAll()
                self.suggestionSnapsList.removeAll()
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
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.suggestionsTableView.addSubview(refreshControl!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("presentNewController:"), name: "ShowGameController", object: nil)
        
      
//        refreshControl = UIRefreshControl()
//        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
//        self.notificationsTableView.addSubview(refreshControl!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func infoButtonPressed(sender: AnyObject) {
        let howMessage = self.parseMessage
        let alert = UIAlertController(title: "How it Works", message: howMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let yesAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
          
        }
        alert.addAction(yesAction)
        self.presentViewController(alert, animated: true, completion: { () -> Void in
            
        })
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.suggestionList.count == 0 {
            var emptyCell: SadCell?
            emptyCell = self.suggestionsTableView.dequeueReusableCellWithIdentifier("sadCell") as? SadCell
            
            return emptyCell!
        }
        
        var cell: SuggestionCell?
        cell = self.suggestionsTableView.dequeueReusableCellWithIdentifier("suggestionCell")! as? SuggestionCell
        cell?.suggestionText.text = self.suggestionList[indexPath.row]
        cell?.likeCount.text = (String(self.suggestionSnapsList[indexPath.row].count))
        var image = UIImage(named: "snapUnactive")
        if self.suggestionSnapsList[indexPath.row].contains(((PFUser.currentUser()!).objectId!)) {
            image = UIImage(named: "snapActive")
            }
    
        cell?.snap.image = image
    
    
        return cell!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.suggestionList.count == 0 {
            return 1
        }
        return self.suggestionList.count
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.load()
        let likeQuery = PFQuery(className: "Suggestions")
        likeQuery.whereKey("text", equalTo: self.suggestionList[indexPath.row])
        likeQuery.findObjectsInBackgroundWithBlock({ ( results:[PFObject]?, error: NSError?) -> Void in
            var object: PFObject?
            if error != nil {
                self.logIn()
            }
            
            if results?.count > 0  {
                print (results?[0])
                object = results![0]
            }
            else {
                object = PFObject(className: "Suggestions")
                object!.setValue("", forKey: "text")
                
            }
            if self.suggestionSnapsList[indexPath.row].contains(((PFUser.currentUser()!).objectId!)) {
                object!.removeObject(((PFUser.currentUser()!).objectId!), forKey: "usersThatSnapped")
            }
            else {
                object!.addObject(((PFUser.currentUser()!).objectId!), forKey: "usersThatSnapped")
            }
            
            object!.saveInBackgroundWithBlock({ (Bool, NSError) -> Void in
                self.stopLoad()
                self.suggestionsTableView.deselectRowAtIndexPath( indexPath, animated: true)
                self.refresh()
            })
            }
        )
    }
  
    @IBAction func newSuggestionPressed(sender: AnyObject) {
        
        locationManager.requestLocation()
        if let here = locationManager.location {
            self.coordinates = [here.coordinate.latitude, here.coordinate.longitude]
            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("newViewController") as! newViewController
            
            viewController.lat = here.coordinate.latitude
            viewController.lon = here.coordinate.longitude
            
            self.presentViewController(viewController, animated: true, completion: { () -> Void in
            
            })
        }
        else {
          locationWarning()
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let coordinates = sender as? [Double] {
            if let destination = segue.destinationViewController as? newViewController {
                destination.lat = coordinates[0]
                destination.lon = coordinates[1]
            }
        }
    }
    
    func presentNewController(notification: NSNotification) {
        if let coordinates = notification.object as? [Double] {
            self.performSegueWithIdentifier("segueToNew", sender: coordinates)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationWarning()
        
    }
    func locationWarning() {
        let howMessage = "Please make sure you are connected to the internet and that Snapbox has permission to access your location."
        let alert = UIAlertController(title: "Could not retrieve location", message: howMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let yesAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
        }
        alert.addAction(yesAction)
        self.presentViewController(alert, animated: true, completion: { () -> Void in
            
        })
    }
    func updateGUI() {
        logIn()
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton = UITableViewRowAction(style: .Default, title: "Flag", handler: { (action, indexPath) in
            self.suggestionsTableView.dataSource?.tableView?(
                self.suggestionsTableView,
                commitEditingStyle: .Delete,
                forRowAtIndexPath: indexPath
            )
            return
        })

        deleteButton.backgroundColor = UIColor(red: 250/255, green: 43/255, blue: 86/255, alpha: 0.9)

        
        return [deleteButton]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let alert = UIAlertController(title: "Flag this suggestion?", message: "After three flags this suggestion will be deleted", preferredStyle: UIAlertControllerStyle.Alert)
            let yesAction = UIAlertAction(title: "Flag", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
                self.flag(indexPath.row)
            }
            let noAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                (UIAlertAction) -> Void in
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.presentViewController(alert, animated: true, completion: { () -> Void in
                
            })
    
    
        }
    }
    func flag(deleteIndex : Int) {
        
        self.load()
        
        let valueQuery = PFQuery(className: "Suggestions")
        valueQuery.whereKey("text", equalTo: self.suggestionList[deleteIndex])
        valueQuery.findObjectsInBackgroundWithBlock({ ( results:[PFObject]?, error: NSError?) -> Void in
            if results != nil {
                for data in results! {
                    if let flaggedData = data["flag"] as? [String] {
                        if flaggedData.contains(((PFUser.currentUser()!).objectId!)) {
                            data.removeObject(((PFUser.currentUser()!).objectId!), forKey: "flag")
                        }
                            
                        else {
                            data.addObject(((PFUser.currentUser()!).objectId!), forKey: "flag")
                        }
                        
                        
                        if flaggedData.count > 3 {
                            data.deleteInBackgroundWithBlock({ (Bool, error) -> Void in
                                self.stopLoad()
                                if error != nil {
                                    self.logIn()
                                }
                                else {
                                    self.refresh()
                                }
                            })
                        }
                        else {
                            data.saveInBackgroundWithBlock({ (Bool, error) -> Void in
                                self.stopLoad()
                                if error != nil {
                                    self.logIn()
                                }
                                else {
                                    self.refresh()
                                }
                            })
                        }
                        
                    }
                }
            }
        })
    }

}

