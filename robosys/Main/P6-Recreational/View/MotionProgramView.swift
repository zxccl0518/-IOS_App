//
//  MotionProgramView.swift
//  robosys
//
//  Created by Cheer on 16/6/2.
//  Copyright © 2016年 joekoe. All rights reserved.
//
import UIKit
import AVFoundation
import MediaPlayer

class MotionProgramView: AppView,UITableViewDelegate,UITableViewDataSource,AVAudioRecorderDelegate,UIAlertViewDelegate
{
    //时间按钮
    @IBOutlet weak var timeBtn: UIButton!
    //保存按钮
    @IBOutlet weak var saveBtn: UIButton!
    //左侧tableView
    @IBOutlet weak var leftTable: UITableView!
    
    var rightTable: UITableView?
    //返回按钮
    @IBOutlet weak var previewBtn: UIButton!
    internal let ALERT_WIDTH:CGFloat = 300
    private var player:AVAudioPlayer!
    var programming : Programming?
    var programming_Last : Programming?
    var isPushBtnClickBool = false
    var tableViewCellDic : NSMutableDictionary?
    var originalWidthFloat = CGFloat(0.0)
    @IBOutlet weak var leftHeightConstraint: NSLayoutConstraint!
    //右侧的scrollView
    @IBOutlet weak var backGroundScrollView: UIScrollView!
    var isEdit = false {
    
        didSet {
            
            if isEdit {
                
                self.frameDic = (self.programming?.getFrameDic())!
                self.functionDic = (self.programming?.getFunctionDic())!
                self.timerArr = (self.programming?.timerArr)!
                self.imgDic = (self.programming?.imgDic)!
                self.rightTable!.reloadData()
                self.indexArry = (self.programming?.indexArry)!
                
            }
        }
    }
    
    //左边table的数据
    private lazy var cellArr = [
        ("播放-按钮","播放-红"),("底盘","底盘-橙"),("点头","点头-黄"),("摇头","摇头-绿"),
        ("右臂","右臂-靛"),("左臂","左臂-蓝"),("表情","表情-紫"),("耳朵","耳朵-墨蓝")]
    //右边table的数据
    private lazy var cellDic = [
        0:["文本","录音","音频"],
        1:["前进","后退","左转","右转","原地右转","原地左转"],
        2:["点头-内","抬头","低头"],
        3:["摇头-内","左转头","右转头"],
        4:["摇动","举起","向前","向下","向后"],
        5:["摇动","举起","向前","向下","向后"],
        6:["淡定","开心","喜欢","调皮","鄙视","愤怒","烦闷","悲伤","惊奇","正确","错误","疑问-编程"],
        7:["全亮灯","跑马灯","呼吸灯","律动灯"]]
    
    //方法名对照
    private lazy var functionNameDic = [
        0:["didPlaySST:","didPlayRecord:","didPlayAudio:"],
        1:["didForward:","didFallback:","didTurnLeft:otherSpeed:","didTurnRight:otherSpeed:","didClosewise:time:","didCounterClosewise:time:"],
        2:["didNod:times:","didLookUp","didLookDown"],
        3:["didShake:times:","didLookLeft","didLookRight"],
        4:["didHandRightShake:type:","didHandRightUp:","didHandRightUp:","didHandRightUp:","didHandRightBack:"],
        5:["didLeftHandShake:type:","didHandLeftUp:","didHandLeftUp:","didHandLeftUp:","didHandLeftBack:"],
        6:["1","2","8","5","4","9","6","7","10","12","13","16"],
        7:["23","2","11","0"]]
    //方法数据
    lazy var functionDic:[Int:[(String,[String?],Int,Int)?]] = [
        0:[],
        1:[],
        2:[],
        3:[],
        4:[],
        5:[],
        6:[],
        7:[]]
    
    //IndexArry
    lazy var indexArry:[Int:[Int]] = [
        0:[],
        1:[],
        2:[],
        3:[],
        4:[],
        5:[],
        6:[],
        7:[]]
    
    private lazy var timerArr = [NSTimer(),NSTimer(),NSTimer(),NSTimer(),NSTimer(),NSTimer(),NSTimer(),NSTimer()]
    
    //右边cell的数据
    lazy var imgDic = [Int:[UIImage]]()
    
    var frameDic =
        [
            0:[CGRect](),
            1:[CGRect](),
            2:[CGRect](),
            3:[CGRect](),
            4:[CGRect](),
            5:[CGRect](),
            6:[CGRect](),
            7:[CGRect](),
            ]
        {
        didSet
        {
            var rectArr = [CGRect]()
            
            for item in frameDic
            {
                for i in 0..<item.1.count
                {
                    let startTime = item.1[i].origin.x * 30 / rightTable!.frame.width
                    let endTime = (item.1[i].origin.x + item.1[i].width) * 30 / rightTable!.frame.width
                    
                    if let _ = functionDic[row] where functionDic[row]?.count > 0
                    {
                        if functionDic[row]!.count - 1 >= i
                        {
                            self.functionDic[row]![i]!.2 = Int(startTime)
                            self.functionDic[row]![i]!.3 = Int(endTime)
                        }
                    }
                }
                
                if let rect = item.1.last
                {
                    rectArr.append(rect)
                }
            }
            
            if let temp = (rectArr.sort{ $0.origin.x + $0.size.width  > $1.origin.x + $1.size.width }.first)
            {
                totalTime = Int(temp.origin.x / rightTable!.frame.width * 30 + temp.width / 17)
            }
            else
            {
                totalTime = 0
            }
        }
    }
    //程序总时
    var totalTime:Int! = 0
        {
        didSet
        {
            timeBtn.setTitle((totalTime / 60 < 10 ? "0\(totalTime / 60)'" : "\(totalTime / 60)'" ) + (totalTime % 60 < 10 ? "0\(totalTime % 60)''" : "\(totalTime % 60)''"), forState: .Normal)
            
            let width = sliderWidth! / (totalTime > 450 ?  15 : CGFloat(totalTime) / 30)
            slider.frame.size.width = width < 450 ? width : 450
            
            
            slider.hidden = totalTime > 30 ? false : true
            sliderView.hidden = slider.hidden
            
            //处理rightTableView可以滚动的距离
            self.handleRightTableViewcontentSize()
        }
    }
    

    
    //左边table的view
    internal lazy var viewDic = [Int:UIView]()
    //弹窗
    var alertView:ProgramAlertView!
    //录音
    var audioRecorder:AVAudioRecorder!
    //录音的定时器
    var timer:NSTimer!
    //定时器初始值
    private var tempCount = 0
    //脚本ID
    private var scriptID:Int32 = -1
    
    //背景
    lazy var sliderView:UIView! =
        {
            let sliderView =  UIView(frame: CGRectMake(45,UIScreen.mainScreen().bounds.width - 25,UIScreen.mainScreen().bounds.height - 60,15))
            sliderView.backgroundColor = UIColor(red: 6 / 255, green: 12 / 255, blue: 22 / 255, alpha: 0.8)
            sliderView.hidden = true
            return sliderView
    }()
    //滑块
    lazy var slider : UIImageView =
        {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(MotionProgramView.handleGesture(_:)))
            
            let slider = UIImageView(frame: CGRectMake(0, 0, 450, 15))
            slider.image = UIImage(named:"滚动条2秒")!.resizableImageWithCapInsets(UIEdgeInsetsMake(5, 40, 5, 40), resizingMode:.Tile)
            slider.userInteractionEnabled = true
            slider.addGestureRecognizer(gesture)
            slider.hidden = true
            
            return slider
    }()
    
    private lazy var originX:CGFloat = 0
    //录音
    private lazy var recordURL = ""
    //previewAction
    private var action:previewAction!

    
    func handleRightTableViewcontentSize() {
        
        //如果超出显示的范围
        if CGFloat(totalTime*17) > originalWidthFloat {
            
            self.backGroundScrollView.scrollEnabled = true
            var contentSize = self.backGroundScrollView!.contentSize
            contentSize.width = CGFloat(totalTime*17)
            self.backGroundScrollView!.contentSize = contentSize
            
            var rect = self.rightTable?.frame
            rect?.size.width = contentSize.width
            self.rightTable!.frame = rect!
            
            if tableViewCellDic != nil {
            for key in (self.tableViewCellDic?.allKeys)! {
                
                let cell = self.tableViewCellDic?.objectForKey(key) as! MotionProgramCell
                
                var rect = cell.backImgView?.frame
                rect?.size.width = contentSize.width
                cell.backImgView?.frame = rect!
                
                if cell.collect != nil {
                    
                    var collectRect = cell.collect.frame
                    collectRect.size.width = contentSize.width
                    cell.collect.frame = collectRect;
                }
            }
            }
        }
        else if originalWidthFloat <= originalWidthFloat {
        
            var contentSize = self.backGroundScrollView!.contentSize
            contentSize.width = originalWidthFloat
            self.backGroundScrollView!.contentSize = contentSize
            
            var rect = self.rightTable?.frame
            rect?.size.width = contentSize.width
            self.rightTable!.frame = rect!
            
            if tableViewCellDic != nil {
            for key in (self.tableViewCellDic?.allKeys)! {
                
                let cell = self.tableViewCellDic?.objectForKey(key) as! MotionProgramCell
                
                var rect = cell.backImgView?.frame
                rect?.size.width = contentSize.width
                cell.backImgView?.frame = rect!
                
                if cell.collect != nil {
                    
                    var collectRect = cell.collect.frame
                    collectRect.size.width = contentSize.width
                    cell.collect.frame = collectRect;
                }
            }
            }
        }
    }
    
    
    func handleGesture(gesture:UILongPressGestureRecognizer)
    {
        let offsetX = gesture.locationInView(sliderView).x
        
        guard offsetX < 0 else
        {
            switch gesture.state
            {
            case .Began:
                
                originX = gesture.locationInView(sliderView).x
                
            case .Changed:
                
                for cell in rightTable!.visibleCells
                {
                    if let collect = (cell as! MotionProgramCell).collect
                    {
                        if !slider.hidden && (offsetX - originX) <= sliderView.frame.width - slider.frame.width && offsetX >= originX
                        {
                            //根据总时间和宽度来算偏移量
                            let unit = (sliderView.frame.width - slider.frame.width) / CGFloat(totalTime - 30)
                            let scale = offsetX / unit
                            
                            for i in 0..<timeArr.count
                            {
                                (timeArr[i] as! TimeScale).timeLabel.text = "00:" + (i < 5 ? "0\(i * 2)" : "\(i * 2)")
                                
                                let tempArr = (timeArr[i] as! TimeScale).timeLabel.text?.characters.split{$0 == ":"}.flatMap(String.init)
                                
                                if let first = Int(tempArr!.first!.substringToIndex(tempArr!.first!.startIndex.advancedBy(2))),let last = Int(tempArr!.last!.substringToIndex(tempArr!.last!.startIndex.advancedBy(2)))
                                {
                                    let sec = last + Int(scale)
                                    let min = first + (totalTime / 60)
                                    (timeArr[i] as! TimeScale).timeLabel.text = (min < 10 ? "0\(min)'" : "\(min)'" ) + ":" + (sec % 60 < 10 ? "0\(sec % 60)''" : "\(sec % 60)''")
                                }
                                
                            }
                            collect.setContentOffset(CGPointMake(((offsetX - originX) / (sliderView.frame.width - slider.frame.width)) * (collect.contentSize.width - collect.frame.width), collect.frame.height), animated: false)
                        }
                        return
                    }
                }
            default:break
            }
            return
        }
        
    }
    //滑块原始宽度
    private var sliderWidth:CGFloat!
    //时间标尺
    lazy var timeArr : [UIView]! =
        {
            var timeArr = [TimeScale]()
            
            for i in 0...15
            {
                let timeView = UINib(nibName: "TimeScale", bundle: nil).instantiateWithOwner(nil, options: nil).first as! TimeScale
                timeView.timeLabel.text = "00:" + (i < 5 ? "0\(i * 2)" : "\(i * 2)")
                timeView.frame = CGRectMake(34 + 45 * CGFloat(i), UIScreen.mainScreen().bounds.width - 70, UIScreen.mainScreen().bounds.width, 0)
                timeView.index = i
                timeArr.append(timeView)
            }
            
            return timeArr
    }()
    //记录点击cell
    private var lastIndexPath:NSIndexPath!
    //弹窗
    private var alert:AppAlert!
    /*------------------------------------------------------------------------------------------------------------*/
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backGroundScrollView.scrollEnabled = true
        self.rightTable = UITableView.init(frame: CGRectMake(51, 0, self.backGroundScrollView.frame.size.height, self.backGroundScrollView.frame.size.width*2), style: .Plain)
        
        self.leftTable.bounces = false
        self.rightTable?.bounces = false
        
        self.leftTable.scrollEnabled = true
        self.rightTable!.scrollEnabled = false
        
        self.backGroundScrollView.addSubview(self.rightTable!)
        
        self.leftTable.backgroundColor = .clearColor()
        self.rightTable!.backgroundColor = .clearColor()
        
        self.leftTable.separatorStyle = .None
        self.rightTable!.separatorStyle = .None
        
        self.rightTable!.registerClass(MotionProgramCell.classForCoder(), forCellReuseIdentifier: "MotionProgramCell")
        
        sliderWidth = slider.frame.width
        sliderView.frame.size.height = slider.frame.height
        
        sliderView.addSubview(slider)
        addSubview(sliderView)
        
        for i in 0..<timeArr.count
        {
            
            timeArr[i].frame.origin.x -= (timeArr[i] as! TimeScale).timeImg.frame.origin.x * CGFloat(i)
            
            addSubview(timeArr[i])
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        // 点击区域是cell 并且右边有弹出 就交给didselect去处理
        if let _ = lastIndexPath where touches.reverse().last?.view?.superview == leftTable.cellForRowAtIndexPath(lastIndexPath)
        {
            return
        }
        else
        {
            for item in viewDic
            {
                item.1.hidden = true
            }
        }
        
        for i in 0..<8
        {
            if let cell = self.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)){
                if cell.subviews.last is UIImageView
                {
                    cell.subviews.last?.removeFromSuperview()
                }
            }
        }
    }
    
    /*------------------------------------------------------------------------------------------------------------*/
    
    //MARK:-代理方法
    ///点击return
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if scrollView == leftTable
        {
            self.backGroundScrollView!.contentOffset.y = leftTable.contentOffset.y
        }
        else if scrollView == self.backGroundScrollView
        {
            leftTable.contentOffset.y = self.backGroundScrollView.contentOffset.y
            
        }
        //当滚动右边或者左边的时候
        if scrollView == self.backGroundScrollView || scrollView == leftTable
        {
            var tempArr = [UITableViewCell]()
            
            var isGray = false
            
            for cell in self.rightTable!.visibleCells
            {
                if cell.subviews.last is UIImageView
                {
                    isGray = true
                }
                else
                {
                    tempArr.append(cell)
                }
            }
            
            if isGray
            {
                for cell in tempArr
                {
                    let v = UIImageView(frame: CGRectMake(0, 0, self.rightTable!.frame.width, cell.frame.height))
                    v.image = UIImage(named: "灰色遮罩")
                    
                    cell.addSubview(v)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableView.tag == 10000 ? musicArr.count : cellArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return setUpCell(tableView, indexPath: indexPath)
    }
    func setUpCell(tableView:UITableView,indexPath:NSIndexPath)->UITableViewCell
    {
        if tableView.tag != 10000
        {
            if tableView == leftTable
            {
                let backImgV = UIImageView(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.height / 4))
                backImgV.image = UIImage(named: cellArr[indexPath.row].1)

                let cell = UITableViewCell()
                cell.addSubview(backImgV)
                
                let imgV = UIImageView(image: UIImage(named: cellArr[indexPath.row].0))
                imgV.frame.size.height = tableView.frame.height / 4
                imgV.frame.size.width = tableView.frame.width * 0.6
                imgV.center = CGPointMake(tableView.frame.size.width * 0.5,backImgV.center.y)
                imgV.contentMode = .ScaleAspectFit
                cell.addSubview(imgV)
                cell.backgroundColor = .clearColor()
                return cell
            }
            else
            {
                let backImgV = UIImageView(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.height / 8))
                backImgV.image = UIImage(named: cellArr[indexPath.row].1)

                if self.tableViewCellDic == nil {
                    
                    self.tableViewCellDic = NSMutableDictionary()
                }
                
                let identifier = "section_\(indexPath.section),row_\(indexPath.row)"

                var cell =  self.tableViewCellDic!.objectForKey(identifier) as? MotionProgramCell
                
                if cell == nil {
                    
                    cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? MotionProgramCell
                    
                    if cell == nil
                    {
                        cell =  MotionProgramCell(row: indexPath.row, frameArr: frameDic[indexPath.row]!, style: .Default, reuseIdentifier: "MotionProgramCell")
                        cell!.frame = CGRectMake(0, 0, self.rightTable!.frame.width, self.rightTable!.frame.height / 4)
                    }
                    
                    self.tableViewCellDic!.setObject(cell!, forKey: identifier)
                }
                
                cell?.backImgView = backImgV
              
                cell!.selectionStyle = .None
                cell!.backgroundColor = .clearColor()
                
                //为了显示数据
                if imgDic[indexPath.row]?.count > 0
                {
                    cell!.dataArr = imgDic[indexPath.row]!
                }
                
                if isEdit {
                    self.configerCollectionCell(indexPath.row)
                }

            
                return cell!
            }
        }
        else
        {
            let cell = UITableViewCell()
            cell.frame.size.height = leftTable.frame.height / 4
            
            let label = UILabel(frame: CGRectMake(10,0,cell.frame.width - 10,cell.frame.height))
            label.attributedText = NSAttributedString(string:"\(musicArr[indexPath.row].0)",attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            cell.addSubview(label)
            cell.backgroundColor = .clearColor()
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return leftTable.frame.height / 4
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.selectionStyle = .None
        
        if tableView == leftTable
        {
            //点自己 去灰
            if let _ = lastIndexPath where lastIndexPath == indexPath
            {
                for i in 0..<8
                {
                    if let cell = self.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)){
                        if cell.subviews.last is UIImageView
                        {
                            cell.subviews.last?.removeFromSuperview()
                        }
                        else
                        {
                            let v = UIImageView(frame: CGRectMake(0, 0, self.rightTable!.frame.width, cell.frame.height))
                            v.image = UIImage(named: "灰色遮罩")
                            
                            cell.addSubview(v)
                        }
                    }
                }
            }
            else
            {
                //给其他加灰
                for i in 0..<8
                {
                    if let cell = self.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)){
                        
                        let v = UIImageView(frame: CGRectMake(0, 0, self.rightTable!.frame.width, cell.frame.height))
                        v.image = UIImage(named: "灰色遮罩")
                        
                        cell.addSubview(v)
                    }
                    
                }
            }
            
            lastIndexPath = indexPath
            
            guard viewDic[indexPath.row] != nil else
            {
                let view = UIView(frame: CGRectMake(0,0,self.rightTable!.frame.width,cell!.frame.height))
                
                let bg = UIImageView(frame:view.frame)
                bg.image = UIImage(named: cellArr[indexPath.row].1)
                view.addSubview(bg)
                
                for i in 0..<cellDic[indexPath.row]!.count
                {
                    let btn = UIButton(frame: CGRectMake(cell!.frame.height * 1.2 * CGFloat(i),0,cell!.frame.height * 1.2,cell!.frame.height))
                    btn.setImage(UIImage(named: cellDic[indexPath.row]![i]), forState: .Normal)
                    btn.setImage(UIImage(named: "\(cellDic[indexPath.row]![i])-按下"), forState: .Selected)
                    btn.imageView?.contentMode = .ScaleAspectFit
                    btn.addTarget(self, action: #selector(MotionProgramView.clickAction(_:)), forControlEvents: .TouchUpInside)
                    btn.tag = (indexPath.row + 1) * 30 + i
                    btn.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
                    
                    view.frame = CGRectMake(0, CGFloat(indexPath.row) * tableView.frame.height / 4, btn.frame.width * CGFloat(i + 1), btn.frame.height)
                    view.userInteractionEnabled = true
                    viewDic[indexPath.row] = view
                    view.addSubview(btn)
                }
                
                self.rightTable!.addSubview(view)
                
                return
            }
            viewDic[indexPath.row]!.hidden = !viewDic[indexPath.row]!.hidden
        }
        
        if tableView.tag == 10000
        {
            for cell in tableView.visibleCells
            {
                cell.backgroundColor = .clearColor()
            }
            
            let select = tableView.cellForRowAtIndexPath(indexPath)
            select?.backgroundColor = .lightGrayColor()
            
            lastIndexPath = indexPath
            alertView.ensureBtn.enabled = true
        }
    }
    
    /*------------------------------------------------------------------------------------------------------------*/
    var tempLabel = UILabel()
    var musicArr =  [(String,String)]()
    
    func caculateTime(url:String)->Int
    {
        do
        {
            let player = try AVAudioPlayer(contentsOfURL: NSURL(string: "\(url)")!)
            
            return Int(player.duration)
        }
        catch
        {
            
        }
        
        return 0
    }
    
    func clickAction(btn:UIButton)
    {
        //去掉灰层
        for i in 0..<8
        {
            let cell = self.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            cell?.subviews.last?.removeFromSuperview()
        }
        
        showPopView(btn.tag / 30 - 1, index: btn.tag % 30,bool:false)
    }
    
    func showPopView(row:Int,index:Int,bool:Bool)
    {
        
        viewDic[row]?.hidden = true
        
        alertView = UINib(nibName: "ProgramAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ProgramAlertView
        alertView.frame = CGRectMake(0, 0, ALERT_WIDTH, 240)
        
        switch row
        {
        case 0:
            switch index
            {
            case 0: doAction({ [weak self] in
                
                let textfield = UITextField(frame: CGRectMake(self!.alertView.cancelBtn.frame.origin.x,50,self!.ALERT_WIDTH - 40,30))
                textfield.textColor = .whiteColor()
                textfield.backgroundColor = UIColor(red: 14/255, green: 56/255, blue: 86/255, alpha: 1)
                textfield.keyboardType = UIKeyboardType.EmailAddress
                textfield.addTarget(self, action: #selector(MotionProgramView.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
                self?.alertView.addSubview(textfield)
                
                self?.alertView.addSubview(self!.createLabel("输入待播放的文字", frame: CGRectMake(self!.alertView.cancelBtn.frame.origin.x,10,self!.ALERT_WIDTH - 40,30)))
                
                self!.tempLabel = self!.createLabel("预计播放时长0秒", frame: CGRectMake(self!.alertView.cancelBtn.frame.origin.x,90,self!.ALERT_WIDTH - 40,30))
                self?.alertView.addSubview(self!.tempLabel)
                
                self?.alertView.code =
                    {
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }
                        
                        let time = CGFloat(textfield.tag) * 0.5
                        let width = CGFloat(time) * 17 //CGFloat(time) *  30 * self!.rightTable.frame.width
                        self?.createCollectionCell(row, index: index,width:width,param:[textfield.text])
                        
                        
                        dispatch_async(dispatch_get_main_queue(), { 
                            
                            self!.alert.dismiss()

                        })
                    }
                })
            //录音
            case 1: doAction({ [weak self] in
                //初始化label
                let label = self!.createLabel("00:00:00", frame: CGRectMake(self!.alertView.cancelBtn.frame.origin.x,10,self!.ALERT_WIDTH - 40,30))
                self?.alertView.addSubview(label)
                
                //初始化图标
                let imgV = UIImageView(frame: CGRectMake(0,40,80,80))
                imgV.center.x = self!.alertView.center.x
                imgV.image = UIImage(named: "按住录音")
                imgV.highlightedImage = UIImage(named: "松开暂停")
                imgV.userInteractionEnabled = true
                
                //加手势
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MotionProgramView.longPress(_:)))
                imgV.addGestureRecognizer(longPress)
                self?.alertView.addSubview(imgV)
                
                //初始化录音
                if let url = self!.clickRecord()
                {
                    self?.recordURL = "\(url)"
                }
                
                self?.tempCount
                
                //初始化定时器
                self?.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self!, selector: #selector(MotionProgramView.changeText(_:)), userInfo:label, repeats: true)
                self?.timer.fireDate = NSDate.distantFuture()
                
                self?.alertView.code =
                    {
                        
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }
                        
                        let timeArr = label.text!.componentsSeparatedByString(":")
                        
                        let time = Int(timeArr[0])! * 3600 + Int(timeArr[1])! * 60 + Int(timeArr[2])!
                        
                        let width = CGFloat(time) * 17 //CGFloat(time) *  30 * self!.rightTable.frame.width
                        
                        
                        if self?.recordURL == nil
                        {
                            let url = self!.clickRecord()
                            self?.recordURL = "\(url)"
                        }
                        
                        self?.createCollectionCell(row, index: index,width:width,param:[self?.recordURL])
                        
                        self?.alert.dismiss()
                }
                
                })
            //播放音乐
            case 2: doAction({ [weak self] in
                
                //有一个隐藏的label
                let contentLabel = UILabel(frame: CGRectMake(0,0,self!.alertView.frame.width,self!.alertView.frame.height))
                contentLabel.attributedText = NSAttributedString(string:"您选择的文件有误,请重新选择! \n\n 仅支持mp3,wav格式", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(15)])
                contentLabel.textAlignment = .Center
                contentLabel.numberOfLines = 4
                contentLabel.lineBreakMode = .ByWordWrapping
                contentLabel.hidden = true
                
                self?.alertView.addSubview(contentLabel)
                
                self!.musicArr.removeAll()
                
                //获取iTunes音乐数据，第三方音乐应用的数据获取不到
                if let collection = MPMediaQuery.songsQuery().collections
                {
                    for song in collection
                    {
                        for item in song.items
                        {
                            if #available(iOS 8.0, *)
                            {
                                self!.musicArr.append((item.title!,"\(item.assetURL!)"))
                            }
                            else
                            {                                
                            }
                        }
                    }
                }
                
                if !self!.musicArr.isEmpty
                {
                    let table = UITableView(frame: CGRectMake(0,0,self!.alertView.frame.width,self!.alertView.cancelBtn.frame.origin.y - 20))
                    table.delegate = self
                    table.dataSource = self
                    table.tag = 10000
                    table.separatorStyle = .None
                    table.backgroundColor = .clearColor()
                    table.reloadData()
                    self?.alertView.addSubview(table)
                }
                else
                {
                    contentLabel.attributedText = NSAttributedString(string:"没有找到文件", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(15)])
                    contentLabel.hidden = false
                    return
                }
                
                self?.alertView.code =
                    {
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }
                        
                        let time = self!.caculateTime(self!.musicArr[self!.lastIndexPath.row].1)
                        
                        let width = CGFloat(time) * 17
                        
                        self?.createCollectionCell(row, index: index,width:width,param:["\(self!.musicArr[self!.lastIndexPath.row].1)","\(self!.musicArr[self!.lastIndexPath.row].0)"])
                        
                        self?.alert.dismiss()

                    }
                })
            default:break
            }
        case 1:
            switch index
            {
            case 0,1: doAction({ [weak self] in
                let speedSlider = self?.createSliderV(("\(self?.cellDic[row]![index] ?? "前进")速度","3cm/s"), values: (3, 20), frame: CGRectMake(10, 30, self!.ALERT_WIDTH - 20, 40))
                let timeSlider = self?.createSliderV(("\(self?.cellDic[row]![index] ?? "前进")时长","00:00"), values: ("00:00", "00:30"), frame: CGRectMake(10, 100, self!.ALERT_WIDTH - 20, 40))
                self?.alertView.code =
                    {
                        
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }
                        
                        var time = 0
                        
                        if let str = timeSlider?.rightLabel.text
                        {
                            let (minR,secR) = ((str as NSString).substringToIndex(2),(str as NSString).substringFromIndex(3))
                            time = Int(minR)! * 60 + Int(secR)!
                        }
                        let width = CGFloat(time) * 17//CGFloat(time) / 30 * self!.rightTable.frame.width
                        
                        self?.createCollectionCell(row, index: index,width:width,param:[speedSlider!.rightLabel.text!.componentsSeparatedByString("cm/s").first!])
                        
                        self?.alert.dismiss()
                        
                }
                })
            case 2,3: doAction({ [weak self] in
                let speedSlider = self?.createSliderV(("旋转速度","3*/s"), values: (3, 20), frame: CGRectMake(10, 20, self!.ALERT_WIDTH - 20, 30))
                
                let v = UIView(frame: CGRectMake(10, 60, 350, 30))
                let leftLabel = UILabel(frame: CGRectMake(8,0,70,30))
                let Txtfield = UITextField(frame: CGRectMake(88,5,110,20))
                let rightLabel = UILabel(frame: CGRectMake(220,0,55,30))
                
                Txtfield.backgroundColor = UIColor(white: 0.8, alpha: 0.4)
                Txtfield.keyboardType = .NumberPad
                Txtfield.tag = 123
                Txtfield.layer.cornerRadius = 5.0
                Txtfield.delegate = self
                Txtfield.addTarget(self, action: #selector(MotionProgramView.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
                
                Txtfield.attributedPlaceholder = NSAttributedString(string:"请输入正整数", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(15)])
                
                leftLabel.attributedText = NSAttributedString(string: "旋转半径", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
                
                rightLabel.attributedText = NSAttributedString(string: "厘米", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
                
                v.addSubview(leftLabel)
                v.addSubview(Txtfield)
                v.addSubview(rightLabel)
                self?.alertView.addSubview(v)
                
                let timeSlider = self?.createSliderV(("旋转时长","00:00"), values: ("00:00", "00:30"), frame: CGRectMake(10, 110, self!.ALERT_WIDTH - 20, 30))
                
                self?.alertView.code =
                    {
                        
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }
                        
                        var time = 0
                        
                        if let str = timeSlider?.rightLabel.text
                        {
                            let (minR,secR) = ((str as NSString).substringToIndex(2),(str as NSString).substringFromIndex(3))
                            time = Int(minR)! * 60 + Int(secR)!
                            
                        }
                        let width = CGFloat(time) * 17//CGFloat(time) / 30 * self!.rightTable.frame.width
                        self?.createCollectionCell(row, index: index,width: width,param: [speedSlider!.rightLabel.text!.componentsSeparatedByString("*/s").first!,Txtfield.text!,"\(time)"])
                        
                        self?.alert.dismiss()

                }
                
                })
            case 4,5:
                doAction({ [weak self] in
                    let speedSlider = self?.createSliderV(("旋转速度","3*/s"), values: (3, 20), frame: CGRectMake(10, 20, self!.ALERT_WIDTH - 20, 40))
                    let timeSlider = self?.createSliderV(("旋转时长","00:00"), values: ("00:00", "00:30"), frame: CGRectMake(10, 100, self!.ALERT_WIDTH - 20, 40))
                    self?.alertView.code =
                        {
                            if bool
                            {
                                if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                                {
                                    cell.delete()
                                }
                            }
                            
                            var time = 0
                            
                            if let str = timeSlider?.rightLabel.text
                            {
                                let (minR,secR) = ((str as NSString).substringToIndex(2),(str as NSString).substringFromIndex(3))
                                time = Int(minR)! * 60 + Int(secR)!
                                
                            }
                            let width = CGFloat(time) * 17//CGFloat(time) / 30 * self!.rightTable.frame.width
                            
                            self?.createCollectionCell(row, index: index,width: width,param: [speedSlider!.rightLabel.text!.componentsSeparatedByString("*/s").first!,"\(time)"])
                            
                            self?.alert.dismiss()

                    }
                    
                    })
            default:break
            }
            
            
        case 2,3:
            switch index
            {
            case 0: doAction({ [weak self] in
                
                let timeSlider = self?.createSliderV(("\(String((self!.cellDic[row]![index] as String).characters.dropLast(2)))次数","0次"), values: (0, 30), frame: CGRectMake(10, 70, self!.ALERT_WIDTH - 20, 40))
                
                let frame = CGRectMake(self!.alertView.cancelBtn.frame.origin.x,20,70,30)
                
                let leftLabel = UILabel(frame: frame)
                leftLabel.attributedText = NSAttributedString(string: "\(String((self!.cellDic[row]![index] as String).characters.dropLast(2)))速度", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
                
                let leftBtn = self!.createButton("快", image: "性别选择底", selectedImg: "性别选择", frame: CGRectMake(frame.origin.x + 60, frame.origin.y, 70, frame.height))
                leftBtn.selected = true
                
                let midBtn = self!.createButton("中", image: "性别选择底", selectedImg: "性别选择", frame: CGRectMake(leftBtn.frame.origin.x + 70, frame.origin.y, 70, frame.height))
                let right = self!.createButton("慢", image: "性别选择底", selectedImg: "性别选择", frame: CGRectMake(midBtn.frame.origin.x + 70, frame.origin.y, 70, frame.height))
                
                self!.alertView.addSubview(leftLabel)
                
                self?.alertView.code =
                    {
                        
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }
                        
                        var eachSecond : Float = 0.0
                        
                        //如果快
                        if leftBtn.selected {
                        
                            eachSecond = 0.561
                        }
                        //中
                        else if midBtn.selected
                        {
                            eachSecond = 0.917
                        }
                        //慢
                        else if right.selected
                        {
                            eachSecond = 1.267
                        }
                    
                        let countString = timeSlider?.rightLabel.text?.componentsSeparatedByString("次").first
                        let countFloat = Float(countString!)
                        
                        let time = countFloat! * eachSecond

                        let widthFloat = CGFloat(time) * 17

                        let speed = leftBtn.selected ? 3 : (midBtn.selected ? 2 : 1)
                        
                        self?.createCollectionCell(row, index: index,width: widthFloat,param: ["\(speed)",timeSlider!.rightLabel.text!.componentsSeparatedByString("次").first!])
                        
                        self?.alert.dismiss()

                }
                })
            case 1,2: doAction({ [weak self] in
                let label = self!.createLabel("确认选择\(self!.cellDic[row]![index])动作?（时长：1s)", frame: CGRectMake(self!.alertView.cancelBtn.frame.origin.x,50,300 - 40,30))
                label.textAlignment = .Center
                self?.alertView.addSubview(label)
                self!.alertView.ensureBtn.enabled = true
                
                self?.alertView.code =
                    {
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }
                        
                        self?.createCollectionCell(row, index: index,width: CGFloat(17),param: [])
                        
                        self?.alert.dismiss()

                }
                })
            default:break
            }
            
            
        case 4,5:
            switch index
            {
            case 0: doAction({ [weak self] in
                
                let timeSlider = self?.createSliderV(("\(self!.cellDic[row]![index])次数","0次"), values: (0, 30), frame: CGRectMake(10, 70, self!.ALERT_WIDTH - 20, 40))
                
                let frame = CGRectMake(self!.alertView.cancelBtn.frame.origin.x,20,70,30)
                
                let leftLabel = UILabel(frame: frame)
                leftLabel.attributedText = NSAttributedString(string: "\(self!.cellDic[row]![index])速度", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
                
                let leftBtn = self!.createButton("上下摇摆", image: "性别选择底", selectedImg: "性别选择", frame: CGRectMake(frame.origin.x + 70, frame.origin.y, 90, frame.height))
                leftBtn.selected = true
                
                let rightBtn = self!.createButton("前后摇摆", image: "性别选择底", selectedImg: "性别选择", frame: CGRectMake(leftBtn.frame.origin.x + 110, frame.origin.y, 90, frame.height))
                
                self!.alertView.addSubview(leftLabel)
                
                self?.alertView.code =
                    {
                        
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }                        
                        
                        var eachSecond : Float = 0.0
                        
                        //上下摆动
                        if leftBtn.selected {
                            
                            eachSecond = 0.561
                        }
                        //前后摇摆
                        else if rightBtn.selected
                        {
                            eachSecond = 0.917
                        }
                        
                        let countString = timeSlider?.rightLabel.text?.componentsSeparatedByString("次").first
                        let countFloat = Float(countString!)
                        
                        let time = countFloat! * eachSecond
                        let widthFloat = CGFloat(time) * 17

                        let speed = leftBtn.selected ? 0 : 1
                        
                        self?.createCollectionCell(row, index: index,width:CGFloat(widthFloat),param: ["\(speed)",timeSlider!.rightLabel.text!.componentsSeparatedByString("次").first!])
                        
                        self?.alert.dismiss()

                }
                })
            case 1...4: doAction({ [weak self] in
                
                let actionStr = "\(row == 4 ? "右" : "左")臂\(self!.cellDic[row]![index])"
                
                let label = self!.createLabel("确认选择\(actionStr)动作?（时长：2s)", frame: CGRectMake(self!.alertView.cancelBtn.frame.origin.x,50,300 - 40,30))
                label.textAlignment = .Center
                self?.alertView.addSubview(label)
                self!.alertView.ensureBtn.enabled = true
                
                self?.alertView.code =
                    {
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }
                        
                        var param = 0.0
                        
                        switch index
                        {
                        case 1: param = 1000.0
                        case 2: param = 900.0
                        case 3: param = 0.0
                        case 4: param = 300.0
                        default:break
                        }
                        
                        
                        self?.createCollectionCell(row, index: index,width: CGFloat(34),param: ["\(param)"])
                        
                        self?.alert.dismiss()

                }
                })
            default:break
            }
            
        case 6,7:
            switch index
            {
            case 0...11: doAction({ [weak self] in
                //初始化label
                let timeSlider = self?.createSliderV(("持续时长","00:00"), values: ("00:00", "00:30"), frame: CGRectMake(10, 70, self!.ALERT_WIDTH - 10, 40))
                
                self?.alertView.addSubview(self!.createLabel("\(index == 11 ? "疑问":self!.cellDic[row]![index])状态", frame: CGRectMake(self!.alertView.cancelBtn.frame.origin.x,10,self!.ALERT_WIDTH - 40,30)))
                
                self?.alertView.code =
                    {
                        if bool
                        {
                            if let cell = self!.rightTable!.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? MotionProgramCell
                            {
                                cell.delete()
                            }
                        }
                        
                        var time = 0
                        
                        if let str = timeSlider?.rightLabel.text
                        {
                            let (minR,secR) = ((str as NSString).substringToIndex(2),(str as NSString).substringFromIndex(3))
                            time = Int(minR)! * 60 + Int(secR)!
                        }
                        let width = CGFloat(time) * 17/// 30 * self!.rightTable.frame.width
                        
                        self?.createCollectionCell(row, index: index,width:width,param: [])
                        
                        self?.alert.dismiss()

                }
                })
            default:break
            }
        default:break
        }
        
    }
    
    /*------------------------------------------------------------------------------------------------------------*/
    private var row = 0
    //添加CollectionCell
    func createCollectionCell(row:Int,index:Int,width:CGFloat,param:[String?])
    {
        self.row = row
  
        let identifier = "section_\(0),row_\(row)"
        let cell = self.tableViewCellDic!.objectForKey(identifier) as! MotionProgramCell
        cell.deleteObject = {(cell:MotionProgramCell,row:Int) in
            
            var number : Int?
            
            for i in 0..<self.tableViewCellDic!.count {
                
                let identifier = "section_\(0),row_\(i)"

                self.tableViewCellDic?.objectForKey(identifier)
                
                if (self.tableViewCellDic?.objectForKey(identifier) as! MotionProgramCell) == cell {
                    
                    number = i
                    break;
                }
            }
            
            self.imgDic[number!]?.removeAtIndex(row)
            
            if row < self.functionDic[number!]?.count {
                self.functionDic[number!]?.removeAtIndex(row)
            }
            
            if row < self.frameDic[number!]?.count {
                self.frameDic[number!]?.removeAtIndex(row)
            }
        }
    
        
        cell.indexArr.append(index)
        
        self.indexArry[row] = cell.indexArr
        
        if imgDic[row] == nil {
            
            imgDic[row] = [UIImage(named:cellDic[row]![index])!]
        }
        else
        {
            imgDic[row]?.append(UIImage(named:cellDic[row]![index])!)
        }
        
        cell.dataArr = imgDic[row]!
        
        
        frameDic[row]!.append(frameDic[row]!.count == 0 ? CGRectMake(0, 0, width,cell.frame.height) : CGRectMake(frameDic[row]!.last!.size.width + frameDic[row]!.last!.origin.x, 0, width,cell.frame.height))
        
        cell.frameArr = frameDic[row]!
        
        let startTime = frameDic[row]!.count == 0 ? 0 : frameDic[row]![functionDic[row]!.count].origin.x / rightTable!.frame.width * 30
        let endTime = width / rightTable!.frame.width * 30 + startTime
        
        if 6 == row || 7 == row
        {
            functionDic[row]?.append((row == 6 ? "didEye:":"didEar:",[functionNameDic[row]![index]],Int(startTime),Int(endTime)))
        }
        else
        {
            functionDic[row]?.append((functionNameDic[row]![index],param,Int(startTime),Int(endTime)))
        }
        
        cell.funcArr = functionDic[row]!
        
        saveBtn.enabled = true
    }
    
    //配置collectionCell
    func configerCollectionCell(row:Int)
    {
        self.row = row
        
        let identifier = "section_\(0),row_\(row)"
        let cell = self.tableViewCellDic!.objectForKey(identifier) as! MotionProgramCell
        
        cell.deleteObject = {(cell:MotionProgramCell,row:Int) in
            
            var number : Int?
            
            for i in 0..<self.tableViewCellDic!.count {
                
                let identifier = "section_\(0),row_\(i)"
                
                self.tableViewCellDic?.objectForKey(identifier)
                
                if (self.tableViewCellDic?.objectForKey(identifier) as! MotionProgramCell) == cell {
                    
                    number = i
                    break;
                }
            }
            
            self.imgDic[number!]?.removeAtIndex(row)
            
            if row < self.functionDic[number!]?.count {
                self.functionDic[number!]?.removeAtIndex(row)
            }
            
            if row < self.frameDic[number!]?.count {
                self.frameDic[number!]?.removeAtIndex(row)
            }
        }
        
        if self.indexArry.count > row {
            cell.indexArr = self.indexArry[row]!
        }
        
        if self.imgDic.count > row {
            
            let imageArry = imgDic[row]
            
            if imageArry != nil {
            cell.dataArr = imageArry!
            }
            else
            {
                cell.dataArr = [UIImage]()
            }
        }
        
        if self.frameDic.count > row {
            cell.frameArr = frameDic[row]!
        }
        
        if self.functionDic.count > row {
            cell.funcArr = functionDic[row]!
        }
        
        if cell.collect != nil {
            
            cell.collect.reloadData()
        }
        
        saveBtn.enabled = true
    }
    
    //更新cell的内容
    func updateCellContentSize(frameObject:(String,[String?],Int,Int)?)
    {
        
    }
    
    //改变状态
    func textFieldDidChange(textField:UITextField)
    {
        //如果是输入整数
        if textField.tag == 123 {
            
            if !textField.text!.checkMatch(const.speedPattern)
            {
                Alert({
                    textField.text = ""
                    }, title: "请输入正整数数字", message: "")
                return
            }
            else
            {
                for view in alertView.subviews
                {
                    if let v = view as? ProgramSliderView
                    {
                        
                        if v.slider.value > 0 {
                            
                            alertView.ensureBtn.enabled = true
                            
                        }
                        else
                        {
                            alertView.ensureBtn.enabled = false
                        }
                    }
                }
            }
        }
        else
        {
            if textField.layer.cornerRadius == 5
            {
                var result = true
                
                for view in alertView.subviews
                {
                    if let v = view as? ProgramSliderView where v.rightLabel.text == "00:00"
                    {
                        result = false
                    }
                }
                
                alertView.ensureBtn.enabled = result
                
                return
            }
            
            alertView.ensureBtn.enabled = textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ? true : false
            
            
            //文本相关内容
            if textField.text?.characters.count > 144
            {
                textField.text = (textField.text! as NSString).substringToIndex(144)
            }
            
            textField.tag = textField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            tempLabel.attributedText = NSAttributedString(string: "预计播放时长\(Double(textField.tag ) * 0.5)秒", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 14)!])
        }
        
        
    }
    
    //长按手势
    func longPress(sender:UILongPressGestureRecognizer)
    {
        switch sender.state
        {
        case .Changed:
            
            (sender.view as! UIImageView).highlighted = true
            
            if !audioRecorder.recording
            {//判断是否正在录音状态
                do
                {
                    try AVAudioSession.sharedInstance().setActive(true)
                    timer.fireDate = NSDate.distantPast()
                    //初始化录音
                    if let url = self.clickRecord()
                    {
                        recordURL = "\(url)"
                    }
                    audioRecorder.record()
                    alertView.ensureBtn.enabled = true
                    
                    print("record!")
                }
                catch
                {
                    print(error)
                }
            }
            
        case .Ended:
            (sender.view as! UIImageView).highlighted = false
            
            if audioRecorder.recording && audioRecorder != nil
            {
                audioRecorder.pause()
                do {
                    timer.fireDate = NSDate.distantFuture()
                    
                    recordURL = Convert().audioToMp3(recordURL)
                    
                    try AVAudioSession.sharedInstance().setActive(false)
                    print("stop!!")
                }
                catch
                {
                    print(error)
                }
            }
            
        default:break
        }
    }
    
    ///录音准备
    func clickRecord()->NSURL?
    {
        var recordURL:NSURL!
        
        AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
            if !allowed
            {
                let alertView = UIAlertView(title: "无法访问您的麦克风" , message: "请到设置 -> 隐私 -> 麦克风 ，打开访问权限", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "好的")
                alertView.show()
            }
            else
            {
                let recordSettings =
                    [AVSampleRateKey : NSNumber(float: Float(8000.0)),//声音采样率
                        AVFormatIDKey : NSNumber(int: Int32(kAudioFormatLinearPCM)),//编码格式
                        AVNumberOfChannelsKey : NSNumber(int: 2),//采集音轨
                        AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Max.rawValue))]//音频质量
                
                let directoryURL =
                    {
                        () -> NSURL? in
                        //根据时间设置存储文件名
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = "ddMMyyyyHHmmss"
                        let recordingName = formatter.stringFromDate(NSDate()) + ".caf"
                        
                        let documentDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
                        let soundURL = documentDirectory.URLByAppendingPathComponent(recordingName)//将音频文件名称追加在可用路径上形成音频文件的保存路径
                        
                        return soundURL
                }
                
                let audioSession = AVAudioSession.sharedInstance()
                
                do
                {
                    try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    recordURL = directoryURL()!
                    try self.audioRecorder = AVAudioRecorder(URL: recordURL,settings: recordSettings)//初始化实例
                    self.audioRecorder.delegate = self
                    self.audioRecorder.prepareToRecord()//准备录音
                    
                }
                catch
                {
                    print(error)
                }
            }
        }
        
        return recordURL
    }
    
    ///定时器方法
    func changeText(timer:NSTimer)
    {
        let hourStr = tempCount / 3600 < 10 ? "0\(tempCount / 3600)" : "\(tempCount / 3600)"
        let minuteStr = tempCount / 60 < 10 ? "0\(tempCount / 60)" : "\(tempCount / 60)"
        let secondStr = tempCount % 60 < 10 ? "0\(tempCount % 60)" : "\(tempCount % 60)"
        
        (timer.userInfo as! UILabel).attributedText = NSAttributedString(string: "\(hourStr):\(minuteStr):\(secondStr)", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 14)!])
        
        tempCount += 1
    }
    
    //创建label
    func createLabel(text:String,frame:CGRect)->UILabel
    {
        let label = UILabel(frame: frame)
        
        label.attributedText = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 14)!])
        return label
    }
    
    //创建Btn
    func createButton(title:String,image:String,selectedImg:String,frame:CGRect)->UIButton
    {
        let button = UIButton(frame: frame)
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 14)!]), forState: .Normal)
        button.setImage(UIImage(named: "\(image)"), forState: .Normal)
        button.setImage(UIImage(named: "\(selectedImg)"), forState: .Selected)
        button.addTarget(self, action: #selector(MotionProgramView.handleBtnState(_:)), forControlEvents: .TouchUpInside)
        alertView.addSubview(button)
        return button
    }
    
    func handleBtnState(sender:UIButton)
    {
        sender.selected = true
        
        for view in alertView.subviews
        {
            if view.classForCoder == UIButton().classForCoder && view != sender && view.frame.origin.y == sender.frame.origin.y
            {
                (view as! UIButton).selected = false
            }
        }
    }
    
    //创建sliderView
    func createSliderV<T:Hashable where T:Equatable>(texts:(String,String),values:(T,T),frame:CGRect)->ProgramSliderView
    {
        let view = UINib(nibName: "ProgramSliderView", bundle:nil).instantiateWithOwner(nil, options: nil)[0] as! ProgramSliderView
        
        view.setFrame = frame
        
        view.leftLabel.text = texts.0
        view.rightLabel.text = texts.1
        
        if let _ = values.0 as? Int
        {
            view.subLeftLabel.text = "\(values.0)"
            view.subRightLabel.text = "\(values.1)"
        }
        
        if let _ = values.0 as? String
        {
            view.subLeftLabel.text = values.0 as? String
            view.subRightLabel.text = values.1 as? String
        }
        
        alertView.addSubview(view)
        
        return view
    }
    
    ///执行方法
    func doAction(function:()->())
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            if self.alert != nil {
                
                self.alert.dismiss()
            }
            
            function()
            
            self.alert = AppAlert(frame:UIScreen.mainScreen().bounds, view: self.alertView, currentView: self, autoHidden: false)
        })
    }
    
    
    /*------------------------------------------------------------------------------------------------------------*/
    
    
    //MARK:-交互方法
    @IBAction func clickBack(sender: UIButton)
    {
        
        guard self.totalTime > 0 else
        {
           (self.getCurrentVC() as! UINavigationController).popViewControllerAnimated(true)
            return
        }
        
        if self.saveBtn.selected
        {
            (self.getCurrentVC() as! UINavigationController).popViewControllerAnimated(true)
        }
        else
        {
            if self.isEdit{
                
                //如果添加或者删除了内容
//                self.frameDic = (self.programming?.getFrameDic())!
//                self.functionDic = (self.programming?.getFunctionDic())!
//                self.timerArr = (self.programming?.timerArr)!
//                self.imgDic = (self.programming?.imgDic)!
//                self.rightTable!.reloadData()
//                self.indexArry = (self.programming?.indexArry)!
//                if self.frameDic == (self.programming!.getFrameDic()!){
                
                
//                if frameDi == pro_frameDic{
//                
//                    (self.getCurrentVC() as! UINavigationController).popViewControllerAnimated(true)
//                }else{
                
                    //程序做了修改
                    let alert = UIAlertController(title: "尚未保存，是否退出", message: "", preferredStyle: .Alert)
                    let action1 = UIAlertAction(title: "确定", style: .Destructive) { [weak self](_) in
                        (self?.getCurrentVC() as! UINavigationController).popViewControllerAnimated(true)
                    }
                    let action2 = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                    alert.addAction(action1)
                    alert.addAction(action2)
                    (self.getCurrentVC() as! UINavigationController).presentViewController(alert, animated: false, completion: nil)

//                }
            }else{
                (self.getCurrentVC() as! UINavigationController).popViewControllerAnimated(true)
                
                print(self.programming)
                print((MotionProgramViewController().view as! MotionProgramView).programming)
        }
    }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        
        if buttonIndex == 0
        {
            (getCurrentVC() as! UINavigationController).popViewControllerAnimated(true)
        }
        else
        {
            alertView.dismissWithClickedButtonIndex(buttonIndex, animated: true)
        }
    }
    
    @IBAction func clickSave(sender: UIButton)
    {
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            guard self.totalTime > 0 else
            {
                self.Alert({}, title: "程序不能为空", message: "")
                return
            }
            
            //保存名字和时间
            let view = UIView(frame: CGRectMake(0,0,260,180))
            
            let bgImg = UIImageView(frame: CGRectMake(0, 0, 260, 180))
            bgImg.image = UIImage(named: "WiFi弹窗")
            view.addSubview(bgImg)
            
            let titleLabel = UILabel(frame: CGRectMake(0, 10, 260, 20))
            titleLabel.textAlignment = .Center
            titleLabel.attributedText = NSAttributedString(string:"请输入程序名称" ,attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            
            view.addSubview(titleLabel)
            
            
            
            let tempTxtField = UITextView(frame: CGRectMake(30,50,200,40))
            tempTxtField.center.x = view.frame.width * 0.5
            tempTxtField.textColor = .whiteColor()
            tempTxtField.keyboardType = .NumbersAndPunctuation
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MotionProgramView.dropWords(_:)), name: UITextViewTextDidChangeNotification, object: tempTxtField)
            
            if self.programming != nil {
                tempTxtField.text = self.programming?.saveName
            }
            
            
            self.addBorder(tempTxtField)
            view.addSubview(tempTxtField)
            
            let btn = UIButton(frame: CGRectMake(40,100,180,30))
            btn.setBackgroundImage(UIImage(named: "小蓝按钮"), forState: .Normal)
            btn.center.x = view.frame.width * 0.5
            btn.setTitle("确定", forState: .Normal)
            btn.addTarget(self, action: #selector(MotionProgramView.saveOkBtnClick(_:)), forControlEvents: .TouchUpInside)
            view.addSubview(btn)
            
            let btn1 = UIButton(frame: CGRectMake(40,140,180,30))
            btn1.setBackgroundImage(UIImage(named: "小橙按钮"), forState: .Normal)
            btn1.center.x = view.frame.width * 0.5
            btn1.setTitle("取消", forState: .Normal)
            btn1.addTarget(self, action: #selector(MotionProgramView.saveOkBtnClick(_:)), forControlEvents: .TouchUpInside)
            view.addSubview(btn1)
            
            
            if self.alert != nil {
                
                self.alert.dismiss()
            }
            
            self.alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: view, currentView: self, autoHidden: false)
        }
    }
    func dropWords(sender:NSNotification)
    {
        let textView = sender.object as! UITextView
        if textView.text?.characters.count > 50
        {
            textView.text = (textView.text! as NSString).substringToIndex(50)
        }
    }
    
    //保存的确定按钮
    func saveOkBtnClick(sender:UIButton)
    {
        if alert != nil {
            
            self.alert.dismiss()
        }
        
        if alertView != nil {
            
            alertView.dismiss()
        }
        
        
        if sender.titleLabel?.text == "取消"
        {
            return
        }
        
        for sub in sender.superview!.subviews
        {
            if let field = (sub as? UITextView)
            {
                if field.text!.characters.count <= 0
                {
                    Alert({}, title: "请输入程序名称", message: "")
                    return
                }
                else
                {
                    self.saveData(field.text)
                    self.saveBtn.selected = true
                    
                    if !self.isPushBtnClickBool {
                        
                        Alert({}, title: "保存成功", message: "")
                    }
                }
            }
        }
        
        //如果点击了 推送按钮
        if self.isPushBtnClickBool {
            
            if self.alert != nil {
                
                self.alert.dismiss()
            }
            
    
                let view = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
                view.titleLabel.hidden = true
                view.subTitleLabel.hidden = true
                view.contentLabel.textAlignment = .Center
                view.backBtn.hidden = true
                view.contentLabel.text = "正在处理数据。。。"
                view.frame = CGRectMake(0, 0, 300, 240)
                self.alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: view, currentView: self, autoHidden: false)
                print("创建alert\(self.alert)  1729")
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(1 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
                {
                    [unowned self] in
                    
                    self.action = previewAction(functionDic:self.functionDic,frameDic:self.frameDic,totalTime: self.totalTime,alert: self.alert,saveName: self.programming!.saveName!)
                    self.scriptID = self.action.getID()
                }

            self.isPushBtnClickBool = false
        }
    }
    
    //推送
//    func clickEnsure(sender:UIButton)
//    {
//        if sender.titleLabel?.text == "取消"
//        {
//            if self.alert != nil {
//                
//                self.alert.dismiss()
//            }
//            
//            return
//        }
//        
//        for sub in sender.superview!.subviews
//        {
//            if let field = (sub as? UITextView)
//            {
//                if field.text!.characters.count <= 0
//                {
//                    Alert({}, title: "请输入程序名称", message: "")
//                }
//                else
//                {
//                    if self.alert != nil {
//                        
//                        self.alert.dismiss()
//                    }
//                    let view = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
//                    view.titleLabel.hidden = true
//                    view.subTitleLabel.hidden = true
//                    view.contentLabel.textAlignment = .Center
//                    view.backBtn.hidden = true
//                    view.contentLabel.text = "正在处理数据。。。"
//                    view.frame = CGRectMake(0, 0, 300, 240)
//                    self.alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: view, currentView: self, autoHidden: false)
//                    print("创建alert\(self.alert)  1783")
//
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(1 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
//                    {
//                        [unowned self] in
//                        
//                        self.action = previewAction(functionDic:self.functionDic,frameDic:self.frameDic,totalTime: self.totalTime,alert: self.alert,saveName: field.text)
//                        self.scriptID = self.action.getID()
//                        self.saveBtn.selected = true
//                    }
//                }
//            }
//        }
//    }
    
    //保存数据
    func saveData(saveName:String)
    {
        if self.programming == nil{
            
            self.programming = Programming.createProgramming(self.functionDic, frameDic: self.frameDic, totalTime: self.totalTime, saveName: saveName)
            self.programming!.timerArr = self.timerArr;
            self.programming!.imgDic = self.imgDic;
            self.programming!.indexArry = self.indexArry
            ProgrammingManager.shareManager.addProgramming(self.programming!)
        }
        else
        {
            self.programming?.setFunctionDic(self.functionDic)
            self.programming?.setFrameDic(self.frameDic)
            self.programming!.totalTime = self.totalTime
            self.programming!.saveName = saveName
            self.programming!.timerArr = self.timerArr;
            self.programming!.imgDic = self.imgDic;
            self.programming!.indexArry = self.indexArry
            ProgrammingManager.shareManager.updateProgramming(self.programming!)
        }
    }
    
    
    @IBAction func clickGuide(sender: UIButton)
    {
        let guideView = ProgramGuideView(frame:UIScreen.mainScreen().bounds)
        addSubview(guideView)
    }
    
    private var playBtn:UIButton!
    private var pauseBtn:UIButton!
    private var stopBtn:UIButton!
    private var timeKeeping:NSTimer!
    private var timeCount = 0
    
    //推送给小盒
    @IBAction func clickPlay(sender: UIButton)
    {
        guard  networkM.isConnectRobot == true else
        {
            Alert({}, title: "请连接机器人", message: "")
            return
        }
        
        //推送按钮点击
        self.isPushBtnClickBool = true
        
        //保存按钮的点击
        self.clickSave(self.saveBtn)

    }
    
    deinit
    {
        if timer != nil
        {
            timer.invalidate()
            timer = nil
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("\(classForCoder)--hello there")
    }
}


class previewAction:NSObject
{
    
    var data = [(String,[String?],CGFloat)?]()
    var functionDic:[Int:[(String,[String?],Int,Int)?]]!
    var frameDic:[Int:[CGRect]]!
    var scriptID:Int32 = -1
    
    
    private var saveName:String!
    private var alertView:AppAlert!
    private var totalCount = 0
    private var total:Int!
    
    private var audioArray = [String]()
    
    convenience init(functionDic:[Int:[(String,[String?],Int,Int)?]],frameDic:[Int:[CGRect]],totalTime:Int,alert: AppAlert?,saveName:String = "")
    {
        self.init()
        
        self.functionDic = functionDic
        self.frameDic = frameDic
        self.alertView = alert
        self.saveName = saveName
        self.total = totalTime
        
        for i in 0...7
        {
            totalCount += functionDic[i]!.count
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            self.scriptID = self.doAction()
        }
    }
    
    func getID()->Int32
    {
        return scriptID
    }
    
    
    private func handleData()
    {
        var temp = [(Int,(String,[String?],CGFloat)?)]()
        
        for i in 0...7
        {
            let function = functionDic[i]!
            let frame = frameDic[i]!
            
            if function.count > 0
            {
                temp.append((i,(function[0]!.0,function[0]!.1,frame[0].origin.x)))
            }
        }
        
        let sorted = temp.sort({ $0.1!.2 < $1.1!.2 })
        
        data.append(sorted[0].1)
        
        functionDic[sorted[0].0]?.removeAtIndex(0)
        frameDic[sorted[0].0]?.removeAtIndex(0)
        
    }
    
    private func createAction() -> String
    {
        var result = ""
        var tempX:CGFloat = 0
        
        while totalCount > 0
        {
            handleData()
            totalCount -= 1
        }
        
        //动作编号+#+参数+@+延时+|
        for i in data
        {
            if let item = i
            {
                var (name,params,pointX) = (item.0,item.1,item.2)
                
                switch item.0
                {
                    
                case "didPlaySST:": name = "1"
                case "didPlayAudio:":
                    
                    name = "0"
                    RobotControl.shareInstance().semaphoreMain = dispatch_semaphore_create(0)
                    
                    RobotControl.shareInstance().didPlayAudio(params.first ?? "", name: params.last ?? "", num: loginModel.sharedInstance.num, token: loginModel.sharedInstance.token, robotId: loginModel.sharedInstance.robotId)
                    
                    dispatch_semaphore_wait(RobotControl.shareInstance().semaphoreMain, DISPATCH_TIME_FOREVER);
                    params = [params.last!! + ".m4a"]
                    
                    for str in RobotControl.shareInstance().buf
                    {
                        audioArray.append("\(str)")
                    }
                case "didPlayRecord:":
                    name = "0"
                    RobotControl.shareInstance().semaphoreMain = dispatch_semaphore_create(0)
                    let name = params.last!!.componentsSeparatedByString(" ").last!.stringByReplacingOccurrencesOfString(":", withString: "")
                    RobotControl.shareInstance().didPlayRecord(params.first ?? "", name: name,num: loginModel.sharedInstance.num, token: loginModel.sharedInstance.token, robotId: loginModel.sharedInstance.robotId)
                    params = [name]
                    
                    dispatch_semaphore_wait(RobotControl.shareInstance().semaphoreMain, DISPATCH_TIME_FOREVER);
                    for str in RobotControl.shareInstance().buf
                    {
                        audioArray.append("\(str)")
                    }
                    
                //前进 后退
                case "didForward:":  name = "11"
                case "didFallback:": name = "14"
                //左右转
                case "didTurnLeft:otherSpeed:":name = "17"
                case "didTurnRight:otherSpeed:":name = "19"
                //原地转
                case "didClosewise:time:":name = "61"
                case "didCounterClosewise:time:":name = "62"
                    
                //点头摇头
                case "didNod:times:":name = "24"
                case "didShake:times:":name = "25"
                case "didLookUp": name = "27"
                case "didLookDown": name = "28"
                case "didLookLeft": name = "29"
                case "didLookRight": name = "30"
                    
                //摇动手
                case "didLeftHandShake:type:":name = "58"
                params = [params.last!!,"150","300"]
                case "didHandRightShake:type:":name = "59"
                params = [params.last!!,"150","300"]
                //左右抬手
                case "didHandRightUp:":name = "56"
                case "didHandRightBack:":name = "57"
                case "didHandLeftUp:":name = "54"
                case "didHandLeftBack:":name = "55"
                    
                //耳朵眼睛
                case "didEye:":name = "32"
                case "didEar:":name = "40"
                    
                //none
                default:name = ""
                }
                
                result += name
                
                if params.count > 0
                {
                    for param in params
                    {
                        result += "#\(param!)"
                    }
                }
                
                if pointX > tempX
                {
                    var arr = result.componentsSeparatedByString("|")
                    
                    for i in 0..<arr.count
                    {
                        if i == arr.count - 1
                        {
                            arr[i-1] += "@\(Int((pointX - tempX) / 15))000|"
                        }
                        if i < arr.count - 2
                        {
                            arr[i] += "|"
                        }
                    }
                    var temp = ""
                    
                    for str in arr
                    {
                        temp += str
                    }
                    result = temp
                }
                
                result += "|"
                
                tempX = pointX
            }
        }
        return "\(saveName)^\(result.substringToIndex(result.endIndex.advancedBy(-1)))^" + (total / 60 < 10 ? "0\(total / 60)" : "\(total / 60)") + (total % 60 < 10 ? "'0\(total % 60)":"'\(total % 60)")
    }
    
    func doAction()->Int32
    {
        (alertView.topView as! AppAlertView).contentLabel.text = "正在向机器人端发送"
        
        let scriptString = createAction()
        
        if 0 == RobotControl.shareInstance().didPushScript(scriptString, audio: audioArray)
        {
            //查询脚本文件
            let dictArr = RobotControl.shareInstance().didQueryScript()
            if let _ = dictArr.lastObject
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
                {
                    [unowned self] in
                
                    if self.alertView != nil
                    {
                        (self.alertView.topView as! AppAlertView).contentLabel.text = "发送成功"
                    
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(1 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
                    {
                        [unowned self] in
                        
                        self.alertView.dismiss()

                    }
                    }
                    
                }
                if let id = dictArr.lastObject?["ID"] as? NSNumber
                {
                    return id.intValue
                }
                return -1
            }
        }
        else
        {
            (alertView.topView as! AppAlertView).titleLabel.text = "发送失败，请重试"
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
            {
                [unowned self] in
                (self.alertView.topView as! AppAlertView).dismiss()
            }
        }
        return -1
    }
}




