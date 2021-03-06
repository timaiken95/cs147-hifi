//
//  AppDelegate.swift
//  CS147HiFi
//
//  Created by clmeiste on 11/21/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var photos:[ARPhoto] = []
    var audio:[ARAudio] = []
    var tours:[ARTour] = []
    var dataInitialized:Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DispatchQueue.global(qos: .background).async {
        
            do {
                if let file = Bundle.main.url(forResource: "AppContent", withExtension: "json") {
                    let data = try Data(contentsOf: file)
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let object = json as? [String: Any] {
                        // json is a dictionary
                        
                        if let photoDicts = object["photos"] as? [[String:Any]] {
                            for dict in photoDicts {
                                let id = dict["photoId"] as! Int
                                let file = dict["file"] as! String
                                let title = dict["title"] as! String
                                let description = dict["description"] as! String
                                let lat = dict["lat"] as! Float
                                let long = dict["long"] as! Float
                                let tours = dict["tours"] as! [Int]
                                
                                let photoEntry = ARPhoto(pID: id, filename: file, t: title, d: description, lat: lat, long: long, ts: tours, s: 1)
                                self.photos.append(photoEntry)
                            }
                        }
                        
                        if let audioDicts = object["audio"] as? [[String:Any]] {
                            for dict in audioDicts {
                                let id = dict["audioId"] as! Int
                                let file = dict["file"] as! String
                                let photo = dict["photo"] as! Int
                                
                                let audioEntry = ARAudio(aID: id, filename: file, photo: photo)
                                self.audio.append(audioEntry)
                            }
                        }
                        
                        if let tourDicts = object["tours"] as? [[String:Any]] {
                            for dict in tourDicts {
                                let id = dict["tourId"] as! Int
                                let title = dict["title"] as! String
                                let description = dict["description"] as! String
                                let time = dict["time"] as! TimeInterval
                                let tourPhotos = dict["photos"] as! [Int]
                                
                                let tourEntry = ARTour(tID: id, t: title, d: description, ps: tourPhotos, time: time)
                                self.tours.append(tourEntry)
                            }
                        }
                        
                        self.dataInitialized = true
                        
                        DispatchQueue.main.async {
                            let vc = self.window?.rootViewController as! ViewController
                            vc.dataReady = true
                        }
                        
                        //                    print(object)
                    } else if let object = json as? [Any] {
                        // json is an array
                        print(object)
                    } else {
                        print("JSON is invalid")
                    }
                } else {
                    print("no file")
                }

            } catch {
                print(error.localizedDescription)
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

