//
//  MyProgramViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/31.
//  Copyright © 2016年 joekoe. All rights reserved.
//
import UIKit

class MyProgramViewController: AppViewController
{
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            
            RobotControl.shareInstance().didStop()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_global_queue(0, 0))
        {
            
            let mutabArr:NSMutableArray? = RobotControl.shareInstance().didQueryScript()
            
            if mutabArr != nil{
                
//                for dict in RobotControl.shareInstance().didQueryScript()
                for dict in mutabArr!
                {
                    (self.view as! MyProgramView).dataArr.append(functionModel( id: "\(dict.valueForKey("ID")!)",
                        time: dict.valueForKey("time") as? String ?? "" ,
                        name: dict.valueForKey("name") as? String ?? "",
                        date: dict.valueForKey("date") as? String ?? ""))
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    (self.view as! MyProgramView).tableView.reloadData()
                })
            }
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let connect = robotModel.sharedInstance.connect where connect else
        {
            print(NSThread.currentThread())
            Alert({}, title: "请连接机器人", message: "")
            return
        }

    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
}
