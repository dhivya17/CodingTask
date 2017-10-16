//
//  ViewController.swift
//  Instagram
//
//  Created by Dhivya on 13/10/17.
//  Copyright © 2017 mymac. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class StoriesViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,LightBoxMessage {
    
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    var rowImage = [String]()
    var rowName = [String]()
    var data = [Any]()
    var jsonDict : [String:Any]?
    var statusBarHidden  = false
    var progressView : [UIProgressView]?
    var dataIndexToShow :  Int = 0
    var timer : Timer?
    var dataToShow: [Any]?
    var lightBoxView : LightBoxView?
    var avPlayer : AVPlayer?
    var timeObserver: AnyObject!
    var indexPathToShow : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readJSONData()
        // print("rowimg--\(rowImage) \r rowname--\(rowName) \r data-- \(data)")
        storiesCollectionView.dataSource = self
        storiesCollectionView.delegate = self
        storiesCollectionView.register(UINib(nibName:"StoriesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"storiesCell")
        storiesCollectionView.register(UINib(nibName:"StoryHeaderView",bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0, left: 5, bottom: 0, right: 5)
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 80 , height: 120)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.headerReferenceSize = CGSize(width: 100, height: 100)
        storiesCollectionView!.collectionViewLayout = layout
        self.automaticallyAdjustsScrollViewInsets = false
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - collection View Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowImage.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        addLightBox(indexPath)
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storiesCell", for: indexPath as IndexPath) as! StoriesCollectionViewCell
        
        cell.storyName.text = self.rowName[indexPath.item]
        let image  = UIImage(named: self.rowImage[indexPath.row])
        cell.stroyImageView.image = image?.circleMask
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as! StoryHeaderView
        
        header.headerName.text = "Santo"
        let image  = UIImage(named: "image5")
        header.headerImage.image = image?.circleMask
        
        return header
    }
    
    //MARK: - HELPERS
    override var prefersStatusBarHidden: Bool{
        return (self.statusBarHidden) ? true  : false;
    }
    func isLightBoxClosed(closed: Bool){
        if closed {
            statusBarHidden = !statusBarHidden
            self.navigationController?.setNavigationBarHidden(statusBarHidden, animated: false)
            resetTimer()
        }
    }
    func readJSONData(){
        
        do {
            if let file = Bundle.main.url(forResource: "Data", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonArr = json as? [Any] {
                    for value in jsonArr{
                        if let dict = value as? Dictionary<String, Any>{
                            
                            self.rowName.append(dict["outlinName"] as! String)
                            self.rowImage.append( dict["outlineImage"] as! String)
                            self.data.append( dict["data"] as Any)
                            
                        }
                    }
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no such file exists")
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func addLightBox(_ indexPath : IndexPath){
        
        //hide status bar and navigation bar so that lightbox in full screen
        statusBarHidden = !statusBarHidden
        self.navigationController?.setNavigationBarHidden(statusBarHidden, animated: false)
        
        lightBoxView = Bundle.main.loadNibNamed("LightBoxView", owner: nil, options: nil)?[0] as? LightBoxView
        lightBoxView?.delegate = self
        dataToShow =  data[indexPath.row] as? [Any]
        progressView =  lightBoxView?.addProgressBar(count: (dataToShow?.count)!)
        indexPathToShow = indexPath
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
            
            self.view.addSubview(self.lightBoxView!)
            
        }, completion: nil)
        
        //  add constrainsts
        let topConstraint = NSLayoutConstraint(item:self.view , attribute: .top, relatedBy: .equal, toItem: lightBoxView, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: lightBoxView, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: lightBoxView, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: lightBoxView, attribute: .trailing, multiplier: 1, constant: 0)
        lightBoxView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        lightBoxView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        
        setupSwipeGestureRecognizer()
        
    }
    
    func resetTimer(){
        timer?.invalidate()
        timer = nil
        dataIndexToShow = 0
    }
    func updateTimer(){
        
        if dataIndexToShow == dataToShow?.count
        {
            resetTimer()
        }
        else
        {
            //print("updateTimerImage called\(dataIndexToShow)")
            let dict =  dataToShow?[dataIndexToShow] as! [String : String]
            if dict["wrapperType"] == "image" {
                lightBoxView?.imageView.isHidden = false
                progressView?[dataIndexToShow].progress += 0.1
                progressView?[dataIndexToShow].tintColor = UIColor.white
                lightBoxView?.setUpView(index: dataIndexToShow, dataToShow: dataToShow!)
                if progressView?[dataIndexToShow].progress == 1 {
                    dataIndexToShow += 1
                }
            }
            else if dict["wrapperType"] == "video" {
                
                addVideo(dict["name"]!)
                timer?.invalidate()
                timer = nil
                
            }
            
            
        }
        
    }
    func addVideo(_ fileName : String){
        
        let filepath: String? = Bundle.main.path(forResource: fileName, ofType: "mp4")
        let fileURL = URL.init(fileURLWithPath: filepath!)
        avPlayer = AVPlayer(url: fileURL)
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        avPlayer?.volume = 5.0
        avPlayerController.view.frame = (lightBoxView?.videoView.frame)!
        avPlayerController.showsPlaybackControls = false
        avPlayerController.player?.play()
        lightBoxView?.videoView.addSubview(avPlayerController.view)
        lightBoxView?.imageView.isHidden = true
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = avPlayer!.addPeriodicTimeObserver(forInterval: timeInterval,
                                                         queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
                                                            
                                                            self.observeTime(elapsedTime: elapsedTime)
            } as AnyObject
        
    }
    func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds((avPlayer?.currentItem!.duration)!)
        
        if duration.isFinite {
            let elapsedTime : Float64 = CMTimeGetSeconds(elapsedTime)
            print("inside observeTime\(elapsedTime) duration\(duration) dataIndexToShow\(dataIndexToShow) progress --\(String(describing:  progressView?[dataIndexToShow].progress))")
            progressView?[dataIndexToShow].progress += Float(elapsedTime/duration) - 0.01
            progressView?[dataIndexToShow].tintColor = UIColor.white
            if progressView?[dataIndexToShow].progress == 1 && elapsedTime == duration  {
                dataIndexToShow += 1
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            }
            
        }
    }
    //MARK:-GESTURE
    func setUpTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapAction(_:)))
        lightBoxView?.swipeView.addGestureRecognizer(tapGesture)
    }
    
    func handleTapAction(_ sender: UITapGestureRecognizer){
        timer?.invalidate()
        timer = nil
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        let dict =  dataToShow?[dataIndexToShow] as! [String : String]
        if dict["wrapperType"] == "image" {
            progressView?[dataIndexToShow].progress = 1
        }
        else{
            avPlayer?.removeTimeObserver(timeObserver)
            progressView?[dataIndexToShow].progress = 1
        }
        if dataIndexToShow < (dataToShow?.count)!{
            
            dataIndexToShow += 1
        }
        
        
    }
    
    func setupSwipeGestureRecognizer() {
        
        //For left swipe
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedScreen))
        swipeGestureLeft.direction = .left
        lightBoxView?.swipeView.addGestureRecognizer(swipeGestureLeft)
        
        //For right swipe
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedScreen))
        swipeGestureRight.direction = .right
        lightBoxView?.swipeView.addGestureRecognizer(swipeGestureRight)
        
    }
    func swipedScreen(gesture: UISwipeGestureRecognizer) {
        if (indexPathToShow?.row)! >= 0 && (indexPathToShow?.row)! < rowImage.count  {
            if gesture.direction == .left {
                guard (indexPathToShow?.row)! + 1  >= rowImage.count else{
                    indexPathToShow = IndexPath(row: (indexPathToShow?.row)! + 1, section: (indexPathToShow?.section)!)
                    resetTimer()
                    if self.view.subviews.contains(lightBoxView!) {
                        self.lightBoxView?.removeFromSuperview()
                        addLightBox(indexPathToShow!)
                        statusBarHidden = !statusBarHidden
                        self.navigationController?.setNavigationBarHidden(statusBarHidden, animated: false)
                        
                    }
                    
                    return
                }
            }
            else if gesture.direction == .right {
                guard (indexPathToShow?.row)! - 1 < 0 else{
                    indexPathToShow = IndexPath(row: (indexPathToShow?.row)! - 1, section: (indexPathToShow?.section)!)
                    resetTimer()
                    if self.view.subviews.contains(lightBoxView!) {
                        self.lightBoxView?.removeFromSuperview()
                        addLightBox(indexPathToShow!)
                        statusBarHidden = !statusBarHidden
                        self.navigationController?.setNavigationBarHidden(statusBarHidden, animated: false)
                        
                    }
                    return
                }
                
            }
        }
    }
    
    //MARK:-DEINIT
    deinit {
        avPlayer?.removeTimeObserver(timeObserver)
    }
}
extension UIImage {
    var circleMask: UIImage {
        
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.borderColor = UIColor.red.cgColor
        imageView.layer.borderWidth = 45
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
        
        
    }
    
}
