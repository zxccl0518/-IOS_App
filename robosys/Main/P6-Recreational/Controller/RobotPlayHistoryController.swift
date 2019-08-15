//
//  RobotPlayHistoryController.swift
//  robosys
//
//  Created by Alan on 2017/9/19.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

protocol RobotHistoryDelegate: class{
    func historyDelegate(historyList:NSMutableArray,path:String) -> Void
}

class RobotPlayHistoryController: AppViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var robotHistoryView: AppView!
    @IBOutlet weak var robotHistoryTable: UITableView!
    
    var robotHistoryList = NSMutableArray()
    var historyMusicidList = NSMutableArray()
    var historyPath = String()
    
    private lazy var control = RobotControl.shareInstance()
    private lazy var musicModel = MusicModel.sharedInstance
    weak var delegate:RobotHistoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            //处理耗时操作
            self.querData()
            
            for arr in self.robotHistoryList {
                if arr as? String == "" {
                    self.robotHistoryList.removeObject(arr)
                }
            }
            //操作完成后调用主线程刷新界面
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.Alert({self.robotHistoryTable.reloadData()}, title: "加载完成...", message: "")
//                self.robotHistoryTable.reloadData()
            })
        }
        
        robotHistoryTable.delegate = self
        robotHistoryTable.dataSource = self
        
       robotHistoryView.initMainHeadView("播放历史", imageName: "返回")
       robotHistoryTable.indicatorStyle = .White
        
        robotHistoryTable.backgroundView?.backgroundColor = UIColor.clearColor()
        robotHistoryTable.backgroundColor = UIColor.clearColor()
        
        robotHistoryTable.registerClass(RobotHistoryCell.classForCoder(), forCellReuseIdentifier: "RobotHistoryCell")
    
    }
    
    func querData(){
        
        self.robotHistoryList = self.control.didGetAlbumList(0, page: 1)
        let hisOne = control.didGetAlbumList(0, page: 2)
        let historyTwo = control.didGetAlbumList(0, page: 3)
//        let historyThree = control.didGetAlbumList(0, page: 4)
//        let historyFour = control.didGetAlbumList(0, page: 5)
        
        for i in 0..<15 {
            robotHistoryList.insertObject(hisOne[i], atIndex: i+15)
        }
        for i in 0..<15 {
            robotHistoryList.insertObject(historyTwo[i], atIndex: i+30)
        }
//        for i in 0..<15 {
//            robotHistoryList.insertObject(historyThree[i], atIndex: i+45)
//        }
//        for i in 0..<15 {
//            robotHistoryList.insertObject(historyFour[i], atIndex: i+60)
//        }
        
        self.historyMusicidList = self.control.didGetMusicIdList(0, page: 1)
        let historyIdListOne = control.didGetMusicIdList(0, page: 2)
        let historyIdListTwo = control.didGetMusicIdList(0, page: 3)
//        let historyIdListThree = control.didGetMusicIdList(0, page: 4)
//        let historyIdListFour = control.didGetMusicIdList(0, page: 5)
        
        if historyIdListOne.count != 0 {
            
            for i in 0..<15 {
                historyMusicidList.insertObject(historyIdListOne[i], atIndex: i+15)
            }
        }
        
        for i in 0..<15 {
            historyMusicidList.insertObject(historyIdListTwo[i], atIndex: i+30)
        }
//        for i in 0..<15 {
//            historyMusicidList.insertObject(historyIdListThree[i], atIndex: i+45)
//        }
//        for i in 0..<15 {
//            historyMusicidList.insertObject(historyIdListFour[i], atIndex: i+60)
//        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return robotHistoryList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = RobotHistoryCell(style: .Default, reuseIdentifier: "RobotHistoryCell")
        cell.label.text = robotHistoryList[indexPath.row] as? String
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let musicName = robotHistoryList[indexPath.row]
//        let path = historyPath[indexPath.row]
        
        let muscid = historyMusicidList[indexPath.row] as! String
        let md:Int32 = Int32(muscid)!
        control.didPlayerStartHistory(4, audioId: md)
        
//        self.querData()
        
        for v in self.navigationController!.viewControllers
        {
            if v.classForCoder == MusicPlayViewController.classForCoder()
            {
                let vc = v as! MusicPlayViewController
                
                vc.cellList = self.robotHistoryList
                
                //                vc.musicPathList.insert(musicPath, atIndex: 0)
                vc.cellListId = self.historyMusicidList
                vc.cellListSouce = "历史"
                musicModel.cellListSouce = "历史"
                vc.isPlayingBtn.setImage(UIImage(named: "确认暂停"), forState: .Normal)
                self.navigationController?.popToViewController(v, animated: true)
                
            }
        }

    }

}


class RobotHistoryCell: UITableViewCell {
    
    lazy var label = UILabel()
    lazy var imageBack = UIImageView()
    lazy var bottomLine = UIImageView()
    lazy var bottomLinB = UIImageView()
    
    private lazy var control = RobotControl.shareInstance()
    lazy var index:Int32 = 0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor  = .clearColor()
        selectionStyle = .None
        frame = CGRectMake(0, 0, 200, 50)
        self.imageBack.image = UIImage(named: "Configure Network-Middle-Background1-")
        self.bottomLine.image = UIImage(named: "侧边分割线")
        self.bottomLinB.image = UIImage(named: "侧边分割线")
        
        //        label = UILabel(frame: CGRectMake(40,0,300,40))
        label.textColor = .whiteColor()
        
        addSubview(imageBack)
        addSubview(bottomLine)
        addSubview(bottomLinB)
        addSubview(label)
        
        label.snp_makeConstraints { (make) in
            make.left.equalTo(50)
            make.width.equalTo(250)
            make.height.equalTo(40)
            make.centerY.equalTo(self)
        }
        imageBack.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        bottomLine.snp_makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(imageBack.snp_top)
            make.height.equalTo(1)
        }
        bottomLinB.snp_makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(imageBack.snp_bottom)
            make.height.equalTo(1)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
