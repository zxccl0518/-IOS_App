//
//  ProgramViewTableViewCell.swift
//  robosys
//
//  Created by yaorenjin on 2017/3/17.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class ProgramViewTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        
        self.progressView.trackTintColor = UIColor.clearColor()
        self.progressView.backgroundColor = UIColor.clearColor()
                
        self.backImageView.layer.borderColor = UIColor(red: 136/255, green: 150/255, blue: 204/255, alpha: 1).CGColor
        self.backImageView.layer.borderWidth = 1.0
        self.backImageView.layer.cornerRadius = 5.0
        self.backImageView.backgroundColor = UIColor(red: 7/255, green: 17/255, blue: 35/255, alpha: 0.5)
        
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var zantingBtn: UIButton!
    @IBOutlet weak var tingzhiBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var backImageView: UIImageView!
    
    var currentModel : functionModel?
    
    @IBAction func selectBtnClick(sender: UIButton) {
        
        sender.selected = !sender.selected
        currentModel?.isSelectBool = sender.selected
        
        NSNotificationCenter.defaultCenter().postNotificationName("noticeNotAllSelect", object: nil)
    }
    
    @IBAction func playBtnClick(sender: AnyObject) {
        
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            
            let scriptId = Int32((self.currentModel?.scriptID)!)
            
            if self.currentModel?.currentTime != 0
            {
                //0--执行脚本 1--删除脚本 2--停止执行 3--暂停执行 4--恢复执行
                RobotControl.shareInstance().didExecScript(4, id: scriptId!)
            }
            else
            {
                print(NSThread.currentThread())
                RobotControl.shareInstance().didExecScript(0, id: scriptId!)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if self.currentModel?.timer == nil {
                    
                    self.currentModel?.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:#selector(ProgramViewTableViewCell.timeOut(_:)), userInfo: nil, repeats: true)
                }
                
            })
        }
    }
    
    func timeOut(time:NSTimer) {
        
        self.currentModel?.currentTime = (self.currentModel?.currentTime)! + 1
        self.handleProgressView()
    }
    
    @IBAction func zantingBtnClick(sender: AnyObject) {
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            
            let scriptId = Int32((self.currentModel?.scriptID)!)
            RobotControl.shareInstance().didExecScript(3, id: scriptId!)
            
            dispatch_async(dispatch_get_main_queue(), {

                self.currentModel?.timer?.invalidate()
                self.currentModel?.timer = nil

            })
        }
    }
    
    @IBAction func tingzhiBtnClick(sender: AnyObject) {
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            
            let scriptId = Int32((self.currentModel?.scriptID)!)
            RobotControl.shareInstance().didExecScript(2, id: scriptId!)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.currentModel?.currentTime = 0
                self.currentModel?.timer?.invalidate()
                self.currentModel?.timer = nil
                self.handleProgressView()
                
            })
        }
    }
    
    func reloadData(model:functionModel) {
        
        currentModel = model
        
        if let name = model.name
        {
            nameLabel.text = "\(name)"
        }
        if let time = model.totalTime
        {
            timeLabel.text = time
        }
        if let date = model.date
        {
            let fmt =  NSDateFormatter()
            fmt.dateFormat = "yyyyMMdd"
            
            if let temp = fmt.dateFromString(date)
            {
                fmt.dateFormat = "yyyy/MM/dd"
                dateLabel.text = fmt.stringFromDate(temp)
            }
        }
        
        self.selectedBtn.selected = (currentModel?.isSelectBool)!

        self.handleProgressView()
    }
    
    func handleProgressView() {
        
        let totalTimeArry = currentModel?.totalTime.stringByReplacingOccurrencesOfString("\"", withString: "").componentsSeparatedByString("\'")
        let m = totalTimeArry?.first
        let s = totalTimeArry?.last
        let mInt = Int(m!) ?? 0
        let sInt = Int(s!) ?? 0
        let totalInt = mInt*60 + sInt
        
        //如果当前时间和total时间相等 说明已经播放完毕。
        if (currentModel?.currentTime)! == totalInt {
            
            currentModel?.currentTime = 0
            self.currentModel?.timer?.invalidate()
            self.currentModel?.timer = nil
        }
        
        self.progressView.progress = Float((currentModel?.currentTime)!)/Float(totalInt)
        
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        
        super.setHighlighted(highlighted, animated: animated)
    
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

   
        // Configure the view for the selected state
    }
}
