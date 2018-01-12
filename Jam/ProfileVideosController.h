//
//  ProfileVideosController.h
//  Jam
//
//  Created by Ben Ferraro on 9/3/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef ProfileVideosController_h
#define ProfileVideosController_h
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVKit/AVKit.h>
#import "AVFoundation/AVFoundation.h"
#import "VideoTableCellController.h"
#import "Account.h"
#import "NavigationView.h"

@interface ProfileVideosController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property NSMutableDictionary *profileAccountFeatureVideos;
@property NSMutableArray *profileAccountFeatureVideoIDs;
@property NSMutableDictionary *profileAccountFeatureVideoThumbnails;

@property (strong, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet UITableView *videosTable;

@property NSMutableArray *videoAssets;


@end
#endif /* ProfileVideosController_h */
