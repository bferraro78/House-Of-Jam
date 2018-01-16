//
//  LaunchController.m
//  Jam
//
//  Created by Ben Ferraro on 10/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LaunchController.h"

@implementation LaunchController

-(void)viewDidLoad {
    
    SPAM(("\nLAUNCH SCREEN LOADING....\n"));
    
    /* Start finding location by setting up - CLLocationManager / GMSPlacesClient (apple location / google maps)*/
    [[LocationManager sharedLocationManager] startFindingLocation];
    
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    if (screenHeight > 1000.0) { // ipad and greater
        _largeScreen = true;
    } else {
        _largeScreen = false;
    }
    
    UIImageView *cloud = [[UIImageView alloc] init]; // moves right
    cloud.image = [UIImage imageNamed:@"Cloud"];
    cloud.contentMode = UIViewContentModeScaleAspectFill;
    cloud.alpha = 1.0;
    cloud.tag = 2;

    UIImageView *cloudTwo = [[UIImageView alloc] init]; // moves left
    cloudTwo.image = [UIImage imageNamed:@"Cloud"];
    cloudTwo.contentMode = UIViewContentModeScaleAspectFill;
    cloudTwo.alpha = 1.0;
    cloudTwo.tag = 3;
    
    if (_largeScreen) { // large screen (ipad and above)
        cloud.frame = CGRectMake(-275.0, -screenHeight*2, screenWidth*4, screenHeight*4);
        cloudTwo.frame = CGRectMake(-2000.0, -screenHeight*1.2, screenWidth*4, screenHeight*4);
    } else {
        cloud.frame = CGRectMake(-125.0, -screenHeight*1.4, screenWidth*3, screenHeight*3);
        cloudTwo.frame = CGRectMake(-250.0, -screenHeight/1.5, screenWidth*3, screenHeight*3);
    }

    _launchImageView = [[UIImageView alloc] init];
    _launchImageView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
    _launchImageView.image = [UIImage imageNamed:@"LaunchScreen.jpg"];
    _launchImageView.contentMode = UIViewContentModeScaleAspectFill;
    _launchImageView.clipsToBounds = true;
    
    [self.view addSubview:_launchImageView];
    [self.view addSubview:cloud];
    [self.view addSubview:cloudTwo];
    
    [self enlargePic];
}

-(void)enlargePic {
    
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    // Inital moving clouds animation
    [UIView animateWithDuration:1.0 delay:0.08 options:0
                     animations:^{
                         
                         if (_largeScreen) { // large screen (ipad and above)
                             [self.view viewWithTag:2].frame = CGRectMake(-275.0+2000.0, -screenHeight*2, screenWidth*4, screenHeight*4);
                             [self.view viewWithTag:3].frame = CGRectMake(-2000.0-screenHeight*2, -screenHeight*1.2, screenWidth*4, screenHeight*4);
                         } else {
                             [self.view viewWithTag:2].frame = CGRectMake(-125.0+1250.0, -screenHeight*1.4, screenWidth*3, screenHeight*3);
                             [self.view viewWithTag:3].frame = CGRectMake(-250.0-1500.0, -screenHeight/1.5, screenWidth*3, screenHeight*3);
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.7 delay:0.4 options:0
                                          animations:^{
                                              
                                              _launchImageView.alpha = 0.0;
                                              
                                              float zoomScal = 1.0; //8.0;
                                              CGPoint CenterPoint = CGPointMake(self.view.frame.size.width/2,
                                                                                self.view.frame.size.height/2);
                                              _launchImageView.frame = CGRectMake(- CenterPoint.x * (zoomScal-1),- CenterPoint.y * (zoomScal-1),self.view.frame.size.width * zoomScal,self.view.frame.size.height * zoomScal);

                                          }
                                          completion:^(BOOL finished) {
                                              [self performSegueWithIdentifier:@"launchScreenSegue" sender:self];
                                          }];// end second nested animation block
                     }];
}

/* SEGUE CODE */
// Pass in info to next page
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    /* goes to log in */
    if ([[segue identifier] isEqualToString:@"launchScreenSegue"]) {
        
    }
}

@end
