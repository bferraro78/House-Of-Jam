//
//  VideoTableCellController.h
//  Jam
//
//  Created by Ben Ferraro on 9/5/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef VideoTableCellController_h
#define VideoTableCellController_h
#import <UIKit/UIKit.h>

@interface VideoTableCellController : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnail;

@property (strong, nonatomic) IBOutlet UILabel *videoName;


@end

#endif /* VideoTableCellController_h */
