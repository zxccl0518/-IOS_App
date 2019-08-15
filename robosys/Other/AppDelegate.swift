//
//  AppDelegate.swift
//  robosys
//
//  Created by Cheer on 16/5/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: String) -> Bool {
        
        UITextField().keyboardType = UIKeyboardType.Default
        
              return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

//        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        
        window?.backgroundColor = UIColor.whiteColor()
        /*
         int cacheSizeMemory = 4*1024*1024; // 4MB
         int cacheSizeDisk = 32*1024*1024; // 32MB
         
         */
        
        let cacheSizeMemory = 1*1024*1024
        let cacheSizeDisk = 5*1024*1024
        
        
        NSURLCache.setSharedURLCache(NSURLCache.init(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "nsurlcache"))
        
//        MobClick.setLogEnabled(true)
//        
//        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
//        MobClick.setAppVersion(version as? String)
//        let obj = UMAnalyticsConfig.sharedInstance()
//        obj.appKey = "58ec070bae1bf82d5e001709"
//        obj.channelId = "App Store"
//        MobClick.startWithConfigure(obj)

        return true
    }
    

    func applicationWillResignActive(application: UIApplication) {
    }

    //程序从前台进入到后台
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if let nav = UIApplication.sharedApplication().keyWindow?.rootViewController
        {
            if (nav as! UINavigationController).viewControllers.last?.classForCoder == BindViewController.classForCoder()
            {
                (nav as! UINavigationController).pushViewController(MainViewController(), animated: true)
            }else if (nav as! UINavigationController).viewControllers.last?.classForCoder == MotionProgramViewController.classForCoder()
            {
                let view = ((nav as! UINavigationController).viewControllers.last?.view as! MotionProgramView)
                
                for item in view.viewDic
                {
                    item.1.hidden = true
                }
            }else{
                return
            }
            /*
             
             //            if (nav as! UINavigationController).viewControllers.last?.classForCoder == HomeViewController.classForCoder(){
             //
             //                 HomeViewController().login(UIButton())
             //            }*/
        }
    }

    //将要进入前台
    func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
    
    //程序从后台进入前台
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let connect = RobotConnect.shareInstance()
        
        //保存的文字单例
        let titleM : titleModel = titleModel.sharedInstance
        
        if let nav = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController
        {
            
            let vc = nav.viewControllers.last
            
            
            if vc?.classForCoder == MotionProgramViewController.classForCoder() || vc?.classForCoder == ControlInterfaceViewController.classForCoder()
            {
                UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
                
                return
            }else if vc?.classForCoder == ConfigurationVC.classForCoder(){
                if !Platform.isSimulator
                {
                    let (success,ssid,bssid) = vc!.view.getSSID()
                    
                    if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
                    {
                            let aler = UIAlertController(title:"正在连接", message:"", preferredStyle: .Alert)
                            nav.viewControllers.last!.presentViewController(aler, animated: true, completion: nil)
                        
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(5 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
                            {
                                dispatch_async(dispatch_get_global_queue(0, 0), { 
                                    let status = connect.didConnOfflineRobot() == 0
                                    
                                    dispatch_async(dispatch_get_main_queue(), { 
                                        networkModel.sharedInstance.isConnectRobot = status
                                        robotModel.sharedInstance.online = false
                                        robotModel.sharedInstance.connect = status
                                        let (success,ssid,bssid) = vc!.view.getSSID()
                                        loginModel.sharedInstance.robotId = (ssid as NSString).substringFromIndex(6)
                                        
                                        
                                        aler.dismissViewControllerAnimated(true, completion:
                                            {
                                                
                                                let alert = UIAlertController(title:"成功连接离线机器人", message:"", preferredStyle: .Alert)
                                                vc!.presentViewController(alert, animated: true, completion: nil)
                                                
                                                if titleM.title.characters.count == 4{
                                                    //配网
                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(1 * Double(NSEC_PER_SEC))),dispatch_get_main_queue()){
                                                        alert.dismissViewControllerAnimated(true, completion: {
                                                            
                                                            titleM.title = ""
                                                            if let dict = RobotControl.shareInstance().didQueryWifiList(){
                                                                let Dic = dict as! [String : AnyObject]
                                                                let switchVC = SwitchWifiVC()
                                                                switchVC.CellWifi = Dic
                                                                
                                                                if nav.viewControllers.last?.classForCoder == ConfigurationVC.classForCoder(){
                                                                    
                                                                    nav.pushViewController(switchVC, animated: true)
                                                                }
                                                                
                                                                
                                                            }else{
                                                                
                                                                //以前输入账号和密码的界面
                                                                nav.pushViewController(ConnectWiFiViewController(nibName: "ConnectWiFiView", bundle: nil), animated: true)
                                                            }
                                                            
                                                        })
                                                    }
                                                    
                                                    
                                                }else{
                                                    
                                                    alert.dismissViewControllerAnimated(true, completion: { 
                                                        //连接离线
                                                        titleM.title = ""
                                                        networkModel.sharedInstance.isConnectRobot = true
                                                        robotModel.sharedInstance.connect = true
//                                                        robotModel.sharedInstance.online = false
                                                        RobotManager.shareManager.getRobotInfo()
                                                        nav.pushViewController(MainViewController(), animated: true)
                                                    })
                                                }
                                        })

                                    })
                                    
                                })
                        }
                    }else{
                        //请连接机器人网络:
                        
                        vc!.Alert({
                            
                            [unowned self] in
                            
                            nav.pushViewController(MainViewController(), animated: true)
                            
                            }, title: "请连接机器人网络", message: "")

                        
                        
                    }
                }
            }else{
                
                return
            }
        }
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSUserDefaults.standardUserDefaults().removeObjectForKey("RecentlyPlayed")
    }
    
    //应用在正在运行(在前台或后台运行)，点击通知后触发appDelegate代理方法:
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        
    }
}

