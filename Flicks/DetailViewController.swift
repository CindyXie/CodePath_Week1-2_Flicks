//
//  DetailViewController.swift
//  Flicks
//
//  Created by Xinxin Xie on 1/25/16.
//  Copyright © 2016 Xinxin Xie. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var posterImageview: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var infoView: UIView!
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        let baseUrl = "http://image.tmdb.org/t/p/w500/"
        
        if let posterPath = movie["poster_path"] as? String,
            let imageUrl = NSURL(string: baseUrl + posterPath) {
                
                let imageRequest = NSURLRequest(URL: imageUrl)
                
                posterImageview.setImageWithURLRequest(
                    imageRequest,
                    placeholderImage: nil,
                    success: { (imageRequest, imageResponse, image) -> Void in
                        if imageResponse != nil {
                            self.posterImageview.alpha = 0.0
                            self.posterImageview.image = image
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.posterImageview.alpha = 1.0
                            })
                        } else {
                            self.posterImageview.image = image
                        }
                    },
                    failure: { (imageRequest, imageResponse,
                        error) -> Void in
                        // do something for the failure condition
                })
                //cell.imageviewLabel.setImageWithURL(imageUrl!)
        }

   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
