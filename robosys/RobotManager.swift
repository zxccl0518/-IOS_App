//
//  RobotManager.swift
//  robosys
//
//  Created by yaorenjin on 2017/3/6.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit


class RobotManager: NSObject {

    
    static let shareManager = RobotManager()
    //key是用户id  value是robot数组
    var robotConnectedDic : NSMutableDictionary?
    let RobotArchiveFileName = "robotConnectedDic.archiver"
    override init() {
        
        super.init()
        
        self.robotConnectedDic = self.unarchiveObjectRobotDic()
    }
    
    func changeCurrentRobotSate()
    {
        let loginM = loginModel.sharedInstance

        let robotArry = self.getCurrentUserConnectedRobotArry()
        
        for robot in robotArry! {
            
            if (robot as! Robot).robotId != nil && ((robot as! Robot).robotId != loginM.robotId)
            {
                (robot as! Robot).online = false
                (robot as! Robot).connect = false
            }
        }
    }
    
    
    /** 在线状态*/
     func robotOnlineState(robotId:String?,netFinished: (NSArray)->()) {
        
        let robotConnet = RobotConnect.shareInstance()
        let loginM = loginModel.sharedInstance
        
            
            var robotIdString = robotId
            //如果robotId等于空
            if robotIdString == nil {
                robotIdString = loginM.robotId
            }
            else{
                robotIdString = robotId
            }
        
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
        
            print("robotIdStringrobotIdStringrobotIdStringrobotIdStringrobotIdString  \(robotIdString)")
            
            //60s判断机器人上线
            let res = robotConnet.didReset(loginM.num, token: loginM.token,robotId:robotIdString,isLogin:false)
            
            print("res ======== ++++++ \(res)")
            
            dispatch_async(dispatch_get_main_queue(), {
                print("res++++++++++++ \(res)")
                let resArry = NSArray.init(array: res)
                netFinished(resArry)
            })
            
            print("+++++++1 ")
        }
    }
    
    /** 连接机器人*/
    func connectRobot(robotId:String?,netFinished: (Int)->()) {
        
        let robotConnet = RobotConnect.shareInstance()
        let loginM = loginModel.sharedInstance
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {

            var robotIdString = robotId
            
            //如果robotId等于空
            if robotIdString == nil {
                robotIdString = loginM.robotId
            }
            else{
                robotIdString = robotId
            }
        

            //连接在线机器人
            let status = robotConnet.didConnRobot(loginM.token, userName: loginM.num, robotId: robotIdString).firstObject as! Int
            
            dispatch_async(dispatch_get_main_queue(), {
        
                print("链接在线机器人&&&&&&&&&&&&&&")
                
                netFinished(status)
            })
        }
    }
    
    /** 查看连接此机器人关联的人*/
    func didQueryUserList(robotId:String?,netFinished: (NSDictionary)->())
    {
        let robotConnet = RobotConnect.shareInstance()
        let loginM = loginModel.sharedInstance
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            
            var robotIdString = robotId
            //如果robotId等于空
            if robotIdString == nil {
                robotIdString = loginM.robotId
            }
            else{
                robotIdString = robotId
            }
            
            let retDic = robotConnet.didQueryUserList(loginM.num, token: loginM.token, robotId:loginM.robotId) as NSDictionary
            
            dispatch_async(dispatch_get_main_queue(), {
                
                netFinished(retDic)
            })
        }
    }
    
    /** 查看连接此机器人关联的人*/
    func bindingRobot(robotId:String?,isAdmin:Bool,netFinished: (Int32)->())
    {
        let robotConnet = RobotConnect.shareInstance()
        let loginM = loginModel.sharedInstance
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            
            var robotIdString = robotId
            //如果robotId等于空
            if robotIdString == nil {
                robotIdString = loginM.robotId
            }
            else{
                robotIdString = robotId
            }
            
            let admin : Int32 = isAdmin ? 1 : 0
            
            let bindingCode = robotConnet.didBind(loginM.num,token:loginM.token,robotId:robotIdString, admin:admin)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                netFinished(bindingCode)
            })
        }
    }
    
    /** 保存robotId */
    func saveRobotId(robotId:String?)
    {
        let loginM = loginModel.sharedInstance
        var robotIdString : String? = robotId
        if robotIdString == nil || (robotId?.isEmpty)!{
            robotIdString = loginM.robotId
        }
        
        let robotKey = "user_\(loginM.num)_robosys_robotId"
        NSUserDefaults.standardUserDefaults().setObject(robotIdString, forKey:robotKey)
        
        
        self.changeCurrentRobotSate()
        
    }
    
    /**  获取robotId */
    func getSaveRobotId()->(String?)
    {
        let loginM = loginModel.sharedInstance
        let robotKey = "user_\(loginM.num)_robosys_robotId"
        return NSUserDefaults.standardUserDefaults().objectForKey(robotKey) as? String
    }
    
    //添加机器人
    func addRobotModel(robot:Robot)
    {
        var robotArry = self.robotConnectedDic!.objectForKey(loginModel.sharedInstance.num)
        if robotArry == nil {
            robotArry = NSMutableArray()
            self.robotConnectedDic?.setObject(robotArry!, forKey: loginModel.sharedInstance.num)
        }
        
        robot.createTime = NSDate()
        var isHaveSameRobotBool = false
        var i = 0
        for rb in robotArry as! NSMutableArray{
            let tmpRobot : Robot =  rb as! Robot
            
            print("\(tmpRobot.robotId) \(robot.robotId)")
            if (tmpRobot.robotId != nil) && (tmpRobot.robotId == robot.robotId) {
                isHaveSameRobotBool = true
                break;
            }
            i += 1
        }
        
        if isHaveSameRobotBool {
            (robotArry as! NSMutableArray).removeObjectAtIndex(i)
        }
        
        (robotArry as! NSMutableArray).insertObject(robot, atIndex: 0)

        self.archiveRootObjectRobotDic()
    }
    
    /** 归档*/
    func archiveRootObjectRobotDic()
    {
        let finish = NSKeyedArchiver.archiveRootObject(self.robotConnectedDic!, toFile:RobotManager.filePathWithFileName(RobotArchiveFileName))
        
        if finish {
            
            print("归档成功")
        }
    }
    
    /** 解压归档*/
    func unarchiveObjectRobotDic()->(NSMutableDictionary)
    {
        let tmpRobotDic = NSKeyedUnarchiver.unarchiveObjectWithFile(RobotManager.filePathWithFileName(RobotArchiveFileName)) as? NSDictionary
        let mutableRobotDic = NSMutableDictionary()
        if nil != tmpRobotDic {
            print("解档成功")
            mutableRobotDic.setDictionary(tmpRobotDic as! [NSObject : AnyObject])
        }
        
        return mutableRobotDic
    }
    
    //获取机器人列表
    func getCurrentUserConnectedRobotArry()->(NSMutableArray?)
    {
        let loginM = loginModel.sharedInstance
        return self.robotConnectedDic!.objectForKey(loginM.num) as? NSMutableArray;
    }
    
    static func filePathWithFileName(fileName:String)->(String)
    {
        let home = NSHomeDirectory() as NSString;
        let docPath = home.stringByAppendingPathComponent("Documents") as NSString;
        let filePath = docPath.stringByAppendingPathComponent(fileName);
        return filePath
    }

    
    //获取机器人信息
    func getRobotInfo()
    {
        let loginM = loginModel.sharedInstance
        let robotM = robotModel.sharedInstance
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            //获取机器人属性
            let dic = RobotControl.shareInstance().didGetRobotAttr()
            
            dispatch_async(dispatch_get_main_queue(), {
        
                if dic.count > 0
                {
                    robotM.name = dic.valueForKey("robotName") as? String
                    
                    if robotM.name == "" {
                        robotM.name = "小盒"
                    }
                    
                    robotM.admin = dic.valueForKey("masterName") as? String
                    robotM.birthday = dic.valueForKey("birthday") as? String
                    robotM.pet_phrase = dic.valueForKey("mantra") as? String
                    
                    robotM.gender = "\((dic.valueForKey("sex") as? Int) ?? -1)"
                    robotM.star = "\((dic.valueForKey("constellation") as? Int) ?? -1)"
                    robotM.voice = "\((dic.valueForKey("speakType") as? Int) ?? -1)"
                    robotM.speed = dic.valueForKey("speakSpeed") as? Int32
                }
        
                
                let robot = Robot.becomeRobotModel(robotM, robotId: loginM.robotId)
                
                //添加机器人
                RobotManager.shareManager.addRobotModel(robot)
                
                RobotManager.shareManager.saveRobotId(nil)
                
            })
        }
    }
    
    //获取机器人信息
    func getCurrentRobotArry()->(NSMutableArray?)
    {
        let loginM = loginModel.sharedInstance
        var currentRobotArry = self.robotConnectedDic!.objectForKey(loginM.num) as? NSMutableArray
        
        if currentRobotArry == nil {
            
            currentRobotArry = NSMutableArray()
        }
        return currentRobotArry
    }
}

