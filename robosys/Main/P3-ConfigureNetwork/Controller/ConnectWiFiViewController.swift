//
//  ConnectWiFiViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/19.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit


class ConnectWiFiViewController: AppViewController
{
    lazy var once = true
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
       
        if once
        {
            let (success,ssid,bssid) = view.getSSID()
            
            if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
            {
                if let ssid = NSUserDefaults.standardUserDefaults().objectForKey("robosys_ssid") as? String
                {
                    (view as! ConnectWiFiView).ssidTxtField.text = ssid ?? ""
                }
            }
            else
            {
                
                //没连接WIFI
//                let destiVC = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
//                for vc in navigationController!.viewControllers
//                {
//                    if vc.classForCoder == destiVC.classForCoder
//                    {
//                        navigationController!.popToViewController(vc, animated: true)
//                        return
//                    }
//                }
//                navigationController!.pushViewController(destiVC, animated: true)
                return
            }
            once = false
        }
    }
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
 }
