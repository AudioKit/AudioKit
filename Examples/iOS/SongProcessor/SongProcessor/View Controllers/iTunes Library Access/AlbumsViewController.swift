//
//  AlbumsViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AlbumsViewController: UITableViewController {
    
    var artistName: String!
    var albumsList = [MPMediaItemCollection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let artistPredicate = MPMediaPropertyPredicate(value: artistName,
                                                       forProperty: MPMediaItemPropertyArtist,
                                                       comparisonType: .Contains)
        
        let albumsQuery = MPMediaQuery.albumsQuery()
        albumsQuery.addFilterPredicate(artistPredicate)
        
        if let list = albumsQuery.collections {
            albumsList = list
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "AlbumCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ?? UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        
        // Configure the cell...
        let repItem = albumsList[indexPath.row].representativeItem!
        let albumTitle = repItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as! String
        cell.textLabel?.text = albumTitle
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SongsSegue" {
            let senderCell = sender as! UITableViewCell
            let songsVC = segue.destinationViewController as! SongsViewController
            songsVC.artistName = artistName
            songsVC.albumName = senderCell.textLabel?.text
            songsVC.title = senderCell.textLabel?.text
        }
        
    }
    
}
