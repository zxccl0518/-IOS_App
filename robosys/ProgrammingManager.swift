//
//  ProgrammingManager.swift
//  robosys
//
//  Created by yaorenjin on 2017/3/16.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class ProgrammingManager: NSObject {

    
    static let shareManager = ProgrammingManager()
    //key是用户id  value是robot数组
    var programmingLocationArry : NSMutableArray?
    
    let ProgrammingLocationFileName = "ProgrammingLocation.data"
    override init() {
        
        super.init()
        
        self.programmingLocationArry = self.unarchiveObject()
    }
    
    /** 归档*/
    func archiveObject()
    {
        let finish = NSKeyedArchiver.archiveRootObject(self.programmingLocationArry!, toFile:RobotManager.filePathWithFileName(ProgrammingLocationFileName))
        
        if finish {
            
            print("归档成功")
        }
    }
    
    /** 解压归档*/
    func unarchiveObject()->(NSMutableArray)
    {
        let tmpProgrammingtArry = NSKeyedUnarchiver.unarchiveObjectWithFile(RobotManager.filePathWithFileName(ProgrammingLocationFileName)) as? NSArray
        var arry = NSMutableArray()
        
        if tmpProgrammingtArry != nil {
            
            arry = NSMutableArray.init(array: tmpProgrammingtArry!)
        }
    
        return arry
    }
    
    //添加编程
    func addProgramming(programming:Programming)
    {
        programming.date = NSDate()
        self.programmingLocationArry?.addObject(programming)
        self.archiveObject()
    }
    
    //更新编程
    func updateProgramming(programming:Programming)
    {
//        var willDeleteProgramming : Programming?
//        
//        for tmpProgramming  in self.programmingLocationArry! {
//            
//            if (tmpProgramming as! Programming).uuid == programming.uuid {
//                
//                willDeleteProgramming = tmpProgramming as? Programming;
//                break;
//            }
//        }
//        
//        if willDeleteProgramming != nil {
//            
//            self.programmingLocationArry?.removeObject(willDeleteProgramming!)
//        }
        
        
        programming.date = NSDate()
//        self.programmingLocationArry?.insertObject(programming, atIndex: 0)
    
        self.archiveObject()
    }
    
    //删除编程
    func deleteProgramming(programming:Programming)
    {
        var willDeleteProgramming : Programming?
        
        for tmpProgramming  in self.programmingLocationArry! {
            
            if (tmpProgramming as! Programming).uuid == programming.uuid {
                
                willDeleteProgramming = tmpProgramming as? Programming;
                break;
            }
        }
        
        if willDeleteProgramming != nil {
            
            self.programmingLocationArry?.removeObject(willDeleteProgramming!)
        }
        
        self.archiveObject()
    }
    
    //搜索编程
    func selectProgramming()->(NSMutableArray)
    {
        return self.programmingLocationArry!;
    }
}
