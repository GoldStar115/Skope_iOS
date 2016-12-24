//
//  HomeVC.h
//  Skope
//
//  Created by CHAU HUYNH on 2/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UICircularSlider.h"
#import "UserCell.h"
#import "PostCell.h"
#import "PHFComposeBarView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@protocol HomeListDelegate <NSObject>
- (void) homeListActionShowUser:(CGFloat)regionMap;
- (void) homeListActionShowPost:(CGFloat)regionMap;
- (void) homePostDone:(CGFloat)regionMap;

@end

@interface HomeVC : UIViewController <UITextFieldDelegate,PHFComposeBarViewDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate, MKMapViewDelegate> {
    BOOL isMyProfile;
}

@property (nonatomic, strong) NSDictionary *selectedUserProfile;

@property (nonatomic, strong) id<HomeListDelegate>   delegate;

- (IBAction)actionGoUsersView:(id)sender;
- (IBAction)actionGoPostsView:(id)sender;
- (IBAction)actionGoProfile:(id)sender;
- (IBAction)actionCompose:(id)sender;
- (IBAction)actionHideCompose:(id)sender;
- (IBAction)actionShowMessageList:(id)sender;

- (CGFloat)recalculatedRadiusUpdate;

- (void)updateNewMessageBagedNumber;
- (void)updateNewCommentBagedNumber;
@end
