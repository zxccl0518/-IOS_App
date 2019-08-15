//
//  BindView.swift
//  robosys
//
//  Created by Cheer on 16/5/23.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class BindView: AppView
{
    //-MARK:属性
    private lazy var code = {}
    internal var isBind:Bool!

    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initHeadView("绑定", imageName: "返回主页")
        
        code =
        {
            [unowned self] in

            
            self.jump2AnyController(MainViewController())
            dispatch_async(dispatch_get_global_queue(0, 0), {
                
                self.connectRobot()
            })
        }
    }
    
    //-MARK:点击方法
    //绑定
    @IBAction func bind(sender: UIButton)
    {
        switch connect.didBind(loginM.num, token: loginM.token, robotId: loginM.robotId,admin: 1)
        {
        case 0:
            Alert({
                [unowned self] in
                
                self.Alert({
                    
                    self.code()
                    
                    }, title: "正在配对..", message: "")
                
                }, title: "绑定成功", message: "")
        case 301,302:
            Alert({
                [unowned self] in
//                self.jump2AnyController(HomeViewController())
                self.getCurrentVC().navigationController?.popToRootViewControllerAnimated(true)
                }, title: "用户登录已过期,正在重新登录", message: "")
        case 303:
            Alert({
                [unowned self] in
                
                self.Alert({
                    
                    self.code()
                    
                    }, title: "正在配对..", message: "")
                
                }, title: "不能重复绑定", message: "")
        case 304:
            Alert({
                [unowned self] in
                
                self.Alert({
                    
                    self.code()
                    
                    }, title: "正在配对..", message: "")
                
                }, title: "机器人不存在", message: "")
        case 307:
            Alert({
                [unowned self] in
                
                self.Alert({
                    
                    self.code()
                    
                    }, title: "正在配对..", message: "")
                
                }, title: "您没有此权限", message: "")
            //已有管理员
        case 309:
            Alert({
                [unowned self] in
                
                self.Alert({
                    
                    self.code()
                    
                    }, title: "正在配对..", message: "")
                
                }, title: "当前机器人已经有了管理员", message: "")

        default:
            Alert({
                
                [unowned self] in
                
                self.Alert({
                    
                    self.code()
                    
                    }, title: "正在配对..", message: "")
                
                }, title: "绑定失败", message: "")
        }
    }
    //跳转
    @IBAction func jump(sender: UIButton)
    {
        //无我
        if !isBind
        {
            connect.didBind(loginM.num, token: loginM.token, robotId: loginM.robotId, admin: 0)
        }
   
        Alert({
            [unowned self] in
            self.code()
            }, title: "正在配对..", message: "")
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
    
    func connectRobot()
    {
        let status = connect.didConnRobot(loginM.token, userName: loginM.num, robotId: loginM.robotId).firstObject as! Int
        
        switch status
        {
        case 301,302:
            
           Alert({
             [weak self] in
               self!.jump2AnyController(HomeViewController())
                }, title: "用户过期请重新登录", message: "")
            
        case 0:
            //配对结果
            Alert({
                [weak self] in
                networkModel.sharedInstance.isConnectRobot = true
                robotModel.sharedInstance.connect = true
                robotModel.sharedInstance.online = true
                RobotManager.shareManager.getRobotInfo()
//                RobotManager.shareManager.saveRobotId(nil)
                
                }, title: "配对成功", message: "")
            
        //超时
        case -1:
            Alert({
                 //[weak self] in
                //self!.jump2AnyController(MainViewController())
                }, title: "配对失败", message: "")
        default:
            Alert({
                 [weak self] in
                self!.jump2AnyController(MainViewController())
                }, title: "\(status)", message: "")
        }
    }
}
