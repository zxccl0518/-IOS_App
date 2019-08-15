//
//  Robot.swift
//  robosys
//
//  Created by yaorenjin on 2017/3/7.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class Robot: NSObject,NSCoding{

    var robotId:String?
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
    var createTime:NSDate?
    
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(robotId, forKey: "robotId")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(admin, forKey: "admin")
        aCoder.encodeBool(online!, forKey: "online")
        aCoder.encodeBool(connect!, forKey: "connect")
        if speed != nil {
            aCoder.encodeInt(speed!, forKey: "speed")
        }
        aCoder.encodeObject(gender, forKey: "gender")
        aCoder.encodeObject(star, forKey: "star")
        aCoder.encodeObject(birthday, forKey: "birthday")
        aCoder.encodeObject(voice, forKey: "voice")
        aCoder.encodeObject(wakeWord, forKey: "wakeWord")
        aCoder.encodeObject(pet_phrase, forKey: "pet_phrase")
        aCoder.encodeObject(createTime, forKey: "createTime")
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        super.init()
        
        robotId = aDecoder.decodeObjectForKey("robotId")as?String
        name = aDecoder.decodeObjectForKey("name")as?String
        admin = aDecoder.decodeObjectForKey("admin")as?String
        online = aDecoder.decodeBoolForKey("online")
        connect = aDecoder.decodeBoolForKey("connect")
        gender = aDecoder.decodeObjectForKey("gender")as?String
        star = aDecoder.decodeObjectForKey("star")as?String
        birthday = aDecoder.decodeObjectForKey("birthday")as?String
        voice = aDecoder.decodeObjectForKey("voice")as?String
        wakeWord = aDecoder.decodeObjectForKey("wakeWord")as?String
        pet_phrase = aDecoder.decodeObjectForKey("pet_phrase")as?String
        createTime = aDecoder.decodeObjectForKey("createTime")as?NSDate
    }
    
    override init()
    {
        super.init()
    }
    
    
    static func becomeRobotModel(model:robotModel,robotId:String) -> (Robot) {
        
        let robot = Robot()
        robot.name = model.name
        robot.admin = model.admin
        robot.online = false
        robot.connect = false
        robot.gender = model.gender
        robot.star = model.star
        robot.birthday = model.birthday
        robot.voice = model.voice
        robot.speed = model.speed
        robot.wakeWord = model.wakeWord
        robot.pet_phrase = model.pet_phrase
        robot.robotId = robotId
        return robot
    }
}


