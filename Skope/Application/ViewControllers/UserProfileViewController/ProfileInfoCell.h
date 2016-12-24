//
//  profileCell.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView         *viewInforProfile;
@property (weak, nonatomic) IBOutlet UIImageView    *imgView_UserAvatar;
@property (weak, nonatomic) IBOutlet UILabel        *lbl_UserName;
@property (weak, nonatomic) IBOutlet UIButton       *btn_SendMessage;
@property (weak, nonatomic) IBOutlet UIButton       *btn_ShowFullAvatar;

@end
