//
//  ConfigurationView.swift
//  robosys
//
//  Created by Cheer on 16/5/24.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class ConfigurationView: AppView
{
    @IBOutlet weak var offlineBtn: UIButton!
    @IBOutlet weak var onlineBtn: UIButton!
    @IBOutlet weak var configBtn: UIButton!
    //-MARK:生命周期
    override func awakeFromNib()
    {
        super.awakeFromNib()
        initHeadView("选择连接方式", imageName: "返回")
        configBtn.setImage(UIImage(named: "配置wifi-按下"), forState: .Selected)
         offlineBtn.setImage(UIImage(named: "连接离线机器人按下"), forState: .Selected)
         onlineBtn.setImage(UIImage(named: "连接在线机器人按下"), forState: .Selected)
    }
    //-MARK:点击方法
    //点击配置WiFi
    @IBAction func clickConfiguration(sender: UIButton)
    {
        if Platform.isSimulator
        {
            jump2AnyController(ConnectWiFiViewController(nibName: "ConnectWiFiView",bundle: nil))
        }
        else
        {
            let (success,ssid,bssid) = getSSID()
            
            if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
            {
                jump2AnyController(ConnectWiFiViewController(nibName: "ConnectWiFiView",bundle: nil))
            }
            else
            {
                //没连接WIFI
                let vc = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
                (vc.view as! ScanRobotView).isWifi = true
                jump2AnyController(vc)
            }
        }
    }
    //点击离线机器人
    @IBAction func clickOffline(sender: AnyObject) {
        if Platform.isSimulator
        {
            jump2AnyController(ScanRobotViewController(nibName:"ScanRobotView",bundle: nil))
        }
        else
        {
            let (success,ssid,bssid) = getSSID()
            
            if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
            {
                let status = connect.didConnOfflineRobot() == 0
                
                networkM.isConnectRobot = status
                robotM.connect = status
                robotM.online = false
                Alert({
                    
                    }, title: status ? "成功连接离线机器人" : "连接失败", message: "")
            }
            else
            {
                //没连接WIFI
                let vc = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
                (vc.view as! ScanRobotView).isWifi = false
                
                let currentVC = getCurrentVC()
        
                if let nav = currentVC as? UINavigationController
                {
                    nav.pushViewController(vc, animated: true)
                    return
                }
                currentVC.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    //点击在线机器人
    @IBAction func clickOnline(sender: AnyObject)
    {
        let vc = QRCodeViewController()
        vc.lastClass = classForCoder.debugDescription()
        (getCurrentVC() as! UINavigationController).pushViewController(vc, animated: false)
    }
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
