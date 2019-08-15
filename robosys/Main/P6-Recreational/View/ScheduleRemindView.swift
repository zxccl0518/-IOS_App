//
//  ScheduleRemindView.swift
//  robosys
//
//  Created by Cheer on 16/7/15.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class ScheduleRemindView: AppView
{
    @IBOutlet weak var table: UITableView!
    
    internal var dataArr = NSMutableArray()
    {
        didSet
        {
            modelArr = [scheduleModel]()
            
            for i in 0..<dataArr.count
            {
                let model = scheduleModel.createInstance()

                var tempTime = ""
                
                if let id = dataArr[i]["id"] as? String
                {
                   model.ID = id
                }
                if var time = dataArr[i]["time"] as? String where time.characters.count > 10
                {
                    //修复小时的问题
                    let count =  12 - time.characters.count
                    
                    for _ in 0..<count
                    {
                        time.insert("0", atIndex:time.startIndex.advancedBy(8))
                    }
                    
                    tempTime = time
                    
                    time.insert("年", atIndex:time.startIndex.advancedBy(4))
                    time.insert("月", atIndex:time.startIndex.advancedBy(7))
                    time.insert("日", atIndex:time.startIndex.advancedBy(10))
                    time.insert("时", atIndex:time.startIndex.advancedBy(13))
                    time.insert("分", atIndex:time.startIndex.advancedBy(16))

                    model.time = NSDate.formateDate(time, formate: "yyyy年MM月dd日HH时mm分")
                }
                if let _ = dataArr[i]["date"] as? String
                {
                    var temp = " "
                    var temp1 = ""
                    var arr = [Character]()
                    
                    for c in tempTime.characters
                    {
                        arr.append(c)
                    }
                    
                    for index in 0..<arr.count
                    {
                        switch index {
                            
                        case 3,5:
                            
                            temp += "\(arr[index])"
                            temp += "."
                        
                        case 8,9,10,11:
                            
                            if index == 10
                            {
                                temp1 += "."
                            }
                            
                            temp1 += "\(arr[index])"
                            
                        default:temp += "\(arr[index])"
                        }
                        
                        
                    }
                    
                    model.date =  temp1 + temp
                    
                
                }
                if var repeats = dataArr[i]["repeat"] as? String
                {
                    switch repeats
                    {
                    case "0":
                        repeats = "不重复"
                    case "1":
                        repeats = "每天"
                    case "2":
                        repeats = "每周"
                    case "3":
                        repeats = "每两周"
                    case "4":
                        repeats = "每月"
                    case "5":
                        repeats = "每年"
                    default:
                        break
                    }
                    model.repeats = repeats
                }
                if var remind = dataArr[i]["remind"] as? String
                {
                    switch remind {
                    case "0":
                        remind = "正点提醒"
                    case "1":
                        remind = "5分钟前"
                    case "2":
                        remind = "10分钟前"
                    case "3":
                        remind = "15分钟前"
                    case "4":
                        remind = "30分钟前"
                    case "5":
                        remind = "1小时前"
                    case "6":
                        remind = "2小时前"
                    case "7":
                        remind = "1天前"
                    case "8":
                        remind = "2天前"
                    case "9":
                        remind = "1周前"
                    default:
                        break
                    }
                    model.remind = remind
                }
                if let content = dataArr[i]["content"] as? String
                {
                    model.name = content
                }

                modelArr.append(model)
            
//                control.didDeleteAlarm(Int32(dataArr[i]["id"]! as! String)!)
            }
            
            modelArr = modelArr.sort({ (pre:scheduleModel, next:scheduleModel) -> Bool in
                if pre.date.componentsSeparatedByString(" ").last > next.date.componentsSeparatedByString(" ").last{
                    return true
                }
                else
                {
                    if pre.date.componentsSeparatedByString(" ").first > next.date.componentsSeparatedByString(" ").first{
                        return true
                    }
                }
                return false
            })
            dispatch_async(dispatch_get_main_queue()) {
                self.table.reloadData()
            }
        }
    }
    private var modelArr:[scheduleModel]!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView(robotM.name ?? "", imageName: "返回")
        
//        if dataArr.count != 0{
//            
//            table.hidden = false
//        }else{
//            
//            table.hidden = true
//            table.delegate = nil
//        }
    }
    
    //点击新建
    @IBAction func addRemind(sender: UIButton)
    {
        if networkM.isConnectRobot && robotM.online! {
            
            let vc = NewScheduleViewController(nibName: "NewScheduleView", bundle: nil)
            jump2AnyController(vc)
            
        } else {
            Alert({}, title: "请连接在线机器人", message: "")
        }
    }
}

extension ScheduleRemindView
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("dataArr.count+++++tableView++++++\(dataArr.count)")
        
        return dataArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UINib(nibName: "ScheduleRemindCell", bundle: nil).instantiateWithOwner(nil, options: nil).first as! ScheduleRemindCell
        
//        if indexPath.row < 0 {
//            return cell
//        }
        
        if indexPath.row < dataArr.count
        {
            if modelArr != nil{
                
                cell.scheduleM = modelArr[indexPath.row]
            }
        }
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if networkM.isConnectRobot && robotM.online! {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! ScheduleRemindCell
            
            let vc = NewScheduleViewController(nibName: "NewScheduleView", bundle: nil)
            (vc.view as! NewScheduleView).scheduleM = cell.scheduleM
            (vc.view as! NewScheduleView).index = indexPath.row
            (vc.view as! NewScheduleView).modelArr = modelArr
            jump2AnyController(vc)
        } else {
            Alert({}, title: "请连接网络", message: "")
        }
    }
}
