//
//  Programming.swift
//  robosys
//
//  Created by yaorenjin on 2017/3/16.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class Programming: NSObject {

    var functionDic : NSMutableDictionary?
    var frameDic : NSMutableDictionary?
    var totalTime : Int?
    var saveName : String?
    var uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString
    var date : NSDate?
    var timerArr = [NSTimer(),NSTimer(),NSTimer(),NSTimer(),NSTimer(),NSTimer(),NSTimer(),NSTimer()]
    var imgDic = [Int:[UIImage]]()
    var indexArry = [Int:[Int]]()
    var scriptID = Int32()
    var isSelectBool = false
    
    static func createProgramming(functionDic:[Int:[(String,[String?],Int,Int)?]],frameDic:[Int:[CGRect]],totalTime: Int!,saveName: String) -> Programming {
        
        let programming = Programming()
        programming.functionDic = Programming.becomeFunctionDictionary(functionDic)
        programming.frameDic = Programming.becomeFrameDictionary(frameDic)
        programming.totalTime = totalTime;
        programming.saveName = saveName;
        return programming
    }
    
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(functionDic, forKey: "functionDic")
        aCoder.encodeObject(frameDic, forKey: "frameDic")
        aCoder.encodeObject(totalTime, forKey: "totalTime")
        aCoder.encodeObject(saveName!, forKey: "saveName")
        aCoder.encodeObject(uuid!, forKey: "uuid")
        aCoder.encodeObject(date!, forKey: "date")
        aCoder.encodeObject(timerArr, forKey: "timerArr")
        aCoder.encodeObject(imgDic, forKey: "imgDic")
        aCoder.encodeObject(indexArry, forKey: "indexArry")
        aCoder.encodeInt32(scriptID, forKey: "scriptID")

        
        
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        super.init()
        
        let tmpfunctionDic = aDecoder.decodeObjectForKey("functionDic") as? NSDictionary
        let tmpframeDic = aDecoder.decodeObjectForKey("frameDic") as? NSDictionary
        
        functionDic = NSMutableDictionary.init(dictionary: tmpfunctionDic!)
        frameDic = NSMutableDictionary.init(dictionary: tmpframeDic!)
        totalTime = aDecoder.decodeObjectForKey("totalTime") as? Int
        saveName = aDecoder.decodeObjectForKey("saveName") as? String
        uuid = aDecoder.decodeObjectForKey("uuid") as? String
        date = aDecoder.decodeObjectForKey("date") as? NSDate
        timerArr = aDecoder.decodeObjectForKey("timerArr") as! [NSTimer]
        imgDic = aDecoder.decodeObjectForKey("imgDic") as! [Int:[UIImage]]
        indexArry = aDecoder.decodeObjectForKey("indexArry") as! [Int:[Int]]
        scriptID = aDecoder.decodeIntForKey("scriptID")
    }
    
    static func becomeFunctionDictionary(dic:[Int:[(String,[String?],Int,Int)?]])->(NSMutableDictionary?)
    {
        let mutableDic = NSMutableDictionary()
        
        for i in 0..<8 {
            
            let mutableArry = NSMutableArray()
            
            let tmpArry = dic[i]
            
            let itemDic = NSMutableDictionary()
            
            for yz in tmpArry! {
                
                let value1 = yz?.0
                let value2 = yz?.1
                let value3 = yz?.2
                let value4 = yz?.3

                let value2Arry = NSMutableArray()
                for valu2Str in value2! {
                    value2Arry.addObject(valu2Str!)
                }
                
                itemDic.setObject(value1!, forKey: "0")
                itemDic.setObject(value2Arry, forKey: "1")
                itemDic.setObject(value3!, forKey: "2")
                itemDic.setObject(value4!, forKey: "3")

                mutableArry.addObject(itemDic)
            }
            
            mutableDic.setObject(mutableArry, forKey: String(i))
        }
        
        return mutableDic
    }
    
    static func toFunctionDictionary(dic:NSMutableDictionary)->([Int:[(String,[String?],Int,Int)?]]?)
    {
        var mutableDic : [Int:[(String,[String?],Int,Int)?]]? = [0:[],
                          1:[],
                          2:[],
                          3:[],
                          4:[],
                          5:[],
                          6:[],
                          7:[]]
        
        for i in 0..<8 {
            
            var mutableArry = [(String,[String?],Int,Int)?]()
            let tmpArry = dic.objectForKey(String(i))
            
            if tmpArry != nil {
                
                for tmpDic in tmpArry as! NSMutableArray {
                    
                    let value1 = tmpDic.objectForKey("0") as! String
                    let value2 = tmpDic.objectForKey("1")
                    let value3 = tmpDic.objectForKey("2") as! Int
                    let value4 = tmpDic.objectForKey("3") as! Int
                    var value2Arry = [String?]()
                    
                    for valu2Str in value2 as! NSMutableArray {
                        value2Arry.append(valu2Str as? String)
                    }
                    
                    let yz = (value1,value2Arry,value3,value4)
                    mutableArry.append(yz)
                    
                    mutableDic![i] = mutableArry
                }
            }
        }
        
        return mutableDic
    }
 
    static func becomeFrameDictionary(dic:[Int:[CGRect]])->(NSMutableDictionary?)
    {
        let mutableDic = NSMutableDictionary()
        
        for i in 0..<8 {
            
            let mutableArry = NSMutableArray()
            
            let tmpArry = dic[i]
            
            for rect in tmpArry! {
                
                let itemDic = NSMutableDictionary()
                itemDic.setObject(rect.origin.x, forKey: "x")
                itemDic.setObject(rect.origin.y, forKey: "y")
                itemDic.setObject(rect.size.width, forKey: "w")
                itemDic.setObject(rect.size.height, forKey: "h")
                mutableArry.addObject(itemDic)
            }
            
            mutableDic.setObject(mutableArry, forKey: String(i))
        }
        
        return mutableDic
    }
    
    static func toFrameDictionary(dic:NSMutableDictionary)->([Int:[CGRect]]?)
    {
        var mutableDic : [Int:[CGRect]]? = [
            0:[CGRect](),
            1:[CGRect](),
            2:[CGRect](),
            3:[CGRect](),
            4:[CGRect](),
            5:[CGRect](),
            6:[CGRect](),
            7:[CGRect](),
            ]
        
        for i in 0..<8 {
            
            var mutableArry = [CGRect]()
            let tmpArry = dic.objectForKey(String(i))
            
            if tmpArry != nil {
                
                for tmpDic in tmpArry as! NSMutableArray {
                    
                    let x = CGFloat(Double(tmpDic.objectForKey("x") as! NSNumber))
                    let y = CGFloat(Double(tmpDic.objectForKey("y") as! NSNumber))
                    let w = CGFloat(Double(tmpDic.objectForKey("w") as! NSNumber))
                    let h = CGFloat(Double(tmpDic.objectForKey("h") as! NSNumber))
                    
                    var rect = CGRect()
                    rect.origin.x = x
                    rect.origin.y = y
                    rect.size.width = w
                    rect.size.height = h
                    mutableArry.append(rect)
                    mutableDic![i] = mutableArry
                }
            }

        }
        
        return mutableDic
    }
    
    func setFunctionDic(dic:[Int:[(String,[String?],Int,Int)?]])
    {
        self.functionDic = Programming.becomeFunctionDictionary(dic)!
    }
    
    func setFrameDic(dic:[Int:[CGRect]]) {
        
        self.frameDic = Programming.becomeFrameDictionary(dic)!
    }
    
    func getFunctionDic() -> [Int:[(String,[String?],Int,Int)?]] {
        
        return  Programming.toFunctionDictionary(self.functionDic!)!
    }
    
    func getFrameDic()->([Int:[CGRect]]?)
    {
        return  Programming.toFrameDictionary(self.frameDic!)
    }
    
    override init()
    {
        super.init()
    }

    
}
