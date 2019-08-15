
//
//  PlayViewController.swift
//  robosys
//
//  Created by 刘渊 on 2017/4/20.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {
    
    //MARK:自定义topcell数据源
    private lazy var dataTopArr = NSMutableArray()
    
    //MARK:自定义midCell数据源
    private lazy var dataMidArr  = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        
        view.backgroundColor = UIColor.init(red: 238/255.0, green: 239/255.0, blue: 241/255.0, alpha: 1)
        setupData()
        
        //MARK:设置导航栏
        setupNav()
        
        //MARK:顶部
        let topV = TopImageView()
        topV.translatesAutoresizingMaskIntoConstraints = false
        //传递数据源
        topV.pictureData = dataTopArr
        self.view.addSubview(topV)
        
        let leftConstraint = NSLayoutConstraint(item:topV, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: topV, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        let topConstaint = NSLayoutConstraint(item: topV, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 44)
        let heightConstaint = NSLayoutConstraint(item: topV, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant:242)
        leftConstraint.active = true
        rightConstraint.active = true
        topConstaint.active = true
        heightConstaint.active = true

        //MARK:中间播放视图
        let soundV = MidSoundView()
        soundV.translatesAutoresizingMaskIntoConstraints = false
        soundV.soundDataArr = dataMidArr
        self.view.addSubview(soundV)
        
        let leftCos = NSLayoutConstraint(item: soundV, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0)
        let rightCos = NSLayoutConstraint(item: soundV, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0)
        let topCos = NSLayoutConstraint(item: soundV, attribute: .Top, relatedBy: .Equal, toItem: topV, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let heightCos = NSLayoutConstraint(item: soundV, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 216)
        self.view.addConstraints([leftCos,rightCos,topCos,heightCos])
        
        //MARK:底部Table视图
        let botmV = BotmTabView()
        botmV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(botmV)
        
        let leftC = NSLayoutConstraint(item: botmV, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0)
        let rightC = NSLayoutConstraint(item: botmV, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0)
        let topC = NSLayoutConstraint(item: botmV, attribute: .Top, relatedBy: .Equal, toItem: soundV, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let botmC = NSLayoutConstraint(item: botmV, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraints([leftC,rightC,topC,botmC])
        
        
    }
    
    
    func setupData() {
       
        let titleA = ["点头","摇头","自定义"]
        
        for i in 0...titleA.count - 1 {
            
//            let image = UIImage(named: titleA[i])
            
            dataTopArr.addObject(titleA[i])
        }
        
        
        let titleB = ["Middle_-VOL_down_Normal","Midlle_Stop_Normal","Middle_-VOL_up_Normal","Middle_Next_Normal","Middle_Play_Normal","Middle_Previous_Normal"]
       
        for i in 0...titleB.count - 1 {
           
            dataMidArr.addObject(titleB[i])
        }
        
    }
    
    
    func setupNav() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "设置", imageName: "", target: self, action: #selector(set))
        self.navigationItem.title = "演示模式"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", imageName: "", target: self, action: #selector(cancel))
        
        //设置导航栏背景色
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 57/255.0, green: 56/255.0, blue: 61/255.0, alpha: 1)
        //设置字体颜色
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func set() {
        print("点击了set")
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
