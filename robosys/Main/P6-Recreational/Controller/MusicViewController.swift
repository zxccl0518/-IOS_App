//
//  MusicViewController.swift
//  robosys
//
//  Created by Alan on 2017/9/20.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

//protocol MusicViewControllerDelegate: class{
//    func musicDelegate(str: String,index: Int32) -> Void
//}

class MusicViewController: AppViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var appView: AppView!
    
    @IBOutlet weak var tableView: UITableView!
    
//    weak var delegate: MusicViewControllerDelegate?
    
    
    
    var musicList = NSMutableArray()
//        {
//        
//        didSet
//        {
//            musicList.count > 0 ? tableView.reloadData() : Alert({}, title: "扫描失败", message: "")
//        }
//    }
    
    private lazy var control = RobotControl.shareInstance()
    private lazy var musicModel = MusicModel.sharedInstance
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        
//        print(self.musicList.count)
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let strPath = "/mnt/sdcard/"
        
        self.musicList = self.control.didQueryDirecMusicList(1, path: strPath)
        
        if musicList.count != 0 {
            
            for arr in musicList {
                if arr as? String == "" {
                    musicList.removeObject(arr)
                }
            }
        }
        
        appView.initMainHeadView("音乐目录", imageName: "返回")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(MusicCell.classForCoder(), forCellReuseIdentifier: "music")
        tableView.indicatorStyle = .White
        
        self.tableView.backgroundView?.backgroundColor = UIColor.clearColor();
        self.tableView.backgroundColor = UIColor.clearColor();
        print("--------")
//        print(musicList)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return musicList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = MusicCell(style: .Default, reuseIdentifier: "music")
        cell.label.text = musicList[indexPath.row] as? String
        
//        cell.index = (musicList[0] as! String).hasPrefix("1") ?  Int32(indexPath.row) :  Int32(indexPath.row) + 1
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let index = (musicList[0] as! String).hasPrefix("1") ?  Int32(indexPath.row) :  Int32(indexPath.row) + 1
        
//        control.didPlayMusicByIndex(index)
        let musicText = musicList[indexPath.row] as? String ?? ""
        
        var musicCellList = NSMutableArray()

        
        if musicText == "儿歌" {
            musicCellList = musicModel.songList
        }
        
        if musicText == "国学" {
            
//            musicCellList = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/国学")
//            musicModel.chinaList = musicCellList
//            musicModel.chinaPath = "/mnt/sdcard/"+musicText
            musicCellList = musicModel.chinaList
        }
        if musicText == "故事" {
            
//            musicCellList = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/故事")
//            
//            let musicListTwo = control.didQueryDirecMusicList(2, path: "/mnt/sdcard/故事")
//            
//            for i in 0..<10 {
//                musicCellList.insertObject(musicListTwo[i], atIndex: 15)
//            }
            musicCellList = musicModel.storyList
        }
        
        if musicText == "百科" {
//            musicCellList = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/百科")
            musicCellList = musicModel.encycList
        }
        if musicText == "诗词" {
//            musicCellList = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/诗词")
            musicCellList = musicModel.poetryList
        }
        if musicText == "音乐" {
            musicCellList = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/音乐")
        }
        if musicText == "script" {
            musicCellList = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/script")
            
        }
        if musicText == "System Volume Information" {
//            musicCellList = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/System Volume Information")

        }
        
        if musicText != "script" && musicText != "音乐"{
            
            if musicCellList.count != 0 {
                
                for arr in musicCellList {
                    if arr as? String == "" {
                        musicCellList.removeObject(arr)
                    }
                }
            }
        }
        
        
//        self.tableView.reloadData()
//        MusicModel.sharedInstance.musicList = self.musicList
//        MusicModel.sharedInstance.musicPath = "/mnt/sdcard/"+musicText
        
        let vc = MusicListController(nibName: "MusicListController",bundle: nil)
        vc.musicList = musicCellList
        vc.musicPath = "/mnt/sdcard/"+musicText
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }

    
}

class MusicCell: UITableViewCell {
    
    lazy var label = UILabel()
    lazy var imageBack = UIImageView()
    lazy var bottomLine = UIImageView()
    lazy var bottomLinB = UIImageView()
    lazy var rightImg = UIImageView()
    
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
        self.rightImg.image = UIImage(named: "查看")
        
//        label = UILabel(frame: CGRectMake(40,0,300,40))
        label.textColor = .whiteColor()
        
        addSubview(imageBack)
        addSubview(bottomLine)
        addSubview(bottomLinB)
        addSubview(label)
        addSubview(rightImg)
        
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
        rightImg.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.width.equalTo(10)
            make.right.equalTo(-10)
            make.centerY.equalTo(label)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
