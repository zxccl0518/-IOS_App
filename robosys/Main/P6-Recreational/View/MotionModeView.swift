//
//  MotionModeView.swift
//  robosys
//
//  Created by Cheer on 16/5/31.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class MotionModeView: AppView
{
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var freedomBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView("运动模式", imageName: "返回")
        
        stopBtn.setImage(UIImage(named: "停止运动按下"), forState: .Selected)
        freedomBtn.setImage(UIImage(named: "自由漫步按下"), forState: .Selected)
        followBtn.setImage(UIImage(named: "跟随模式按下"), forState: .Selected)
    }
    @IBAction func freedom(sender: UIButton)
    {
        if networkM.isConnectRobot == true
        {
            Alert({
                
                dispatch_async(dispatch_get_global_queue(0, 0), { [weak self] in
                    self!.control.didRunMode(2)
                })
                
                }, title: "设置成功", message: "")
//            Alert({self.control.didRunMode(2)}, title: "设置成功", message: "")
        }
        else
        {
            Alert({}, title: "请连接机器人", message: "")
        }
        
    }
    @IBAction func stop(sender: UIButton)
    {
        if networkM.isConnectRobot == true
        {
//            Alert({self.control.didStop()}, title: "设置成功", message: "")
            Alert({ 
                dispatch_async(dispatch_get_global_queue(0, 0), { [weak self] in
                    self!.control.didStop()
                })
                }, title: "设置成功", message: "")
        }
        else
        {
            Alert({}, title: "请连接机器人", message: "")
        }
        
    }
    @IBAction func follow(sender: UIButton)
    {
        if networkM.isConnectRobot == true
        {
//            Alert({self.control.didRunMode(3)}, title: "设置成功", message: "")
            Alert({ 
                dispatch_async(dispatch_get_global_queue(0, 0), { [weak self] in
                    self!.control.didRunMode(3)
                })
                }, title: "设置成功", message: "")
        }
        else
        {
            Alert({}, title: "请连接机器人", message: "")
        }
        
    }
    
    @IBAction func setMotion(sender: UIButton)
    {
        jump2AnyController(MotionSettingViewController(nibName: "MotionSettingView", bundle: nil))
    }
    
}

