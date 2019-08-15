//
//  InFoWifiModel.swift
//  robosys
//
//  Created by max.liu on 2017/5/12.
//  Copyright © 2017年 joekoe. All rights reserved.
/*
 Address = "F0:B4:29:F9:94:75";
 Channel = 1;
 ESSID = Robosys;
 Encryption = on;
 Frequency = "2.412 GHz";
 Password = roborobogo;
 Quality = 5;
 Registered = yes;
 */

import UIKit

//每一个cell的数据
class CellWifiModel: NSObject {
    
    var Address : String?
    
    var Channel : NSNumber?
    
    var ESSID : String?
    
    var Frequency : String?
    
    var Password : String?
    
    var Quality : NSNumber?
    
    var Registered : NSNumber?

    //是否上锁
    var Encryption : String?
    
//    init(dict: [String : AnyObject]) {
//        super.init()
//        
//        setValuesForKeysWithDictionary(dict)
//    }
//    
//    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
//        
//    }
//    
    
    override var description: String {
        return self .yy_modelDescription()
    }
    
}
