//
//  AppModel.swift
//  robosys
//
//  Created by Cheer on 16/5/20.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class  AppModel: NSObject {
    
}


class titleModel : NSObject{
    
    static let sharedInstance = titleModel()
    private override init(){}
    
    //保存的按钮文字是否有值 如果没有值正常显示
    var title : String! = ""
    
}

class  networkModel: NSObject
{
    static let sharedInstance = networkModel()
    private override init(){}
    
    /*联网状态*/
    var state:Bool! = false
    /*控制连接*/
    var isConnectRobot:Bool = false
}
class  registModel: NSObject
{
    static let sharedInstance = registModel()
    private override init(){}
    
    /*性别*/
    var isMale:Bool = true
    /*出生年月日*/
    var birthday:String! = ""
    /*名字*/
    var name:String! = ""
    /*注册时间*/
    var createTime:String! = ""
    
}
class  loginModel: NSObject
{
    static let sharedInstance = loginModel()
    private override init(){}
    
    /*token*/
    var token:String!
    /*手机号*/
    var num:String!
    /*id*/
    var robotId:String!
    /*自动登陆?*/
    var isAutoLogin:Bool = NSUserDefaults.standardUserDefaults().boolForKey("isAutoLogin")
    {
        didSet
        {
            NSUserDefaults.standardUserDefaults().setBool(isAutoLogin, forKey: "isAutoLogin")
        }
    }
    /*连接机器人个数*/
    var robotCount:Int!
    
    //演示模式
    var showdemo:String!? = ""
}

class  robotModel: NSObject
{
    static let sharedInstance = robotModel()
    private override init(){}
    
    /*姓名*/
    var name:String?
    /*管理员状态*/
    var admin:String?
    
    
    /*在线状态*/
    var online:Bool? 
    /*显示连接*/
    var connect:Bool?

    /*性别*/
    var gender:String?
    {
        didSet
        {
            switch gender!
            {
            case "1": gender = "男"
            case "2": gender = "女"
                
            default:gender = ""
            }
        }
    }
    /*星座*/
    var star:String?
    {
        didSet
        {
            switch star!
            {
            case "0": star = "白羊座"
            case "1": star = "金牛座"
            case "2": star = "双子座"
            case "3": star = "巨蟹座"
            case "4": star = "狮子座"
            case "5": star = "室女座"
            case "6": star = "天秤座"
            case "7": star = "天蝎座"
            case "8": star = "人马座"
            case "9": star = "摩羯座"
            case "10": star = "宝瓶座"
            case "11": star = "双鱼座"
                
            default:star = ""
            }
        }
    }
    /*生日*/
    var birthday:String?
    /*音色*/
    var voice:String?
    {
        didSet
        {
            switch voice!
            {
            case"0":voice = "男孩"
            case"1":voice = "女孩"
            case"2":voice = "志玲"
                
            default:voice = ""
            }
        }
    }
    /*语速*/
    var speed:Int32?
    /*唤醒词*/
    var wakeWord:String?
    /*口头禅*/
    var pet_phrase:String?
    
    //设置robot属性
    func setRobotModel(robot:Robot) {
    
        name = robot.name
        admin = robot.admin
        online = robot.online
        connect = robot.connect
        gender = robot.gender
        star = robot.star
        birthday = robot.birthday
        voice = robot.voice
        speed = robot.speed
        wakeWord = robot.wakeWord
        pet_phrase  = robot.pet_phrase
        
    }

}


class functionModel: NSObject//,NSCoding
{
        var scriptID:String!
        var totalTime:String!
        var name:String!
        var date:String!
        var isSelectBool = false
        var timer : NSTimer?
        var currentTime = 0
    
    init(id:String,time:String,name:String,date:String)
    {
        (self.scriptID,self.totalTime,self.name,self.date) = (id,time,name,date)
        
    }
}

class scheduleModel: NSObject//,NSCoding
{
//    static var instance = scheduleModel()
//    
//    private override init(){}
    
    /*ID*/
    var ID:String!
    /*事件名*/
    var name:String!
    /*开始时间*/
    var date:String!
    /*提醒时长*/
    var time:String!
    /*重复*/
    var repeats:String!
    /*提醒*/
    var remind:String!
        
    class func createInstance()->scheduleModel
    {
        return scheduleModel()
    }
}

class MusicModel: NSObject {
    
    static let sharedInstance = MusicModel()
    private override init(){}
    
    var isPlaying:Bool = false
    // 儿歌
    var songList = NSMutableArray()
    var songPath = String()
    // 国学
    var chinaList = NSMutableArray()
    var chinaPath = String()
    // 故事
    var storyList = NSMutableArray()
    var storyPath = String()
    // 百科
    var encycList = NSMutableArray()
    var encycyPath = String()
    // 诗词
    var poetryList = NSMutableArray()
    var poetryPath = String()
    // 音乐
    var musicList = NSMutableArray()
    var musicPath = String()
    
    
    // 最近播放
    var musicListHistory = NSMutableArray()
    // 判断是历史播放列表还是歌单
    var cellListSouce = String()
}


