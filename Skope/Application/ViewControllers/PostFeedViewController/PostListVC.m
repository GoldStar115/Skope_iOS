//
//  PostListVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "PostListVC.h"
#import "ProfileVC.h"
#import "ARScrollViewEnhancer.h"
#import "ReportPostView.h"
#import "NewPostNofiticationTopHeaderView.h"
#import "FacebookStyleBarBehaviorDefiner.h"
#import "UITableView+ReloadData.h"
#import "MyProfileVC.h"
#import "SVModalWebViewController.h"
#import "UIView+RoundedCorners.h"
#import "UIViewController+IsVisible.h"
#import "PostCell.h"
#import "PostCellLastSectionNoComment.h"
#import "CommentTableViewCell.h"
#import "CommentTableViewCellLastWithoutLoadMore.h"
#import "ShowMoreCommentTableViewCell.h"
#import "ProfileNavigationController.h"

#import "BLKDelegateSplitter.h"
#import "SquareCashStyleBehaviorDefiner.h"


#define AlertDeletePostTag      55
#define AlertBlockUserTag       66
#define AlertHidePostTag        77
#define AlertReportPostTag      99

#define COUNT_START_MPF_COMMENTS        3
#define ShowMoreButtonHeight            40.0

@interface PostListVC () <PostCellDelegate, CommentCellDelegate, ShowMoreCommentCellDelegate, PHFComposeBarViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MWPhotoBrowserDelegate,ReportpostViewDelegate,PopoverViewDelegate,NewPostNofiticationTopHeaderViewDelegate, UIAlertViewDelegate>
{
    NSInteger       addCommentAtCellIndexPath;
    NSUInteger      paging_offset;
    NSIndexPath     *activeIndexPath;
    
    NSInteger       selectedIndexPath;
    NSInteger       selectedFullContentIndexPath;
    CGFloat         regionMapTemp;
}

@property (nonatomic, assign) CGFloat   regionMap;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray    *selections;
@property (nonatomic, strong) NSMutableArray    *photos;
@property (nonatomic, strong) NSMutableArray    *thumbs;

@property (nonatomic, strong) PHFComposeBarView *composeBarView;
@property (nonatomic, strong) UIView            *container;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;

@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, strong) AFHTTPRequestOperation *loadingOperation;

@property (nonatomic, strong) PostCell *prototypeCellNormal;
@property (nonatomic, strong) PostCell *prototypeCellLastNoComment;
@property (nonatomic, strong) RZCellSizeManager *cellSizeManager;

@property (nonatomic, strong) CommentTableViewCell *commentprototypeCellNormal;
@property (nonatomic, strong) CommentTableViewCellLastWithoutLoadMore *commentprototypeCellLastNoComment;
@property (nonatomic, strong) RZCellSizeManager *commentcellSizeManager;

@property (nonatomic, strong) NewPostNofiticationTopHeaderView *haveNewPostNotificationBar;
@property (nonatomic, strong) BLKDelegateSplitter *delegateSplitter;

@end

@implementation PostListVC

static NSString * const LoadingCellReuseIdentifier = @"LoadingCell_Identifier";
static NSString * const PostCellReuseIdentifier = @"PostCell_Identifier_XIB";
static NSString * const PostCellLastSectionNoCommentIdentifier = @"PostCellLastSectionNoComment_Identifier_XIB";
static NSString * const CommentCellReuseIdentifier = @"CommentTableViewCell";
static NSString * const CommentCellLastWithoutLoadMoreReuseIdentifier = @"CommentTableViewCellLastWithoutLoadMore_XIB";
static NSString * const ShowMoreCellReuseIdentifier = @"ShowMoreCommentTableViewCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _postsList = [[NSMutableArray alloc] init];
        
        isloading = NO;
        addCommentAtCellIndexPath = -1;
        paging_offset = 0;
        totalPostInCurrentRegion = 0;
        selectedIndexPath = -1;
        selectedFullContentIndexPath = -1;
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        _postsList = [[NSMutableArray alloc] init];
        
        isloading = NO;
        addCommentAtCellIndexPath = -1;
        paging_offset = 0;
        totalPostInCurrentRegion = 0;
        selectedIndexPath = -1;
        selectedFullContentIndexPath = -1;
        
    }
    return self;
}

- (void)setRegionMap:(CGFloat)regionMap {
    
    _regionMap = regionMap;
    
    //Do something when have new regionMap
    
    if ((_regionMap > 0 && _regionMap != regionMapTemp)) {
        
        isloading = YES;
        
        regionMapTemp = _regionMap;
        
        _regionMap = 0;
        
        if (_postsList) {
            
            paging_offset = 0;
            
            totalPostInCurrentRegion = 0;
        }
        
        [self fetchMorePostWithLimit:LIMIT_LIST_POST];
        
    } else {
        
        //Else do nothing
        
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self prepareForSubViews];
}

- (void)prepareForSubViews {
    
    
    //  Refresh Control
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(reloadPostList) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:_refreshControl atIndex:0];
    
    
    // Register NIB cell for tableView
    
    [self.tableView registerNib:[UINib nibWithNibName:CommentCellReuseIdentifier bundle:nil] forCellReuseIdentifier:CommentCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:ShowMoreCellReuseIdentifier bundle:nil] forCellReuseIdentifier:ShowMoreCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:LoadingCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:nil] forCellReuseIdentifier:PostCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCellLastSectionNoComment" bundle:nil] forCellReuseIdentifier:PostCellLastSectionNoCommentIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCellLastWithoutLoadMore" bundle:nil] forCellReuseIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier];
    
    
    
    
    // Init size manager
    
    self.cellSizeManager = [[RZCellSizeManager alloc] init];
    
    [self.cellSizeManager registerCellClassName:NSStringFromClass([PostCell class]) withNibNamed:@"PostCell" forReuseIdentifier:PostCellReuseIdentifier withHeightBlock:^CGFloat(PostCell *cell, NSMutableDictionary *postInfo) {
        
        if (!self.prototypeCellNormal)
        {
            self.prototypeCellNormal = [self.tableView dequeueReusableCellWithIdentifier:PostCellReuseIdentifier];
            [self.prototypeCellNormal setNeedsLayout];
            [self.prototypeCellNormal layoutIfNeeded];
        }
        [self.prototypeCellNormal fillDataToCellWithPostInfo:postInfo tableViewWidth:_tableView.bounds.size.width];
        [self.prototypeCellNormal setNeedsLayout];
        [self.prototypeCellNormal layoutIfNeeded];
        CGSize size = [self.prototypeCellNormal.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height;
    }];
    
    
    [self.cellSizeManager registerCellClassName:NSStringFromClass([PostCellLastSectionNoComment class]) withNibNamed:@"PostCellLastSectionNoComment" forReuseIdentifier:PostCellLastSectionNoCommentIdentifier withHeightBlock:^CGFloat(PostCellLastSectionNoComment *cell, NSMutableDictionary *postInfo) {
        
        if (!self.prototypeCellLastNoComment)
        {
            self.prototypeCellLastNoComment = [self.tableView dequeueReusableCellWithIdentifier:PostCellLastSectionNoCommentIdentifier];
            [self.prototypeCellLastNoComment setNeedsLayout];
            [self.prototypeCellLastNoComment layoutIfNeeded];
        }
        [self.prototypeCellLastNoComment fillDataToCellWithPostInfo:postInfo tableViewWidth:_tableView.bounds.size.width];
        [self.prototypeCellLastNoComment setNeedsLayout];
        [self.prototypeCellLastNoComment layoutIfNeeded];
        CGSize size = [self.prototypeCellLastNoComment.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height;
    }];
    
    
    
    
    
    // Comment cell size manager
    
    self.commentcellSizeManager = [[RZCellSizeManager alloc] init];
    
    [self.commentcellSizeManager registerCellClassName:NSStringFromClass([CommentTableViewCell class]) withNibNamed:@"CommentTableViewCell" forReuseIdentifier:CommentCellReuseIdentifier withHeightBlock:^CGFloat(CommentTableViewCell *cell, NSMutableDictionary *commentInfo) {
        
        if (!self.commentprototypeCellNormal)
        {
            self.commentprototypeCellNormal = [self.tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier];
            [self.commentprototypeCellNormal setNeedsLayout];
            [self.commentprototypeCellNormal layoutIfNeeded];
        }
        [self.commentprototypeCellNormal fillCommentInfoToView:commentInfo];
        [self.commentprototypeCellNormal setNeedsLayout];
        [self.commentprototypeCellNormal layoutIfNeeded];
        CGSize size = [self.commentprototypeCellNormal.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height;
    }];
    
    
    [self.commentcellSizeManager registerCellClassName:NSStringFromClass([CommentTableViewCellLastWithoutLoadMore class]) withNibNamed:@"CommentTableViewCellLastWithoutLoadMore" forReuseIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier withHeightBlock:^CGFloat(CommentTableViewCellLastWithoutLoadMore *cell, NSMutableDictionary *commentInfo) {
        
        if (!self.commentprototypeCellLastNoComment)
        {
            self.commentprototypeCellLastNoComment = [self.tableView dequeueReusableCellWithIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier];
            [self.commentprototypeCellLastNoComment setNeedsLayout];
            [self.commentprototypeCellLastNoComment layoutIfNeeded];
        }
        [self.commentprototypeCellLastNoComment fillCommentInfoToView:commentInfo];
        [self.commentprototypeCellLastNoComment setNeedsLayout];
        [self.commentprototypeCellLastNoComment layoutIfNeeded];
        CGSize size = [self.commentprototypeCellLastNoComment.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height;
    }];
    
    
    
    
    // ComposerBar container
    
    self.container = [self container];
    [_container addSubview:[self composeBarView]];
    [self.view addSubview:_container];
    _container.hidden = YES;
    
    
    
    // Setup the bar
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        self.haveNewPostNotificationBar = [[NewPostNofiticationTopHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.superview.frame), MaxBarHeigt)];
        self.haveNewPostNotificationBar.delegate = self;
        self.haveNewPostNotificationBar.maximumBarHeight = MaxBarHeigt;
        self.haveNewPostNotificationBar.minimumBarHeight = MinBarHeigt;
    
        FacebookStyleBarBehaviorDefiner *behaviorDefiner = [[FacebookStyleBarBehaviorDefiner alloc] init];
        [behaviorDefiner addSnappingPositionProgress:0.0 forProgressRangeStart:0.0 end:30.0/(MaxBarHeigt)];
        [behaviorDefiner addSnappingPositionProgress:1.0 forProgressRangeStart:30.0/(MaxBarHeigt) end:1.0];
        behaviorDefiner.snappingEnabled = YES;
        behaviorDefiner.elasticMaximumHeightAtTop = YES;
        behaviorDefiner.thresholdNegativeDirection = 1.5*MaxBarHeigt;
        
        self.haveNewPostNotificationBar.behaviorDefiner = behaviorDefiner;
        self.delegateSplitter = [[BLKDelegateSplitter alloc] initWithFirstDelegate:behaviorDefiner secondDelegate:self];
        self.tableView.delegate = (id<UITableViewDelegate>)self.delegateSplitter;
        [self.tableView.superview addSubview:self.haveNewPostNotificationBar];
        
    });

    
    
    // Notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChangedRegionmap:) name:kUserChangedCurrentRegionMapNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appActiveRefreshBagedNumber)
                                                 name:APP_DID_ACTIVE_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataWhenHaveInternetConnection)
                                                 name:kInternetConnectionIsEnableNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeBlockedUserPosts:)
                                                 name:kUserBlockedPersonFromChatVCNotification
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    [self appActiveRefreshBagedNumber];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    _container.hidden = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)appActiveRefreshBagedNumber {
    
    if ([self isVisible]) {
        [self refreshBagedNumber];
    }
}

- (void)reloadDataWhenHaveInternetConnection {
    
    if (_postsList.count == 0 && !isloading) {
        isloading = YES;
        [self fetchMorePostWithLimit:LIMIT_LIST_POST];
        
    }
    
}

- (void)refreshBagedNumber {
    
    [[UserDefault currentUser] setPostBagedNumber:@"0"];
    [UserDefault performCache];
        
    [AppDelegate resetNotificationBagedNumberToServerWithType:kNotificationNewPost];
    [AppDelegate updateAppIconBadgedNumber];
    
}

- (void)userChangedRegionmap:(NSNotification *)notification {
    
    CGFloat regionMap = [[[notification userInfo] valueForKey:@"regionMap"] floatValue];
    self.regionMap = regionMap;
    
}

#pragma mark - ACTION ON POST CELL

- (void)PostCell:(PostCell*)cell didClickedReportButton:(id)sender {
    
    UIButton *button = (UIButton*) sender;
    activeIndexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:activeIndexPath.section];
    
    if ([postInfo[@"user"][@"id"] isEqualToString:[UserDefault currentUser].u_id]) {
        [Common showAlertView:APP_NAME message:@"Do you really want to delete this post?" delegate:self cancelButtonTitle:@"Cancel" arrayTitleOtherButtons:@[@"Delete"] tag:AlertDeletePostTag];
    } else {
        
        CGRect cellRect = [self.containerView convertRect:[self.tableView convertRect:[cell convertRect:[cell.view_contentBackground convertRect:button.frame toView:cell] toView:self.tableView] toView:self.containerView] toView:self.view];
        CGPoint showPoint = CGPointMake(CGRectGetMidX(cellRect), CGRectGetMidY(cellRect));
        
        ReportPostView *reportView = [[ReportPostView alloc] init];
        reportView.delegate = self;
        self.popoverView = [PopoverView showPopoverAtPoint:showPoint
                                                    inView:self.view
                                                  maskType:PopoverMaskTypeGradient
                                           withContentView:reportView
                                                  delegate:self];
    }
}

- (void)PostCell:(PostCell *)cell didClickedShowFullPostContentButton:(id)sender {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:indexPath.section];
    
    if ([postInfo[@"show_full_content"] isEqualToString:@"false"]) {
        
        postInfo[@"show_full_content"] = @"true";
        
    } else {
        
        postInfo[@"show_full_content"] = @"false";
        
    }
    
    [_cellSizeManager invalidateCellSizeAtIndexPath:indexPath];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
}

- (void)PostCell:(PostCell *)cell didClickedAddCommentButton:(id)sender {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    addCommentAtCellIndexPath = indexPath.section;
    _composeBarView.textView.text = @"";
    _container.hidden = NO;
    [_composeBarView.textView becomeFirstResponder];
    [_composeBarView setUtilityButtonImage:nil];
    
}

- (void)PostCell:(PostCell *)cell didClickedLikePostButton:(id)sender {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:indexPath.section];
    
    NSString *userLikedThisPost = postInfo[@"voted_type"];
    NSInteger number_like = [postInfo[@"like"][@"total"] integerValue];
    NSInteger number_dislike = [postInfo[@"dislike"][@"total"] integerValue];
    
    if ([userLikedThisPost isEqualToString:@"dislike"] || userLikedThisPost.length == 0) {
        
        if (number_dislike > 0) {
            number_dislike--;
        }
        number_like++;
        
        postInfo[@"like"][@"total"] = @(number_like);
        postInfo[@"dislike"][@"total"] = @(number_dislike);
        postInfo[@"voted_type"] = @"like";

        [self callWSPfLikeDislikePost:postInfo[@"id"] andLikeDislike:@"like" andIndexPath:indexPath];
    }
    
}

- (void)PostCell:(PostCell *)cell didClickedDislikePostButton:(id)sender {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:indexPath.section];
    
    NSString *userLikedThisPost = postInfo[@"voted_type"];
    NSInteger number_like = [postInfo[@"like"][@"total"] integerValue];
    NSInteger number_dislike = [postInfo[@"dislike"][@"total"] integerValue];
    
    if ([userLikedThisPost isEqualToString:@"like"]  || userLikedThisPost.length == 0) {
        
        number_dislike++;
        if (number_like > 0) {
            number_like--;
        }
        
        postInfo[@"like"][@"total"] = @(number_like);
        postInfo[@"dislike"][@"total"] = @(number_dislike);
        postInfo[@"voted_type"] = @"dislike";

        [self callWSPfLikeDislikePost:postInfo[@"id"] andLikeDislike:@"dislike" andIndexPath:indexPath];
    }
    
}

- (void)PostCell:(PostCell *)cell didClickedShowPostImageButton:(id)sender {
    
    ButtonShowImageSlide *button = (ButtonShowImageSlide *)sender;
    
    NSMutableDictionary *postInfo = [_postsList objectAtIndex:button.indexPathCell.section];
    
    //NSLog(@"%@",postInfo);
    
    NSArray *arrMedia = postInfo[@"media"];
    
    if ([arrMedia count] > 0 && [arrMedia objectAtIndex:(int)button.indexImageSelected]!=nil) {
        
        NSDictionary *objSelected = [arrMedia objectAtIndex:(int)button.indexImageSelected];
        
        if ([objSelected[@"type"] isEqualToString:@"video"]) {

            // Just for test
            
            if (!_moviePlayer) {
                _moviePlayer = [[MPMoviePlayerViewController alloc] init];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(donefinishedPlayVideo:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:_moviePlayer.moviePlayer];
            
            [_moviePlayer.moviePlayer stop];
            _moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
            [_moviePlayer.moviePlayer setContentURL:[NSURL URLWithString:objSelected[@"src"]]];
            
            _moviePlayer.moviePlayer.shouldAutoplay=YES;
            [_moviePlayer.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            
            [self presentViewController:_moviePlayer animated:YES completion:^{
                [_moviePlayer.moviePlayer play];
            }];
            
        } else {
            
            //Choose array has only images
            
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            BOOL displayActionButton = kAllowUserSaveOtherUserAvatar;
            BOOL displaySelectionButtons = NO;
            BOOL displayNavArrows = NO;
            BOOL enableGrid = NO;
            BOOL startOnGrid = NO;
            int indexRealSelectedImg = (int)button.indexImageSelected;
            
            for (int i = 0; i < [arrMedia count]; i++) {
                NSDictionary *objImg = [arrMedia objectAtIndex:i];
                if ([objImg[@"type"] isEqualToString:@"video"]) {
                    indexRealSelectedImg--;
                }
            }
            
            for (int i = 0; i < [arrMedia count]; i++) {
                NSDictionary *objImg = [arrMedia objectAtIndex:i];
                if ([objImg[@"type"] isEqualToString:@"photo"]) {
                    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:objImg[@"src"]]]];
                }
            }
            
            self.photos = photos;

            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = displayActionButton;
            browser.displayNavArrows = displayNavArrows;
            browser.displaySelectionButtons = displaySelectionButtons;
            browser.alwaysShowControls = displaySelectionButtons;
            browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            browser.wantsFullScreenLayout = YES;
#endif
            browser.enableGrid = enableGrid;
            browser.startOnGrid = startOnGrid;
            browser.enableSwipeToDismiss = YES;
            [browser setCurrentPhotoIndex:indexRealSelectedImg];
            
            // Reset selections
            if (displaySelectionButtons) {
                _selections = [NSMutableArray new];
                for (int i = 0; i < photos.count; i++) {
                    [_selections addObject:[NSNumber numberWithBool:NO]];
                }
            }
            
            // Show Modal
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
            
            
            // Test reloading of data after delay
            double delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            });
            
        }
        
    }
}

- (void)PostCell:(id)cell didClickedOnUserAvatar:(id)sender {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:indexPath.section];
    NSDictionary *userInfo = postInfo[@"user"];
    
    if ([userInfo[@"id"] isEqualToString:[UserDefault currentUser].u_id]) {
        
        MyProfileVC *myProfileVC = [[MyProfileVC alloc] initWithNibName:@"MyProfileVC" bundle:nil];//[Main_Storyboard instantiateViewControllerWithIdentifier:@"MyProfileVC"];
        UINavigationController *profileNavVC = [[UINavigationController alloc] initWithRootViewController:myProfileVC];
        
        if (self.presentedViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentViewController:profileNavVC animated:YES completion:nil];
            }];
        } else {
            [self presentViewController:profileNavVC animated:YES completion:nil];
        }
  
    } else {
        
        ProfileVC *profileVC = [[ProfileVC alloc] initWithNibName:@"ProfileVCNavigation" bundle:nil];//[self.storyboard instantiateViewControllerWithIdentifier:@"VIEW_PROFILE"];
        [profileVC setUserProfileInfo:userInfo];
        
        ProfileNavigationController *navigation = [[ProfileNavigationController alloc] initWithRootViewController:profileVC];
        navigation.navigationBar.barTintColor = [UIColor whiteColor];
        navigation.navigationBar.backgroundColor = [UIColor whiteColor];
        
        if (self.presentedViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentViewController:navigation animated:YES completion:nil];
            }];
        } else {
            [self presentViewController:navigation animated:YES completion:nil];
        }
    }

}

- (void)PostCell:(id)cell wantToOpenURL:(NSURL *)url {
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[url absoluteString]];
    [self presentViewController:webViewController animated:YES completion:NULL];
}

- (void)PostCell:(id)cell didClickedSaveVideoButton:(id)sender {
    
    ButtonShowImageSlide *button = (ButtonShowImageSlide *)sender;
    
    NSMutableDictionary *postInfo = [_postsList objectAtIndex:button.indexPathCell.section];
    
    NSArray *arrMedia = postInfo[@"media"];
    
    __weak __typeof(self)weakSelf = self;
    
    
    if ([arrMedia count] > 0 && [arrMedia objectAtIndex:(int)button.indexImageSelected]!=nil) {
        
        NSDictionary *objSelected = [arrMedia objectAtIndex:(int)button.indexImageSelected];
        
        if ([objSelected[@"type"] isEqualToString:@"video"]) {
            
            [Common showNetworkActivityIndicator];
            
            NSURL *videoUrl = [NSURL URLWithString:objSelected[@"src"]];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:videoUrl];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[videoUrl lastPathComponent]];
            
            [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
            
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                NSLog(@"bytesRead: %lu, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
            }];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [Common hideNetworkActivityIndicator];
                
                __strong __typeof__(self) strongSelf = weakSelf;
                
                NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
                
                NSError *error;
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
                
                if (error) {
                    
                    NSLog(@"ERR: %@", [error description]);
                    
                    // Remove file after save to camera roll
                    
                    NSFileManager *fileMgr = [NSFileManager defaultManager] ;
                    NSError *removeFileError = nil;
                    BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&removeFileError];
                    if (!removeSuccess) {
                        // Error handling
                        NSLog( @"Error while delete video with metadata to Photo Library %@", fullPath);
                    } else {
                        NSLog( @"Deleted video with metadata to Photo Library %@", fullPath);
                    }
                    
                } else {
                    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
                    long long fileSize = [fileSizeNumber longLongValue];
                    NSLog(@"File size: %lld",fileSize);
                    
                    [strongSelf saveToCameraRoll:[NSURL fileURLWithPath:fullPath] completion:^(NSURL *newURL, NSError *error) {
                        if (error) {
                            
                            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
                            
                        } else {
                            
                            NSLog( @"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
                            
                            [SVProgressHUD showInfoWithStatus:@"Video was saved to Camera Roll"];
                            
                        }
                        
                        // Remove file after save to camera roll
                        
                        NSFileManager *fileMgr = [NSFileManager defaultManager] ;
                        NSError *removeFileError = nil;
                        BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&removeFileError];
                        if (!removeSuccess) {
                            // Error handling
                            NSLog( @"Error while delete video with metadata to Photo Library %@", fullPath);
                        } else {
                            NSLog( @"Deleted video with metadata to Photo Library %@", fullPath);
                        }
                    }];

                }

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [Common hideNetworkActivityIndicator];
                
                NSLog(@"ERR: %@", [error description]);
                
                // Remove file after save to camera roll
                
                NSFileManager *fileMgr = [NSFileManager defaultManager] ;
                NSError *removeFileError = nil;
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&removeFileError];
                if (!removeSuccess) {
                    // Error handling
                    NSLog( @"Error while delete video with metadata to Photo Library %@", fullPath);
                } else {
                    NSLog( @"Deleted video with metadata to Photo Library %@", fullPath);
                }
  
            }];
            
            [operation start];
            
        }
    }
}

- (void) saveToCameraRoll:(NSURL *)srcURL completion:(void (^)(NSURL *newURL, NSError *error))completion
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock =
    ^(NSURL *newURL, NSError *error) {
        completion(newURL,error);
    };
    
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:srcURL])
    {
        [library writeVideoAtPathToSavedPhotosAlbum:srcURL
                                    completionBlock:videoWriteCompletionBlock];
    }
}

#pragma mark - ACTION ON COMMENT CELL

- (void)CommentCell:(id)cell didClickedShowFullPostContentButton:(id)sender {
    
}

- (void)CommentCell:(id)cell didClickedReportButton:(id)sender {
    
}

- (void)CommentCell:(id)cell didClickedOnUserAvatar:(id)sender {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:indexPath.section];
    NSMutableArray *comments = postInfo[@"comment"][@"items"];
    NSDictionary *commentInfo = comments[indexPath.row - 1];
    NSDictionary *userInfo = commentInfo[@"user"];
    
    if ([userInfo[@"id"] isEqualToString:[UserDefault currentUser].u_id]) {
        
        MyProfileVC *myProfileVC = [[MyProfileVC alloc] initWithNibName:@"MyProfileVC" bundle:nil];//[Main_Storyboard instantiateViewControllerWithIdentifier:@"MyProfileVC"];
        UINavigationController *profileNavVC = [[UINavigationController alloc] initWithRootViewController:myProfileVC];
        
        __block UIViewController *parentVC = self.presentingViewController;
        
        if (parentVC) {
            [parentVC dismissViewControllerAnimated:NO completion:^{
                [parentVC presentViewController:profileNavVC animated:YES completion:nil];
            }];
        } else {
            [self presentViewController:profileNavVC animated:YES completion:nil];
        }
        
    } else {
        
        ProfileVC *profileVC = [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];//[self.storyboard instantiateViewControllerWithIdentifier:@"VIEW_PROFILE"];
        [profileVC setUserProfileInfo:userInfo];
        
        __block UIViewController *parentVC = self.presentingViewController;
        
        if (parentVC) {
            [parentVC dismissViewControllerAnimated:NO completion:^{
                [parentVC presentViewController:profileVC animated:YES completion:nil];
            }];
        } else {
            [self presentViewController:profileVC animated:YES completion:nil];
        }
    }
    
}

- (void)CommentCell:(id)cell wantToOpenURL:(NSURL*)url {
    
}

#pragma mark - SHOW MORE COMMENT CELL DELEGATE

- (void)ShowMoreCommentTableViewCell:(ShowMoreCommentTableViewCell*)cell didClickedSeeMoreCommentButton:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSMutableDictionary *postInfo = [_postsList objectAtIndex:indexPath.section];
    [self fetchMoreCommentForPost:postInfo withLimit:LIMIT_LIST_COMMENT forCell:cell];//insection:indexPath.section];
}

#pragma mark - WEBSERVICE FUNTIONS

- (void)fetchMoreCommentForPost:(NSMutableDictionary*)postInfo withLimit:(NSUInteger)page_limit forCell:(ShowMoreCommentTableViewCell*)cell//insection:(NSUInteger)section
{
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSMutableArray *comments = postInfo[@"comment"][@"items"];
    NSString *offset = [NSString stringWithFormat:@"%lu",(unsigned long)comments.count];
    NSString *limit = [NSString stringWithFormat:@"%lu",(unsigned long)page_limit];
    NSString *postID = postInfo[@"id"];
    if (!access_token || access_token.length == 0 || !offset || !limit || !postID) {
        return;
    }
    
    [Common showNetworkActivityIndicator];

    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    

    NSMutableDictionary *request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          offset,@"offset",
                                          limit,@"limit", nil
                                          ];
    
    NSArray* allComments = (NSArray*)postInfo[@"comment"][@"items"];
    NSDictionary *firstComment = ([allComments count] > 0 ? [allComments firstObject] : nil);
    
    if (firstComment) {
        //NSString* since = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] + 1];
        //[request_param setObject:since forKey:@"since"];
        NSString* after = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] - 1];
        [request_param setObject:after forKey:@"after"];
    }
    
    _tableView.scrollEnabled = NO;
    
    [manager GET:URL_SERVER_API(API_COMMENT_FOR_A_POST(postID)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
            NSMutableArray *newObjects = [NSMutableArray new];
            NSMutableArray *newIndexPaths = [NSMutableArray new];
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSBlockOperation *blockoperation = [NSBlockOperation blockOperationWithBlock:^{
                                        
                    if (success &&  object[@"data"][@"items"] != nil) {
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                        
                        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
                        
                        [(NSArray *) object[@"data"][@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            [newIndexPaths addObject:[NSIndexPath indexPathForRow:comments.count + (idx+1) inSection:indexPath.section]];
                            
                        }];
                    }
                    
                }];
                
                [blockoperation setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
                        
                        
                        if ([_tableView.visibleCells containsObject:cell])
                        {
                            // Do your thing
                        }
                        
                        if (success &&  newObjects.count > 0) {
                            
                            [_tableView beginUpdates];

                            NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
                            
                            PostCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
                            [cell.lbl_commentCount setText:[NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalComments]];
                            
                            if (totalComments <= comments.count + newObjects.count && [_tableView numberOfRowsInSection:indexPath.section] > comments.count + 1) {
                                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:comments.count+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                            }
                            
                            [comments addObjectsFromArray:newObjects];
                            
                            [_tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                            
                            [_tableView endUpdates];
                            
                        } else {
                            
                            //Have no comment return
                            
                        }
                        
                        _tableView.scrollEnabled = YES;
                        
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:blockoperation];
                
            }];
            
        } else {
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            NSLog(@"Error: %@",errorMsg);
            
            _tableView.scrollEnabled = YES;
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [Common hideNetworkActivityIndicator];
        
        _tableView.scrollEnabled = YES;
        
    }];
    
}

- (void)fetchNewestPostWithLimit:(NSUInteger)page_limit {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *latitude = [UserDefault currentUser].strLat;
    NSString *longitude = [UserDefault currentUser].strLong;
    NSString *distance = [NSString stringWithFormat:@"%f",regionMapTemp];
    NSString *offset = @"0";
    NSString *limit = [NSString stringWithFormat:@"%lu",(unsigned long)page_limit];
    
    if (!access_token || access_token.length == 0 || !latitude || !longitude || !distance || !offset || !limit) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    [self.loadingOperation cancel];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    
    NSMutableDictionary *request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          latitude,@"latitude",
                                          longitude,@"longitude",
                                          distance,@"distance",
                                          offset,@"offset",
                                          limit, @"limit", nil
                                          ];
    
    NSDictionary *firstPost = ([_postsList count] > 1 ? [_postsList firstObject] : nil);
    
    if (firstPost) {
        NSString* after = firstPost[@"created_at"];
        [request_param setObject:after forKey:@"after"];
    }
    
    
    self.loadingOperation = [manager GET:URL_SERVER_API(API_LIST_POST) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
            NSMutableArray *newObjects = [NSMutableArray new];
            NSMutableArray *newIndexPaths = [NSMutableArray new];
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSBlockOperation *blockoperation = [NSBlockOperation blockOperationWithBlock:^{
                    
                    if (success &&  object[@"data"][@"items"] != nil) {
                        
                        if (object[@"data"][@"total"] != nil) {
                            
                            totalPostInCurrentRegion += [object[@"data"][@"total"] intValue];
                            
                        }
                        
                        [object[@"data"][@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            NSMutableDictionary *postInfo = obj;
                            
                            postInfo[@"show_full_content"] = @"false";
                            
                            NSMutableArray *comments = [postInfo[@"comment"][@"items"] mutableCopy];
                            
                            postInfo[@"comment"][@"items"] = comments;
                            
                            if (paging_offset > 0) {
                                
                                [newIndexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:idx]];
                                
                            }
                        }];
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                        
                    }
                    
                }];
                
                [blockoperation setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        if (success &&  newObjects.count > 0) {
                            
                            [self.cellSizeManager invalidateCellSizeCache];
                            
                            [_tableView beginUpdates];
                            
                            [_postsList insertObjects:newObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newObjects.count)]];
                            
                            NSIndexSet *newSectionsIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newIndexPaths.count)];
                            
                            [_tableView insertSections:newSectionsIndexSet withRowAnimation:UITableViewRowAnimationFade];
                            
                            [_tableView endUpdates];
                            
                            [UIView animateWithDuration:0.3 animations:^{
                                [_tableView setContentOffset:CGPointMake(0, 0)];
                            }];
                            
                            paging_offset+=newObjects.count;
                            
                        } else {
                            
                            // Have no post return
                            
                        }
                        
                        isloading = NO;
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:blockoperation];
                
            }];
            
        } else {
            
            isloading = NO;
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        isloading = NO;
        
    }];
    
}

- (void)fetchMorePostWithLimit:(NSUInteger)page_limit {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *latitude = [UserDefault currentUser].strLat;
    NSString *longitude = [UserDefault currentUser].strLong;
    NSString *distance = [NSString stringWithFormat:@"%f",regionMapTemp];
    NSString *offset = [NSString stringWithFormat:@"%lu",(unsigned long)paging_offset];
    NSString *limit = [NSString stringWithFormat:@"%lu",(unsigned long)page_limit];
    
    if (!access_token || access_token.length == 0 || !latitude || !longitude || !distance || !offset || !limit) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    [self.loadingOperation cancel];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    
    NSMutableDictionary *request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          latitude,@"latitude",
                                          longitude,@"longitude",
                                          distance,@"distance",
                                          offset,@"offset",
                                          limit, @"limit", nil
                                          ];
    
    NSDictionary *firstPost = ([_postsList count] > 1 ? [_postsList firstObject] : nil);
    
    if (firstPost) {
        NSString* since = [NSString stringWithFormat:@"%ld",[firstPost[@"created_at"] integerValue] + 1];
        [request_param setObject:since forKey:@"since"];
    }
    
    
    self.loadingOperation = [manager GET:URL_SERVER_API(API_LIST_POST) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
        [self.refreshControl endRefreshing];
        
        if ([Common validateResponse:responseObject]) {
            
            NSMutableArray *newObjects = [NSMutableArray new];
            NSMutableArray *newIndexPaths = [NSMutableArray new];
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSBlockOperation *blockoperation = [NSBlockOperation blockOperationWithBlock:^{
                    
                    if (success &&  object[@"data"][@"items"] != nil) {
                        
                        if (object[@"data"][@"total"] != nil) {
                            
                            totalPostInCurrentRegion = [object[@"data"][@"total"] intValue];
                            
                        }

                        if (paging_offset == 0) {
                            [_postsList removeAllObjects];
                        }
                        
                        [object[@"data"][@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            NSMutableDictionary *postInfo = obj;
                            
                            postInfo[@"show_full_content"] = @"false";
                            
                            NSMutableArray *comments = [postInfo[@"comment"][@"items"] mutableCopy];
                            
                            postInfo[@"comment"][@"items"] = comments;
                            
                            if (paging_offset > 0) {
                                
                                [newIndexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:(_postsList.count-2 + idx + 1)]];
                                
                            }
                        }];
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                        
                    }
                    
                }];
                
                [blockoperation setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        if (success &&  newObjects.count > 0) {
                            
                            if (paging_offset == 0) {
                                
                                [self.cellSizeManager invalidateCellSizeCache];
                                
                                [_postsList addObjectsFromArray:newObjects];
                                [_postsList addObject:@"jummy"];
                                
                                [_tableView setContentOffset:CGPointMake(0, 0)];
                                
                                [_tableView reloadData:YES completion:^(BOOL finished) {
                                    //
                                }];
                                
                            } else {
                                
                                [_tableView beginUpdates];
                                
                                [_postsList insertObjects:newObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_postsList.count - 1, newObjects.count)]];
                                
                                NSIndexPath *firstIndex = newIndexPaths.firstObject;
                                NSIndexSet *newSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstIndex.section, newIndexPaths.count)];
                                [_tableView insertSections:newSection withRowAnimation:UITableViewRowAnimationFade];
                                
                                [_tableView endUpdates];
                            }
                            
                            paging_offset+=newObjects.count;
                            
                        } else {
                            
                            // Have no post return
                            
                        }
                        
                        isloading = NO;
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:blockoperation];
                
            }];
            
        } else {
            
            isloading = NO;
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
        [self.refreshControl endRefreshing];
        
        isloading = NO;
        
    }];

}

- (void)callWSAddComment:(NSMutableDictionary *)postInfo andTextCm:(NSString *) strComment cellIndexPath:(NSIndexPath *)indexPath {

    //  !(@#$!(@#*!)(@#*$()!*()#@*$!)(@#
    
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSMutableArray *comments = postInfo[@"comment"][@"items"];
    NSString *offset = [NSString stringWithFormat:@"%lu",(unsigned long)comments.count];
    NSString *limit = [NSString stringWithFormat:@"%lu",(unsigned long)1000];
    NSString *postID = postInfo[@"id"];
    if (!access_token || access_token.length == 0 || !offset || !limit || !postID) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    
    NSMutableDictionary *request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          offset,@"offset",
                                          limit,@"limit", nil
                                          ];
    
    NSArray* allComments = (NSArray*)postInfo[@"comment"][@"items"];
    NSDictionary *firstComment = ([allComments count] > 0 ? [allComments firstObject] : nil);
    
    if (firstComment) {
        //NSString* since = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] + 1];
        //[request_param setObject:since forKey:@"since"];
        
        NSString* after = [NSString stringWithFormat:@"%d",[firstComment[@"created_at"] integerValue] - 1];
        [request_param setObject:after forKey:@"after"];
    }
    
    _tableView.scrollEnabled = NO;
    
    [manager GET:URL_SERVER_API(API_COMMENT_FOR_A_POST(postID)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
            NSMutableArray *newObjects = [NSMutableArray new];
            NSMutableArray *newIndexPaths = [NSMutableArray new];
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSBlockOperation *blockoperation = [NSBlockOperation blockOperationWithBlock:^{
                    
                    if (success &&  object[@"data"][@"items"] != nil) {
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                        
                        // Add local comment first
                        
                        NSMutableDictionary *commentObj = [NSMutableDictionary dictionaryWithObject:strComment forKey:@"content"];
                        NSDictionary *user = [NSDictionary dictionaryWithObjects:@[[UserDefault currentUser].name,[UserDefault currentUser].avatar] forKeys:@[@"name",@"avatar"]];
                        NSString *create_at = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
                        [commentObj setObject:user forKey:@"user"];
                        [commentObj setObject:create_at forKey:@"created_at"];
                        [newObjects addObject:commentObj];
                        
                        [newObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            [newIndexPaths addObject:[NSIndexPath indexPathForRow:comments.count + (idx+1) inSection:indexPath.section]];
                            
                        }];

                    }
                    
                }];
                
                [blockoperation setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue] + 1;   //+1 for newest comment
                        [postInfo[@"comment"] setObject:[NSString stringWithFormat:@"%d",totalComments] forKey:@"total"];
                        
                        
                        if (success &&  newObjects.count > 0) {
                            
                            [_tableView beginUpdates];

                            PostCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
                            [cell.lbl_commentCount setText:[NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalComments]];
                            
                            if (totalComments <= comments.count + newObjects.count && [_tableView numberOfRowsInSection:indexPath.section] > comments.count + 1) {
                                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:comments.count+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                            }
                            
                            [comments addObjectsFromArray:newObjects];
                            
                            [_tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                            
                            [_tableView endUpdates];

                        } else {
                            
                            //  Have no comment return
                            
                        }

                        //  Reload firstCell and last cell
                        
                        NSIndexPath *postCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                        PostCell *cell = [self.tableView cellForRowAtIndexPath:postCellIndexPath];
                        cell.lbl_commentCount.text = [NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalComments];
                        
                        NSIndexPath *lastCell = [NSIndexPath indexPathForRow:comments.count-1 inSection:indexPath.section];
                        
                        [_tableView reloadRowsAtIndexPaths:@[lastCell] withRowAnimation:UITableViewRowAnimationFade];
                        
                        
                        
                        //  Call WS TO ADD Comment
                        //  #@$&!*&#$*(!@&#$*(!&@#$*!@(&#$*
                        
                        [Common showNetworkActivityIndicator];
                        
                        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                        
                        NSDictionary *request_param = @{@"access_token":[UserDefault currentUser].server_access_token,
                                                        @"content":strComment,
                                                        @"id":postInfo[@"id"],
                                                        };
                        
                        [manager POST:URL_SERVER_API(API_COMMENT_FOR_A_POST(postInfo[@"id"])) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject){
                            
                            [Common hideNetworkActivityIndicator];
                            
                            if ([Common validateResponse:responseObject]) {
                                
                                [postInfo[@"comment"][@"items"] replaceObjectAtIndex:comments.count-1 withObject:responseObject[@"data"][@"comment"]];
                                
                            } else {
                                
                                NSString* errorMsg = [Common errorMessageFromResponseObject:responseObject];
                                if (errorMsg) {
                                    [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                                }
                            }
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [Common hideNetworkActivityIndicator];
                        }];
                        
                        
                        //  @#$&%@*($&%@(*#$&%(*@&#$%(*@#&

                        _tableView.scrollEnabled = YES;
                        
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:blockoperation];
                
            }];
            
        } else {
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            NSLog(@"Error: %@",errorMsg);
            
            _tableView.scrollEnabled = YES;
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideNetworkActivityIndicator];
        
        _tableView.scrollEnabled = YES;
        
    }];
    
    
    //  !#$(!&#$*(!&#@(*$&!#*$&!(@*#&!(*@#&
    
        /*
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *postId = postInfo[@"id"];
    
    if (!access_token || access_token.length == 0 || !strComment || !postId) {
        return;
    }

    // Add local comment first
    
    NSMutableDictionary *commentObj = [NSMutableDictionary dictionaryWithObject:strComment forKey:@"content"];
    NSDictionary *user = [NSDictionary dictionaryWithObjects:@[[UserDefault currentUser].name,[UserDefault currentUser].avatar] forKeys:@[@"name",@"avatar"]];
    NSString *create_at = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    [commentObj setObject:user forKey:@"user"];
    [commentObj setObject:create_at forKey:@"created_at"];
    
    
    [postInfo[@"comment"][@"items"] insertObject:commentObj atIndex:0];
    NSUInteger totalCm = [postInfo[@"comment"][@"total"] intValue] + 1;
    postInfo[@"comment"][@"total"] = @(totalCm);
    NSIndexPath *postCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
    PostCell *cell = [self.tableView cellForRowAtIndexPath:postCellIndexPath];
    cell.lbl_commentCount.text = [NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalCm];
    
    [_commentcellSizeManager invalidateCellSizeCache];
    
    [_tableView beginUpdates];
    if (totalCm == 1) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    }
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if (totalCm == COUNT_START_MPF_COMMENTS + 1) {
        
        [postInfo[@"comment"][@"items"] removeLastObject];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:totalCm inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:totalCm-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    [_tableView endUpdates];
    
    
    
    
    // Call API to add comment to server
    
    [Common showNetworkActivityIndicator];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{@"access_token":[UserDefault currentUser].server_access_token,
                                    @"content":strComment,
                                    @"id":postInfo[@"id"],
                                    };
    
    [manager POST:URL_SERVER_API(API_COMMENT_FOR_A_POST(postInfo[@"id"])) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
            [postInfo[@"comment"][@"items"] replaceObjectAtIndex:0 withObject:responseObject[@"data"][@"comment"]];
            
        } else {
            
            NSString* errorMsg = [Common errorMessageFromResponseObject:responseObject];
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
    }];
         
         
    */
    
    
}

- (void)callWSPfLikeDislikePost:(NSString *)postId andLikeDislike:(NSString *) strLike andIndexPath:(NSIndexPath *)indexPath {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    
    if (!access_token || access_token.length == 0 || !strLike || !postId) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{@"access_token":[UserDefault currentUser].server_access_token,
                                    @"type":strLike,
                                    @"id":postId,
                                    };
    
    [manager POST:URL_SERVER_API(API_LIKE_DISLIKE_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];
        [Common hideLoadingViewGlobal];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideNetworkActivityIndicator];
        [Common hideLoadingViewGlobal];
    }];
}

- (void)removeBlockedUserPosts:(NSNotification *)notification {
    
    NSLog(@"User info: %@",[notification userInfo]);
    
    NSString *blockedUserId = [[notification userInfo] valueForKey:@"blockedUserId"];
    NSString *blockedUserEmail = [[notification userInfo] valueForKey:@"blockedUserEmail"];
    
    if (blockedUserEmail) {
        
        [self removeBlockedUserPost:nil email:blockedUserEmail];
        
    } else if (blockedUserId){
        
        [self removeBlockedUserPost:blockedUserId email:nil];
    }
    
}

- (void)removeBlockedUserPost:(NSString*)userID email:(NSString*)userEmail {
    
    NSMutableArray *objectDelete = [NSMutableArray new];
    NSMutableArray *indexPathDelete = [NSMutableArray new];
    
    //now we figure out if we need to remove any sections
    NSMutableIndexSet *sectionsToRemove = [NSMutableIndexSet indexSet];
    [sectionsToRemove removeAllIndexes];
    
    if (userID) {
        
        [_postsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if ([obj isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *post = (NSDictionary*)obj;
                NSString *postUserId = post[@"user"][@"id"];
                
                if ([postUserId isEqualToString:userID]) {
                    
                    totalPostInCurrentRegion--;
                    paging_offset--;
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:idx];
                    
                    [objectDelete addObject:obj];
                    [indexPathDelete addObject:indexPath];
                    [sectionsToRemove addIndex:indexPath.section];
                    
                }
            }
        }];
        
    } else  if (userEmail) {
        
        [_postsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if ([obj isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *post = (NSDictionary*)obj;
                NSString *postUserEmail = post[@"user"][@"email"];
                
                if ([postUserEmail isEqualToString:userEmail]) {
                    
                    totalPostInCurrentRegion--;
                    paging_offset--;
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:idx];
                    
                    [objectDelete addObject:obj];
                    [indexPathDelete addObject:indexPath];
                    [sectionsToRemove addIndex:indexPath.section];
                    
                }
            }
        }];
        
    }

    [_tableView beginUpdates];
    
    [_postsList removeObjectsInArray:objectDelete];
    
    [_tableView deleteSections:sectionsToRemove withRowAnimation:UITableViewRowAnimationFade];
    //[_tableView deleteRowsAtIndexPaths:indexPathDelete withRowAnimation:UITableViewRowAnimationFade];
    
    [_cellSizeManager invalidateCellSizeCache];
    [_tableView endUpdates];
}

- (void)reloadPostList {
    
    if (regionMapTemp > 0) {
        
        isloading = YES;
        
        if (_postsList) {
            
            paging_offset = 0;
            
            totalPostInCurrentRegion = 0;
        }
        
        [self fetchMorePostWithLimit:LIMIT_LIST_POST];
        
    }
}

#pragma mark - COMPOSE POST

- (void)keyboardWillToggle:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect startFrame;
    CGRect endFrame;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]        getValue:&startFrame];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&endFrame];
    
    NSInteger signCorrection = 1;
    if (startFrame.origin.y < 0 || startFrame.origin.x < 0 || endFrame.origin.y < 0 || endFrame.origin.x < 0)
        signCorrection = -1;
    CGRect newContainerFrame = [[self container] frame];
    newContainerFrame.origin.y = endFrame.origin.y - newContainerFrame.size.height;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [_container setFrame:newContainerFrame];
                     }
                     completion:NULL];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    
    [composeBarView resignFirstResponder];
    _container.hidden = YES;
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:addCommentAtCellIndexPath];
    [self callWSAddComment:postInfo andTextCm:composeBarView.textView.text cellIndexPath:[NSIndexPath indexPathForRow:0 inSection:addCommentAtCellIndexPath]];
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView {
    
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve
{
    
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
{
    
}


//@synthesize container = _container;
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_CALCULATED, SCREEN_HEIGHT_CALCULATED - (self.navigationController?64:0))];
        _container.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionHideKeyboard:)];
        [_container addGestureRecognizer:tapGesture];

    }
    return _container;
}

- (PHFComposeBarView *) composeBarView {
    if (!_composeBarView) {
        CGRect frame = CGRectMake(0.0f,
                                  CGRectGetHeight(_container.bounds)/*SCREEN_HEIGHT_CALCULATED*/ - PHFComposeBarViewInitialHeight - (self.navigationController?64:0),
                                  SCREEN_WIDTH_CALCULATED,
                                  PHFComposeBarViewInitialHeight);
        
        _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
        [_composeBarView setBackgroundColor:[UIColor whiteColor]];
        [_composeBarView setUtilityButtonImage:nil];
        [_composeBarView setButtonTintColor:COLOR_BUTTON_POST_SEND];
        [_composeBarView.textView setFont:FONT_TEXT_COMPOSE_BAR];
        [_composeBarView setMaxLinesCount:5];
        [_composeBarView setMaxHeight:120];
        [_composeBarView setButtonTitle:@"Post"];
        [_composeBarView setPlaceholder:@"Type something..."];
        [_composeBarView.button setTitleColor:COLOR_BUTTON_POST_SEND forState:UIControlStateDisabled];
        [_composeBarView setDelegate:self];
    }
    return _composeBarView;
}


#pragma mark - REPORTVIEW DELEGATE

- (void)reportpostView:(ReportPostView*)view didPressedReportButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to report this post?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertReportPostTag];
    }];
}

- (void)reportpostView:(ReportPostView*)view didPressedHideButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to hide this post?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertHidePostTag];
    }];
}

- (void)reportpostView:(ReportPostView*)view didPressedBlockUserButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to block user and remove all posts?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertBlockUserTag];
    }];
}

#pragma mark - PopoverViewDelegate Methods

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.popoverView = nil;
}

#pragma mark - TABLE DELEGATE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [_postsList count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == [_postsList count] - 1) {
        
        // For loadmore cell

        return 1;
        
    } else if (section < _postsList.count){
        
        NSMutableDictionary *postInfo = [_postsList objectAtIndex:section];
        
        NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
        
        if (totalComments > 0) {
            
            NSMutableArray *comments = postInfo[@"comment"][@"items"];
            
            if (totalComments > COUNT_START_MPF_COMMENTS) {
                
                // Have loadmore cell
                
                if (totalComments > comments.count) {
                    
                    return comments.count + 1 + 1;  //For Post cell and loadmore cell
                    
                } else {
                    
                    return comments.count + 1;
                }

            } else {
                
                // Have no loadmore cell
                
                return comments.count + 1;  //For Post cell
            }
            
        } else {
            
            return 1;
            
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == [_postsList count] - 1) {
        
        //  Jummy cell
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellReuseIdentifier];
        UIActivityIndicatorView *indicatorV = (UIActivityIndicatorView *)[cell viewWithTag:12];
        
        if (totalPostInCurrentRegion > [_postsList count]-1) {
            [indicatorV startAnimating];
        } else {
            [indicatorV stopAnimating];
        }
        
        return cell;
        
    } else {
        
        NSMutableDictionary *postInfo = [_postsList objectAtIndex:indexPath.section];
        
        NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
        
        if (indexPath.row == 0) {
            
            //  Use Post cell
            
            if (totalComments > 0) {
                
                //  Use Normal Post cell
                
                PostCell *cell = [tableView dequeueReusableCellWithIdentifier:PostCellReuseIdentifier forIndexPath:indexPath];
                [cell configureCellDisplayWithPostInfo:postInfo tableViewWidth:tableView.bounds.size.width indexPath:indexPath nodeConstructionQueue:[Common sharedBackgroundOperationQueue]];//[[UIScreen mainScreen] bounds].size.width - 2*kCellContentLeftPadding - 16
                [cell setDelegate:self];
                
                return cell;
                
            } else {

                //  Use Last Post cell
                
                PostCellLastSectionNoComment *cell = [tableView dequeueReusableCellWithIdentifier:PostCellLastSectionNoCommentIdentifier forIndexPath:indexPath];
                [cell configureCellDisplayWithPostInfo:postInfo tableViewWidth:tableView.bounds.size.width indexPath:indexPath nodeConstructionQueue:[Common sharedBackgroundOperationQueue]];//[[UIScreen mainScreen] bounds].size.width - 2*kCellContentLeftPadding - 16
                [cell setDelegate:self];
                return cell;
            }
            
        } else {
            
            //  Use Comment cell and last cell

            if (totalComments > 0) {
                
                NSMutableArray *comments = postInfo[@"comment"][@"items"];
                
                if (totalComments > COUNT_START_MPF_COMMENTS) {
                    
                    //  Have loadmore cell
                    
                    if (totalComments <= comments.count) {
                        
                        if (indexPath.row == comments.count) {
                            
                            //  Use last comment cell without loadmore cell
                            
                            CommentTableViewCellLastWithoutLoadMore *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier forIndexPath:indexPath];
                            NSDictionary *commentInfo = comments[indexPath.row - 1];
                            [commentCell fillCommentInfoToView:commentInfo];
                            commentCell.isLastCell = YES;
                            commentCell.delegate = self;
                            
                            return commentCell;
                            
                        } else {
                            
                            //  Use Normal Comment cell
                            
                            CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier forIndexPath:indexPath];
                            NSDictionary *commentInfo = comments[indexPath.row - 1];
                            [commentCell fillCommentInfoToView:commentInfo];
                            commentCell.delegate = self;
                            
                            return commentCell;
                            
                        }
                        
                    } else {
                        
                        if (indexPath.row == comments.count + 1) {
                            
                            //  Use Load more cell
                            
                            ShowMoreCommentTableViewCell *showmoreCell = [tableView dequeueReusableCellWithIdentifier:ShowMoreCellReuseIdentifier forIndexPath:indexPath];
                            showmoreCell.delegate = self;
                            return showmoreCell;
                            
                        } else {
                            
                            //  Use Normal Comment cell
                            
                            CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier forIndexPath:indexPath];
                            NSDictionary *commentInfo = comments[indexPath.row - 1];
                            [commentCell fillCommentInfoToView:commentInfo];
                            commentCell.delegate = self;
                            
                            return commentCell;
                            
                        }
                        
                    }
                    
                } else {

                    //  Have no loadmore cell
                    
                    if (indexPath.row < comments.count) {
                        
                        //  Use normal comment cell
                        
                        CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier forIndexPath:indexPath];
                        NSDictionary *commentInfo = comments[indexPath.row - 1];
                        [commentCell fillCommentInfoToView:commentInfo];
                        commentCell.delegate = self;
                        
                        return commentCell;
                        
                    } else {
                        
                        //  Use last comment cell without loadmore cell
                        
                        CommentTableViewCellLastWithoutLoadMore *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier forIndexPath:indexPath];
                        NSDictionary *commentInfo = comments[indexPath.row - 1];
                        [commentCell fillCommentInfoToView:commentInfo];
                        commentCell.isLastCell = YES;
                        commentCell.delegate = self;
                        
                        return commentCell;
                        
                    }
                }
            }
        }
        
        CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier forIndexPath:indexPath];
        
        return commentCell;

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [_postsList objectAtIndex:indexPath.section];
    
    if ((indexPath.section == [_postsList count] - 1) || [object isKindOfClass:[NSString class]]) {
        
        //===jummy cell
        
        if (totalPostInCurrentRegion == [_postsList count] - 1) {
            
            return 0;
            
        } else {
            
            return ShowMoreButtonHeight;
            
        }
        
    } else {
        
        NSDictionary* postInfo = [_postsList objectAtIndex:indexPath.section];
        
        NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
        
        if (indexPath.row == 0) {
            
            if (totalComments > 0) {

                CGFloat rowHeight = [self.cellSizeManager cellHeightForObject:postInfo indexPath:indexPath cellReuseIdentifier:PostCellReuseIdentifier];
                return rowHeight;
                
            } else {
                
                CGFloat rowHeight = [self.cellSizeManager cellHeightForObject:postInfo indexPath:indexPath cellReuseIdentifier:PostCellLastSectionNoCommentIdentifier];
                return rowHeight;
            }
     
        } else {

            if (totalComments > 0) {
                
                NSMutableArray *comments = postInfo[@"comment"][@"items"];
                
                if (totalComments > COUNT_START_MPF_COMMENTS) {
                    
                    // Have loadmore cell
                    
                    if (totalComments <= comments.count) {
                        
                        if (indexPath.row == comments.count) {
                            
                            // Use last comment cell without loadmore cell
                            
                            NSDictionary *commentObj = comments[indexPath.row - 1];
                            CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier];
                            return rowHeight;
                            
                        } else {
                            
                            // Normal Comment cell
                            
                            NSDictionary *commentObj = comments[indexPath.row - 1];
                            CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellReuseIdentifier];
                            return rowHeight;
                        }
                        
                    } else {
                        
                        if (indexPath.row == comments.count + 1) {
                            
                            // Load more cell
                            
                            return ShowMoreButtonHeight;
                            
                        } else {
                            
                            // Normal Comment cell
                            
                            NSDictionary *commentObj = comments[indexPath.row - 1];
                            CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellReuseIdentifier];
                            return rowHeight;
                            
                        }
                        
                    }
                    
                } else {
                    
                    // Have no loadmore cell
                    
                    if (indexPath.row < comments.count) {
                        
                        // Use normal comment cell
                        
                        NSDictionary *commentObj = comments[indexPath.row - 1];
                        CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellReuseIdentifier];
                        return rowHeight;
                        
                    } else {
                        
                        // Use last comment cell without loadmore cell
                        
                        NSDictionary *commentObj = comments[indexPath.row - 1];
                        CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier];
                        return rowHeight;
                        
                    }
                }
            }
        }
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
     [cell setSeparatorInset:UIEdgeInsetsZero];
     }
     
     if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
     [cell setLayoutMargins:UIEdgeInsetsZero];
     }
     */
    
    if ((indexPath.section ==  [_postsList count] - 3) && totalPostInCurrentRegion > _postsList.count-1 && !isloading) {
        //If scroll to bottom cell and still have mor post => Call to loadmore post
        isloading = YES;
        [self fetchMorePostWithLimit:LIMIT_LIST_POST];
    }
}

- (IBAction)actionHideKeyboard:(id)sender {
    [_composeBarView resignFirstResponder];
    _container.hidden = YES;
}

- (IBAction)actionPostBack:(id)sender {
    if([_delegate respondsToSelector:@selector(postListActionBack)])
    {
        [_delegate postListActionBack];
    }
}

#pragma mark - PLAY VIDEO DELEGATE

- (void) donefinishedPlayVideo:(NSNotification*)aNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_moviePlayer.moviePlayer];
    
    [_moviePlayer.moviePlayer stop];
    
    [_moviePlayer dismissViewControllerAnimated:YES completion:^{
        _moviePlayer = nil;
    }];
}

#pragma mark -  NewPostNofiticationTopHeaderViewDelegate

- (void)TopHeaderViewButtonClicked:(UIButton *)sender {
    
    [UserDefault currentUser].haveNewPostNotification = @"0";
    
    //  Scroll tableView to top with animation and then reload data
    
    if (regionMapTemp > 0) {
        
        isloading = YES;

        [_tableView setContentOffset:self.tableView.contentOffset animated:NO];
        
        [self fetchNewestPostWithLimit:LIMIT_LIST_POST];
        
    }
    
    [self appActiveRefreshBagedNumber];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    //NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    //NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? ALERT_YES_BUTTON : ALERT_NO_BUTTON);
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    //NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PopoverMethods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // get new center coords
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    
    if (_popoverView) {
        // popover is visible, so we need to either reposition or dismiss it (dismising is probably best to avoid confusion)
        bool dismiss = YES;
        if (dismiss) {
            [_popoverView dismiss:NO completion:^{
                //
            }];
        }
        else {
            // move popover
            [_popoverView animateRotationToNewPoint:center
                                             inView:self.view
                                       withDuration:duration];
        }
    }
}

#pragma mark - Confirm user actions 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        //Do action
        
        NSString *access_token = [UserDefault currentUser].server_access_token;
        NSString *userId = [UserDefault currentUser].u_id;
        
        if (!access_token || access_token.length == 0 || !userId ) {
            return;
        }
        
        switch (alertView.tag) {
            case AlertDeletePostTag:
            {
                //=====Delete user owner post=====
                
                NSString *postId = _postsList[activeIndexPath.section][@"id"];
                
                if (!postId) {
                    return;
                }
                
                [Common showNetworkActivityIndicator];
                
                AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                NSDictionary *request_param = @{@"access_token":access_token,
                                                @"id":postId,
                                                };
                
                [manager DELETE:URL_SERVER_API(API_DELETE_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    if ([Common validateResponse:responseObject]) {
                        
                        //completion(YES,object);
                        
                        totalPostInCurrentRegion--;
                        paging_offset--;
                        
                        [_tableView beginUpdates];
                        [_postsList removeObjectAtIndex:activeIndexPath.section];
                        
                        NSIndexSet *deleteSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(activeIndexPath.section, 1)];
                        [_tableView deleteSections:deleteSection withRowAnimation:UITableViewRowAnimationFade];
                        //[_tableView deleteRowsAtIndexPaths:@[activeIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                        
                        [_cellSizeManager invalidateCellSizeCache];
                        [_tableView endUpdates];
                        
                        NSString* successMsg = responseObject[@"data"][@"message"];
                        if (!successMsg || successMsg.length == 0) {
                            successMsg = @"Post was deleted!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:successMsg];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:POST_HIDDEN_DELETED_NOTIFICATION object:nil];
                        
                    } else {
                        
                        //completion(NO,nil);
                        NSString* errorMsg = responseObject[@"data"][@"message"];
                        if (!errorMsg || errorMsg.length == 0) {
                            errorMsg = @"There was an issue while delete your post!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                        
                        //[Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    //completion(NO,nil);
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while delete your post!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while delete your post!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];

            }
                break;
                
            case AlertReportPostTag:
            {
                //=====Report a post=====
                
                NSString *postId = _postsList[activeIndexPath.section][@"id"];
                
                if (!postId) {
                    return;
                }
                
                [Common showNetworkActivityIndicator];
                
                AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                NSDictionary *request_param = @{@"access_token":access_token,
                                                @"id":postId,
                                                };
                
                [manager PUT:URL_SERVER_API(API_REPORT_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    if ([Common validateResponse:responseObject]) {
                        
                        NSString* successMsg = responseObject[@"data"][@"message"];
                        if (!successMsg || successMsg.length == 0) {
                            successMsg = @"Post was reported!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:successMsg];
                        
                        //[Common showAlertView:APP_NAME message:successMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                        
                    } else {
                        
                        NSString* errorMsg = responseObject[@"data"][@"message"];
                        if (!errorMsg || errorMsg.length == 0) {
                            errorMsg = @"There was an issue while report this post!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                        
                        //[Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    //completion(NO,nil);
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while report this post!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while report this post!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];
            }
                break;
                
            case AlertHidePostTag:
            {
                //=====Hide a post=====
                
                NSString *postId = _postsList[activeIndexPath.section][@"id"];
                
                if (!postId) {
                    return;
                }
                
                [Common showNetworkActivityIndicator];
                
                AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                NSDictionary *request_param = @{@"access_token":access_token,
                                                @"id":postId,
                                                };
                
                [manager PUT:URL_SERVER_API(API_HIDE_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    if ([Common validateResponse:responseObject]) {
                        
                        totalPostInCurrentRegion--;
                        paging_offset--;
                        
                        [_tableView beginUpdates];
                        [_postsList removeObjectAtIndex:activeIndexPath.section];
                        
                        NSIndexSet *deleteSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(activeIndexPath.section, 1)];
                        [_tableView deleteSections:deleteSection withRowAnimation:UITableViewRowAnimationFade];
                        //[_tableView deleteRowsAtIndexPaths:@[activeIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                        
                        [_cellSizeManager invalidateCellSizeCache];
                        [_tableView endUpdates];
                        
                        
                        NSString* successMsg = responseObject[@"data"][@"message"];
                        if (!successMsg || successMsg.length == 0) {
                            successMsg = @"Post was reported!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:successMsg];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:POST_HIDDEN_DELETED_NOTIFICATION object:nil];
                        
                    } else {
                        
                        NSString* errorMsg = responseObject[@"data"][@"message"];
                        if (!errorMsg || errorMsg.length == 0) {
                            errorMsg = @"There was an issue while hide this post!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                        
                        //[Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                        
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    //completion(NO,nil);
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while hide this post!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while hide this post!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];

            }
                break;
            case AlertBlockUserTag:
            {
                //=====Block a post=====
                
                NSDictionary *post_author = _postsList[activeIndexPath.section][@"user"];
                
                NSString *blocked_userId = post_author[@"id"];
                
                if (!blocked_userId) {
                    return;
                }
                
                [Common showNetworkActivityIndicator];
                
                AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                NSDictionary *request_param = @{@"access_token":access_token,
                                                @"id":blocked_userId,
                                                };
                
                [manager PUT:URL_SERVER_API(API_BLOCK_USER(blocked_userId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    if ([Common validateResponse:responseObject]) {
                        
                        //Sync block user to Parse
                        
                        NSString *blockUserEmail = post_author[@"email"];
                        
                        if (blockUserEmail) {
                            
                            PFQuery *query = [PFUser query];
                            [query whereKey:@"emailCopy" equalTo:blockUserEmail];
                            [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
                                
                                PFUser *user2 = (PFUser *)object;
                                
                                if (!user2) {
                                    
                                    [Common hideLoadingViewGlobal];
                                    
                                } else {
                                    
                                    //===The find succeeded.
                                    
                                    [PAPUtility blockUserEventually:user2 block:^(BOOL succeeded, NSError *error) {
                                        if (!error) {
                                            
                                        } else {
                                            
                                        }
                                    }];
                                }
                            }];
                        }
                        
                        
                        //  Call Function to delete user's posts
                        
                        [self removeBlockedUserPost:blocked_userId email:nil];
                        
                        //  Show result message to user
                        
                        NSString* successMsg = responseObject[@"data"][@"message"];
                        if (!successMsg || successMsg.length == 0) {
                            successMsg = @"User was blocked!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:successMsg];
                        
                        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                        NSDictionary *userInfo = @{ @"blockedUserId": blocked_userId };
                        [notificationCenter postNotificationName:kUserBlockedPersonNotification object:nil userInfo:userInfo];
                        [notificationCenter postNotificationName:kDecreaseUsersCountNotification object:nil];
                        
                        //[Common showAlertView:APP_NAME message:successMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    } else {
                        
                        NSString* errorMsg = responseObject[@"data"][@"message"];
                        if (!errorMsg || errorMsg.length == 0) {
                            errorMsg = @"There was an issue while block this user!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                        
                        //[Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    }
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    //completion(NO,nil);
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while block this user!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while block this user!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];

            }
                break;
            default:
                break;
        }
    }
}


@end
