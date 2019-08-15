//
//  WifiModel.swift
//  robosys
//
//  Created by max.liu on 2017/5/12.
//  Copyright © 2017年 joekoe. All rights reserved.
/*
 AccessPoint = "F0:B4:29:F9:94:75";
 Cells =     (
 {
 Address = "F0:B4:29:F9:94:75";
 Channel = 1;
 ESSID = Robosys;
 Encryption = on;
 Frequency = "2.412 GHz";
 Password = roborobogo;
 Quality = 5;
 Registered = yes;
 },
 {
 Address = "30:B4:9E:3F:4D:72";
 Channel = 1;
 ESSID = "candys.cheng391";
 Encryption = on;
 Frequency = "2.412 GHz";
 Quality = 1;
 Registered = no;
 },
 {
 Address = "78:D3:8D:C2:B2:A4";
 Channel = 1;
 ESSID = "Master Room";
 Encryption = on;
 Frequency = "2.412 GHz";
 Quality = 2;
 Registered = no;
 },
 {
 Address = "28:6C:07:9B:65:2E";
 Channel = 2;
 ESSID = "JR Home";
 Encryption = on;
 Frequency = "2.417 GHz";
 Quality = 2;
 Registered = no;
 },
 {
 Address = "C8:3A:35:5C:0A:48";
 Channel = 4;
 ESSID = "House-2F";
 Encryption = on;
 Frequency = "2.427 GHz";
 Quality = 1;
 Registered = no;
 },
 {
 Address = "D4:EE:07:3E:4D:72";
 Channel = 4;
 ESSID = "HiWiFi_3E4D72";
 Encryption = on;
 Frequency = "2.427 GHz";
 Quality = 2;
 Registered = no;
 },
 {
 Address = "30:B4:9E:3F:4D:0A";
 Channel = 9;
 ESSID = groupctrl391;
 Encryption = on;
 Frequency = "2.452 GHz";
 Quality = 4;
 Registered = no;
 },
 {
 Address = "28:6C:07:9C:DD:23";
 Channel = 12;
 ESSID = "Robosys-PC";
 Encryption = on;
 Frequency = "2.467 GHz";
 Quality = 5;
 Registered = no;
 },
 {
 Address = "1C:60:DE:54:F3:5C";
 Channel = 11;
 ESSID = "Robosys-demo";
 Encryption = on;
 Frequency = "2.462 GHz";
 Quality = 1;
 Registered = no;
 }
 );
 ESSID = Robosys;
 Frequency = "2.412 GHz";
 Mode = Managed;
 Quality = 5;
 SN = B10CN7180135;
 */


//小盒的wifi信息

import UIKit

class WifiModel: NSObject {
    
    
    //AccessPoint : "F0:B4:29:F9:94:75"
    var AccessPoint : String?
    
    //wifi名称
    var ESSID : String?
    
    //Frequency
    var Frequency : String?
    
    //模式 managed -> master 定义成 结构体
    var Mode : String?
    
    //质量
    var Quality : Int64 = 0
    
    //小盒SN号码
    var SN : String?
    
    //所有cell数组
    var Cells : [CellWifiModel]?
    
    //指定容器类属性
//    class func modelContainerPropertyGenericClass() -> [String: Any] {
//        
//        return [
//            "Cells": CellWifiModel.self
//        ]
//    }
    
    static func modelContainerPropertyGenericClass() ->[String : AnyObject]? {
        return ["Cells":CellWifiModel.self]
    }
    
    override var description: String {
        return self.yy_modelDescription()
    }
    
}
