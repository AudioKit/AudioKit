//
//  SongsViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import MediaPlayer
import UIKit

class SongsViewController: UITableViewController {

    var albumName: String!
    var artistName: String!
    var songsList = [MPMediaItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let albumPredicate = MPMediaPropertyPredicate(value: albumName,
                                                      forProperty: MPMediaItemPropertyAlbumTitle,
                                                      comparisonType: .contains)

        let artistPredicate = MPMediaPropertyPredicate(value: artistName,
                                                       forProperty: MPMediaItemPropertyArtist,
                                                       comparisonType: .contains)

        let songsQuery = MPMediaQuery.songs()
        songsQuery.addFilterPredicate(albumPredicate)
        songsQuery.addFilterPredicate(artistPredicate)
        songsQuery.addFilterPredicate(MPMediaPropertyPredicate(
            value: NSNumber(value: false as Bool),
            forProperty: MPMediaItemPropertyIsCloudItem))

        if songsQuery.items != nil {
            songsList = songsQuery.items!
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return songsList.count
    }
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "SongCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default,
                                                                                                    reuseIdentifier: cellIdentifier)

        let song: MPMediaItem = songsList[(indexPath as NSIndexPath).row]
        let songTitle = song.value(forProperty: MPMediaItemPropertyTitle) as! String

        let minutes = (song.value(forProperty: MPMediaItemPropertyPlaybackDuration)! as AnyObject).floatValue / 60
        let seconds = ((song.value(forProperty: MPMediaItemPropertyPlaybackDuration)! as AnyObject).floatValue).truncatingRemainder(dividingBy: 60)

        cell.textLabel?.text = songTitle
        cell.detailTextLabel?.text = String(format: "%.0f:%02.0f", minutes, seconds)

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "SongSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let songVC = segue.destination as! SongViewController
                songVC.song = songsList[(indexPath as NSIndexPath).row]
                songVC.title = songVC.song!.value(forProperty: MPMediaItemPropertyTitle) as? String
            }
        }

    }
}
