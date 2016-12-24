//
//  UserListVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCell.h"
#import "LocationTracker.h"
#import "UIViewController+IsVisible.h"

@protocol UserListDelegate <NSObject>
- (void) userListActionBack;
- (void) userListActionGoProfile:(NSDictionary *)dicPf;
- (void) userListActionPassData:(NSDictionary *)dicPf;
@end


@interface UserListVC : UIViewController <UITableViewDataSource, UITableViewDelegate, LocationTrackerDelegate> {
    
}

@property (nonatomic, strong)   id<UserListDelegate> delegate;
@property (nonatomic, strong)   id dataFromHome;
@property (nonatomic, assign)   CGFloat regionMap;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)actionBackOfUser:(id)sender;
- (NSArray*)arrayUsers;
@end
