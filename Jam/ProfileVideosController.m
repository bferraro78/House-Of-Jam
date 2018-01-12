//
//  ProfileVideosController.m
//  Jam
//
//  Created by Ben Ferraro on 9/3/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileVideosController.h"

@implementation ProfileVideosController

static NSString* const kAccountVideos = @"accountVideos";


-(void)viewDidLoad {

    _videosTable.dataSource = self;
    _videosTable.delegate = self;
    _videosTable.bounces = false;
    _videosTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /* Button UI */
    _backButton = [[UIButton alloc] init];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"backX"] forState:UIControlStateNormal];
    [_backButton addTarget:self
                            action:@selector(leaveProfileVideos:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [NavigationView showNavView:@"View Profile Videos" leftButton:_backButton rightButton:nil view:self.view];
    
    if ([_profileAccountFeatureVideoIDs count] == 0) { // no videos!!
        _videosTable.hidden = true;
        UILabel *noFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width/2, self.view.frame.size.height)];
        noFriendsLabel.text = @"No videos posted!";
        noFriendsLabel.textAlignment = NSTextAlignmentCenter;
        noFriendsLabel.numberOfLines = 2;
        noFriendsLabel.center = self.view.center;
        noFriendsLabel.font = [UIFont fontWithName:@"ActionMan" size:30.0];
        [self.view addSubview:noFriendsLabel];
        _videosTable.hidden = true;
    }
    
    
}


- (IBAction)backToCreateSession:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /* When clicked on, show video */
    NSNumber *idIndex = [NSNumber numberWithInteger:[indexPath row]];
    AVPlayer *player = [AVPlayer playerWithURL:[_profileAccountFeatureVideos objectForKey:idIndex]];
    
    if (player != nil) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [player seekToTime:kCMTimeZero];
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        playerViewController.player = player;
     
        [self presentViewController:playerViewController animated:YES completion:^{
            [player play];
        }];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}


// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_profileAccountFeatureVideoIDs count];
}

// This will tell your UITableView what data to put in which cells in your table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifer = @"videoCell";
    VideoTableCellController *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    NSUInteger row = [indexPath row];
    NSString *videoNum = [[NSString alloc] initWithFormat:@"Video #%lu", (unsigned long)row+1];
    
    cell.thumbnail.clipsToBounds = YES;
    cell.thumbnail.layer.cornerRadius = 3;
    
    cell.videoName.text = videoNum;
    cell.videoName.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    NSNumber *idIndex = [NSNumber numberWithInteger:row];
    UIImage* i = (UIImage*)[_profileAccountFeatureVideoThumbnails objectForKey:idIndex];
    cell.thumbnail.image = i;
    
    return cell;
}


-(IBAction)leaveProfileVideos:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
