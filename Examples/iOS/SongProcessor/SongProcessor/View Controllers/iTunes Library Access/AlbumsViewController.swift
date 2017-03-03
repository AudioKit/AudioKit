//
//  AlbumsViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import MediaPlayer
import UIKit

class AlbumsViewController: UITableViewController {

    var artistName: String!
    var albumsList = [MPMediaItemCollection]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let artistPredicate = MPMediaPropertyPredicate(value: artistName,
                                                       forProperty: MPMediaItemPropertyArtist,
                                                       comparisonType: .contains)

        let albumsQuery = MPMediaQuery.albums()
        albumsQuery.addFilterPredicate(artistPredicate)

        if let list = albumsQuery.collections {
            albumsList = list
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "AlbumCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
            UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)

        // Configure the cell...
        if let repItem = albumsList[(indexPath as NSIndexPath).row].representativeItem,
            let albumTitle = repItem.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String {
            cell.textLabel?.text = albumTitle
        }

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "SongsSegue" {
            if let senderCell = sender as? UITableViewCell, let songsVC = segue.destination as? SongsViewController {
                songsVC.artistName = artistName
                songsVC.albumName = senderCell.textLabel?.text
                songsVC.title = senderCell.textLabel?.text
            }
        }

    }

}
