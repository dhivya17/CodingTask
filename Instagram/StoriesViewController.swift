//
//  ViewController.swift
//  Instagram
//
//  Created by Dhivya on 13/10/17.
//  Copyright © 2017 mymac. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    var rowImage = [String]()
    var rowName = [String]()
    var data = [Any]()
    var jsonDict : [String:Any]?
    
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
        // [collectionView .deselectItem(at: , animated: YES)]
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
    
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}
