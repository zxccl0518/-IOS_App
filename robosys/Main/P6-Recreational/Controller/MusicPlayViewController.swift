//
//  MusicPlayViewController.swift
//  robosys
//
//  Created by Alan on 2017/9/19.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit


class MusicPlayViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var playView: AppView!
    
    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var robotMusicList: UIButton!
    
    
    @IBOutlet weak var isPlayingBtn: UIButton!
    @IBOutlet weak var appPlayHistory: UITableView!
    
    @IBOutlet weak var popLocationList: UIButton!
    var cellList = NSMutableArray()
    var cellListId = NSMutableArray()
    var cellListSouce = String()
    
    var indexR = [Int32]()
    var musicPathList = String()
    
    
    private lazy var control = RobotControl.shareInstance()
    private lazy var musicModel = MusicModel.sharedInstance
    // 头部视图
    private lazy var topImageV : UIView = {
        
        //        let headView = AppHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,140))
        let headView = MainHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width, 140))
        headView.titleLabel.text = "播放列表"
        
        headView.leftBtn.setImage(UIImage(named: "返回"), forState: .Normal)
        
        return headView
    }()

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if cellList.count != 0 {
            
            musicModel.musicListHistory = cellList
        }
        
        print("回来走了吗1 ???????????????")
//        musicModel.cellListSouce = self.cellListSouce
        if cellListSouce.isEmpty {
            cellListSouce = musicModel.cellListSouce
        }
            NSUserDefaults.standardUserDefaults().setObject(cellListId, forKey: "cellListId")
            NSUserDefaults.standardUserDefaults().setObject(cellList, forKey: "cellList")
            NSUserDefaults.standardUserDefaults().setObject(musicPathList, forKey: "musicPathList")
            NSUserDefaults.standardUserDefaults().setObject(cellListSouce, forKey: "cellListSouce")
        
        appPlayHistory.reloadData()
       
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        querData()
//        appPlayHistory.reloadData()
//        NSUserDefaults.standardUserDefaults().setObject(cellListId, forKey: "cellListId")
//        NSUserDefaults.standardUserDefaults().setObject(cellList, forKey: "cellList")
//        NSUserDefaults.standardUserDefaults().setObject(musicPathList, forKey: "musicPathList")
//    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let celist = NSUserDefaults.standardUserDefaults().valueForKeyPath("cellList") as? NSMutableArray
        print("*******第一次从偏好取********")
        print(celist)
        if celist?.count == 0 && musicModel.songList.count != 0{
            cellList = musicModel.songList
        }
        print("***************")
        if musicModel.songList.count == 0  {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                //处理耗时操作
                self.quiredTotalList()
                if celist?.count == nil{
                    self.cellList = self.musicModel.songList
                } else {
                    
                    self.cellList = celist!
                }
                print("走线程了吗")
                //操作完成后调用主线程刷新界面
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
//                    self.Alert({self.appPlayHistory.reloadData()}, title: "加载中...", message: "")
                    self.appPlayHistory.reloadData()
                })
            }
        }
        
        supportedInterfaceOrientations()
        
        playView.addSubview(topImageV)
//        self.topImageV.addSubview(popLocationList)
        
        topImageV.snp_makeConstraints { (make) in
            
            make.left.top.right.equalTo(playView)
            make.height.equalTo(140)
        }
        
        if cellListSouce.isEmpty {
            cellListSouce = musicModel.cellListSouce
        }
        
        if cellList.count == 0 {
            cellList = musicModel.musicListHistory
            print("********celist = 历史model*******")
            if cellList.count == 0{
                cellList = musicModel.songList
            }
        }
        
        
        if let path = NSUserDefaults.standardUserDefaults().valueForKeyPath("musicPathList") as? String {
            musicPathList = path
            
        } else if musicPathList == "" {
            
            musicPathList = "/mnt/sdcard/儿歌"
            print("-----------------------------")
            print(musicPathList)
        }

        
        if let cellId = NSUserDefaults.standardUserDefaults().valueForKeyPath("cellListId") as? NSMutableArray{
            cellListId = cellId
        }
        
        if let cellListSou = NSUserDefaults.standardUserDefaults().valueForKeyPath("cellListSouce") as? String{
            cellListSouce = cellListSou
        }
        
        if cellListSouce.isEmpty {
            cellListSouce = musicModel.cellListSouce
        }
        
        
        self.appPlayHistory.delegate = self
        self.appPlayHistory.dataSource = self
        
        
        self.appPlayHistory.registerClass(MusicPlayCell.classForCoder(), forCellReuseIdentifier: "music")
        self.appPlayHistory.indicatorStyle = .White
        
        self.appPlayHistory.backgroundView?.backgroundColor = UIColor.clearColor()
        self.appPlayHistory.backgroundColor = UIColor.clearColor()
        
        
        
    }
    
    func quiredTotalList(){
        let pat = "/mnt/sdcard/"
        
        let musicCellListSong = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/儿歌")
        
        let musicListTwo = control.didQueryDirecMusicList(2, path: "/mnt/sdcard/儿歌")
        
        let musicListThree = control.didQueryDirecMusicList(3, path: "/mnt/sdcard/儿歌")
        
        let musicListFour = control.didQueryDirecMusicList(4, path: "/mnt/sdcard/儿歌")
        
        let musicListFive = control.didQueryDirecMusicList(5, path: "/mnt/sdcard/儿歌")
        
        for i in 0..<15 {
            musicCellListSong.insertObject(musicListTwo[i], atIndex: 15+i)
//            musicCellListSong.insertObject(musicListThree[i], atIndex: 15)
//            musicCellListSong.insertObject(musicListFour[i], atIndex: 15)
        }
        
        for i in 0..<15 {
            musicCellListSong.insertObject(musicListThree[i], atIndex: i+30)
        }
        for i in 0..<15 {
            musicCellListSong.insertObject(musicListFour[i], atIndex: i+45)
        }
        for i in 0..<8 {
            musicCellListSong.insertObject(musicListFive[i], atIndex: i+60)
        }
//        for i in 0..<8 {
//            musicCellListSong.insertObject(musicListFive[i], atIndex: 15)
//        }
        
        musicModel.songList = musicCellListSong
        // --过滤空歌曲儿歌--
        for arr in musicModel.songList {
            if arr as? String == "" {
                musicModel.songList.removeObject(arr)
            }
        }
        musicModel.songPath = pat+"儿歌"
//        if musicModel.songList.count != 0 {
//            cellList = musicModel.songList
//            musicPathList = musicModel.songPath
//            appPlayHistory.reloadData()
//        }
        // -------国学数据----
        let musicCellListChina = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/国学")
        musicModel.chinaList = musicCellListChina
        musicModel.chinaPath = pat+"国学"
        // ----- 故事----
        let musicCellListStory = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/故事")
        
        let musicListStroyTwo = control.didQueryDirecMusicList(2, path: "/mnt/sdcard/故事")
        
        for i in 0..<10 {
            musicCellListStory.insertObject(musicListStroyTwo[i], atIndex: 15)
        }
        musicModel.storyList = musicCellListStory
        musicModel.storyPath = pat+"故事"
        // ---- 百科 -----
        let musicCellListencyc = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/百科")
        musicModel.encycList = musicCellListencyc
        musicModel.encycyPath = pat+"百科"
        // ---- 诗词 ----
        let musicCellListPeorty = control.didQueryDirecMusicList(1, path: "/mnt/sdcard/诗词")
        musicModel.poetryList = musicCellListPeorty
        musicModel.poetryPath = pat+"诗词"
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellList.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =  MusicPlayCell(style: .Default, reuseIdentifier: "music")
        
        cell.label.text = cellList[indexPath.row] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        isPlayingBtn.setImage(UIImage(named: "确认暂停"), forState: .Normal)
        if cellListSouce == "历史" {
            
            let musid = cellListId[indexPath.row]
            
            let md:Int32 = Int32(musid as! String)!
            print(md)
            control.didPlayerStartHistory(4, audioId: md)
            print("******刷新前*****")
            
            querData()
            appPlayHistory.reloadData()
            
            print("*****刷新后*****")
            print(md)
            
        } else {
            
//            let path = musicPathList
            let musicName = cellList[indexPath.row] as? String
            control.didPlayerStart(2, path: musicPathList, musicName: musicName)
            
        }
        MusicModel.sharedInstance.isPlaying = true
    }
    
    func querData(){
        
        self.cellList = self.control.didGetAlbumList(0, page: 1)
        let hisOne = control.didGetAlbumList(0, page: 2)
        let historyTwo = control.didGetAlbumList(0, page: 3)
        //        let historyThree = control.didGetAlbumList(0, page: 4)
        //        let historyFour = control.didGetAlbumList(0, page: 5)
        
        for i in 0..<15 {
            cellList.insertObject(hisOne[i], atIndex: i+15)
        }
        for i in 0..<15 {
            cellList.insertObject(historyTwo[i], atIndex: i+30)
        }
        //        for i in 0..<15 {
        //            robotHistoryList.insertObject(historyThree[i], atIndex: i+45)
        //        }
        //        for i in 0..<15 {
        //            robotHistoryList.insertObject(historyFour[i], atIndex: i+60)
        //        }
        
        self.cellListId = self.control.didGetMusicIdList(0, page: 1)
        let historyIdListOne = control.didGetMusicIdList(0, page: 2)
        let historyIdListTwo = control.didGetMusicIdList(0, page: 3)
        //        let historyIdListThree = control.didGetMusicIdList(0, page: 4)
        //        let historyIdListFour = control.didGetMusicIdList(0, page: 5)
        if historyIdListOne.count != 0 {
            for i in 0..<15 {
                cellListId.insertObject(historyIdListOne[i], atIndex: i+15)
            }
        }
        
        for i in 0..<15 {
            cellListId.insertObject(historyIdListTwo[i], atIndex: i+30)
        }
        //        for i in 0..<15 {
        //            historyMusicidList.insertObject(historyIdListThree[i], atIndex: i+45)
        //        }
        //        for i in 0..<15 {
        //            historyMusicidList.insertObject(historyIdListFour[i], atIndex: i+60)
        //        }
    }
    
    @IBAction func popLocationListClick(sender: UIButton) {
        
        let vc = MusicLocationListController(nibName: "MusicLocationListController",bundle: nil)
        //        vc.delegate = self
        vc.musicPathList = self.musicPathList
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func robotHistoryList(sender: UIButton) {
        
        Alert({
        let vc = RobotPlayHistoryController(nibName: "RobotPlayHistoryController",bundle: nil)
        vc.historyPath = self.musicPathList
        
        self.navigationController?.pushViewController(vc, animated: true)
            }, title: "扫描历史歌单...", message: "")
        
    }
    
    @IBAction func robotMusicListClick(sender: UIButton) {
        
        let vc = MusicViewController(nibName: "MusicViewController",bundle: nil)
//        vc.delegate = self
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func lastMusic(sender: UIButton) {
        
        Alert({
            
            self.querData()
            self.appPlayHistory.reloadData()
            self.control.didPlayerCtrl(4, type: 0)
            
            }, title: "播放中...", message: "")
        musicModel.isPlaying = true
    }
    
    @IBAction func playOrPause(sender: UIButton) {
        
        if MusicModel.sharedInstance.isPlaying == true{
            print(MusicModel.sharedInstance.isPlaying)
            sender.setImage(UIImage(named: "播放new"), forState: .Normal)
            control.didPlayerCtrl(2, type: 0)
            MusicModel.sharedInstance.isPlaying = false
            print("暂停了")
        }else{
            print(MusicModel.sharedInstance.isPlaying)
            sender.setImage(UIImage(named: "确认暂停"), forState: .Normal)
            control.didPlayerCtrl(3, type: 0)
            MusicModel.sharedInstance.isPlaying = true
            print("继续播放了")
        }
    }
    
    @IBAction func nextMusic(sender: UIButton) {
        
        Alert({
            self.querData()
            self.appPlayHistory.reloadData()
            self.control.didPlayerCtrl(5, type: 0)
            }, title: "播放中...", message: "")
        musicModel.isPlaying = true
    }
    
    @IBAction func cyclicCtrl(sender: UIButton) {
        if sender.tag == 0 {
            control.didPlayerCtrl(7, type: 1)
            print("走了单曲循环")
            sender.setImage(UIImage(named: "随机播放"), forState: .Normal)
            sender.tag = 1
        } else if sender.tag == 1 {
            control.didPlayerCtrl(7, type: 2)
            print("走了顺序播放")
            sender.setImage(UIImage(named: "确认暂停"), forState: .Normal)
            sender.tag = 2
        } else if sender.tag == 2{
            
            control.didPlayerCtrl(7, type: 3)
            print("走了顺序循环")
            sender.tag = 0
            sender.setImage(UIImage(named: "播放-按下"), forState: .Normal)
        }
        
    }
    
    
    
    deinit {
        print("deinit")
        
    }

}

class MusicPlayCell: UITableViewCell {
    
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
        frame = CGRectMake(0, 0, 300, 50)
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
            make.width.equalTo(300)
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

