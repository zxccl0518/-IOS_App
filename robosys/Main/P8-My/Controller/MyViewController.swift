//
//  MyViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/26.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class MyViewController: AppViewController
{
        override func viewDidAppear(animated: Bool) {
            super.viewDidAppear(animated)
    
            dispatch_async(dispatch_get_global_queue(0, 0)) {
                var tempCount:Int = 0
    
                let (success,ssid,_) = self.view.getSSID()
    
                //连接离线
                if networkModel.sharedInstance.isConnectRobot && success && ssid.hasPrefix("MrBox") && ssid.characters.count == 18
                {
                    tempCount = 1
                }
                else if networkModel.sharedInstance.state && !Platform.isSimulator
                {
                    let tempArr = (self.view as! MyView).connect.didQueryRobotList(loginModel.sharedInstance.num, token: loginModel.sharedInstance.token,robotId: loginModel.sharedInstance.robotId)
    
                    switch tempArr.firstObject as! Int
                    {
                    case 301,302:
    
                        self.Alert({
                            [unowned self] in
                            (self.view as! MyView).getCurrentVC().navigationController?.popToRootViewControllerAnimated(true)
                            }, title: "用户登录已过期,正在重新登录", message: "")
                    default:
                        break
                    }
    
                    tempCount = tempArr[1] as! Int
                }
    
                dispatch_async(dispatch_get_main_queue(), {
                    (self.view as! MyView).robotCount = tempCount
    
                    tempCount == 0 ? (self.view as! MyView).setUp(true) : (self.view as! MyView).setUp(false)
                    (self.view as! MyView).tableView?.reloadData()
                })
            }
    
        }
}
//        override func viewWillAppear(animated: Bool)
//        {
//            super.viewWillAppear(animated)
//            
//            dispatch_async(dispatch_get_global_queue(0, 0)) {
//                var tempCount:Int = 0
//                
//                let (success,ssid,_) = self.view.getSSID()
//                
//                //连接离线
//                if networkModel.sharedInstance.isConnectRobot && success && ssid.hasPrefix("MrBox") && ssid.characters.count == 18
//                {
//                    tempCount = 1
//                }
//                else if networkModel.sharedInstance.state && !Platform.isSimulator
//                {
//                    
//                    let tempArr = (self.view as! MyView).connect.didQueryRobotList(loginModel.sharedInstance.num, token: loginModel.sharedInstance.token,robotId: loginModel.sharedInstance.robotId)
//                    
//                    switch tempArr.firstObject as! Int
//                    {
//                    case 301,302:
//                        
//                        self.Alert({
//                            [unowned self] in
//                            (self.view as! MyView).getCurrentVC().navigationController?.popToRootViewControllerAnimated(true)
//                            }, title: "用户登录已过期,正在重新登录", message: "")
//                    default:
//                        break
//                    }
//                    
//                    tempCount = tempArr[1] as! Int
//                }
//                
//                dispatch_async(dispatch_get_main_queue(), { 
//                    (self.view as! MyView).robotCount = tempCount
//                    
//                    tempCount == 0 ? (self.view as! MyView).setUp(true) : (self.view as! MyView).setUp(false)
//                    
//                    (self.view as! MyView).tableView?.reloadData()
//                })
//            }
//        }

//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)

//        dispatch_async(dispatch_get_global_queue(0, 0)) {
//            var tempCount:Int = 0
//            
//            let (success,ssid,_) = self.view.getSSID()
//            
//            //连接离线
//            if networkModel.sharedInstance.isConnectRobot && success && ssid.hasPrefix("MrBox") && ssid.characters.count == 18
//            {
//                tempCount = 1
//            }
//            else if networkModel.sharedInstance.state && !Platform.isSimulator
//            {
//                let tempArr = (self.view as! MyView).connect.didQueryRobotList(loginModel.sharedInstance.num, token: loginModel.sharedInstance.token,robotId: loginModel.sharedInstance.robotId)
//                
//                switch tempArr.firstObject as! Int
//                {
//                case 301,302:
//                    
//                    self.Alert({
//                        [unowned self] in
//                        (self.view as! MyView).getCurrentVC().navigationController?.popToRootViewControllerAnimated(true)
//                        }, title: "用户登录已过期,正在重新登录", message: "")
//                default:
//                    break
//                }
//                
//                tempCount = tempArr[1] as! Int
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                (self.view as! MyView).robotCount = tempCount
//                
//                tempCount == 0 ? (self.view as! MyView).setUp(true) : (self.view as! MyView).setUp(false)
//            })
//        }
//
//        (self.view as! MyView).tableView?.reloadData()
//    }
//}
