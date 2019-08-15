//
//  RecreationalView.swift
//  robosys
//
//  Created by Cheer on 16/5/23.
//  Copyright © 2016年 joekoe. All rights reserved.
//
import UIKit

class RecreationalView: AppView,UIGestureRecognizerDelegate
{
    
    
    @IBOutlet weak var leftBtn: UIButton!
    
    @IBOutlet weak var rightBtn: UIButton!
    
    //-MARK:属性
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningImg: UIImageView!
    
    private lazy var btnArray = ["讲笑话","讲故事","运动模式","我的程序","盒成音"]
    
    private lazy var scroll : UIScrollView = {
        
       let scro = UIScrollView()
        scro.bounces = false
        scro.showsHorizontalScrollIndicator = false
        return scro
    }()
    
    lazy var headView : MainHeadView = MainHeadView()
    
    lazy var right:UISwipeGestureRecognizer =
    {
        let ges = UISwipeGestureRecognizer(target: self, action: #selector(RecreationalView.swipeGesture(_:)))
        
        ges.direction = .Right
        return ges
    }()
    
    //-MARK:生命周期
    override func awakeFromNib()
    {
        super.awakeFromNib()

        right.delegate = self
        
        let headView = initMainHeadView("未连接", imageName: "菜单")
        self.headView = headView
        
        scroll.frame = CGRectMake(30,frame.height - 150,frame.width - 60,55)
        
        for i in 0...btnArray.count-1
        {
            scroll.addSubview(initBtn(i, title: btnArray[i]))
        }
        
        if let temp = scroll.subviews.last
        {
            scroll.contentSize = CGSizeMake(temp.frame.width + temp.frame.origin.x, 0)
        }

        addSubview(scroll)
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
    
    func initBtn(index:Int,title:String)->UIButton
    {
        
        let btn = UIButton()
        let width = scroll.frame.size.width/4
        btn.frame = CGRectMake(width * CGFloat(index), 0,width, 54)
        
        btn.tag = index
        
        btn.setImage(UIImage(named: "\(btnArray[index])"), forState: .Normal)
        btn.imageView?.contentMode = .ScaleAspectFit
        btn.addTarget(self, action: #selector(RecreationalView.clickScrollBtn(_:)), forControlEvents: .TouchUpInside)
        return btn
    }
    
    func clickScrollBtn(sender:UIButton)
    {
        switch sender.tag
        {
        case 0:
            if networkM.isConnectRobot && robotM.online!
            {
                sender.selected = !sender.selected

                control.didJoke(sender.selected ? 3 : 0)
            }
            else
            {
                Alert({}, title: "请连接在线机器人", message: "")
            }

        case 1:
            if networkM.isConnectRobot && robotM.online!
            {
                sender.selected == false ? control.didStoryPlay() : control.didStoryStop()
                sender.selected = !sender.selected
            }
            else
            {
                Alert({}, title: "请连接在线机器人", message: "")
            }
            
        case 2:
            
            if networkM.isConnectRobot && robotM.online!
            {
                getCurrentVC().navigationController?.pushViewController(MotionModeViewController(nibName: "MotionModeView", bundle: nil), animated: true)
            }
            else
            {
                Alert({}, title: "请连接在线机器人", message: "")
            }

        case 3:
            
            if networkM.isConnectRobot && robotM.online!
            {
                getCurrentVC().navigationController?.pushViewController(MyProgramViewController(nibName: "MyProgramView", bundle: nil), animated: true)
            }
            else
            {
                Alert({}, title: "请连接在线机器人", message: "")
            }
        
        case 4:
            
            if networkM.isConnectRobot && robotM.online!
            {
                getCurrentVC().navigationController?.pushViewController(CompactSoundViewController(nibName: "CompactSoundViewController", bundle: nil), animated: true)
            }
            else
            {
                Alert({}, title: "请连接在线机器人", message: "")
            }
            
            
        default:break
        }
    }

    @IBAction func moveLeft(sender: UIButton)
    {
        guard scroll.contentOffset.x <= 0 else
        {
            scroll.contentOffset.x = 0
            return
        }
    }
    @IBAction func moveRight(sender: UIButton)
    {
        guard scroll.contentOffset.x >= 62 else
        {
            scroll.contentOffset.x = scroll.contentSize.width - scroll.frame.width
            return
        }
    }
    
    //点击运动控制
    @IBAction func motionControl(sender: UIButton)
    {
        if networkM.isConnectRobot == true
        {
            getCurrentVC().navigationController?.pushViewController(ControlInterfaceViewController(nibName: "ControlInterfaceView",bundle: nil), animated: true)
        
        }
        else
        {
            Alert({}, title: "请连接机器人", message: "")
        }
    }
    
    //点击编程控制
    @IBAction func programControl(sender: UIButton)
    {
        getCurrentVC().navigationController?.pushViewController(ProgramControlViewController(nibName: "ProgramControlView",bundle: nil), animated: true)
    }

    //点击日程提醒
    @IBAction func scheduleRemind(sender: UIButton)
    {

            jump2AnyController(ScheduleRemindViewController(nibName: "ScheduleRemindView",bundle: nil))
    }
    
    //点击播放音乐
    @IBAction func clickMusic(sender: UIButton)
    {
        
        if networkM.isConnectRobot == true && robotModel.sharedInstance.online!
        {
            getCurrentVC().navigationController?.pushViewController(MusicPlayViewController(nibName: "MusicPlayViewController",bundle: nil), animated: true)
        }
        else
        {
            Alert({}, title: "请连接机器人", message: "")
        }
        
        
//        Alert({}, title: "功能暂未开放", message: "")
//        if networkM.isConnectRobot && robotM.online!{
////        let nav = UINavigationController(rootViewController: MusicViewController())
        
//        }
    }
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        print(touch.view?.classForCoder)
        
        return true
    }
}
