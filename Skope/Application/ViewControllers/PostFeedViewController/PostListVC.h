//
//  PostListVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MediaPlayer;

@protocol PostListDelegate <NSObject>

- (void) postListActionBack;

@end

@interface PostListVC : NTLViewController {
    
    BOOL            isrefreshing;
    BOOL            isloading;
    NSUInteger      totalPostInCurrentRegion;
}

@property (nonatomic, strong) NSMutableArray    *postsList;

@property (nonatomic, assign) id<PostListDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)actionPostBack:(id)sender;

- (void)setRegionMap:(CGFloat)regionMap;

@end
