//
//  MyViewCell.swift
//  robosys
//
//  Created by Cheer on 16/5/26.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

@objc public protocol MyViewCellDelegate {
    
    @objc optional func connectRobotId(robotId:String)
}


class MyViewCell: UITableViewCell
{
    @IBOutlet weak var snLabel: UILabel!
    @IBOutlet weak var portraitImg: UIImageView!
    @IBOutlet weak var onlineStatus: UILabel!
    @IBOutlet weak var accountId: UILabel!
    @IBOutlet weak var robotName: UILabel!
    @IBOutlet weak var adminStatus: UILabel!
    @IBOutlet weak var userBtn: UIButton!
    @IBOutlet weak var connectStatus: UILabel!
    @IBOutlet weak var breakBtn: UIButton!
    @IBOutlet weak var bgImgView: UIImageView!
    private lazy var loginM = loginModel.sharedInstance
    private lazy var robotM = robotModel.sharedInstance
    var currentRobot = Robot()
    weak var delegate : MyViewCellDelegate?
    var timer:NSTimer!
    
    @IBAction func clickBreak(sender: UIButton)
    {
        
        switch sender.currentBackgroundImage!.accessibilityIdentifier!
        {
        case "断开":
          
            self.disconnect()

        case "连接":
            
            self.delegate?.connectRobotId!((self.currentRobot.robotId)!)
            let code =
                {
                    [weak self] in
                    
                    let loginM = loginModel.sharedInstance
                    loginM.robotId = self?.currentRobot.robotId
                    
                dispatch_async(dispatch_get_global_queue(0, 0), {[weak self] in
                    
                    guard RobotConnect.shareInstance().didOnline(loginModel.sharedInstance.num, token: loginModel.sharedInstance.token, robotId: loginModel.sharedInstance.robotId) == 0 else
                    {
                        self?.Alert({
                            self!.robotM.connect = false
                            self!.robotM.online = false
                            if let table = self?.superview?.superview as? UITableView
                            {
                                table.reloadData()
                            }
                            }, title: "机器人已经离线,请重新连接", message: "")
                        return
                    }
                    
                    
                    let ret = RobotConnect.shareInstance().didConnRobot(loginM.token, userName: loginM.num, robotId: loginM.robotId)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                    
                        if let status = ret.firstObject as? Int where 0 == status
                        {

                            networkModel.sharedInstance.isConnectRobot = true
                            self?.currentRobot.connect? = true
                            self?.currentRobot.online? = true
                            
                            self?.robotM.setRobotModel((self?.currentRobot)!)
                            self?.setUp((self?.currentRobot)!)
                            return
                        }
                    })
                })
                    
            }
            Alert(code, title: "正在连接", message: "")
        default:
            break
        }
    }
    
    //断开连接
    func disconnect()
    {
        //断开机器人
        networkModel.sharedInstance.isConnectRobot = false
        
        loginM.robotId = nil
        robotM.connect = false
        robotM.online = false
        
        self.currentRobot.online = false
        self.currentRobot.connect = false
        self.setUp(self.currentRobot)
    }
    
    func setUp(model:Robot)
    {
        self.snLabel.text = String.init(format: "ID %@", model.robotId!)
        
        //如果相同的话  说明是目前正在连接的机器人
        if model.robotId != nil && (model.robotId == loginM.robotId) {
            
            robotName.text = self.currentRobot.name
            
            self.currentRobot.online = robotM.online
            self.currentRobot.connect = robotM.connect

            portraitImg.image = UIImage(named:(self.currentRobot.online ?? false) ? "在线头像" : "离线头像")
            let breakImg = UIImage(named:(robotM.connect ?? false) ? "断开":"连接")
            breakImg?.accessibilityIdentifier = (self.currentRobot.connect ?? false) ? "断开":"连接"
            breakBtn.setBackgroundImage(breakImg, forState: .Normal)
            breakBtn.hidden = false
            connectStatus.hidden = false
            connectStatus.text = (self.currentRobot.connect ?? false) ? "已连接":"未连接"
            
            if robotM.admin?.characters.count > 0
            {
                adminStatus.hidden = false
                userBtn.setTitle(self.currentRobot.admin ?? "", forState: .Normal)
            }
            else
            {
                adminStatus.hidden = true

            }
            onlineStatus.text = self.currentRobot.online ?? false ? "在线": "离线"
            selectionStyle = .None
            addBorder(bgImgView)
        }
        else
        {
            robotName.text = model.name ?? ""
            portraitImg.image = UIImage(named:(model.online ?? false) ? "在线头像" : "离线头像")
            let breakImg = UIImage(named:(model.connect ?? false) ? "断开":"连接")
            breakImg?.accessibilityIdentifier = (model.connect ?? false) ? "断开":"连接"
            breakBtn.setBackgroundImage(breakImg, forState: .Normal)
            breakBtn.hidden = false
            connectStatus.hidden = false
            connectStatus.text = (model.connect ?? false) ? "已连接":"未连接"
            if robotM.admin?.characters.count > 0
            {
                adminStatus.hidden = false
                userBtn.setTitle(model.admin ?? "", forState: .Normal)
            }
            else
            {
                adminStatus.hidden = true
                
            }
            onlineStatus.text = model.online ?? false ? "在线": "离线"
            selectionStyle = .None
            addBorder(bgImgView)
        }
    }
    
    func addBorder(view:UIView)
    {
        view.layer.borderColor = UIColor(red: 136/255, green: 150/255, blue: 204/255, alpha: 1).CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5.0
        view.backgroundColor = UIColor(red: 7/255, green: 17/255, blue: 35/255, alpha: 0.5)
    }
    
    func reloadModel(model:Robot)
    {
        self.currentRobot = model
        self.setUp(model)
    }
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        snLabel.text = ""
//        onlineStatus.text = ""
//        accountId.text = ""
//        robotName.text = ""
//        adminStatus.text = ""
//        connectStatus.text = ""
//    }
}

