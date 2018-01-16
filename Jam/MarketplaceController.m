//
//  MarketplaceController.m
//  House Of Jam
//
//  Created by james schuler on 12/13/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarketplaceController.h"

@implementation MarketplaceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Background images */
    CGRect newBackGroundFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    _backGroundPic = [[UIImageView alloc] initWithFrame:newBackGroundFrame];
    _backGroundPic.image = [UIImage imageNamed:@"parchment"];
    _backGroundPic.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_backGroundPic];
    [self.view sendSubviewToBack:_backGroundPic];
    

    // Scroll View
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    mainScrollView.bounces = false;
    mainScrollView.backgroundColor = [UIColor clearColor];
    
    if (self.view.frame.size.height < 600.0) { // small iphones
        mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2.2);
    } else if (self.view.frame.size.height < 900.0) { // medium iphones (including iphoneX)
        mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2.0);
    } else { // ipads/iphonex
        mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2.0);
    }
    
    [self.view addSubview:mainScrollView];
    [self.view bringSubviewToFront:mainScrollView];
    
    // Store Name
    NSString *storeName = @"Hickory and Tweed";
    
    UIButton *voidStore = [[UIButton alloc] init];
    [voidStore setBackgroundImage:[UIImage imageNamed:@"backX"] forState:UIControlStateNormal];
    [voidStore addTarget:self
                     action:@selector(voidStore)
           forControlEvents:UIControlEventTouchUpInside];
    
    // Nav View
    [NavigationView showNavView:storeName leftButton:(UIButton *)voidStore rightButton:nil view:self.view];
    
    
    // Main Image
    UIImageView *storeImage = [[UIImageView alloc]init];
    CGFloat statusBarSize = [UIApplication sharedApplication].statusBarFrame.size.height;
    storeImage.frame = CGRectMake(-2.0, [self.view viewWithTag:navBarViewTag].frame.size.height-statusBarSize, self.view.frame.size.width+4.0, self.view.frame.size.height/2);
    storeImage.image = [UIImage imageNamed:@"hick.jpg"];
    storeImage.layer.borderColor = [[UIColor blackColor] CGColor];
    storeImage.layer.borderWidth = 1.5f;

    // Store Location
    UILabel *storeLocation = [[UILabel alloc] init];
    storeLocation.frame = CGRectMake(40.0, storeImage.frame.origin.y+storeImage.frame.size.height+13.5, self.view.frame.size.width-40.0, 45.0);
    storeLocation.textAlignment = NSTextAlignmentLeft;
    storeLocation.numberOfLines = 2;
    storeLocation.tag = 1;
    storeLocation.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    NSMutableAttributedString *storeLocationString = [[NSMutableAttributedString alloc] initWithString:@"359 E Main Street, Mt Kisco NY, 10549"];
    [storeLocationString addAttribute:NSUnderlineStyleAttributeName
                           value:[NSNumber numberWithInt:4]
                           range:(NSRange){0,[storeLocationString length]}];
    storeLocation.attributedText = storeLocationString;
    
    UITapGestureRecognizer *tapGestureCopyAddress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyAddress)];
    tapGestureCopyAddress.delegate = self;
    storeLocation.userInteractionEnabled = YES;
    [storeLocation addGestureRecognizer:tapGestureCopyAddress];
    
    UIImageView *housePic = [[UIImageView alloc]init];
    housePic.image = [UIImage imageNamed:@"profileLocation"];
    housePic.frame = CGRectMake(5.0, storeLocation.frame.origin.y, 30.0, 30.0);
    
    // Link Button
    UIButton *linkToStore = [[UIButton alloc] init];
    linkToStore.frame = CGRectMake(10.0, storeLocation.frame.origin.y+storeLocation.frame.size.height+15.0
                                   ,self.view.frame.size.width-20.0, 50.0);
    [linkToStore addTarget:self
                    action:@selector(copyAddress)
          forControlEvents:UIControlEventTouchUpInside];
    linkToStore.layer.cornerRadius = 3;
    [linkToStore setTitle:@"Shop" forState:UIControlStateNormal];
    [linkToStore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    linkToStore.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:20.0];
    [linkToStore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    linkToStore.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    
    // Label/Category/Description
    UITextView *storeDescription = [[UITextView alloc] init];
    storeDescription.frame = CGRectMake(10.0, linkToStore.frame.origin.y+linkToStore.frame.size.height+10.0, self.view.frame.size.width-20.0, 100.0);
    storeDescription.textAlignment = NSTextAlignmentLeft;
    storeDescription.layer.borderColor = [[UIColor blackColor] CGColor];
    storeDescription.layer.borderWidth = 1.5f;
    storeDescription.layer.cornerRadius = 3;
    storeDescription.editable = false;
    storeDescription.selectable = false;
    storeDescription.backgroundColor = [UIColor clearColor];
    storeDescription.text = @"Winter sports and bike store";
    storeDescription.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    
    // Featured Products Setup
    UILabel *featProdLabel = [[UILabel alloc] init];
    featProdLabel.frame = CGRectMake(5.0, storeDescription.frame.origin.y+storeDescription.frame.size.height+15.0,
                                     self.view.frame.size.width-5.0, 40.0);
    featProdLabel.textAlignment = NSTextAlignmentLeft;
    featProdLabel.text = @"Featured Products:";
    featProdLabel.font = [UIFont fontWithName:@"ActionMan" size:22.0];
    
    _featProducts = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, (featProdLabel.frame.origin.y+featProdLabel.frame.size.height+5.0),
                                                                                mainScrollView.frame.size.width, self.view.frame.size.height/2)];
    _featProducts.showsHorizontalScrollIndicator = true;
    _featProducts.backgroundColor = [UIColor clearColor];
    
    int x=0;
    _featProducts.pagingEnabled=YES;
    NSArray *image=[[NSArray alloc]initWithObjects:@"img1.jpg",@"img2.jpg",@"img4.jpg",@"img5.png",@"img6.jpg", nil];
    for (int i=0; i<image.count; i++) {
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(x, 0,[[UIScreen mainScreen] bounds].size.width, _featProducts.frame.size.height)];
        img.image=[UIImage imageNamed:[image objectAtIndex:i]];
        img.contentMode = UIViewContentModeScaleAspectFit;
        x = x + [[UIScreen mainScreen] bounds].size.width;
        [_featProducts addSubview:img];
    }
    _featProducts.contentSize=CGSizeMake(x, _featProducts.frame.size.height);
    _featProducts.contentOffset=CGPointMake(0, 0);
    
    // Map View Setup
    UILabel *locationLabel = [[UILabel alloc] init];
    locationLabel.frame = CGRectMake(5.0, (_featProducts.frame.origin.y+_featProducts.frame.size.height+15.0),
                                     self.view.frame.size.width-5.0, 40.0);
    locationLabel.textAlignment = NSTextAlignmentLeft;
    locationLabel.text = @"Location:";
    locationLabel.font = [UIFont fontWithName:@"ActionMan" size:22.0];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:41.1491
                                                            longitude:-73.705
                                                                 zoom:15];
    
    [_mapViewMarket setMinZoom:2 maxZoom:17]; // set min/max zoom
    _mapViewMarket.myLocationEnabled = YES;
    _mapViewMarket.delegate = self;
    CGFloat restOfViewSize = mainScrollView.contentSize.height - (locationLabel.frame.origin.y+locationLabel.frame.size.height+5.0);
    CGRect bounds = CGRectMake(0.0, (locationLabel.frame.origin.y+locationLabel.frame.size.height+5.0),
                               self.view.frame.size.width,
                               restOfViewSize);
    _mapViewMarket = [GMSMapView mapWithFrame:bounds camera:camera];

    // Add Subviews
    [mainScrollView addSubview:housePic];
    [mainScrollView addSubview:storeLocation];
//    [mainScrollView addSubview:storeName];
    [mainScrollView addSubview:storeImage];
    [mainScrollView addSubview:storeDescription];
    [mainScrollView addSubview:linkToStore];
    [mainScrollView addSubview:featProdLabel];
    [mainScrollView addSubview:_featProducts];
    [mainScrollView addSubview:locationLabel];
    [mainScrollView addSubview:_mapViewMarket];
    
    // Set up marker
    [self setUpMarker:storeName storeLat:0.0 storeLong:0.0];
}

-(void)setUpMarker:(NSString*)storeName storeLat:(CGFloat)storeLat storeLong:(CGFloat)storeLong {
    SPAM(("\nMaking Map\n"));

    // 1. Create Marker object & load its userData
    GMSMarker *tmpMarker = [[GMSMarker alloc] init];
    tmpMarker.position = CLLocationCoordinate2DMake(41.1491, -73.705);
    // Set Title to store name
    tmpMarker.title = storeName;
    // Set Color
    tmpMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    // Set map
    tmpMarker.map  = _mapViewMarket;
    [_mapViewMarket setSelectedMarker:tmpMarker];
}

-(void)copyAddress {
    [AlertView showAlertTab:@"Address copied to clipboard" view:self.view];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    UILabel *addr = (UILabel*)[self.view viewWithTag:1];
    pasteboard.string = addr.text;
}

-(void)voidStore {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
