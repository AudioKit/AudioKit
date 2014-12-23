//
//  AlbumsViewController.m
//  SongLibraryPlayer
//
//  Created by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2013 Aurelius Prochazka. All rights reserved.
//

#import "AlbumsViewController.h"
#import "SongsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AlbumsViewController ()
@property (nonatomic, strong) NSMutableArray *albumsList;
@end

@implementation AlbumsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    
    MPMediaPropertyPredicate *artistPredicate =
    [MPMediaPropertyPredicate predicateWithValue:self.artistName
                                     forProperty:MPMediaItemPropertyArtist
                                  comparisonType:MPMediaPredicateComparisonContains];
    
    MPMediaQuery *albumsQuery = [MPMediaQuery albumsQuery];
    [albumsQuery addFilterPredicate:artistPredicate];
    
    self.albumsList = [NSMutableArray arrayWithArray:[albumsQuery collections]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.albumsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlbumCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *albumTitle = [[[self.albumsList objectAtIndex:indexPath.row] representativeItem] valueForProperty:MPMediaItemPropertyAlbumTitle];
    cell.textLabel.text = albumTitle;
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *senderCell = (UITableViewCell *)sender;
    SongsViewController *vc = [segue destinationViewController];
    vc.albumName = senderCell.textLabel.text;
    vc.title = senderCell.textLabel.text;
}


@end
