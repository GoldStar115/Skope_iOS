//
//  myProfileCell.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "MyProfileInfoCell.h"

@implementation MyProfileInfoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //self.layoutMargins = UIEdgeInsetsMake(0, 1000, 0, 0);
    //self.preservesSuperviewLayoutMargins = NO;
    self.tf_UserName.userInteractionEnabled = NO;
    [Common circleImageView:self.imgView_UserAvatar];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
