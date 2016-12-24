//
//  ReportpostView.h
//  Skope
//
//  Created by Nguyen Truong Luu on 7/22/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "PSCustomViewFromXib.h"

@class ReportPostView;

@protocol ReportpostViewDelegate <NSObject>

- (void)reportpostView:(ReportPostView*)view didPressedReportButton:(id)sender;
- (void)reportpostView:(ReportPostView*)view didPressedHideButton:(id)sender;
- (void)reportpostView:(ReportPostView*)view didPressedBlockUserButton:(id)sender;

@end

@interface ReportPostView : PSCustomViewFromXib
@property (nonatomic, strong) id <ReportpostViewDelegate> delegate;
@end
