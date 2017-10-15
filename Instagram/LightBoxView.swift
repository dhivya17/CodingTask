//
//  LightBoxView.swift
//  Instagram
//
//  Created by Ravneet Dhaliwal on 14/10/17.
//  Copyright © 2017 mymac. All rights reserved.
//

import UIKit
protocol LightBoxMessage {
    func isLightBoxClosed(closed: Bool)
}
class LightBoxView: UIView {
    var delegate : LightBoxMessage?
    @IBAction func closeAction(_ sender: Any) {
        UIView.transition(with: self.superview!, duration: 0.5, options: .transitionFlipFromRight, animations: { () -> Void in
                    self.delegate?.isLightBoxClosed(closed: true)
                    self.removeFromSuperview()
            
                    }, completion: nil)
    }
    
    func addProgressBar(count: Int) -> [UIProgressView]{
        let screenWidth = UIScreen.main.bounds.width
        var progressBarArray: [UIProgressView] = []
        var originX : Double  = 2
        let width = Double(screenWidth)/Double(count) - 2.8
        
        for _ in 0..<count{
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.frame = CGRect(x: originX, y: 10.0, width: width, height: 20.0)
        progressView.trackTintColor = UIColor.lightGray
        progressView.setProgress(0, animated: false)
         progressView.tintColor = UIColor.blue
        self.addSubview(progressView)
        originX +=   width + 2.0
        progressBarArray.append(progressView)
        }
        return progressBarArray
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
     
    */
    

}
