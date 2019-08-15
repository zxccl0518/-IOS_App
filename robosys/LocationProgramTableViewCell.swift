//
//  LocationProgramTableViewCell.swift
//  robosys
//
//  Created by yaorenjin on 2017/3/17.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class LocationProgramTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        
        self.backImageView.layer.borderColor = UIColor(red: 136/255, green: 150/255, blue: 204/255, alpha: 1).CGColor
        self.backImageView.layer.borderWidth = 1.0
        self.backImageView.layer.cornerRadius = 5.0
        self.backImageView.backgroundColor = UIColor(red: 7/255, green: 17/255, blue: 35/255, alpha: 0.5)
        
    }
    
    @IBOutlet weak var selectBtn: UIButton!

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var program:Programming?
    var action : previewAction?
    
    @IBAction func pushBtnClick(sender: AnyObject) {

//        guard  networkM.isConnectRobot == true else
//        {
//            Alert({}, title: "请连接机器人", message: "")
//            return
//        }
        guard networkModel.sharedInstance.isConnectRobot == true else {
            Alert({}, title: "请连接机器人", message: "")
            return
        }
        
        let view = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
        view.titleLabel.hidden = true
        view.subTitleLabel.hidden = true
        view.contentLabel.textAlignment = .Center
        view.backBtn.hidden = true
        view.contentLabel.text = "正在发送给机器人。。。"
        view.frame = CGRectMake(0, 0, 300, 240)
        let alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: view, currentView: self.getCurrentVC().view, autoHidden: false)
        
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            
            self.action = previewAction(functionDic:(self.program?.getFunctionDic())!,frameDic:(self.program?.getFrameDic())!,totalTime: (self.program?.totalTime)!,alert: alert,saveName: self.program!.saveName!)
            self.program?.scriptID = self.action!.getID()
            ProgrammingManager.shareManager.updateProgramming((self.program!))
            
        }
        
       
  
    }
    @IBAction func selectBtnClick(sender: UIButton) {
        
        sender.selected = !sender.selected
        
        self.program?.isSelectBool = sender.selected
        
        NSNotificationCenter.defaultCenter().postNotificationName("noticeNotAllSelect", object: nil)
        
    }
    
    func reloadData(program:Programming) {
        
        self.program = program
        
        self.nameLabel.text = program.saveName
        self.timeLabel.text = self.handleTime(program.totalTime!)
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy/mm/dd";
        
        let stringDate = dateFormatter.stringFromDate(program.date!)
        self.dateLabel.text = stringDate
        
        self.selectBtn.selected = self.program!.isSelectBool
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        
        if highlighted
        {
            self.backImageView.backgroundColor = UIColor.blueColor()
        }
        else
        {
            self.backImageView.backgroundColor = UIColor.clearColor()
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func handleTime(timeInt:Int) -> String {
        
        let mitue = timeInt/60
        let second = timeInt%60

        if mitue >= 10 {
    
            if second>=10 {
                
                return "\(mitue)'\(second)\""
            }
            else
            {
                return "\(mitue)'0\(second)\""
            }
        }
        else
        {
            if second>=10 {
                
                return "0\(mitue)'\(second)\""
            }
            else
            {
                return "0\(mitue)'0\(second)\""
            }
        }
    }
    
}
