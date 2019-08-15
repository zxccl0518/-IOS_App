//
//  ControlInterface.swift
//  robosys
//
//  Created by Cheer on 16/6/8.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import CoreMotion


class ControlInterfaceView: AppView,UIScrollViewDelegate,UIAlertViewDelegate
{
    //MARK:-属性
    var ownTimer:NSTimer!
    var playTimer:NSTimer!
    
    lazy var ownTimeInterval = 1.0
    lazy var playTimeInterval = 1.0
    
    lazy var distance = 0.0
    lazy var isSelected = false
    
    lazy var count = 0
    
    lazy var motionManager = CMMotionManager()
    
    private lazy var isSet = false
    
    internal var originOffsetY:CGFloat!
    {
        didSet
        {
            if oldValue != nil
            {
                originOffsetY = oldValue
            }
        }
    }
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var totalBtn: UIButton!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var speedBtn: UIButton!
    @IBOutlet weak var backOrForwardBtn: UIButton!
    @IBOutlet weak var rightScroll: UIScrollView!
    @IBOutlet weak var leftScroll: UIScrollView!
    @IBOutlet weak var middleScroll: UIScrollView!
    @IBOutlet weak var midImage: UIImageView!
    
    
    //MARK:-生命周期
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        ownTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(ControlInterfaceView.ownTime), userInfo: nil, repeats: true)
        playTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ControlInterfaceView.playTime), userInfo: nil, repeats: true)

        recordBtn.setImage(UIImage(named: "暂停录制"), forState: .Selected)
        backOrForwardBtn.setImage(UIImage(named: "后退-运动"), forState: .Selected)
        
        setUpScorllView(rightScroll)
        setUpScorllView(leftScroll)
        
        
        let imageView = UIImageView(image: UIImage(named: "运动时速进度"))
        //imageView.contentMode = .ScaleAspectFill
        imageView.frame.size.height = middleScroll.frame.height

        middleScroll.contentSize = CGSizeMake(imageView.frame.width, 0)
        middleScroll.setContentOffset(CGPointMake(0,0), animated: false)
        middleScroll.bounces = false
        middleScroll.delegate = self
        middleScroll.clipsToBounds = true
        middleScroll.userInteractionEnabled = false
        middleScroll.showsHorizontalScrollIndicator = false
        middleScroll.addSubview(imageView)
        
        midImage.image = UIImage(named: "小盒大小比例")
    }
    
    func setUpScorllView(scrollV:UIScrollView)
    {
        let imageView = UIImageView(image: UIImage(named: "摇臂滚动条"))
        //imageView.contentMode = .
        imageView.frame.size.width = scrollV.frame.width
        
        scrollV.contentSize = CGSizeMake(0, imageView.frame.height)
        //scrollV.setContentOffset(CGPointMake(0, scrollV.frame.height * 0.266), animated: false)
        scrollV.bounces = false
        scrollV.clipsToBounds = true
        scrollV.showsVerticalScrollIndicator = false
        scrollV.delegate = self
        scrollV.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isSet
        {
            rightScroll.setContentOffset(CGPointMake(0, rightScroll.frame.height * 0.266), animated: false)
            leftScroll.setContentOffset(CGPointMake(0, leftScroll.frame.height * 0.266), animated: false)
            isSet = true
        }
    }
    
    //MARK:-定时器相关
    var speed = 0.0
    var angle = 0.0
    
    func ownTime()
    {
        count += 1
        
        caculateTime(Int(ownTimeInterval), button: totalBtn)
        ownTimeInterval += 0.5
        
        /*
         这个问题是这样的:旋转360的时间是8秒左右（实际是7.5），在发送了原地旋转的命令后对手机陀螺仪产生的速度控制进行屏蔽掉，等旋转时间到了后再启用陀螺仪控制速度
         */
        
        //检测设备可用性
        guard motionManager.deviceMotionAvailable == false else
        {
            //更新周期
            motionManager.deviceMotionUpdateInterval = 1
            
            //motion值就是通过加速度和旋转速度进行变换算出来的
            //打开陀螺仪监听处理参数更新回调
            motionManager.startDeviceMotionUpdatesToQueue(.mainQueue(), withHandler: { [weak self](motion:CMDeviceMotion?, error:NSError?) in
//                print(motion!.gravity.x,motion!.gravity.y)
                
                self!.speed = fabs(motion!.gravity.x) <= 15 / 90 ? 0 : fabs(motion!.gravity.x) <= 70 / 90 ? ( fabs(motion!.gravity.x) - 15 / 90) * 90 / 55 * 15 : 15
                
                
//                self!.angle = (Int32(fabs(motion!.gravity.y)) - 15 / 90) / (25 / 90) * 7 + self!.speed //5 + 5 + self!.speed / 15 * 3
                 self!.angle = fabs(motion!.gravity.y) * 1.94 - 0.33 + self!.speed
                
                if motion!.gravity.y < 0
                {
                    self!.angle = -self!.angle
                }
                
                if fabs(motion!.gravity.y) <= 15.0 / 90
                {
                    self!.angle = 0
                }
                
                if fabs(motion!.gravity.y) >= 40.0 / 90
                {
                    self!.angle = 40.0 / 90
                }
                
                if motion!.gravity.x >= 0
                {
                    self!.speed = 0
                }
            })
            
            if isSelected { speed = 10 }
            
            speedBtn.setAttributedTitle(createString(String(format: "%.1f", speed) + "  ", sufString: "厘米/秒"), forState: .Normal)
            
            distance += speed / 100
            distanceBtn.setTitle(String(format: "%.1f", distance) + "米", forState: .Normal)
            
            middleScroll.setContentOffset(CGPointMake((middleScroll.contentSize.width - middleScroll.frame.width) / 15 * CGFloat(speed), 0), animated: false)
            
            dispatch_async(dispatch_get_global_queue(0, 0),
            {
                [weak self] in
                
                if self!.angle != 0 //&& self!.count % 2 == 0
                {
                    let baseSpeed:Int32 = Int32(fabs(self!.speed)), deltaSpeed = Int32(self!.angle) < 0 ? -Int32(self!.angle) + baseSpeed : Int32(self!.angle) + baseSpeed
                    //前
                    if !self!.isSelected
                    {
                        print(self?.angle,baseSpeed,deltaSpeed)
                        self!.angle < 0 ? self?.control.didTurnLeft(deltaSpeed,otherSpeed:baseSpeed) : self?.control.didTurnRight(deltaSpeed,otherSpeed:baseSpeed)
//                     self!.angle < 0 ? self?.control.didTurnLeft(6,otherSpeed:12) : self?.control.didTurnRight(6,otherSpeed:12)
//
                    }
                }
                else
                {
                    if self!.speed == 0
                    {
                        self!.control.didStop()
                        return
                    }
                    
                    !self!.isSelected ? self!.control.didForward(Int32(self!.speed)) : self!.control.didFallback(Int32(self!.speed))
                }
            })
            return
        }
    }
    
    func playTime()
    {
        guard !recordBtn.selected else
        {
            caculateTime(Int(playTimeInterval), button: playBtn)
            playTimeInterval += 1
            
            //录制
            
            
            
            return
        }
    }
    func caculateTime(timeInterval:Int,button:UIButton)
    {
        guard timeInterval < 1 else
        {
            let hourStr = timeInterval / 3600 < 10 ? "0\(timeInterval / 3600)" : "\(timeInterval / 3600)"
            let minuteStr = timeInterval / 60 < 10 ? "0\(timeInterval / 60)" : "\(timeInterval / 60)"
            let secondStr = timeInterval % 60 < 10 ? "0\(timeInterval % 60)" : "\(timeInterval % 60)"
            
            button.setTitle("\(hourStr):\(minuteStr):\(secondStr)",forState: .Normal)
            return
        }
    }
    func createString(preString:String,sufString:String)-> NSMutableAttributedString
    {
        let string = NSMutableAttributedString(
            string: preString, attributes: [
                NSForegroundColorAttributeName:UIColor.whiteColor(),
                NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!
            ])
        string.appendAttributedString(
            NSAttributedString(string: sufString, attributes: [
                NSForegroundColorAttributeName:UIColor(red: 59/255, green: 129/255, blue: 168/255, alpha: 1),
                NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!
                ]))
        return string
    }
 
    //MARK:-按钮方法
    @IBAction func pause(sender: UIButton)
    {
        ownTimer.fireDate = NSDate.distantFuture()
        playTimer.fireDate = NSDate.distantFuture()
        
            let alert = UIAlertController(title:"请选择", message:"", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "继续", style: .Cancel, handler: { [unowned self](_) in
                self.ownTimer.fireDate = NSDate.distantPast()
                self.playTimer.fireDate = NSDate.distantPast()
                }))
            alert.addAction( UIAlertAction(title: "退出", style: .Destructive, handler: {
                _ in self.back()
            }))
            
            getCurrentVC().presentViewController(alert, animated: true, completion: nil)
    }
    //录制
    @IBAction func record(sender: UIButton)
    {
        sender.selected = !sender.selected
        playBtn.hidden = !playBtn.hidden
        
    }
    
    @IBAction func back(sender: UIButton)
    {
        back()
    }
    func back()
    {
        dispatch_async(dispatch_get_global_queue(0, 0)) {[weak self] in
            self!.control.didStop()
            self!.playTimer.invalidate()
            self!.ownTimer.invalidate()
        }
        (self.getCurrentVC() as! UINavigationController).popViewControllerAnimated(true)
    }
    @IBAction func backOrForward(sender: UIButton)
    {
        sender.selected = !sender.selected
        isSelected = sender.selected
        
    }
    
    //MARK:-手势方法
    @IBAction func pressLeft(sender: UITapGestureRecognizer)
    {
        tapGestrue(sender) {  [weak self] in
           
            self?.control.didLookLeft()
        }
     
    }
    @IBAction func pressRight(sender: UITapGestureRecognizer)
    {
        tapGestrue(sender) { [weak self] in
           
            self?.control.didLookRight()
        }
    }
    @IBAction func pressUp(sender: UITapGestureRecognizer)
    {
        tapGestrue(sender) { [weak self] in
           
            self?.control.didLookUp()
        }
    }
    @IBAction func pressDown(sender: UITapGestureRecognizer)
    {
        tapGestrue(sender) { [weak self] in

            self?.control.didLookDown()
        }
    }
    
    
    /*
     这个问题是这样的:旋转360的时间是8秒左右（实际是7.5），在发送了原地旋转的命令后对手机陀螺仪产生的速度控制进行屏蔽掉，等旋转时间到了后再启用陀螺仪控制速度
 
     */
    //左转
    @IBAction func pressLeftTurn(sender: UITapGestureRecognizer)
    {
        
        tapGestrue(sender) { [weak self] in
            //停掉定时器，不让走路
        
            //停止获取陀螺仪数据
            self?.motionManager.stopGyroUpdates()
            
            self?.ownTimer.fireDate = NSDate.distantFuture()
            
            
             self?.control.didCounterClosewise()
                        //等待转圈完成
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(7.5 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
            {
                
                self?.ownTime()
                
                self?.ownTimer.fireDate = NSDate.distantPast()
                
            }
        }
    }
    
    //右转
    @IBAction func pressRightTurn(sender: UITapGestureRecognizer)
    {
        tapGestrue(sender) { [weak self] in
            self?.ownTimer.fireDate = NSDate.distantFuture()
           
            self?.motionManager.stopGyroUpdates()
            //右转
            self?.control.didClosewise()

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(7.5 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
            {
                
                self?.ownTime()
                self?.ownTimer.fireDate = NSDate.distantPast()
            }
        }
    }
    @IBAction func pressNodHead(sender: UITapGestureRecognizer)
    {
        tapGestrue(sender) { [weak self] in

            self?.control.didNod(1, times: 1)
        }
    }
    @IBAction func pressShakeHead(sender: UITapGestureRecognizer)
    {
        tapGestrue(sender) { [weak self] in
 
            self?.control.didShake(1, times: 1)
        }
    }
    func tapGestrue(sender:UITapGestureRecognizer,code:()->())
    {
        switch sender.state
        {
        case .Began:
            (sender.view as! UIImageView).highlighted = true

        case.Ended:
            
            dispatch_async(dispatch_get_global_queue(0, 0),
            {
                code()
            })
          
            (sender.view as! UIImageView).highlighted = false
            
        default:
            break
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
//        if scrollView == middleScroll
//        {
//            return
//        }
//        
//        originOffsetY = scrollView.contentOffset.y
//
//        //抬起
//        if scrollView.contentOffset.y > originOffsetY
//        {
//            dispatch_async(dispatch_get_global_queue(0, 0),
//            {
//                [weak self] in
//                
//                let angle = (scrollView.contentOffset.y) / (scrollView.contentSize.height - scrollView.frame.height) * 1000
//                
//                scrollView == self!.leftScroll ?  self!.control.didHandLeftUp(Float(angle)) : self!.control.didHandRightUp(Float(angle))
//                
//                //print("Up:\(angle)")
//            })
//        }
//        else
//        {
//            dispatch_async(dispatch_get_global_queue(0, 0),
//            {
//                [weak self] in
//                
//                let angle = (self!.originOffsetY - scrollView.contentOffset.y) / self!.originOffsetY * 300
//                
//                scrollView == self!.leftScroll ? self!.control.didHandLeftBack(Float(angle)) : self!.control.didHandRightBack(Float(angle))
//                
//                //print("Down:\(angle)")
//            })
//        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == middleScroll
        {
            return
        }
        
        originOffsetY = scrollView.contentOffset.y
        
        //抬起
        if scrollView.contentOffset.y > originOffsetY
        {
            dispatch_async(dispatch_get_global_queue(0, 0),
                           {
                            [weak self] in
                            
                            let angle = (scrollView.contentOffset.y) / (scrollView.contentSize.height - scrollView.frame.height) * 1000
                            
                            scrollView == self!.leftScroll ?  self!.control.didHandLeftUp(Float(angle)) : self!.control.didHandRightUp(Float(angle))
                            
                            //print("Up:\(angle)")
                })
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(0, 0),
                           {
                            [weak self] in
                            
                            let angle = (self!.originOffsetY - scrollView.contentOffset.y) / self!.originOffsetY * 300
                            
                            scrollView == self!.leftScroll ? self!.control.didHandLeftBack(Float(angle)) : self!.control.didHandRightBack(Float(angle))
                            
                            //print("Down:\(angle)")
                })
        }
    }
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
