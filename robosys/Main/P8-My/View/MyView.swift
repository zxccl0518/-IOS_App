//
//  MyView.swift
//  robosys
//
//  Created by Cheer on 16/5/26.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class MyView: AppView,UITableViewDelegate,UITableViewDataSource,MyViewCellDelegate
{

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var telNum: UILabel!

    lazy var robotCount:Int = 0
    
    private lazy var label = UILabel()
    
    var tableView: UITableView?
    
    lazy var right:UISwipeGestureRecognizer =
    {
        let ges = UISwipeGestureRecognizer(target: self, action: #selector(RecreationalView.swipeGesture(_:)))
        
        ges.direction = .Right
        return ges
    }()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView("我的", imageName: "菜单")
        // 是否显示未连接任何机器人控件
        if RobotManager.shareManager.getCurrentRobotArry()?.count != 0 || networkModel.sharedInstance.isConnectRobot == true {
            connectBtn.hidden = true
            contentLabel.hidden = true
        }
        addBorder(settingView)
        addBorder(userView)
        
        label = UILabel(frame: CGRectMake(10, 300, UIScreen.mainScreen().bounds.width - 20, 30))
        label.textColor = .whiteColor()
        label.textAlignment = .Center
        label.text = "您连接过的机器人"
        
        tableView = UITableView(frame: CGRectMake(10, 40 + label.frame.origin.y, UIScreen.mainScreen().bounds.width  - 20, UIScreen.mainScreen().bounds.height - 94 - label.frame.origin.y))
        tableView?.showsVerticalScrollIndicator = false
        tableView?.separatorStyle = .None
        tableView?.backgroundColor = .clearColor()
        tableView?.delegate = self
        tableView?.dataSource = self
        
        addSubview(label)
        addSubview(tableView!)
        addGestureRecognizer(right)
    }
    // 手势响应
    func swipeGesture(swipe:UISwipeGestureRecognizer)
    {
        let vc = getCurrentVC()
        
        if vc is MainViewController
        {
            (vc as! MainViewController).leftView.show()
        }
    }
    func setUp(isHidden:Bool)
    {
        userName.text = registM.name
        telNum.text = loginM.num

        contentLabel.hidden = !isHidden
        connectBtn.hidden = !isHidden
        
        label.hidden = isHidden
        tableView?.hidden = isHidden
        
        if !isHidden
        {
            tableView?.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UINib(nibName: "MyViewCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MyViewCell
        cell.selectionStyle = .None
        cell.delegate = self
        
        if RobotManager.shareManager.getCurrentRobotArry() != nil {
            cell.reloadModel(RobotManager.shareManager.getCurrentRobotArry()!.objectAtIndex(indexPath.row) as! Robot)
        }
        
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if RobotManager.shareManager.getCurrentRobotArry() == nil
        {
            return 0
        }
        else
        {
            return RobotManager.shareManager.getCurrentRobotArry()!.count
        }
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 140
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row != 0 {return}
        let vc = RobotDetailsViewController(nibName: "RobotDetailsView",bundle: nil)
        (vc.view as! RobotDetailsView).model = robotM
        getCurrentVC().navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickPersonal(sender: UIButton)
    {
        getCurrentVC().navigationController?.pushViewController(PersonalInformationViewController(nibName: "PersonalInformationView",bundle: nil), animated: true)
    }
    @IBAction func clickConnect(sender: UIButton)
    {
        jump2AnyController(ConfigurationViewController(nibName:"ConfigurationView",bundle: nil))
    }
    @IBAction func clickSetting(sender: UIButton) {
        jump2AnyController(MySettingViewController(nibName:"MySettingView",bundle: nil))
    }
    
    //连接连接
    func connectRobotId(robotId: String) {

        var indexRow = 0
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            
            let NSMutableArr:NSMutableArray = RobotManager.shareManager.getCurrentRobotArry()!
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                for robot in NSMutableArr {
                    
                    //如果相等
                    if (robot as! Robot).robotId != nil && loginModel.sharedInstance.robotId != nil {
                        
                        if ((robot as! Robot).robotId! == loginModel.sharedInstance.robotId!) {
                            
                            let indexPath = NSIndexPath.init(forRow: indexRow, inSection: 0)
                            let cell = self.tableView?.cellForRowAtIndexPath(indexPath) as? MyViewCell
                            
                            if cell != nil {
                                
                                cell!.disconnect()
                                break;
                            }
                            
                        }
                    }
                    
                    indexRow += 1
                }

                
            })
            
            
        }
        
//        for robot in RobotManager.shareManager.getCurrentRobotArry()! {
//            
//            //如果相等
//            if (robot as! Robot).robotId != nil && loginM.robotId != nil {
//                
//                if (robot.robotId! == loginM.robotId!) {
//                    
//                    let indexPath = NSIndexPath.init(forRow: indexRow, inSection: 0)
//                    let cell = self.tableView?.cellForRowAtIndexPath(indexPath) as? MyViewCell
//                    
//                    if cell != nil {
//                        
//                        cell!.disconnect()
//                        break;
//                    }
//                    
//                }
//            }
//            
//            indexRow += 1
//        }
    }
}
