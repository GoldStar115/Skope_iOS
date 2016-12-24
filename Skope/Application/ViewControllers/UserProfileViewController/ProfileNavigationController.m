//
//  ProfileNavigationController.m
//  Skope
//
//  Created by Nguyen Truong Luu on 10/21/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import "ProfileNavigationController.h"

@interface ProfileNavigationController ()

@end

@implementation ProfileNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIView *theWindow = self.view ;
    if( animated ) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45f];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [[theWindow layer] addAnimation:animation forKey:kCATransition];
    }
    
    //make sure we pass the super "animated:NO" or we will get both our
    //animation and the super's animation
    [super pushViewController:viewController animated:NO];
    
    //[self swapButtonsForViewController:viewController];
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIView *theWindow = self.view ;
    if( animated ) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45f];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [[theWindow layer] addAnimation:animation forKey:kCATransition];
    }
    return [super popViewControllerAnimated:NO];
}

@end
