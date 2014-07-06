//
//  ArtistsViewController.m
//  SongLibraryPlayer
//
//  Created by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "ArtistsViewController.h"
#import "AlbumsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ArtistsViewController ()
@property (strong, nonatomic) NSMutableArray *artistList;
@end

@implementation ArtistsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.artistList = [NSMutableArray arrayWithArray:[[MPMediaQuery artistsQuery] collections]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.artistList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MusicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];

    NSString *artistName = [[[self.artistList objectAtIndex:indexPath.row] representativeItem] valueForProperty:MPMediaItemPropertyArtist];
    cell.textLabel.text = artistName;
    return cell;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *senderCell = (UITableViewCell *)sender;
    AlbumsViewController *vc = [segue destinationViewController];
    vc.artistName = senderCell.textLabel.text;
    vc.title = senderCell.textLabel.text;
}



@end
