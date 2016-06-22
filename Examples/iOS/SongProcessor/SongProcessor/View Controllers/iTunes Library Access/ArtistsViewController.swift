//
//  ArtistsViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ArtistsViewController: UITableViewController {
    
    var artistList: [MPMediaItemCollection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let list = MPMediaQuery.artistsQuery().collections {
            artistList = list
            tableView.reloadData()
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return artistList.count
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "MusicCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ?? UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        
        // Configure the cell...
        let repItem = artistList[indexPath.row].representativeItem!
        let artistName = repItem.valueForProperty(MPMediaItemPropertyArtist) as! String
        cell.textLabel?.text = artistName
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "AlbumsSegue" {
            let senderCell = sender as! UITableViewCell
            let albumsVC = segue.destinationViewController as! AlbumsViewController
            albumsVC.artistName = senderCell.textLabel?.text
            albumsVC.title = senderCell.textLabel?.text
        }
    }
    
    
}
