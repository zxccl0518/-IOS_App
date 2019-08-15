//
//  MusicListController.swift
//  robosys
//
//  Created by Alan on 2017/9/25.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

//protocol MusicListControllerDelegate: class{
//    func musicDelegate(str: String) -> Void
//}

class MusicListController: AppViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var appView: AppView!
    @IBOutlet weak var tableView: UITableView!
    
//    weak var delegate: MusicListControllerDelegate?
    
    var musicList = NSMutableArray()
    var musicPath = String()
//        {
//        
//        didSet
//        {
//            musicList.count > 0 ? tableView.reloadData() : Alert({}, title: "扫描失败", message: "")
//        }
//    }
    
    private lazy var control = RobotControl.shareInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appView.initMainHeadView("音乐列表", imageName: "返回")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(MusicCellList.classForCoder(), forCellReuseIdentifier: "music")
        tableView.indicatorStyle = .White
//        self.tableView.tableFooterView = UIView.init(frame: CGRectZero)
        
        self.tableView.backgroundView?.backgroundColor = UIColor.clearColor();
        self.tableView.backgroundColor = UIColor.clearColor();
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return musicList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = MusicCellList(style: .Default, reuseIdentifier: "music")
        cell.label.text = musicList[indexPath.row] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(musicList[indexPath.row])
        guard let musicText = musicList[indexPath.row] as? String else { return }
        control.didPlayerStart(2, path: musicPath, musicName: musicText)
        MusicModel.sharedInstance.isPlaying = true
        
        for v in self.navigationController!.viewControllers
        {
            if v.classForCoder == MusicPlayViewController.classForCoder()
            {
                let vc = v as! MusicPlayViewController

                vc.cellList = musicList
                
//                vc.musicPathList.insert(musicPath, atIndex: 0)
                vc.musicPathList = musicPath
                vc.cellListSouce = "歌单"
                MusicModel.sharedInstance.cellListSouce = "歌单"
                self.navigationController?.popToViewController(v, animated: true)
    
            }
        }
    }
}

class MusicCellList: UITableViewCell {
    
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

   
