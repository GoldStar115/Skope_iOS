//
//  ShowMoreCommentTableViewCell.m
//  Skope
//
//  Created by Nguyen Truong Luu on 10/15/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import "ShowMoreCommentTableViewCell.h"
#import "UIView+RoundedCorners.h"

@implementation ShowMoreCommentTableViewCell

- (void)awakeFromNib {
    
    // Initialization code
    
    [super awakeFromNib];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView updateConstraints];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    [_corner_View setRoundedCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radius:CELL_CONTENT_CORNER_RADIUS];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)action_showmore_comment:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(ShowMoreCommentTableViewCell:didClickedSeeMoreCommentButton:)]) {
        [_delegate ShowMoreCommentTableViewCell:self didClickedSeeMoreCommentButton:sender];
        
    }
    
}
@end
