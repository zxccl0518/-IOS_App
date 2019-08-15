//
//  ScheduleRemindViewController.swift
//  robosys
//
//  Created by Cheer on 16/7/15.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import Foundation

class ScheduleRemindViewController : AppViewController
{
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_global_queue(0, 0))
        {
            let tempArr = RobotControl.shareInstance().didGetAlarmList()
//            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                (self.view as! ScheduleRemindView).dataArr = tempArr
//                if (self!.view as! ScheduleRemindView).table.visibleCells.first == nil
//                {
//                }
//            })
            
        }
    }
}
//import UIKit
//import Foundation
//
//class ScheduleRemindViewController : AppViewController
//{
//    override func viewWillAppear(animated: Bool)
//    {
//        super.viewWillAppear(animated)
//        
//        dispatch_async(dispatch_get_global_queue(0, 0))
//        {
//            (self.view as! ScheduleRemindView).dataArr = RobotControl.shareInstance().didGetAlarmList()
//            
//            if (self.view as! ScheduleRemindView).table.visibleCells.first == nil
//            {
//                (self.view as! ScheduleRemindView).dataArr = RobotControl.shareInstance().didGetAlarmList()
//            }
//        }
//    }
//}


