//
//  ScheduleRemindCell.swift
//  robosys
//
//  Created by Cheer on 16/7/21.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class ScheduleRemindCell: UITableViewCell
{
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    internal var scheduleM:scheduleModel!
    {
        didSet
        {
            if scheduleM != nil
            {
                (timeLabel.text,repeatLabel.text,nameLabel.text,dateLabel.text) = (scheduleM.time,scheduleM.repeats,scheduleM.name,scheduleM.date)
            }
        }
    }
    
    internal lazy var longGesture:UILongPressGestureRecognizer =
    {
        let ges = UILongPressGestureRecognizer(target: self, action: #selector(ScheduleRemindCell.handleGesture(_:)))
        return ges
    }()
    
    func handleGesture(sender :UILongPressGestureRecognizer)
    {
        //判断手势的状态
        if sender.state == .Began {
            
        let v = UINib(nibName: "ProgramAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ProgramAlertView
        v.frame = CGRectMake(0, 0, 300, 240)
        v.ensureBtn.enabled = true
        
        let label = UILabel(frame: CGRectMake(0,0,v.frame.size.width,80))
        label.center = v.center
        label.attributedText = NSAttributedString(string:"确定要删除吗",attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
        label.textAlignment = .Center
        v.addSubview(label)
        
        v.code =
        {
            RobotControl.shareInstance().didDeleteAlarm(Int32(self.scheduleM.ID ?? "") ?? 0)
            
            if let view = self.superview?.superview?.superview as? ScheduleRemindView
        {
                view.dataArr = RobotControl.shareInstance().didGetAlarmList()
                
                if view.table.visibleCells.first == nil
                {
                    view.dataArr = RobotControl.shareInstance().didGetAlarmList()
                }
            }
        }
        
        if let view = superview?.superview?.superview as? ScheduleRemindView
        {
             _ = AppAlert(frame: UIScreen.mainScreen().bounds, view: v, currentView: view, autoHidden: false)
            print("我是删除提醒的弹框")
        }
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        addBorder(headView)
        backgroundColor = .clearColor()
        footerView.backgroundColor = backgroundColor
        selectionStyle = .None
        
        addGestureRecognizer(longGesture)
    }

    func addBorder(view:UIView)
    {
        view.layer.borderColor = UIColor(red: 136/255, green: 150/255, blue: 204/255, alpha: 1).CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5.0
        view.backgroundColor = UIColor(red: 7/255, green: 17/255, blue: 35/255, alpha: 0.5)
    }
}
