//
//  LYLog.swift
//  robosys
//
//  Created by 刘渊 on 2017/7/28.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

//全局函数
func LYLog<T>(_ message:T,file:String = #file,function:String = #function,line:Int = #line){
    
    #if DEBUG
    
        //获取文件名
    let fileName = (file as NSString).lastPathComponent
    //打印日志内容
        print("\(fileName):\(line) \(function) | \(message)")
    
    #endif
}


