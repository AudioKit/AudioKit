//
//  SongsViewController.m
//  SongLibraryPlayer
//
//  Created by Aurelius Prochazka on 12/19/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "SongsViewController.h"
#import "SongViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SongsViewController () <UITableViewDelegate> {
}

@property (strong, nonatomic) NSMutableArray *songsList;

@end

@implementation SongsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    MPMediaPropertyPredicate *artistPredicate =
    [MPMediaPropertyPredicate predicateWithValue:self.albumName
                                     forProperty:MPMediaItemPropertyAlbumTitle
                                  comparisonType:MPMediaPredicateComparisonContains];
    
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    [songsQuery addFilterPredicate:artistPredicate];
    
    NSArray *itemsFromGenericQuery = [songsQuery items];
    self.songsList = [NSMutableArray arrayWithArray:itemsFromGenericQuery];
    [self.tableView reloadData];
    

}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.songsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    MPMediaItem *song = [self.songsList objectAtIndex:indexPath.row];
    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    int minutes = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue] / 60;
    int seconds = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue] % 60;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    cell.textLabel.text = songTitle;
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    SongViewController *vc = [segue destinationViewController];
    vc.song  = [self.songsList objectAtIndex:path.row];
    vc.title = [vc.song valueForProperty:MPMediaItemPropertyTitle];
}

@end
