//
//  RobotDetailsViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/27.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class RobotDetailsViewController: AppViewController
{
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        (view as! RobotDetailsView).scroll.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width,UIScreen.mainScreen().bounds.height * 2 )
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
       
        if let _ = robotModel.sharedInstance.online where networkModel.sharedInstance.isConnectRobot
        {
            RobotManager.shareManager.getRobotInfo()
        }
    }
}
