//
//  ReportpostView.m
//  Skope
//
//  Created by Nguyen Truong Luu on 7/22/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "ReportUserView.h"

@implementation ReportUserView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)action_reportUser:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(reportpostView:didPressedReportButton:)]) {
        [_delegate reportpostView:self didPressedReportButton:sender];
    }
}

- (IBAction)action_blockUser:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(reportpostView:didPressedBlockUserButton:)]) {
        [_delegate reportpostView:self didPressedBlockUserButton:sender];
    }
}
@end
