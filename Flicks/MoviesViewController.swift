//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Xinxin Xie on 1/24/16.
//  Copyright © 2016 Xinxin Xie. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbarView: UISearchBar!
    @IBOutlet weak var errorView: ErrorMessageView!
    
    var movies:[NSDictionary] = []
    var fileredMovies:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        searchbarView.delegate = self
        fileredMovies = movies
        
        refreshControlAction(refreshControl)
        
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { _ in
            self.errorView.hidden = AFNetworkReachabilityManager.sharedManager().reachable

        }
    }

    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            if let results = responseDictionary["results"] as? [NSDictionary] {
                                self.movies = results
                                self.updateFilteredMovies()
                            }
                            self.tableView.reloadData()
                            
                    }
                }
                self.tableView.reloadData()
                refreshControl.endRefreshing()
                MBProgressHUD.hideHUDForView(self.view, animated: true)

        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fileredMovies.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
        let movie = fileredMovies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500/"
        
        //let imageUrl = NSURL(string: baseUrl + posterPath)
        let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.imageviewLabel.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                                if imageResponse != nil {
                    cell.imageviewLabel.alpha = 0.0
                    cell.imageviewLabel.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.imageviewLabel.alpha = 1.0
                    })
                } else {
                    cell.imageviewLabel.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        //cell.imageviewLabel.setImageWithURL(imageUrl!)
        
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        updateFilteredMovies()
        tableView.reloadData()
    }
    
    func updateFilteredMovies() {
        let searchText = searchbarView.text ?? ""
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            fileredMovies = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            fileredMovies = movies.filter({dictionary in
                // If dataItem matches the searchText, return true to include it
                if let title = dictionary["title"] as? String {
                    return title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
                }
                return false
            })
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies[indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        // Get the new view contr]oller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
