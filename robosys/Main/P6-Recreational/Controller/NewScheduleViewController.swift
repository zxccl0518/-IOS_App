//
//  NewScheduleViewController.swift
//  robosys
//
//  Created by Cheer on 16/7/15.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class NewScheduleViewController: AppViewController
{
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let view = self.view as! NewScheduleView
        
        if view.scheduleM != nil
        {
            if  view.scheduleM.time.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 10
            {
                view.timeLabel.text = NSDate.formateDate(view.scheduleM.time, formate: "yyyyMMddHHmm")
            }
            else
            {
                view.timeLabel.text = view.scheduleM.time
            }
     
            (view.repeatLabel.text,view.inputName.text,view.remindLabel.text) = (view.scheduleM.repeats,view.scheduleM.name,view.scheduleM.remind)
            
            switch view.repeatLabel.text!
            {
            case "不重复":
                view.repeatCount = 0
            case "每天":
                view.repeatCount = 1
            case "每周":
                view.repeatCount = 2
            case "每两周":
                view.repeatCount = 3
            case "每月":
                view.repeatCount = 4
            case "每年":
                view.repeatCount = 5
            default:
                break
            }
            
            switch view.remindLabel.text!
            {
            case "正点提醒":
                view.remindCount = 0
            case "5分钟前":
                view.remindCount = 1
            case "10分钟前":
                view.remindCount = 2
            case "15分钟前":
                view.remindCount = 3
            case "30分钟前":
                view.remindCount = 4
            case "1小时前":
                view.remindCount = 5
            case "2小时前":
                view.remindCount = 6
            case "1天前":
                view.remindCount = 7
            case "2天前":
                view.remindCount = 8
            case "1周前":
                view.remindCount = 9
            default:
                break
            }
        }
    }
}
