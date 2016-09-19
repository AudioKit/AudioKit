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
        
        if let list = MPMediaQuery.artists().collections {
            artistList = list
            tableView.reloadData()
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return artistList.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "MusicCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        
        // Configure the cell...
        let repItem = artistList[(indexPath as NSIndexPath).row].representativeItem!
        let artistName = repItem.value(forProperty: MPMediaItemPropertyArtist) as! String
        cell.textLabel?.text = artistName
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AlbumsSegue" {
            let senderCell = sender as! UITableViewCell
            let albumsVC = segue.destination as! AlbumsViewController
            albumsVC.artistName = senderCell.textLabel?.text
            albumsVC.title = senderCell.textLabel?.text
        }
    }
    
    
}
