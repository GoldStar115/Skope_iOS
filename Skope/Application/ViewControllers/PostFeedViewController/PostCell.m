//
//  postsCell.m
//  Skope
//
//  Created by Huynh Phong Chau on 2/20/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "PostCell.h"
#import "Define.h"
#import "UIView+RoundedCorners.h"

#define MARGIN_RIGHT_ALL_CELL           13

#define kCellContentTopPadding          4
#define kCellContentLeftPadding         16
#define kCellContentVerticalSpacing     8
#define kContentLabelHeightLimit        150
#define kNormalOneLineTextLabelHeight   18
#define kViewLikeCountsAreaHeight       35
#define kShowAllCommentButtonHeight     35
#define kSeeMorebuttonHeight            32

@interface PostCell ()

@end

@implementation PostCell

+ (NSString *)htmlTemplate {
    static NSString *_sharedhtmlTemplate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"html-template" ofType:@"html"];
        _sharedhtmlTemplate = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    });
    return _sharedhtmlTemplate;
}


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.lbl_postContent.delegate = self;
    self.lbl_postContent.dataDetectorTypes = kAllowLinkDetectOnPostContent?UIDataDetectorTypeAll:UIDataDetectorTypeNone;
    self.lbl_postContent.scrollView.scrollEnabled = NO;
    self.lbl_postContent.scrollView.bounces = NO;
    
    //  Fontsize and color for views
    
    _lbl_authorName.font = FONT_TEXT_POST_AUTHOR_NAME;
    
    _lbl_postedAway.font = FONT_TEXT_POST_DISTANCE;
    _lbl_likeCount.font = FONT_TEXT_POST_LIKE_COUNT;
    _lbl_dislikeCount.font = FONT_TEXT_POST_DISLIKE_COUNT;
    _lbl_postedTimeAgo.font = FONT_TEXT_POST_TIME;
    
    
    _lbl_postedAway.textColor = COLOR_POST_DISTANCE;
    _lbl_likeCount.textColor = COLOR_POST_LIKE_COUNT;
    _lbl_dislikeCount.textColor = COLOR_POST_DISLIKE_COUNT;
    _lbl_postedTimeAgo.textColor = COLOR_POST_TIME;
    

    [self resetAllButtonStatus];
    
    [self resetAllLabelContents];
}


- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    [self resetAllButtonStatus];
    
    [self resetAllLabelContents];
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        [subView removeFromSuperview];
    }];
    
    _imgView_authorAvatar.URL = nil;
    
    self.scroll_images_height_CST.constant = HEIGHT_SLIDE_IMAGE_POST_LIST;
    self.scroll_images_space_CST.constant = HEIGHT_SLIDE_IMAGE_POST_LIST + 2*kCellContentVerticalSpacing;
    self.seemore_height_CST.constant = kSeeMorebuttonHeight;
    self.content_height_CST.constant = 0.0;
    self.comment_count_height_CST.constant = kNormalOneLineTextLabelHeight;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    NSInteger totalComments = [_postInfo[@"comment"][@"total"] integerValue];
    
    if (totalComments > 0) {
        
        [self.view_contentBackground setRoundedCorners:UIRectCornerTopLeft | UIRectCornerTopRight radius:CELL_CONTENT_CORNER_RADIUS];
 
    } else {
        
        [self.view_contentBackground setRoundedCorners:UIRectCornerAllCorners radius:CELL_CONTENT_CORNER_RADIUS];
        
    }
}

- (void)resetAllButtonStatus {
    
    self.lbl_likeCount.textColor = COLOR_LIKE_DISLIKE_DISABLE;
    self.lbl_dislikeCount.textColor = COLOR_LIKE_DISLIKE_DISABLE;
    
    self.btn_likePost.titleLabel.font = FONT_LIKE_DISLIKE_BUTTON_DISABLE;
    self.btn_dislikePost.titleLabel.font = FONT_LIKE_DISLIKE_BUTTON_DISABLE;
    
    [self.btn_likePost setTitleColor:COLOR_LIKE_DISLIKE_DISABLE forState:UIControlStateNormal];
    [self.btn_dislikePost setTitleColor:COLOR_LIKE_DISLIKE_DISABLE forState:UIControlStateNormal];
}

- (void)resetAllLabelContents {

    self.lbl_commentCount.text = @"";
    self.lbl_likeCount.text = @"";
    self.lbl_dislikeCount.text = @"";
    self.lbl_postedAway.text = @"";
    self.lbl_postedTimeAgo.text = @"";

}

- (void)configureCellDisplayWithPostInfo:(NSMutableDictionary*)postInfo tableViewWidth:(CGFloat)tableViewWidth indexPath:(NSIndexPath*)indexPath
                   nodeConstructionQueue:(NSOperationQueue*)nodeConstructionQueue {

    _postInfo = postInfo;
    
    __weak __typeof(self)weakSelf = self;
    __strong __typeof__(self) strongSelf = weakSelf;
    
    if (strongSelf) {       
        
        
        //  AUTHOR AVATAR IMAGE NODE
        
        if (!strongSelf.imgView_authorAvatar) {
            
            ASNetworkImageNode *author_avatar_image_node = [[ASNetworkImageNode alloc] initWithWebImage];
            author_avatar_image_node.image = USER_DEFAULT_AVATAR;
            author_avatar_image_node.layerBacked = NO;
            author_avatar_image_node.frame = CGRectMake(8, 10, 70, 70);
            author_avatar_image_node.backgroundColor = [UIColor clearColor];
            author_avatar_image_node.placeholderColor = APP_COMMON_LIGHT_GRAY_BACKGROUND_COLOR;
            author_avatar_image_node.URL = [NSURL URLWithString:postInfo[@"user"][@"avatar"]];
            author_avatar_image_node.contentMode = UIViewContentModeScaleAspectFill;
            author_avatar_image_node.cornerRadius = 35.0;
//            author_avatar_image_node.borderColor = [UIColor whiteColor].CGColor;
//            author_avatar_image_node.borderWidth = 3.0;
            author_avatar_image_node.clipsToBounds = YES;
            
            [author_avatar_image_node addTarget:strongSelf action:@selector(action_show_profile:) forControlEvents:ASControlNodeEventTouchUpInside];
            
            strongSelf.imgView_authorAvatar = author_avatar_image_node;
            
            [strongSelf.view_contentBackground addSubnode:strongSelf.imgView_authorAvatar];
            
        } else {
            
            strongSelf.imgView_authorAvatar.URL = [NSURL URLWithString:postInfo[@"user"][@"avatar"]];
            
        }

        

        
        // REPORT BUTTON
        
        if ([postInfo[@"user"][@"id"] isEqualToString:[UserDefault currentUser].u_id]) {
            [strongSelf.btn_report setImage:[UIImage imageNamed:@"trash_icon"] forState:UIControlStateNormal];
        } else {
            [strongSelf.btn_report setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
        }
        
        [strongSelf.btn_addComment addTarget:strongSelf action:@selector(actionAddComment:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        
        // POSTED AWAY KM
        
        CLLocationCoordinate2D userLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@",[UserDefault currentUser].strLat, [UserDefault currentUser].strLong]];
        CLLocationCoordinate2D postLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@",postInfo[@"location"][@"latitude"], postInfo[@"location"][@"longitude"]]];
        
        CGFloat kmAway = [Common kilometersfromPlace:userLocation andToPlace:postLocation];
        
        strongSelf.lbl_authorName.text = postInfo[@"user"][@"name"];
        
        strongSelf.lbl_postedAway.text = [NSString stringWithFormat:@"Posted at %.0f %@ away", kmAway,kmAway>1?@"kms":@"km"];
        
        NSString *next_to_distance = postInfo[@"location"][@"next_to_distance"];
        
        if (next_to_distance && next_to_distance.length > 0) {
            
            NSString *nextToDistance = postInfo[@"location"][@"next_to_distance"];
            
            NSString *newLocationString = [NSString stringWithFormat:@"Posted at %@ | %.0f %@ away", nextToDistance,kmAway,kmAway>1?@"kms":@"km"];
            
            strongSelf.lbl_postedAway.text = newLocationString;
            
        } else {
            
            CLLocationDegrees lat = [postInfo[@"location"][@"latitude"] floatValue];
            CLLocationDegrees lng = [postInfo[@"location"][@"longitude"] floatValue];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                
                dispatch_async(dispatch_get_main_queue(),^ {
                    
                    // do stuff with placemarks on the main thread
                    
                    if (placemarks.count == 1) {
                        
                        CLPlacemark *place = [placemarks objectAtIndex:0];
                        
                        NSString *city = [place.addressDictionary valueForKey:@"City"];
                        NSString *state = [place.addressDictionary valueForKey:@"State"];
                        
                        NSString *nextToDistance;
                        if (city && state) {
                            nextToDistance = [NSString stringWithFormat:@"%@, %@",city,state];
                        } else {
                            nextToDistance = city?city:(state?state:@"");
                        }
                        
                        NSMutableDictionary *locationInfo = postInfo[@"location"];
                        
                        [locationInfo setObject:nextToDistance forKey:@"next_to_distance"];
                        
                        NSString *newLocationString = [NSString stringWithFormat:@"Posted at %@ | %.0f %@ away", nextToDistance,kmAway,kmAway>1?@"kms":@"km"];
                        
                        strongSelf.lbl_postedAway.text = newLocationString;
                        
                    }
                });
            }];
        }
        
        
        
        
        
        // TIME AGO LABEL
        
        NSString *created_date = [[NSDate dateWithTimeIntervalSince1970:[postInfo[@"created_at"] doubleValue]] timeAgo];
        strongSelf.lbl_postedTimeAgo.text = created_date;
        CGFloat realDisplayWidth = tableViewWidth - 2*kCellContentLeftPadding;
        
        
        
        
        
        // POST CONTENT TEXTVIEW
        
        CGFloat height_content_post = ceilf([Common getHeightOfText:postInfo[@"content"] widthConstraint:realDisplayWidth font:FONT_TEXT_POST_CONTENT]);
        
        CGFloat seemoreheight;
        
        if (height_content_post > kContentLabelHeightLimit) {
            
            if (![postInfo[@"show_full_content"] isEqualToString:@"true"]) {
                
                height_content_post = kContentLabelHeightLimit;
            }
            
            seemoreheight = kSeeMorebuttonHeight;
            [strongSelf.btn_seemoreContent addTarget:strongSelf action:@selector(actionShowHideFullPostContent:) forControlEvents:UIControlEventTouchUpInside];
            strongSelf.btn_seemoreContent.hidden = NO;
            strongSelf.seemore_height_CST.constant = seemoreheight;
            
            if (![postInfo[@"show_full_content"] isEqualToString:@"true"]) {
                [strongSelf.btn_seemoreContent setTitle:@"See more" forState:UIControlStateNormal];
            } else {
                [strongSelf.btn_seemoreContent setTitle:@"Hide" forState:UIControlStateNormal];
            }
            
        } else {
            
            seemoreheight = 0;
            
            strongSelf.btn_seemoreContent.hidden = YES;
            strongSelf.seemore_height_CST.constant = 0;
        }

        [strongSelf setContentText:postInfo[@"content"]];
        strongSelf.content_height_CST.constant = height_content_post;
        
        
        
        
        
        // SCROLL IMAGES
        
        NSArray *post_media_elements = postInfo[@"media"];
        
        if ([post_media_elements count] > 0) {
            
            strongSelf.scrollViewEnhancer.hidden = NO;
            strongSelf.scrollView.hidden = NO;
            strongSelf.scroll_images_height_CST.constant = HEIGHT_SLIDE_IMAGE_POST_LIST;
            strongSelf.scroll_images_space_CST.constant = HEIGHT_SLIDE_IMAGE_POST_LIST + 2*kCellContentVerticalSpacing;
            
            __block CGFloat contentOffset = 0.0f;
            
            for (NSInteger i=0; i < [post_media_elements count]; i++) {
                
                NSMutableDictionary *objImg = [post_media_elements objectAtIndex:i];
                
                CGFloat horizontal_media_element_padding = 5;
                
                CGRect media_element_bounding = CGRectMake(contentOffset, 0, tableViewWidth - 24 , HEIGHT_SLIDE_IMAGE_POST_LIST );//{{contentOffset,0},strongSelf.scrollView.bounds.size};
                
                CGRect show_media_melement_button_frame = CGRectInset(media_element_bounding, horizontal_media_element_padding, 2);//CGRectMake(spaceScroll, 0, mainFrame.size.width - (spaceScroll * 2) + 5, mainFrame.size.height);
                
                ButtonShowImageSlide *show_media_element_button = [[ButtonShowImageSlide alloc] initWithWebImage];
                show_media_element_button.layerBacked = NO;
                show_media_element_button.frame = show_media_melement_button_frame;
                show_media_element_button.backgroundColor = [UIColor clearColor];
                show_media_element_button.placeholderColor = APP_COMMON_LIGHT_GRAY_BACKGROUND_COLOR;
                show_media_element_button.URL = [NSURL URLWithString:objImg[@"thumb"]];
                show_media_element_button.indexPathCell = indexPath;
                show_media_element_button.indexImageSelected = (NSInteger)i;
                show_media_element_button.contentMode = UIViewContentModeScaleAspectFill;
                
                if ([objImg[@"type"] isEqualToString:@"video"]) {
                    ASImageNode *playvideoiamge = [[ASImageNode alloc] init];
                    playvideoiamge.layerBacked = YES;
                    playvideoiamge.image = [UIImage imageNamed:@"btPlayVideo.png"];
                    playvideoiamge.frame = CGRectMake((show_media_melement_button_frame.size.width - 80)/2.0, (show_media_melement_button_frame.size.height - 80)/2.0, 80, 80);
                    [show_media_element_button addSubnode:playvideoiamge];
                }
                
                [show_media_element_button addTarget:strongSelf action:@selector(actionShowPostImage:) forControlEvents:ASControlNodeEventTouchUpInside];
                
                [strongSelf.scrollView addSubview:show_media_element_button.view];
                contentOffset += media_element_bounding.size.width;
            }
            
            strongSelf.scrollView.contentSize = CGSizeMake(contentOffset, HEIGHT_SLIDE_IMAGE_POST_LIST - 4);
            
        } else {
            
            strongSelf.scrollViewEnhancer.hidden = YES;
            strongSelf.scrollView.hidden = YES;
            strongSelf.scroll_images_height_CST.constant = 0;
            strongSelf.scroll_images_space_CST.constant = 0;
            
        }
        
        // LIKE COMMENT
        
        [strongSelf updateLikeDislikeStatus:NO];
        
        [strongSelf.btn_likePost addTarget:strongSelf action:@selector(actionLikePost:) forControlEvents:UIControlEventTouchUpInside];
        [strongSelf.btn_dislikePost addTarget:strongSelf action:@selector(actionDislikePost:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // COMMENT COUNT LABEL
        
        
        NSInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
        
        if (totalComments > 0) {

            strongSelf.comment_count_height_CST.constant = kNormalOneLineTextLabelHeight;
            strongSelf.lbl_commentCount.text = [NSString stringWithFormat:@"Comments (%ld)", (long)totalComments];
            strongSelf.lbl_commentCount.hidden = NO;


        } else {
            
            strongSelf.comment_count_height_CST.constant = 0;
            strongSelf.lbl_commentCount.hidden = YES;

        }
        
    }

    [strongSelf.contentView setNeedsLayout];
    [strongSelf.contentView layoutIfNeeded];

}


- (void)fillDataToCellWithPostInfo:(NSMutableDictionary*)postInfo tableViewWidth:(CGFloat)tableViewWidth {
    
    __weak __typeof(self)weakSelf = self;
    __strong __typeof__(self) strongSelf = weakSelf;
    
    if (strongSelf) {

        CGFloat realDisplayWidth = tableViewWidth - 2*kCellContentLeftPadding;
        
        // POST CONTENT TEXTVIEW
        
        CGFloat height_content_post = ceilf([Common getHeightOfText:postInfo[@"content"] widthConstraint:realDisplayWidth font:FONT_TEXT_POST_CONTENT]);
        
        CGFloat seemoreheight;
        
        if (height_content_post > kContentLabelHeightLimit) {
            
            if (![postInfo[@"show_full_content"] isEqualToString:@"true"]) {
                
                height_content_post = kContentLabelHeightLimit;
            }
            seemoreheight = kSeeMorebuttonHeight;
        } else {
            seemoreheight = 0;
        }
        
        strongSelf.seemore_height_CST.constant = seemoreheight;
        
        strongSelf.content_height_CST.constant = height_content_post;
        
        // SCROLL IMAGES
        
        NSArray *post_media_elements = postInfo[@"media"];
        
        if ([post_media_elements count] > 0) {
            
            strongSelf.scroll_images_height_CST.constant = HEIGHT_SLIDE_IMAGE_POST_LIST;
            strongSelf.scroll_images_space_CST.constant = HEIGHT_SLIDE_IMAGE_POST_LIST + 2*kCellContentVerticalSpacing;

        } else {
            
            strongSelf.scroll_images_height_CST.constant = 0;
            strongSelf.scroll_images_space_CST.constant = 0;
            
        }

        
        NSInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
        
        if (totalComments > 0) {
            strongSelf.comment_count_height_CST.constant = kNormalOneLineTextLabelHeight;
        } else {
            strongSelf.comment_count_height_CST.constant = 0;
        }

        [strongSelf.contentView setNeedsLayout];
        [strongSelf.contentView layoutIfNeeded];

    }

}

- (void)setContentText:(NSString *)contentText {
    NSString *template = [PostCell htmlTemplate];
    NSString *htmlText = [template stringByReplacingOccurrencesOfString:@"REPLACEME" withString:[contentText stringWithNewLinesAsBRs]];
    [_lbl_postContent loadHTMLString:htmlText baseURL:nil];
}

- (void)updateLikeDislikeStatus:(BOOL)animated {
    
    __weak __typeof(self)weakSelf = self;
    __strong __typeof__(self) strongSelf = weakSelf;
    
    
    NSInteger numLike = [_postInfo[@"like"][@"total"] intValue];
    NSInteger numDislike = [_postInfo[@"dislike"][@"total"] intValue];
    
    if (numLike > 0) {
        strongSelf.lbl_likeCount.textColor = COLOR_LIKE_ENABLE;
    }
    
    if (numDislike > 0) {
        strongSelf.lbl_dislikeCount.textColor = COLOR_DISLIKE_ENABLE;
    }
    
    NSString *userLikedThisPost = _postInfo[@"voted_type"];
    
    if (userLikedThisPost.length > 0) {
        
        //===User liked or disliked this post
        
        if ([userLikedThisPost isEqualToString:@"like"]) {
            
            //User liked => Disable like button and enable dislike button
            
            strongSelf.btn_likePost.titleLabel.font = FONT_LIKE_DISLIKE_BUTTON_DISABLE;
            strongSelf.btn_dislikePost.titleLabel.font = FONT_LIKE_DISLIKE_BUTTON_ENABLE;
            
            [strongSelf.btn_likePost setTitleColor:COLOR_LIKE_DISLIKE_DISABLE forState:UIControlStateNormal];
            [strongSelf.btn_dislikePost setTitleColor:COLOR_DISLIKE_ENABLE forState:UIControlStateNormal];
            
        } else {
            
            //User disliked => Disable dislike button and enable like button
            
            strongSelf.btn_likePost.titleLabel.font = FONT_LIKE_DISLIKE_BUTTON_ENABLE;
            strongSelf.btn_dislikePost.titleLabel.font = FONT_LIKE_DISLIKE_BUTTON_DISABLE;
            
            [strongSelf.btn_likePost setTitleColor:COLOR_LIKE_ENABLE forState:UIControlStateNormal];
            [strongSelf.btn_dislikePost setTitleColor:COLOR_LIKE_DISLIKE_DISABLE forState:UIControlStateNormal];
            
        }
        
    } else {
        
        //===User haven't like or dislike this post
        
        strongSelf.btn_likePost.titleLabel.font = FONT_LIKE_DISLIKE_BUTTON_ENABLE;
        strongSelf.btn_dislikePost.titleLabel.font = FONT_LIKE_DISLIKE_BUTTON_ENABLE;
        
        [strongSelf.btn_likePost setTitleColor:COLOR_LIKE_ENABLE forState:UIControlStateNormal];
        [strongSelf.btn_dislikePost setTitleColor:COLOR_DISLIKE_ENABLE forState:UIControlStateNormal];
        
    }
    
    strongSelf.lbl_likeCount.text = [NSString stringWithFormat:@"%ld", (long)numLike];
    strongSelf.lbl_dislikeCount.text = [NSString stringWithFormat:@"%ld", (long)numDislike];
    

    if (animated) {
        
        [UIView animateWithDuration:0.4 animations:^{
            
            if (numLike > 0 || numDislike > 0) {
                
                CGFloat likePercent = numLike*1.0/(numLike + numDislike);
                CGFloat dislikePercent = numDislike*1.0/(numLike + numDislike);
                
                [_likeBalanceRangeView fillColors:@[RANGE_VIEW_LIKE_AREA_COLOR,RANGE_VIEW_DISLIKE_AREA_COLOR] forParts:@[[NSNumber numberWithFloat:likePercent],[NSNumber numberWithFloat:dislikePercent]]];
                
            } else {
                
                [_likeBalanceRangeView fillColors:@[COLOR_LIKE_DISLIKE_DISABLE] forParts:@[@1.0]];
            }
            
            [strongSelf.like_dislike_containerView setNeedsLayout];
            [strongSelf.like_dislike_containerView layoutIfNeeded];
            
        }];
        
    } else {
        
        if (numLike > 0 || numDislike > 0) {
            
            CGFloat likePercent = numLike*1.0/(numLike + numDislike);
            CGFloat dislikePercent = numDislike*1.0/(numLike + numDislike);
            
            [_likeBalanceRangeView fillColors:@[RANGE_VIEW_LIKE_AREA_COLOR,RANGE_VIEW_DISLIKE_AREA_COLOR] forParts:@[[NSNumber numberWithFloat:likePercent],[NSNumber numberWithFloat:dislikePercent]]];
            
        } else {
            
            [_likeBalanceRangeView fillColors:@[COLOR_LIKE_DISLIKE_DISABLE] forParts:@[@1.0]];
        }
        
        [strongSelf.like_dislike_containerView setNeedsLayout];
        [strongSelf.like_dislike_containerView layoutIfNeeded];
    }

}

#pragma mark - Actions

- (IBAction)action_report:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(PostCell:didClickedReportButton:)]) {
        [_delegate PostCell:self didClickedReportButton:sender];
    }
}

- (void)actionShowHideFullPostContent:(id) sender {
    
    if ([_delegate respondsToSelector:@selector(PostCell:didClickedShowFullPostContentButton:)])
    {
        [_delegate PostCell:self didClickedShowFullPostContentButton:sender];
    }

}

- (void) actionAddComment:(id)sender {
    if ([_delegate respondsToSelector:@selector(PostCell:didClickedAddCommentButton:)]) {
        [_delegate PostCell:self didClickedAddCommentButton:sender];
    }
}

- (void) actionLikePost:(id)sender {
    
    NSString *userLikedThisPost = _postInfo[@"voted_type"];
    
    if ([userLikedThisPost isEqualToString:@"dislike"]  || userLikedThisPost.length == 0) {
        
        if ([_delegate respondsToSelector:@selector(PostCell:didClickedLikePostButton:)]) {
            [_delegate PostCell:self didClickedLikePostButton:sender];
        }
        
        [self updateLikeDislikeStatus:YES];
        
        [Common addPopAnimationToLayer:self.btn_likePost.layer withBounce:0.2 damp:0.080];
        
    }

}

- (void) actionDislikePost:(id)sender {
    
    NSString *userLikedThisPost = _postInfo[@"voted_type"];
    
    if ([userLikedThisPost isEqualToString:@"like"]  || userLikedThisPost.length == 0) {
        
        if ([_delegate respondsToSelector:@selector(PostCell:didClickedDislikePostButton:)]) {
            [_delegate PostCell:self didClickedDislikePostButton:sender];
        }
        
        [self updateLikeDislikeStatus:YES];
        
        [Common addPopAnimationToLayer:self.btn_dislikePost.layer withBounce:0.2 damp:0.080];
        
    }

}

- (void) actionShowPostImage:(id)sender {
    if ([_delegate respondsToSelector:@selector(PostCell:didClickedShowPostImageButton:)]) {
        [_delegate PostCell:self didClickedShowPostImageButton:sender];
    }
}

- (IBAction)action_show_profile:(id)sender {
    
    if (kAllowUserShowPostAuthorProfile && [_delegate respondsToSelector:@selector(PostCell:didClickedOnUserAvatar:)]) {
        
        [_delegate PostCell:self didClickedOnUserAvatar:sender];

    }
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked && [_delegate respondsToSelector:@selector(PostCell:wantToOpenURL:)]) {
        [_delegate PostCell:self wantToOpenURL:[request URL]];
        return NO;
    } else if ( navigationType == UIWebViewNavigationTypeLinkClicked && [[UIApplication sharedApplication] canOpenURL:[request URL]]) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

@end
