//
//  MyProgramView.swift
//  robosys
//
//  Created by Cheer on 16/5/31.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class MyProgramView: AppView,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var allSelectBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
//是否是展示本地的数据
    var isShowLocationDataBool = true {
        didSet{
            self.tableView.reloadData()
        }
    
    }
    var isShowRobotDataBool = true {
    
        didSet{
        
            self.tableView.reloadData()
        }
    }
    
    
    lazy var alertView:UIView =
    {
        let view = UIView(frame: CGRectMake(0,0,300,240))
 
        let imgBg = UIImageView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        imgBg.image = UIImage(named: "WiFi弹窗")
        
        let contentLabel = UILabel(frame: CGRectMake(20,40,300 - 40,40))
        contentLabel.attributedText = NSAttributedString(string: "确定要删除程序文件",attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.init(name: "RTWS yueGothic Trial", size: 17)!])
        contentLabel.textAlignment = .Center
        contentLabel.center.x = view.center.x
        
        let ensureBtn = UIButton(frame: CGRectMake(20,140,300 - 40,40))
        ensureBtn.setTitle("确定", forState: .Normal)
        ensureBtn.setBackgroundImage(UIImage(named: "小蓝按钮"), forState: .Normal)
        ensureBtn.addTarget(self, action: #selector(MyProgramView.click(_:)), forControlEvents: .TouchUpInside)
        ensureBtn.center.x = view.center.x
//        ensureBtn.highlighted = true
        
        let cancelBtn = UIButton(frame: CGRectMake(20,190,300 - 40,40))
        cancelBtn.setTitle("取消", forState: .Normal)
        cancelBtn.setBackgroundImage(UIImage(named: "小橙按钮"), forState: .Normal)
        cancelBtn.addTarget(self, action: #selector(MyProgramView.click(_:)), forControlEvents: .TouchUpInside)
        cancelBtn.center.x = view.center.x
        
        view.addSubview(imgBg)
        view.addSubview(contentLabel)
        view.addSubview(ensureBtn)
        view.addSubview(cancelBtn)
        
        return view
    
    }()
    private var alert:AppAlert!
    
    private lazy var programViewArr = [ProgramView]()
    internal lazy var dataArr = [functionModel]()
    internal lazy var tempCount = 0
    internal lazy var timer = NSTimer()
    
    internal var lastPrgram:ProgramView?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
 
        allSelectBtn.setImage(UIImage(named:"性别选择"), forState: .Selected)
        
        let imgV = UIImageView(frame: frame)
        imgV.image = UIImage(named: "首页-背景")
        addSubview(imgV)
        
        initMainHeadView("我的程序", imageName: "返回")
        
        tableView.separatorStyle = .None
        
        for programimg in ProgrammingManager.shareManager.programmingLocationArry! {
            
            (programimg as! Programming).isSelectBool = false
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyProgramView.noticeNotAllSelect(_:)), name: "noticeNotAllSelect", object: nil);
        
    }
    
    func noticeNotAllSelect(notice:NSNotification)
    {
        var isAllSelectBool = true
        
        for programimg in ProgrammingManager.shareManager.programmingLocationArry! {
            
            if !(programimg as! Programming).isSelectBool {
                
                isAllSelectBool = false
            }
        }
        
        for model in dataArr {
            
            if !model.isSelectBool {
                
                isAllSelectBool = false
            }
        }

        if isAllSelectBool {
            
           self.allSelectBtn.selected = true
        }
        else
        {
            self.allSelectBtn.selected = false
        }
        
    }
    
    @IBAction func allSelect(sender: UIButton)
    {
        sender.selected = !sender.selected
        
        //全选
        if sender.selected {
            
            for programimg in ProgrammingManager.shareManager.programmingLocationArry! {
                
                (programimg as! Programming).isSelectBool = true
            }
            
            for model in dataArr {
                
                model.isSelectBool = true
            }
            
            tableView.reloadData()
        }
        else
        {
            for programimg in ProgrammingManager.shareManager.programmingLocationArry! {
                
                (programimg as! Programming).isSelectBool = false
            }
            
            for model in dataArr {
                
                model.isSelectBool = false
            }
            
            tableView.reloadData()
        }
        
    }

    @IBAction func deleteprogramV(sender: UIButton)
    {
        let willDeleteLocationArry = NSMutableArray()
        
        let willDeletePrograme = NSMutableArray()
        
        for program  in ProgrammingManager.shareManager.programmingLocationArry! {
            
            if (program as! Programming).isSelectBool {
                
                willDeleteLocationArry.addObject(program)
            }
        }
        
        for program in self.dataArr {
            
            if program.isSelectBool {
                
                willDeletePrograme.addObject(program)
            }
        }
        
        var canDelete = false

        if willDeletePrograme.count>0 || willDeleteLocationArry.count>0 {
            
            canDelete = true
        }

        
        if canDelete
        {
            //弹窗确认⬇️
            alertView.center = center
            layoutIfNeeded()
            
            alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: alertView, currentView: self, autoHidden: false)
            
        }
        else
        {
            Alert({}, title: "请选择要删除的文件", message: "")
        }
    }
    @IBAction func mediaPause(sender: UIButton)
    {
        guard networkM.isConnectRobot == true else
        {
            Alert({}, title: "请连接机器人", message: "")
            return
        }
        timer.fireDate = NSDate.distantFuture()
        control.didStop()
    }
    
    //点击确定删除
    func click(sender:UIButton)
    {
        if sender.titleLabel!.text == "确定"
        {
            if self.alert != nil {
                
                self.alert.dismiss()
            }
            
            let willDeleteLocationArry = NSMutableArray()
            
            let willDeletePrograme = NSMutableArray()
            
            for program  in ProgrammingManager.shareManager.programmingLocationArry! {
                
                if (program as! Programming).isSelectBool {
                    
                    willDeleteLocationArry.addObject(program)
                }
            }
            
            for program in self.dataArr {
                
                if program.isSelectBool {
                    
                    willDeletePrograme.addObject(program)
                }
            }
            
            let view = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
            view.titleLabel.hidden = true
            view.subTitleLabel.hidden = true
            view.contentLabel.textAlignment = .Center
            view.backBtn.hidden = true
            view.contentLabel.text = "正在删除数据。。。"
            view.frame = CGRectMake(0, 0, 300, 240)
            alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: view, currentView: self, autoHidden: false)
            
            dispatch_async(dispatch_get_global_queue(0, 0), {
                
                [weak self] in
                
                //删除本地
                for program in willDeleteLocationArry {
                    
                    ProgrammingManager.shareManager.deleteProgramming((program as! Programming))
                }
                
                if willDeletePrograme.count == 0
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        [weak self] in
                        self?.alert.dismiss()
                        self?.tableView.reloadData()
                        })
                }
                else
                {
                    let scriptyIdArry = NSMutableArray()
                    
                    for program in willDeletePrograme {
                        
                        scriptyIdArry.addObject((program as! functionModel).scriptID)
                    }
                    
                    let state = self?.control.deleteScriptMulti(scriptyIdArry)
                    
                    if state == 0
                    {
                        for program in willDeletePrograme {
                            
                            self?.dataArr.removeAtIndex((self?.dataArr.indexOf(program as! functionModel))!)
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            [weak self] in
                            self?.alert.dismiss()
                            self?.tableView.reloadData()
                            })
                    }
                    else
                    {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            [weak self] in
                            view.contentLabel.text = "删除失败"
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
                            {
                                [weak self] in
                                self?.alert.dismiss()
                            }
                            })
                    }
                }
                
                
            })
            
        }
        else
        {
            alert.dismiss()
        }
    }
}

extension MyProgramView
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0 {
            
            if isShowLocationDataBool {
                
                return (ProgrammingManager.shareManager.programmingLocationArry?.count)!+1
            }
            else
            {
                return 1
            }
        }
        else
        {
            if isShowRobotDataBool {
                //应该从服务器拿到数据生成
                return dataArr.count+1
            }
            else
            {
                return 1
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                var cell = tableView.dequeueReusableCellWithIdentifier("MyProgramHeaderViewTableViewCell") as? MyProgramHeaderViewTableViewCell
                
                if cell == nil {
                    
                    cell = NSBundle.mainBundle().loadNibNamed("MyProgramHeaderViewTableViewCell", owner: nil, options: nil)?.first as? MyProgramHeaderViewTableViewCell
                }
                
                cell?.titleLabel.text = String(format:"手机本地程序（%ld）",(ProgrammingManager.shareManager.programmingLocationArry?.count)!)

                cell?.clickBolock = { (btn:UIButton) in
                    
                    self.isShowLocationDataBool = !self.isShowLocationDataBool
                }
                
                return  cell!

            }
            else
            {
                var cell = tableView.dequeueReusableCellWithIdentifier("LocationProgramTableViewCell") as? LocationProgramTableViewCell
                
                if cell == nil {
                    
                    cell = NSBundle.mainBundle().loadNibNamed("LocationProgramTableViewCell", owner: nil, options: nil)?.first as? LocationProgramTableViewCell
                }
                    
                cell!.reloadData((ProgrammingManager.shareManager.programmingLocationArry?.objectAtIndex(indexPath.row-1))! as! Programming)
                
                
                return  cell!
            }
        }
        
            //第二组,机器人本地程序
        else
        {
            if indexPath.row == 0 {
                
                var cell = tableView.dequeueReusableCellWithIdentifier("MyProgramHeaderViewTableViewCell") as? MyProgramHeaderViewTableViewCell
                
                if cell==nil {
                    
                    cell = NSBundle.mainBundle().loadNibNamed("MyProgramHeaderViewTableViewCell", owner: nil, options: nil)?.first as? MyProgramHeaderViewTableViewCell
                    
                }
                
                cell?.titleLabel.text = String(format:"机器人本地程序（%ld）",dataArr.count)
                
                cell?.clickBolock = { (btn:UIButton) in
                    
                    self.isShowRobotDataBool = !self.isShowRobotDataBool
                }
                
                return  cell!
            }
            else
            {
                var cell = tableView.dequeueReusableCellWithIdentifier("ProgramViewTableViewCell") as? ProgramViewTableViewCell
                
                if cell==nil {
                    
                    cell = NSBundle.mainBundle().loadNibNamed("ProgramViewTableViewCell", owner: nil, options: nil)?.first as? ProgramViewTableViewCell
                    
                }
                
                print("dataArr++++++\(dataArr)")

                cell!.reloadData(dataArr[indexPath.row-1])
                
                print("dataArr------\(dataArr)")
                return  cell!
            
            }
            
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                return 50;
            }
            else
            {
                return 50;
            }
            
        }
        else
        {
            
            if indexPath.row == 0 {
                
                return 50
            }
            else
            {
                return 100

            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
     
        //如果是手机本地编程
        if indexPath.section == 0 {
            
            if indexPath.row != 0 {
                
                let viewController = MotionProgramViewController(nibName: "MotionProgramView",bundle: nil)
                
                viewController.isEdit = true
                viewController.programming = ProgrammingManager.shareManager.programmingLocationArry?.objectAtIndex(indexPath.row-1) as? Programming
                viewController.programming_Last = viewController.programming
                jump2AnyController(viewController)
            }
        }
    }
}
