//
//  ViewController.swift
//  Instagram
//
//  Created by Dhivya on 13/10/17.
//  Copyright © 2017 mymac. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,LightBoxMessage {
    
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    var rowImage = [String]()
    var rowName = [String]()
    var data = [Any]()
    var jsonDict : [String:Any]?
    var statusBarHidden  = false
    var progressView : [UIProgressView]?
    var dataIndexToShow :  Int?
    var imageTimerCount = 0
    var videoTimerCount = 0
    var videoTimer, imageTimer : Timer?
    
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

        let lightBoxView = Bundle.main.loadNibNamed("LightBoxView", owner: nil, options: nil)?[0] as! LightBoxView
        lightBoxView.delegate = self
        let dataToShow =  data[indexPath.row] as! [Any]
        progressView =  lightBoxView.addProgressBar(count: dataToShow.count)
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
           
            self.view.addSubview(lightBoxView)
            
        }, completion: nil)
        
        //  add constrainsts
        let topConstraint = NSLayoutConstraint(item:self.view , attribute: .top, relatedBy: .equal, toItem: lightBoxView, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: lightBoxView, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: lightBoxView, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: lightBoxView, attribute: .trailing, multiplier: 1, constant: 0)
        lightBoxView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        lightBoxView.translatesAutoresizingMaskIntoConstraints = false
        

}



    func updateTimerImage(timer : Timer){
       
        let count : Int = (timer.userInfo as? Int)!
        print("updateTimerImage called\(count)")
        progressView?[count].tintColor = UIColor.white
        progressView?[count].progress += 0.2
        progressView?[count].tintColor = UIColor.white
        imageTimerCount  += 1
        if imageTimerCount == 5 {
            imageTimer?.invalidate()
        }
        
    }
    func updateTimerVideo(){
          print("updateTimerVideo called")
    //  progressView?[dataIndexToShow!].progress += 0.1
      //progressView?[dataIndexToShow!].tintColor = UIColor.white
    }
    //MARK: Delay func
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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
