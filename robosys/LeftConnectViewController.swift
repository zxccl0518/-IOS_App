//
//  LeftConnectViewController.swift
//  robosys
//
//  Created by Alan on 2017/9/11.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class LeftConnectViewController: UIViewController {

    @IBOutlet var leftConnectView: AppView!
    
    @IBOutlet weak var connectOffOnLine: UIButton!
    
    @IBOutlet weak var connectOnline: UIButton!
    
    let titleM : titleModel = titleModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftConnectView.initMainHeadView("连接机器人", imageName: "返回")
        
    }
    
    @IBAction func connectOnlineClick(sender: UIButton) {
        
        let vc = QRCodeViewController()
        vc.lastClass = classForCoder.debugDescription()
        self.navigationController?.pushViewController(vc, animated: false)
    }

    @IBAction func connectOffOnLineClick(sender: UIButton) {
        
        guard !networkModel.sharedInstance.isConnectRobot else
        {
            //控制连接是false
            leftConnectView.jump2AnyController(ScanRobotViewController(nibName: "ScanRobotView", bundle: nil))
            return
        }
        
        
        let (success,ssid,bssid) = leftConnectView.getSSID()
        
        //如果连接的是小盒的wifi
        if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
        {
            let status = RobotConnect.shareInstance().didConnOfflineRobot() == 0
            
            networkModel.sharedInstance.isConnectRobot = status
            robotModel.sharedInstance.connect = status
            robotModel.sharedInstance.online = false
            
            
            Alert({
                
                }, title: status ? "成功连接离线机器人" : "连接失败", message: "")
        }
        else
        {
            //没连接WIFI
            let vc = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
            titleM.title = ""
            titleM.title = "离线"
            (vc.view as! ScanRobotView).isWifi = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
}
