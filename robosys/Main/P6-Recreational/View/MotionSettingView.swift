//
//  MotionSettingView.swift
//  robosys
//
//  Created by Cheer on 16/5/31.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class MotionSettingView: AppView
{
    @IBOutlet weak var collisionSwitch: UISwitch!
    @IBOutlet weak var fallSwitch: UISwitch!
    
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var bg1: UIImageView!
    
    private var popView:UIView!
    private var alert:AppAlert!
    
    func clickEnsure()
    {
        popView.removeFromSuperview()
        alert.dismiss()
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        initMainHeadView("设置", imageName: "返回")
        addBorder(bg)
        addBorder(bg1)
    }

    @IBAction func chanegStatus(sender: UISwitch)
    {
        switch sender
        {
        case fallSwitch: popView = createPopView("关闭防止跌落后，小盒会从桌子边缘掉下来，请注意保护好小盒哦~")
    
        default:popView = createPopView("")
        }
        
        
        switch sender.on
        {
        case true:
            if networkM.isConnectRobot == true
            {
                control.didRunMode(1)
            }
            else
            {
                Alert({}, title: "请连接机器人", message: "")
            }
        case false:
            
            if networkM.isConnectRobot == true
            {
                control.didRunMode(4)
                alert = AppAlert(frame: UIScreen.mainScreen().bounds, view:popView, currentView: self, autoHidden: false)
            }
            else
            {
                Alert({}, title: "请连接机器人", message: "")
            }
        }
    }
    //popView
    func createPopView(string:String)->UIView
    {
        let view = UIView(frame: CGRectMake(0,0,300,150))
        
        let imageV = UIImageView(frame: CGRectMake(0,0,300,150))
        imageV.image = UIImage(named: "弹框底板")
        
        let label = UILabel(frame: CGRectMake(40,20,220,60))
        label.attributedText = NSAttributedString(string:string ,attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
        label.numberOfLines = 3
        
        let btn = UIButton(frame: CGRectMake(40,100,220,30))
        btn.setAttributedTitle(NSAttributedString(string: "确认", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!]), forState: .Normal)
        btn.setBackgroundImage(UIImage(named:"小橙按钮"), forState: .Normal)
        btn.addTarget(self, action: #selector(MotionSettingView.clickEnsure), forControlEvents: .TouchUpInside)
        
        view.addSubview(imageV)
        view.addSubview(label)
        view.addSubview(btn)
        
        return view
    }
    //弹出方法
    func pop(view:UIView)->[UIView]
    {
        let hudView = UIImageView(frame:UIScreen.mainScreen().bounds)
        hudView.backgroundColor = UIColor(red: 4 / 255, green: 17 / 255, blue: 44 / 255, alpha: 1)

        view.center = center
        
        addSubview(hudView)
        addSubview(view)
        
        bringSubviewToFront(hudView)
        bringSubviewToFront(view)

        return [hudView,view]
    }
}
