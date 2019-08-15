//
//  RecreationalViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/20.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import SystemConfiguration

class RecreationalViewController: AppViewController
{
    private let robotM = robotModel.sharedInstance
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
     
        if networkModel.sharedInstance.state == true
        {
            (view as! RecreationalView).warningLabel.hidden = true
            (view as! RecreationalView).warningImg.hidden = true
        }
        else
        {
            (view as! RecreationalView).warningLabel.hidden = false
            (view as! RecreationalView).warningImg.hidden = false
        }

        if let connect = robotM.connect where connect {
            ((view as! RecreationalView).headView ).titleLabel.text = (networkModel.sharedInstance.isConnectRobot ?  robotM.name ?? "" : "小盒")
        }
    }
    
    func connectOrNot(){
        
        //60s判断机器人上线
        let res = RobotConnect.shareInstance().didReset(loginModel.sharedInstance.num, token: loginModel.sharedInstance.token,robotId:loginModel.sharedInstance.robotId,isLogin:false)
        
        if res.firstObject as! Int == 0 {
            
            //ip地址不为空
            if res[1].length! != 0
            {
                robotModel.sharedInstance.online = true
                let status = RobotConnect.shareInstance().didConnRobot(loginModel.sharedInstance.token, userName: loginModel.sharedInstance.num, robotId: loginModel.sharedInstance.robotId).firstObject as! Int
                if status == 0 {
                    
                    networkModel.sharedInstance.isConnectRobot = true
                    robotModel.sharedInstance.connect = true
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        RobotManager.shareManager.getRobotInfo()
                        ((self.view as! RecreationalView).headView ).titleLabel.text = (networkModel.sharedInstance.isConnectRobot ?  robotModel.sharedInstance.name ?? "小盒" : "小盒")
                    })

                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let id = RobotManager.shareManager.getSaveRobotId() {

            if !id.isEmpty {
                loginModel.sharedInstance.robotId = id
                // 如果已连接,不让其自动连接
                guard !networkModel.sharedInstance.isConnectRobot else {
                    return
                }
                dispatch_async(dispatch_get_global_queue(0, 0), {[unowned self] in
                    self.connectOrNot()
                })
            }
        }
    }
    
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
