//
//  ActivityCell.h
//  Skope
//
//  Created by Nguyen Truong Luu on 10/15/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAcvitityCellHeight         60.0

@interface ActivityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_author_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;

@property (weak, nonatomic) IBOutlet UIView *corner_View;

@property (strong, nonatomic) ASNetworkImageNode *imgView_authorAvatar;

@property (nonatomic, assign) BOOL isNewActivityCell;

@property (weak, nonatomic) id<ActivityCellDelegate> delegate;

- (void)fillActivityInfoToView:(NSDictionary*)activity;

@end
