//
//  ProgramView.swift
//  robosys
//
//  Created by Cheer on 16/5/31.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class ProgramView: AppView
{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var borderView: UIImageView!
    
    
    private lazy var alertView:UIView =
        {
            let view = UIView(frame: CGRectMake(0,0,300,240))
            
            let imgBg = UIImageView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
            imgBg.image = UIImage(named: "WiFi弹窗")
            
            
            let ensureBtn = UIButton(frame: CGRectMake(20,140,300 - 40,40))
            ensureBtn.setTitle("查看", forState: .Normal)
            ensureBtn.setBackgroundImage(UIImage(named: "小蓝按钮"), forState: .Normal)
            ensureBtn.addTarget(self, action: #selector(ProgramView.click(_:)), forControlEvents: .TouchUpInside)
            ensureBtn.center.x = view.center.x
            ensureBtn.highlighted = true
            
            let cancelBtn = UIButton(frame: CGRectMake(20,190,300 - 40,40))
            cancelBtn.setTitle("编辑", forState: .Normal)
            cancelBtn.setBackgroundImage(UIImage(named: "小橙按钮"), forState: .Normal)
            cancelBtn.addTarget(self, action: #selector(ProgramView.click(_:)), forControlEvents: .TouchUpInside)
            cancelBtn.center.x = view.center.x
            
            view.addSubview(imgBg)
//            view.addSubview(contentLabel)
            view.addSubview(ensureBtn)
            view.addSubview(cancelBtn)
            
            return view
            
    }()
    
    internal var model:functionModel!
    {
        didSet
        {

            if let name = model.name
            {
                nameLabel.text = "\(name)"
            }
            if let time = model.totalTime
            {
                timeLabel.text = "时长:" + time
            }
            if let date = model.date
            {
                let fmt =  NSDateFormatter()
                fmt.dateFormat = "yyyyMMdd"
                
                if let temp = fmt.dateFromString(date)
                {
                    fmt.dateFormat = "yyyy年MM月dd日"
                    dateLabel.text = fmt.stringFromDate(temp)
                }
            }
        }
    }
    
    private var isValid:Bool = true
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        selectBtn.setImage(UIImage(named: "性别选择"), forState: .Selected)
        playBtn.setImage(UIImage(named: "暂停"), forState: .Selected)
        addBorder(borderView)
    }

    @IBAction func handleGesture(sender: UILongPressGestureRecognizer)
    {
        alertView.center = superview!.center
        
    }
    
    @IBAction func clickSelect(sender: UIButton)
    {
        if let myProgramView = superview?.superview?.superview?.superview as? MyProgramView
        {
            //置回非选择
            if myProgramView.allSelectBtn.selected
            {
                myProgramView.allSelectBtn.selected = false
            }
            //排除bug
            if myProgramView.tempCount == myProgramView.dataArr.count && sender.selected == false
            {
                myProgramView.tempCount = 0
            }
            myProgramView.tempCount += sender.selected ? -1 : 1
            
            selectBtn.selected = !selectBtn.selected
            
//            clickSelected()
            
            myProgramView.deleteBtn.setTitle(myProgramView.tempCount > 1 ? "删除(\(myProgramView.tempCount))" : "删除", forState: .Normal)
        }
    }
    
    @IBAction func clickplay(sender: UIButton)
    {
        print("program------11111");
        
        guard networkM.isConnectRobot else
        {
            Alert({}, title: "请连接机器人", message: "")
            return
        }
        
        print("program------22222");
        
        playBtn.selected = !playBtn.selected
        
        
        //2--停止执行 3--暂停执行 4--恢复执行
        if let myProgramView = superview?.superview?.superview?.superview as? MyProgramView
        {
            print("program------33333");
            if let program = myProgramView.lastPrgram
            {
                print("program------44444");
                myProgramView.timer.invalidate()
                
                RobotControl.shareInstance().didExecScript(2, id: Int32(model.scriptID)!)
                
                program.recovery()
            }
            
            if isValid
            {
                print("program------55555");
                imgV.frame.size.width = 0
                
                myProgramView.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ProgramView.changeBgColor(_:)), userInfo:model.totalTime, repeats: true)
                
                RobotControl.shareInstance().didExecScript(0, id: Int32(model.scriptID)!)
                
                isValid = false
                
                myProgramView.lastPrgram = self
            }
            
            if !playBtn.selected
            {
                print("program------66666");
                myProgramView.timer.fireDate = NSDate.distantFuture()
                
                RobotControl.shareInstance().didExecScript(3, id: Int32(model.scriptID)!)
            }
            else
            {
                print("program------77777");
                myProgramView.timer.fireDate = NSDate.distantPast()
                
                RobotControl.shareInstance().didExecScript(4, id: Int32(model.scriptID)!)
            }
            print("program------88888");
    
        }
        print("program------99999");
    }

    func changeBgColor(timer:NSTimer)
    {
        print("program------aaaaa");
        
        print("===the:\((timer.userInfo)!)");
        print("===the:\((timer.userInfo)!.doubleValue)");
        
        let str = "\(timer.userInfo)".stringByReplacingOccurrencesOfString("\"", withString: "'") ?? ""
        let array = str.componentsSeparatedByString("'")
        let res = CGFloat(Int(array[1]) ?? 0)
        
//        print("sfvdst====:\(res)")
//        print("sfvdst====:\(array[1])")
        
        imgV.frame.size.width +=  300 / res
        
        
//        imgV.frame.size.width +=  300 / CGFloat((timer.userInfo)!.doubleValue)
        
        if imgV.frame.size.width >= 300
        {
            print("program------bbbbb");
            timer.invalidate()
            isValid =  true
            imgV.frame.size.width = 0
            playBtn.selected = false
        }
    }
    
    func clickSelected()
    {
        imgV.backgroundColor =  selectBtn.selected ? .blueColor() : .clearColor()
    }
    
    func click(sender:UIButton)
    {
        if sender.highlighted
        {
            
        }
        dismiss()
    }
    
    func recovery()
    {
        playBtn.selected = false
        isValid = true
        imgV.frame.size.width = 0
    }
}
