//
//  CommentTableViewCell.m
//  Skope
//
//  Created by Nguyen Truong Luu on 10/15/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIView+RoundedCorners.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    _lbl_author_name.text = @"";
    _lbl_time.text = @"";
    _lbl_comment_content.text = @"";
    
    //  Fontsize and color for views
    
    _lbl_author_name.font = FONT_TEXT_COMMENT_AUTHOR_NAME;
    _lbl_time.font = FONT_TEXT_COMMENT_TIME;
    _lbl_comment_content.font = FONT_TEXT_COMMENT_CONTENT;
    
    _lbl_author_name.textColor = COLOR_COMMENT_AUTHOR_NAME;
    _lbl_time.textColor = COLOR_COMMENT_TIME;
    _lbl_comment_content.textColor = COLOR_COMMENT_CONTENT;
    
    self.lbl_comment_content.preferredMaxLayoutWidth = CGRectGetWidth(self.frame) - 44;
    
    [_corner_View.layer setCornerRadius:CELL_CONTENT_CORNER_RADIUS];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    _isLastCell = NO;
    
    _lbl_author_name.text = @"";
    _lbl_time.text = @"";
    _lbl_comment_content.text = @"";
    
    _imgView_authorAvatar.URL = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    if (_isLastCell) {
        [self.outer_View setRoundedCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight radius:CELL_CONTENT_CORNER_RADIUS];
    } else {
        [self.outer_View setRoundedCorners:UIRectCornerAllCorners radius:0.0];
    }
    
}

- (void)fillCommentInfoToView:(NSDictionary*)comment {
    
    __weak __typeof(self)weakSelf = self;
    __strong __typeof__(self) strongSelf = weakSelf;
    
    //  AUTHOR AVATAR IMAGE NODE
    
    if (!strongSelf.imgView_authorAvatar) {
        
        ASNetworkImageNode *author_avatar_image_node = [[ASNetworkImageNode alloc] initWithWebImage];
        author_avatar_image_node.image = USER_DEFAULT_AVATAR;
        author_avatar_image_node.layerBacked = NO;
        author_avatar_image_node.frame = CGRectMake(6, 6, 36, 36);
        author_avatar_image_node.backgroundColor = [UIColor clearColor];
        author_avatar_image_node.placeholderColor = APP_COMMON_LIGHT_GRAY_BACKGROUND_COLOR;
        author_avatar_image_node.URL = [NSURL URLWithString:comment[@"user"][@"avatar"]];
        author_avatar_image_node.contentMode = UIViewContentModeScaleAspectFill;
        author_avatar_image_node.cornerRadius = 18.0;
        author_avatar_image_node.borderColor = [UIColor whiteColor].CGColor;
        author_avatar_image_node.borderWidth = 1.5;
        author_avatar_image_node.clipsToBounds = YES;
        
        [author_avatar_image_node addTarget:strongSelf action:@selector(action_show_profile:) forControlEvents:ASControlNodeEventTouchUpInside];
        
        strongSelf.imgView_authorAvatar = author_avatar_image_node;
        
        [strongSelf.corner_View addSubnode:strongSelf.imgView_authorAvatar];
        
    } else {
        
        strongSelf.imgView_authorAvatar.URL = [NSURL URLWithString:comment[@"user"][@"avatar"]];
        
    }

    NSString *commentContent = comment[@"content"];
    _lbl_comment_content.text = commentContent;
    
    NSString *commentAuthorName = comment[@"user"][@"name"];
    _lbl_author_name.text = commentAuthorName;
    
    NSString *created_date = [[NSDate dateWithTimeIntervalSince1970:[comment[@"created_at"] doubleValue]] timeAgo];
    _lbl_time.text = created_date;

}


- (IBAction)action_show_profile:(id)sender {
    
    if (kAllowUserShowCommentAuthorProfile && [_delegate respondsToSelector:@selector(CommentCell:didClickedOnUserAvatar:)]) {
        
        [_delegate CommentCell:self didClickedOnUserAvatar:sender];
        
    }
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked && [_delegate respondsToSelector:@selector(PostCell:wantToOpenURL:)]) {
        [_delegate CommentCell:self wantToOpenURL:[request URL]];
        return NO;
    } else if ( navigationType == UIWebViewNavigationTypeLinkClicked && [[UIApplication sharedApplication] canOpenURL:[request URL]]) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}



@end
