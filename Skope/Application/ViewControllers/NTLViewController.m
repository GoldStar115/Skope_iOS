//
//  NTLViewController.m
//  Sync Shot
//
//  Created by Nguyen Truong Luu on 3/27/15.
//  Copyright (c) 2015 Nguyen Truong Luu. All rights reserved.
//

#import "NTLViewController.h"

@interface NTLViewController ()

@end

@implementation NTLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    //[self.navigationController.navigationBar.topItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil]];

}

- (void)prepareForSubViews {
    
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)showBars:(BOOL)show animated:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    CGFloat alpha = show?1.0:0.0;
    if (animated) {
        NSTimeInterval time = show?0.1:0.3;
        [UIView animateWithDuration:time animations:^{
            self.navigationController.navigationBar.alpha = alpha;
        }];
    }
    else
    {
        self.navigationController.navigationBar.alpha = alpha;
    }
    
    if (!show) {
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - AutoRotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {

}
/*
 - (BOOL)shouldAutorotate
 {
 return NO;
 }
 
 - (NSUInteger)supportedInterfaceOrientations {
 return UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown;
 }
 //
 //- (NSUInteger)supportedInterfaceOrientations
 //{
 //    return UIInterfaceOrientationMaskPortraitUpsideDown;
 //}
 
 - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
 {
 
 }
 

 - (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
 {
 
 }
 */

@end
