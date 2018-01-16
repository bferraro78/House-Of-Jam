//
//  MainMenuController.h
//  Jam
//
//  Created by Ben Ferraro on 9/11/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef MainMenuController_h
#define MainMenuController_h
#import <UIKit/UIKit.h>

@protocol MenuDelegate;

@interface MainMenuController : UITableViewController

@property (weak, nonatomic) id <MenuDelegate> delegate;

@property NSMutableArray *menuOptions;

@end

@protocol MenuDelegate <NSObject>
-(void)menuOption:(NSString *)option;
@end

#endif /* MainMenuController_h */
