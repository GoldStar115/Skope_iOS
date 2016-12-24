//
//  MyProfileVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyProfileVC : UIViewController {
    
    BOOL            isrefreshing;
    BOOL            isloading;
    BOOL            isActivityloading;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
