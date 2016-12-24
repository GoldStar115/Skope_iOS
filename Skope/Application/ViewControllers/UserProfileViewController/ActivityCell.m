//
//  ActivityCell.m
//  Skope
//
//  Created by Nguyen Truong Luu on 10/15/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import "ActivityCell.h"

@implementation ActivityCell


+ (NSDictionary*)UserNameTextAttributes {
    
    static NSDictionary *_UserNameTextAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *centerAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        centerAlign_paragraphStyle.alignment = NSTextAlignmentCenter;
        _UserNameTextAttributes = @{ NSFontAttributeName : FONT_TEXT_COMMENT_AUTHOR_NAME,
                                     NSForegroundColorAttributeName : APP_COMMON_GREEN_COLOR,
                                     //NSParagraphStyleAttributeName : centerAlign_paragraphStyle
                                     };
    });
    return _UserNameTextAttributes;
}

+ (NSDictionary*)ActivityTypeStringTextAttributes {
    
    static NSDictionary *_ActivityTypeStringTextAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *centerAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        centerAlign_paragraphStyle.alignment = NSTextAlignmentCenter;
        _ActivityTypeStringTextAttributes = @{ NSFontAttributeName : FONT_TEXT_COMMENT_CONTENT,
                                               NSForegroundColorAttributeName : APP_COMMON_LIGHT_GRAY_TEXT,
                                               //NSParagraphStyleAttributeName : centerAlign_paragraphStyle
                                               };
    });
    return _ActivityTypeStringTextAttributes;
}

+ (NSDictionary*)PostStringTextAttributes {
    
    static NSDictionary *_PostStringTextAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *centerAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        centerAlign_paragraphStyle.alignment = NSTextAlignmentCenter;
        _PostStringTextAttributes = @{ NSFontAttributeName : FONT_TEXT_COMMENT_AUTHOR_NAME,
                                       NSForegroundColorAttributeName : APP_COMMON_BLUE_COLOR,
                                       //NSParagraphStyleAttributeName : centerAlign_paragraphStyle
                                       };
    });
    return _PostStringTextAttributes;
}


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    _lbl_author_name.text = @"";
    _lbl_time.text = @"";
    
    //  Fontsize and color for views
    
    _lbl_author_name.font = FONT_TEXT_COMMENT_AUTHOR_NAME;
    _lbl_time.font = FONT_TEXT_COMMENT_TIME;
    
    _lbl_author_name.textColor = COLOR_COMMENT_AUTHOR_NAME;
    _lbl_time.textColor = COLOR_COMMENT_TIME;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    _isNewActivityCell = NO;
    
    _lbl_author_name.text = @"";
    _lbl_time.text = @"";
    
    _imgView_authorAvatar.URL = nil;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    self.corner_View.layer.cornerRadius = CELL_CONTENT_CORNER_RADIUS;
    
    if (_isNewActivityCell) {
        [self.corner_View setBackgroundColor:[UIColor whiteColor]];
    } else {
        [self.corner_View setBackgroundColor:[UIColor clearColor]];
    }
    
}

- (void)fillActivityInfoToView:(NSDictionary*)activity {
    __weak __typeof(self)weakSelf = self;
    __strong __typeof__(self) strongSelf = weakSelf;
    
    //  AUTHOR AVATAR IMAGE NODE
    
    if (!strongSelf.imgView_authorAvatar) {
        
        ASNetworkImageNode *author_avatar_image_node = [[ASNetworkImageNode alloc] initWithWebImage];
        author_avatar_image_node.image = USER_DEFAULT_AVATAR;
        author_avatar_image_node.layerBacked = NO;
        author_avatar_image_node.frame = CGRectMake(9, 9, 36, 36);
        author_avatar_image_node.backgroundColor = [UIColor clearColor];
        author_avatar_image_node.placeholderColor = APP_COMMON_LIGHT_GRAY_BACKGROUND_COLOR;
        author_avatar_image_node.URL = [NSURL URLWithString:activity[@"user"][@"avatar"]];
        author_avatar_image_node.contentMode = UIViewContentModeScaleAspectFill;
        author_avatar_image_node.cornerRadius = 18.0;
        author_avatar_image_node.borderColor = [UIColor whiteColor].CGColor;
        author_avatar_image_node.borderWidth = 1.5;
        author_avatar_image_node.clipsToBounds = YES;
        
        [author_avatar_image_node addTarget:strongSelf action:@selector(action_show_profile:) forControlEvents:ASControlNodeEventTouchUpInside];
        
        strongSelf.imgView_authorAvatar = author_avatar_image_node;
        
        [strongSelf.corner_View addSubnode:strongSelf.imgView_authorAvatar];
        
    } else {
        
        strongSelf.imgView_authorAvatar.URL = [NSURL URLWithString:activity[@"user"][@"avatar"]];
        
    }
    
    NSString *activityAuthorName = activity[@"user"][@"name"]?activity[@"user"][@"name"]:@"";
    NSString *activityTypeString = @"";
    NSString *activityObject = @"";
    
    NSString *alertType = [activity valueForKey:@"type"];
    
    if ([alertType isEqualToString:@"new-comment"]) {
        activityTypeString = @" commented on";
        activityObject = @" your post";
    } else if ([alertType isEqualToString:@"new-like"]){
        activityTypeString = @" liked";
        activityObject = @" your post";
    } else if ([alertType isEqualToString:@"new-post"]) {
        activityTypeString = @" posted";
        activityObject = @" near you";
    } else if ([alertType isEqualToString:@"new-message"]) {
        activityTypeString = @" send you";
        activityObject = @" a message";
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:activityAuthorName attributes:[ActivityCell UserNameTextAttributes]];
    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:activityTypeString attributes:[ActivityCell ActivityTypeStringTextAttributes]]];
    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:activityObject attributes:[ActivityCell PostStringTextAttributes]]];
    _lbl_author_name.attributedText = attrString;
    
    NSString *created_date = [[NSDate dateWithTimeIntervalSince1970:[activity[@"created_at"] doubleValue]] timeAgo];
    _lbl_time.text = created_date;
}


- (IBAction)action_show_profile:(id)sender {
    
    if (kAllowUserShowActivityAuthorProfile && [_delegate respondsToSelector:@selector(ActivityCell:didClickedOnUserAvatar:)]) {
        
        [_delegate ActivityCell:self didClickedOnUserAvatar:sender];
        
    }
    
}


@end
