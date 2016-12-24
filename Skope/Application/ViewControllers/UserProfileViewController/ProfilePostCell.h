//
//  profilePostCell.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARScrollViewEnhancer.h"
#import "NTLRangeView.h"
#import "PostCellDelegateProtocol.h"

@interface ProfilePostCell : UITableViewCell <UIWebViewDelegate>

// Views

@property (weak, nonatomic) IBOutlet UILabel             *lbl_postedAway;
@property (weak, nonatomic) IBOutlet UIWebView           *lbl_postContent;
@property (weak, nonatomic) IBOutlet UILabel             *lbl_likeCount;
@property (weak, nonatomic) IBOutlet UILabel             *lbl_dislikeCount;
@property (weak, nonatomic) IBOutlet UILabel             *lbl_commentCount;
@property (weak, nonatomic) IBOutlet UILabel             *lbl_postedTimeAgo;

@property (weak, nonatomic) IBOutlet UIButton            *btn_addComment;
@property (weak, nonatomic) IBOutlet UIButton            *btn_likePost;
@property (weak, nonatomic) IBOutlet UIButton            *btn_dislikePost;
@property (weak, nonatomic) IBOutlet UIButton            *btn_seemoreContent;
@property (weak, nonatomic) IBOutlet UIButton            *btn_report;

@property (weak, nonatomic) IBOutlet NTLRangeView        *likeBalanceRangeView;
@property (weak, nonatomic) IBOutlet UIView              *view_contentBackground;
@property (weak, nonatomic) IBOutlet UIView             *like_dislike_containerView;

@property (weak, nonatomic) IBOutlet ARScrollViewEnhancer   *scrollViewEnhancer;
@property (weak, nonatomic) IBOutlet UIScrollView           *scrollView;

// Constraint

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content_height_CST;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seemore_height_CST;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scroll_images_space_CST;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scroll_images_height_CST;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *comment_count_height_CST;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *comment_count_padding_CST;


// More

@property (nonatomic, assign) BOOL isOnMyProfileCell;

@property (weak, nonatomic) id<PostCellDelegate> delegate;
@property (nonatomic, weak) NSMutableDictionary *postInfo;

// Function

- (void)configureCellDisplayWithPostInfo:(NSMutableDictionary*)postInfo tableViewWidth:(CGFloat)tableViewWidth indexPath:(NSIndexPath*)indexPath nodeConstructionQueue:(NSOperationQueue*)nodeConstructionQueue;
- (void)fillDataToCellWithPostInfo:(NSMutableDictionary*)postInfo tableViewWidth:(CGFloat)tableViewWidth;

- (void)resetAllButtonStatus;
- (void)resetAllLabelContents;
- (void)updateLikeDislikeStatus:(BOOL)animated;
- (void)setContentText:(NSString *)contentText;

+ (NSString *)htmlTemplate;

@end
