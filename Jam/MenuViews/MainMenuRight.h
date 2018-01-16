//
//  MainMenuRight.h
//  Jam
//
//  Created by Ben Ferraro on 10/19/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef MainMenuRight_h
#define MainMenuRight_h
#import <UIKit/UIKit.h>

@protocol MenuRightDelegate;

@interface MainMenuRight : UITableViewController

@property (weak, nonatomic) id <MenuRightDelegate> delegate;

@property NSMutableArray *menuOptions;

@end

@protocol MenuRightDelegate <NSObject>
-(void)menuRightOption:(NSString *)option;
@end

#endif /* MainMenuRight_h */
