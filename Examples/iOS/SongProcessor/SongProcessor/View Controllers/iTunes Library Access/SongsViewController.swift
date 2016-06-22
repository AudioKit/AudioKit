//
//  SongsViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class SongsViewController: UITableViewController {
    
    var albumName: String!
    var artistName: String!
    var songsList = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let albumPredicate = MPMediaPropertyPredicate(value: albumName,
                                                      forProperty: MPMediaItemPropertyAlbumTitle,
                                                      comparisonType: .Contains)
        
        let artistPredicate = MPMediaPropertyPredicate(value: artistName,
                                                       forProperty: MPMediaItemPropertyArtist,
                                                       comparisonType: .Contains)
        
        let songsQuery = MPMediaQuery.songsQuery()
        songsQuery.addFilterPredicate(albumPredicate)
        songsQuery.addFilterPredicate(artistPredicate)
        songsQuery.addFilterPredicate(MPMediaPropertyPredicate(
            value: NSNumber(bool: false),
            forProperty: MPMediaItemPropertyIsCloudItem))
        
        if songsQuery.items != nil {
            songsList = songsQuery.items!
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return songsList.count
    }
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SongCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ?? UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        
        let song: MPMediaItem = songsList[indexPath.row] as! MPMediaItem
        let songTitle = song.valueForProperty(MPMediaItemPropertyTitle) as! String
        
        let minutes = song.valueForProperty(MPMediaItemPropertyPlaybackDuration)!.floatValue / 60
        let seconds = song.valueForProperty(MPMediaItemPropertyPlaybackDuration)!.floatValue % 60
        
        cell.textLabel?.text = songTitle
        cell.detailTextLabel?.text = String(format: "%d:%02d", minutes, seconds)
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SongSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let songVC = segue.destinationViewController as! SongViewController
                songVC.song = songsList[indexPath.row] as? MPMediaItem
                songVC.title = songVC.song!.valueForProperty(MPMediaItemPropertyTitle) as? String
            }
        }
        
    }
}