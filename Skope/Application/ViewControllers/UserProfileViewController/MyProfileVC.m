//
//  MyProfileVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "MyProfileVC.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ISDiskCache/ISDiskCache.h>
#import "images.h"
#import "Define.h"
#import "MyProfileInfoCell.h"
#import "ProfilePostCell.h"
#import "ButtonShowImageSlide.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIViewController+IsVisible.h"
#import "UITableView+ReloadData.h"
#import "SVModalWebViewController.h"

#import "BLKDelegateSplitter.h"
#import "SquareCashStyleBehaviorDefiner.h"

#import "UIView+RoundedCorners.h"
#import "MyProfileInfoHeaderView.h"
#import "ProfilePostCell.h"
#import "CommentTableViewCell.h"
#import "ActivityCell.h"
#import "ProfilePostCellLastSectionNoComment.h"
#import "CommentTableViewCellLastWithoutLoadMore.h"
#import "ShowMoreCommentTableViewCell.h"
#import "ProfileVC.h"
#import "MainViewController.h"
#import "SinglePostVC.h"

#define AlertDeletePostTag      55

#define COUNT_START_MPF_COMMENTS        3
#define ShowMoreButtonHeight            40.0

@interface MyProfileVC () <UINavigationControllerDelegate,PHFComposeBarViewDelegate, PostCellDelegate, CommentCellDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UIImagePickerControllerDelegate, MWPhotoBrowserDelegate, PostCellDelegate,ShowMoreCommentCellDelegate, ActivityCellDelegate, MyProfileInfoHeaderViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIPopoverPresentationControllerDelegate>
{
    NSInteger addCommentAtCellIndexPath;
    NSInteger paging_offset;
    NSInteger totalPostInCurrentRegion;
    NSIndexPath       *activeIndexPath;
    
    NSInteger activity_paging_offset;
    NSInteger totalActivity;
    NSInteger newActivityCount;
    BOOL      activitySelected;
    
    BOOL        activityTabActive;
    CGPoint    lastActivityContentOffset;
    CGPoint    lastMyPostContentOffset;
}

@property (nonatomic, strong) NSMutableArray    *selections;
@property (nonatomic, strong) NSMutableArray    *photos;
@property (nonatomic, strong) NSMutableArray    *thumbs;
@property (nonatomic, strong) NSMutableArray    *postsList;
@property (nonatomic, strong) NSMutableArray    *activityList;

@property (nonatomic, strong) PHFComposeBarView *composeBarView;
@property (nonatomic, strong) UIView            *container;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;

@property (nonatomic, strong) NSString          *strNameTemp;

@property (nonatomic, strong) ProfilePostCell *prototypeCellNormal;
@property (nonatomic, strong) ProfilePostCell *prototypeCellLastNoComment;
@property (nonatomic, strong) RZCellSizeManager *cellSizeManager;

@property (nonatomic, strong) CommentTableViewCell *commentprototypeCellNormal;
@property (nonatomic, strong) CommentTableViewCell *commentprototypeCellLastNoComment;
@property (nonatomic, strong) RZCellSizeManager *commentcellSizeManager;

@property (nonatomic, strong) MyProfileInfoHeaderView *infoBarView;
@property (nonatomic, strong) BLKDelegateSplitter *delegateSplitter;

- (IBAction)actionBack:(id)sender;
- (IBAction)actionLogout:(id)sender;

@end

@implementation MyProfileVC

static NSString * const OtherPeopleProfileCellReuseIdentifier = @"OtherPeopleProfileCell_Identifier_XIB";
static NSString * const LoadingCellReuseIdentifier = @"LoadingCell_Identifier";
static NSString * const ProfilePostCellReuseIdentifier = @"ProfilePostCell_Identifier";
static NSString * const ProfilePostCellLastSectionNoCommentIdentifier = @"ProfilePostCellLastSectionNoComment_Identifier";
static NSString * const CommentCellReuseIdentifier = @"CommentTableViewCell_Identifier";
static NSString * const ActivityCellReuseIdentifier = @"ActivityTableViewCell_Identifier";
static NSString * const CommentCellLastWithoutLoadMoreReuseIdentifier = @"CommentTableViewCellLastWithoutLoadMore_Identifier";
static NSString * const ShowMoreCellReuseIdentifier = @"ShowMoreCommentTableViewCell_Identifier";


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        _postsList = [[NSMutableArray alloc] init];
        _activityList = [[NSMutableArray alloc] init];

        addCommentAtCellIndexPath = -1;
        
        paging_offset = 0;
        
        totalPostInCurrentRegion = 0;
        
        if ([[UserDefault currentUser] isLoggedIn]) {
            
            //  [_postsList addObject:self.userProfileInfo];
            [_postsList addObject:@"jummy"];
            [_activityList addObject:@"jummy"];
            [_tableView reloadData:YES completion:^(BOOL finished) {
            }];
            
            if (!isloading) {
                
                isloading = YES;
                
                paging_offset = 0;
                
                totalPostInCurrentRegion = 0;

                [self getPostOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_POST];
            }
            
            if (!isActivityloading) {
                
                isActivityloading = YES;
                
                activity_paging_offset = 0;
                
                totalActivity = 0;
                
                [self getActivityOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_ACVITITY];
            }
            
        } else {
            
            __weak __typeof(self)weakSelf = self;
            typeof(self) selfBlock = weakSelf;
            
            [AppDelegate getCurrentUserProfileInfoFromWebServiceWithCompletion:^(BOOL success, id response) {
                
                [Common hideLoadingViewGlobal];
                
                if (success && response) {
                    
                    NSDictionary *userProfile = response[@"data"][@"user"];
                    
                    [UserDefault setUser:userProfile];

                    //[_postsList addObject:self.userProfileInfo];
                    [_postsList addObject:@"jummy"];
                    [_activityList addObject:@"jummy"];
                    [_tableView reloadData:YES completion:^(BOOL finished) {
                        //
                    }];
                    
                    if (!isloading) {
                        
                        isloading = YES;
                        
                        paging_offset = 0;
                        
                        totalPostInCurrentRegion = 0;
                        
                        [selfBlock getPostOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_POST];
                    }
                    
                    
                    if (!isActivityloading) {
                        
                        isActivityloading = YES;
                        
                        activity_paging_offset = 0;
                        
                        totalActivity = 0;
                        
                        [self getActivityOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_ACVITITY];
                    }
                    
                } else {
                    
                    NSString *errorMsg = [Common errorMessageFromResponseObject:response];
                    if (errorMsg) {
                        [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                    }
                }
                
            }];
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _postsList = [[NSMutableArray alloc] init];
        _activityList = [[NSMutableArray alloc] init];
        
        addCommentAtCellIndexPath = -1;
        
        paging_offset = 0;
        
        totalPostInCurrentRegion = 0;
        
        if ([[UserDefault currentUser] isLoggedIn]) {
            
            //[_postsList addObject:self.userProfileInfo];
            [_postsList addObject:@"jummy"];
            [_activityList addObject:@"jummy"];
            [_tableView reloadData:YES completion:^(BOOL finished) {
            }];
            
            if (!isloading) {
                
                isloading = YES;
                
                paging_offset = 0;
                
                totalPostInCurrentRegion = 0;
                
                [self getPostOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_POST];
            }
            
            
            if (!isActivityloading) {
                
                isActivityloading = YES;
                
                activity_paging_offset = 0;
                
                totalActivity = 0;
                
                [self getActivityOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_ACVITITY];
            }
            
        } else {
            
            __weak __typeof(self)weakSelf = self;
            typeof(self) selfBlock = weakSelf;
            
            [AppDelegate getCurrentUserProfileInfoFromWebServiceWithCompletion:^(BOOL success, id response) {
                
                [Common hideLoadingViewGlobal];
                
                if (success && response) {
                    
                    NSDictionary *userProfile = response[@"data"][@"user"];
                    
                    [UserDefault setUser:userProfile];
                    
                    //[_postsList addObject:self.userProfileInfo];
                    [_postsList addObject:@"jummy"];
                    [_activityList addObject:@"jummy"];
                    [_tableView reloadData:YES completion:^(BOOL finished) {
                        //
                    }];
                    
                    if (!isloading) {
                        
                        isloading = YES;
                        
                        paging_offset = 0;
                        
                        totalPostInCurrentRegion = 0;
                        
                        [selfBlock getPostOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_POST];
                    }
                    
                    
                    if (!isActivityloading) {
                        
                        isActivityloading = YES;
                        
                        activity_paging_offset = 0;
                        
                        totalActivity = 0;
                        
                        [self getActivityOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_ACVITITY];
                    }
                    
                } else {
                    
                    NSString *errorMsg = [Common errorMessageFromResponseObject:response];
                    if (errorMsg) {
                        [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                    }
                }
                
            }];
        }
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //  Style for NavigationBar
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    [self prepareForSubViews];
}

- (void)imageAnimation
{
    CATransition *transition = [CATransition animation];
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.duration = 1.0f;
    transition.type = @"rippleEffect";
    
    [[self.infoBarView.imgView_UserAvatar layer] addAnimation:transition forKey:@"rippleEffect"];
}


- (void)prepareForSubViews {
    
    //  Back button
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back_ul"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack:)];
    backButton.tintColor = APP_COMMON_RED_COLOR;
    self.navigationItem.rightBarButtonItem = backButton;
    
    
    //  Logout button
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_logout"] style:UIBarButtonItemStylePlain target:self action:@selector(actionLogout:)];
    logoutButton.tintColor = APP_COMMON_BLUE_COLOR;
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    
    // Register NIB cell for tableView
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:CommentCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCellLastWithoutLoadMore" bundle:nil] forCellReuseIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActivityCell" bundle:nil] forCellReuseIdentifier:ActivityCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfilePostCell" bundle:nil] forCellReuseIdentifier:ProfilePostCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileInfoCell" bundle:nil] forCellReuseIdentifier:OtherPeopleProfileCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfilePostCellLastSectionNoComment" bundle:nil] forCellReuseIdentifier:ProfilePostCellLastSectionNoCommentIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:LoadingCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShowMoreCommentTableViewCell" bundle:nil] forCellReuseIdentifier:ShowMoreCellReuseIdentifier];
    
    
    // Init size manager
    
    self.cellSizeManager = [[RZCellSizeManager alloc] init];
    
    [self.cellSizeManager registerCellClassName:NSStringFromClass([ProfilePostCell class]) withNibNamed:@"ProfilePostCell" forReuseIdentifier:ProfilePostCellReuseIdentifier withHeightBlock:^CGFloat(ProfilePostCell *cell, NSMutableDictionary *postInfo) {
        
        if (!self.prototypeCellNormal)
        {
            self.prototypeCellNormal = [self.tableView dequeueReusableCellWithIdentifier:ProfilePostCellReuseIdentifier];
        }
        [self.prototypeCellNormal fillDataToCellWithPostInfo:postInfo tableViewWidth:_tableView.bounds.size.width];
        [self.prototypeCellNormal setNeedsLayout];
        [self.prototypeCellNormal layoutIfNeeded];
        CGSize size = [self.prototypeCellNormal.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height;
        
    }];
    
    [self.cellSizeManager registerCellClassName:NSStringFromClass([ProfilePostCellLastSectionNoComment class]) withNibNamed:@"ProfilePostCellLastSectionNoComment" forReuseIdentifier:ProfilePostCellLastSectionNoCommentIdentifier withHeightBlock:^CGFloat(ProfilePostCellLastSectionNoComment *cell, NSMutableDictionary *postInfo) {
        
        if (!self.prototypeCellLastNoComment)
        {
            self.prototypeCellLastNoComment = [self.tableView dequeueReusableCellWithIdentifier:ProfilePostCellLastSectionNoCommentIdentifier];
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
    
    _container = [self container];
    [_container addSubview:[self composeBarView]];
    [self.view addSubview:_container];
    _container.hidden = YES;
    
    
    // Setup header View
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.infoBarView = [[MyProfileInfoHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 100.0)];
        self.infoBarView.delegate = self;
        self.infoBarView.tf_UserName.delegate = self;
        self.infoBarView.tf_UserName.userInteractionEnabled = NO;
        self.infoBarView.backgroundColor = APP_COMMON_LIGHT_GRAY_BACKGROUND_COLOR;
        self.infoBarView.touchBeganView = self.view;
        
        
        SquareCashStyleBehaviorDefiner *behaviorDefiner = [[SquareCashStyleBehaviorDefiner alloc] init];
        //[behaviorDefiner addSnappingPositionProgress:0.0 forProgressRangeStart:0.0 end:0.5];
        //[behaviorDefiner addSnappingPositionProgress:1.0 forProgressRangeStart:0.5 end:1.0];
        behaviorDefiner.snappingEnabled = YES;
        behaviorDefiner.elasticMaximumHeightAtTop = YES;
        self.infoBarView.behaviorDefiner = behaviorDefiner;
        
        self.delegateSplitter = [[BLKDelegateSplitter alloc] initWithFirstDelegate:behaviorDefiner secondDelegate:self];
        self.tableView.delegate = (id<UITableViewDelegate>)self.delegateSplitter;
        [self.containerView addSubview:self.infoBarView];

        self.tableView.contentInset = UIEdgeInsetsMake(self.infoBarView.maximumBarHeight, 0.0, 0.0, 0.0);
        
        lastActivityContentOffset = self.tableView.contentOffset;
        lastMyPostContentOffset = self.tableView.contentOffset;
        
        // Fill Data to headerBarView
        
        [self.infoBarView.imgView_UserAvatar sd_setImageWithURL:[NSURL URLWithString:[UserDefault currentUser].avatar] placeholderImage:USER_DEFAULT_AVATAR];
        self.infoBarView.tf_UserName.delegate = self;
        
        NSString *strName = [NSString stringWithFormat:@"%@", [UserDefault currentUser].name];
        
        if (![strName isEqual:@"(null)"]) {
            self.infoBarView.tf_UserName.text = strName;
            _strNameTemp = strName;
        }
        
        [self.infoBarView.btn_EditUserName addTarget:self action:@selector(actionEditName:) forControlEvents:UIControlEventTouchUpInside];
        [self.infoBarView.btn_ChangeUserAvatar addTarget:self action:@selector(actionChangeAvatar:) forControlEvents:UIControlEventTouchUpInside];
        
    });
    
    
    
    //  For Badget number
    
    NSUInteger count = [[UserDefault currentUser].commentBagedNumber integerValue];
    newActivityCount = count;
   
    
    
    // Notifications
    
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
                                             selector:@selector(loadNewestActivityDataWhenHaveNewNotification)
                                                 name:NEW_COMMENT_LIKE_NOTIFICATION
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self imageAnimation];
    });
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
    
    if (activitySelected) {
        
        //  Reset new like + new comment when user click Activity tab
        
        [self appActiveRefreshBagedNumber];
    }
    
}


- (void)reloadDataWhenHaveInternetConnection {
    
    if (_postsList.count <= 1 && !isloading) {
        isloading = YES;
       [self getPostOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_POST];
    }
    
    if (_activityList.count <= 0 && !isActivityloading) {
        isActivityloading = YES;
        [self getActivityOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_ACVITITY];
    }
    
}



- (void)loadNewestActivityDataWhenHaveNewNotification {
    
    if ([self isVisible]) {
        
        //  Reload activity data
        
        NSUInteger count = [[UserDefault currentUser].commentBagedNumber integerValue];
        
        newActivityCount = count;
        
        isActivityloading = YES;
        
        [self getNewestActivityOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_ACVITITY];
        
        //  Update badget view number
        
        self.infoBarView.activity_badgeView.badgeText = [UserDefault currentUser].commentBagedNumber;
        [self.infoBarView.activity_badgeView setHidden:[[UserDefault currentUser].commentBagedNumber integerValue] == 0];
        
    }
}


- (void)appActiveRefreshBagedNumber {
    
    if ([self isVisible] && activityTabActive) {
        [self refreshBagedNumber];
    }
}

- (void)refreshBagedNumber {

    [[UserDefault currentUser] setCommentBagedNumber:@"0"];
    [UserDefault performCache];
        
    [AppDelegate resetNotificationBagedNumberToServerWithType:kNotificationNewComment];
    [AppDelegate resetNotificationBagedNumberToServerWithType:kNotificationNewLike];
    [AppDelegate updateAppIconBadgedNumber];

}

#pragma mark - WEBSERVICE FUNTIONS

- (void) fetchMoreCommentForPost:(NSMutableDictionary*)postInfo withLimit:(NSUInteger)page_limit forCell:(ShowMoreCommentTableViewCell*)cell//insection:(NSUInteger)section
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

    NSMutableDictionary* request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          offset,@"offset",
                                          limit,@"limit",
                                          nil];
    
    
    NSArray* allComments = (NSArray*)postInfo[@"comment"][@"items"];
    NSDictionary *firstComment = ([allComments count] > 0 ? [allComments firstObject] : nil);
    
    if (firstComment) {
        //NSString* since = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] + 1];    // + 1 to include first post
        //[request_param setObject:since forKey:@"since"];
        
        NSString* after = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] - 1];    // + 1 to include first post
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
                    
                    postInfo[@"comment"][@"total"] = object[@"data"][@"total"];
                    
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

                        if (success &&  newObjects.count > 0) {
                            
                            [_tableView beginUpdates];
                            
                            NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
                            
                            ProfilePostCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
                            [cell.lbl_commentCount setText:[NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalComments]];
                            
                            if (totalComments <= comments.count + newObjects.count) {
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

- (void) getActivityOfUser:(NSString *)userId limit:(NSUInteger) para_page_limit {
    
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSMutableDictionary* request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [UserDefault currentUser].server_access_token,@"access_token",
                                          userId,@"id",
                                          @(activity_paging_offset),@"offset",
                                          @(para_page_limit),@"limit",
                                          nil];
    
    NSDictionary *firstActivity = _activityList.count>1?_activityList.firstObject:nil;
    
    if (firstActivity) {
        NSString* after = firstActivity[@"created_at"];
        [request_param setObject:after forKey:@"since"];
    }
    
    [manager GET:URL_SERVER_API(API_GET_ACTIVITIES_OF_USER) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([Common validateResponse:responseObject]) {
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSMutableArray *newObjects = [NSMutableArray new];
                NSMutableArray *newIndexPaths = [NSMutableArray new];
                
                NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
                    
                    if (success && object[@"data"][@"items"] != nil) {
                        
                        if (object[@"data"][@"total"] != nil) {
                            totalActivity = [object[@"data"][@"total"] intValue];
                        }
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                        
                        [object[@"data"][@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            [newIndexPaths addObject:[NSIndexPath indexPathForRow:(_activityList.count-2 + idx + 1) inSection:0]];
                            
                        }];
                        
                    }
                }];
                
                [block setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        if (success && newObjects.count > 0) {
                            
                            [_activityList insertObjects:newObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_activityList.count - 1, newObjects.count)]];
                            activity_paging_offset+=newObjects.count;
                            
                            if (activityTabActive) {
                                
                                [_tableView beginUpdates];

                                [_tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                                
                                [_tableView endUpdates];
                            }
                        }
                        
                        isActivityloading = NO;
                        
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:block];

            }];
            
        } else {
            
            isActivityloading = NO;
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        isActivityloading = NO;
        
    }];
    
}

- (void) getNewestActivityOfUser:(NSString *)userId limit:(NSUInteger) para_page_limit {
    
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSMutableDictionary *request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [UserDefault currentUser].server_access_token,@"access_token",
                                          userId,@"id",
                                          @(0),@"offset",
                                          @(para_page_limit),@"limit", nil];
    
    NSDictionary *firstActivity = _activityList.count>1?_activityList.firstObject:nil;
    
    if (firstActivity) {
        NSString* after = firstActivity[@"created_at"];
        [request_param setObject:after forKey:@"after"];
    }
    
    [manager GET:URL_SERVER_API(API_GET_ACTIVITIES_OF_USER) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([Common validateResponse:responseObject]) {
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSMutableArray *newObjects = [NSMutableArray new];
                NSMutableArray *newIndexPaths = [NSMutableArray new];
                
                NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
                    
                    if (success && object[@"data"][@"items"] != nil) {
                        
                        if (object[@"data"][@"total"] != nil) {
                            totalActivity += [object[@"data"][@"total"] intValue];
                        }
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                        
                        [object[@"data"][@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            [newIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                            
                        }];
                        
                    }
                }];
                
                [block setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        if (success && newObjects.count > 0) {
                            
                            [_activityList insertObjects:newObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newObjects.count)]];
                            activity_paging_offset+=newObjects.count;
                            
                            if (activityTabActive) {
                                
                                [_tableView beginUpdates];
                                
                                [_tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                                
                                [_tableView endUpdates];
                            }
                        }
                        
                        isActivityloading = NO;
                        
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:block];
                
            }];
            
        } else {
            
            isActivityloading = NO;
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        isActivityloading = NO;
        
    }];
    
}

- (void) getPostOfUser:(NSString *)userId limit:(NSUInteger) para_page_limit {
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{@"access_token":[UserDefault currentUser].server_access_token,
                                            @"id":userId,
                                            @"offset":@(paging_offset),
                                            @"limit":@(para_page_limit),
                                            };
    
    [manager GET:URL_SERVER_API(API_GET_POST_OF_USER(userId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([Common validateResponse:responseObject]) {
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSMutableArray *newObjects = [NSMutableArray new];
                NSMutableArray *newIndexPaths = [NSMutableArray new];
                
                NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
                    
                    if (success && object[@"data"][@"items"] != nil) {
                        
                        if (object[@"data"][@"total"] != nil) {
                            totalPostInCurrentRegion = [object[@"data"][@"total"] intValue];
                        }

                        [object[@"data"][@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            obj[@"show_full_content"] = @"false";
                            
                            [newIndexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:(_postsList.count-2 + idx + 1)]];
                            
                        }];
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];

                    }
                }];
                
                [block setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        if (success && newObjects.count > 0) {
                            
                            [_postsList insertObjects:newObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_postsList.count - 1, newObjects.count)]];
                            paging_offset+=newObjects.count;
                            
                            if (!activityTabActive) {
                                
                                [_tableView beginUpdates];
                                NSIndexPath *firstIndex = newIndexPaths.firstObject;
                                NSIndexSet *newSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstIndex.section, newIndexPaths.count)];
                                [_tableView insertSections:newSection withRowAnimation:UITableViewRowAnimationFade];
                                
                                [_tableView endUpdates];
                            }
                        }
                        
                        isloading = NO;
                        
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:block];
            }];
            
        } else {
            
            isloading = NO;
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        isloading = NO;
        
    }];

}

- (void) callWSAddComment:(NSMutableDictionary *)postInfo andTextCm:(NSString *) strComment cellIndexPath:(NSIndexPath *)indexPath {
    
    
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
    
    NSMutableDictionary* request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          offset,@"offset",
                                          limit,@"limit",
                                          nil];
    
    
    NSArray* allComments = (NSArray*)postInfo[@"comment"][@"items"];
    NSDictionary *firstComment = ([allComments count] > 0 ? [allComments firstObject] : nil);
    
    if (firstComment) {
        //NSString* since = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] + 1];    // + 1 to include first post
        //[request_param setObject:since forKey:@"since"];
        
        NSString* after = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] - 1];    // + 1 to include first post
        [request_param setObject:after forKey:@"after"];
    }
    
    [manager GET:URL_SERVER_API(API_COMMENT_FOR_A_POST(postID)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
            NSMutableArray *newObjects = [NSMutableArray new];
            NSMutableArray *newIndexPaths = [NSMutableArray new];
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSBlockOperation *blockoperation = [NSBlockOperation blockOperationWithBlock:^{
                    
                    postInfo[@"comment"][@"total"] = object[@"data"][@"total"];
                    
                    if (success &&  object[@"data"][@"items"] != nil) {
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                        
                        //  Add local comment
                        
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
                            
                            ProfilePostCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
                            [cell.lbl_commentCount setText:[NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalComments]];
                            
                            if (totalComments <= comments.count + newObjects.count && [_tableView numberOfRowsInSection:indexPath.section] > comments.count + 1 ) {
                                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:comments.count+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                            }
                            
                            [comments addObjectsFromArray:newObjects];
                            
                            [_tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                            
                            [_tableView endUpdates];
                            
                        } else {
                            
                            //Have no comment return
                            
                        }
                        
                        
                        
                        //  Reload firstCell and last cell
                        
                        NSIndexPath *postCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                        ProfilePostCell *cell = [self.tableView cellForRowAtIndexPath:postCellIndexPath];
                        cell.lbl_commentCount.text = [NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalComments];
                        NSIndexPath *lastCell = [NSIndexPath indexPathForRow:comments.count-1 inSection:indexPath.section];
                        [_tableView reloadRowsAtIndexPaths:@[lastCell] withRowAnimation:UITableViewRowAnimationFade];
                        
                        
                        // Call API to add comment to server
                        
                        [Common showNetworkActivityIndicator];
                        
                        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                        
                        NSDictionary *request_param = @{@"access_token":[UserDefault currentUser].server_access_token,
                                                        @"content":strComment,
                                                        @"id":postInfo[@"id"],
                                                        };
                        
                        [manager POST:URL_SERVER_API(API_COMMENT_FOR_A_POST(postInfo[@"id"])) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            [Common hideNetworkActivityIndicator];
                            
                            if ([Common validateResponse:responseObject]) {
                                
                                [postInfo[@"comment"][@"items"] replaceObjectAtIndex:comments.count-1 withObject:responseObject[@"data"][@"comment"]];
                                
                            } else {
                                
                                NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
                                if (errorMsg) {
                                    [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                                }
                            }
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            
                            [Common hideLoadingViewGlobal];
                            
                        }];

                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:blockoperation];
                
            }];
            
        } else {
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            NSLog(@"Error: %@",errorMsg);
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideNetworkActivityIndicator];
        
    }];

    
    
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
    
    
    
    
    // Update to tableView
    
    [_tableView beginUpdates];
    
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    if (totalCm == COUNT_START_MPF_COMMENTS + 1) {
        
        [postInfo[@"comment"][@"items"] removeLastObject];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:totalCm inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:totalCm-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    if (totalCm == 1) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [_tableView endUpdates];
    
    
    // Call API to add comment to server
    
    [Common showNetworkActivityIndicator];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{@"access_token":[UserDefault currentUser].server_access_token,
                                    @"content":strComment,
                                    @"id":postInfo[@"id"],
                                            };

    [manager POST:URL_SERVER_API(API_COMMENT_FOR_A_POST(postInfo[@"id"])) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];

        if ([Common validateResponse:responseObject]) {

            [postInfo[@"comment"][@"items"] replaceObjectAtIndex:0 withObject:responseObject[@"data"][@"comment"]];
            
        } else {
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        
    }];
     
    */
}

- (void) addVoteActionForPost:(NSMutableDictionary *)postInfo andLikeDislike:(NSString *) strLike andIndexPath:(NSIndexPath *)indexPath {
    
    [Common showNetworkActivityIndicator];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{@"access_token":[UserDefault currentUser].server_access_token,
                                    @"type":strLike,
                                    @"id":postInfo[@"id"],
                                    };
    
    [manager POST:URL_SERVER_API(API_LIKE_DISLIKE_POST(postInfo[@"id"])) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];
        [Common hideLoadingViewGlobal];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideNetworkActivityIndicator];
        [Common hideLoadingViewGlobal];
        
    }];
}

- (void) getCommentsForPost:(NSMutableDictionary *)postInfo offset:(NSUInteger)offset limit:(NSUInteger)limit {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *postId = postInfo[@"id"];
    NSString *str_offset = [NSString stringWithFormat:@"%lu",(unsigned long)offset];
    NSString *str_limit = [NSString stringWithFormat:@"%lu",(unsigned long)limit];
    
    if (!access_token || access_token.length == 0 || !postId || !offset || !str_limit) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{@"access_token":access_token,
                                    @"id":postId,
                                    @"offet":str_offset,
                                    @"limit":str_limit,
                                    };
    
    [manager GET:URL_SERVER_API(API_COMMENT_FOR_A_POST(postInfo[@"id"])) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];
        [Common hideLoadingViewGlobal];
        
        if ([Common validateResponse:responseObject]) {
            
        } else {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideNetworkActivityIndicator];
        [Common hideLoadingViewGlobal];
        
    }];
}

- (void) changeProfileUserName:(NSString *)newProfileName {
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{@"access_token":[UserDefault currentUser].server_access_token,
                                            @"name":newProfileName,
                                            };
    
    //===update name to parse.com
    
    PFUser *user = [PFUser currentUser];
    user[PF_USER_FULLNAME] = newProfileName;
    user[PF_USER_FULLNAME_LOWER] = [newProfileName lowercaseString];
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
        } else {
            // Show the errorString somewhere and let the user try again.
        }
    }];
    
    [manager PUT:URL_SERVER_API(API_CHANGE_NAME_MY_PROFILE) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideLoadingViewGlobal];
        
        if ([Common validateResponse:responseObject]) {
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                if (success) {
                    
                    NSDictionary *userProfile = object[@"data"][@"user"];

                    [UserDefault setUser:userProfile];
                }
            }];
            
        } else {
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        
    }];
}

- (void) uploadNewUserAvatar:(UIImage *)imgData{
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    
    if (!access_token || access_token.length == 0 ) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    __strong __typeof__(self) strongSelf = weakSelf;
    
    [self.infoBarView.imgView_UserAvatar setImage:imgData];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSData *mediaData;
    
    NSString *strTypeMedia = @"image/jpeg";
    NSString *strNameMedia = @"photo.jpg";
    
    if ([[imgData class] isSubclassOfClass:[UIImage class]]) {
        mediaData = UIImageJPEGRepresentation((UIImage *)imgData,kImageEncodeQualityForUpload);
    } else return;
    
    NSDictionary *params = @{@"access_token":access_token};
    
    [Common showNetworkActivityIndicator];
    
    [manager POST:URL_SERVER_API(API_CHANGE_AVATAR_MY_PROFILE) parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:mediaData name:@"file" fileName:strNameMedia mimeType:strTypeMedia];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];
        
        [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
            
            if (success) {
                
                NSDictionary *userProfile = object[@"data"][@"user"];

                [UserDefault setUser:userProfile];
                
                [strongSelf uploadAvatarToParse];
                
            }
            else
            {
                NSString* errorMsg = [Common errorMessageFromResponseObject:responseObject];
                if (errorMsg) {
                    [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                }
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"urlAvatar"]) {
        
        [self uploadAvatarToParse];
    }
    
}

- (void) uploadAvatarToParse {
    
    // upload avatar to parse.com
    
    NSString *link = [UserDefault currentUser].avatar;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         UIImage *image = (UIImage *)responseObject;

         UIImage *picture = image;//[[image scaleToAspectFillSize:CGSizeMake(280.0, 280.0)] cropToSize:CGSizeMake(280.0, 280.0) usingMode:XNYCropModeCenter];//ResizeImage(image, 280, 280);
         UIImage *thumbnail = [picture scaleToAspectFillSize:CGSizeMake(140.0, 140.0)];//ResizeImage(image, 60, 60);

         PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture,kImageEncodeQualityForUpload)];
         [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) {
                  NSLog(@"Network error.");
              }
          }];

         PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail,kImageEncodeQualityForUpload)];
         [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) {
                  NSLog(@"Network error.");
              }
          }];

         PFUser *user = [PFUser currentUser];
         
         user[PF_USER_PICTURE] = filePicture;
         user[PF_USER_THUMBNAIL] = fileThumbnail;
         [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error == nil)
              {
                  //NSLog(@"Upload avatar to parse.com");
              }
              else
              {
                  //NSLog(@"%@",error.userInfo[@"error"]);
              }
          }];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //NSLog(@"Failed to fetch avatar profile picture.");
     }];

    [[NSOperationQueue mainQueue] addOperation:operation];
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
    [self callWSAddComment:postInfo andTextCm:composeBarView.textView.text cellIndexPath:[NSIndexPath indexPathForRow:1 inSection:addCommentAtCellIndexPath]];
    
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

#pragma mark - CREATE VIEWS METHODS

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
        _composeBarView.buttonTintColor = COLOR_BUTTON_POST_SEND;
        [_composeBarView.textView setFont:FONT_TEXT_COMPOSE_BAR];
        [_composeBarView setMaxCharCount:160];
        [_composeBarView setMaxLinesCount:5];
        [_composeBarView setMaxHeight:120];
        [_composeBarView setButtonTitle:@"Post"];
        [_composeBarView setPlaceholder:@"Type something..."];
        [_composeBarView.button setTitleColor:COLOR_BUTTON_POST_SEND forState:UIControlStateDisabled];
        _composeBarView.maxCharCount = 0;
        [_composeBarView setDelegate:self];
        
    }
    
    return _composeBarView;
}

#pragma mark - TABLE DELEAGATE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (activityTabActive) {
        return 1;
    } else {
        return _postsList.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (activityTabActive) {
        
        return _activityList.count;
        
    } else {
        
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
                
            }
        }
        
        return 1;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (activityTabActive) {

        id object = [_activityList objectAtIndex:indexPath.row];
        
        if ((indexPath.row == [_activityList count] - 1) || [object isKindOfClass:[NSString class]]) {
            
            //  Jummy cell
            
            if (totalActivity <= [_activityList count] - 1) {
                
                return 0;
                
            } else {
                
                return ShowMoreButtonHeight;
                
            }
            
        } else {
        
            //  Normal Activity cell
            
            return kAcvitityCellHeight;
        }

        
    } else {
        
        id object = [_postsList objectAtIndex:indexPath.section];
        
        if ((indexPath.section == _postsList.count - 1) || [object isKindOfClass:[NSString class]]) {
            
            //===jummy cell
            
            if (totalPostInCurrentRegion <= _postsList.count - 1) {
                
                return 0;
                
            } else {
                
                return ShowMoreButtonHeight;
                
            }
            
        } else {
            
            NSDictionary* postInfo = [_postsList objectAtIndex:indexPath.section];
            
            NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
            
            if (indexPath.row == 0) {
                
                if (totalComments > 0) {
                    
                    CGFloat rowHeight = [self.cellSizeManager cellHeightForObject:postInfo indexPath:indexPath cellReuseIdentifier:ProfilePostCellReuseIdentifier];
                    return rowHeight;
                    
                } else {
                    
                    CGFloat rowHeight = [self.cellSizeManager cellHeightForObject:postInfo indexPath:indexPath cellReuseIdentifier:ProfilePostCellLastSectionNoCommentIdentifier];
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
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (activityTabActive) {
    
        //  Use Comment cell
        
        if (indexPath.row == _activityList.count - 1) {
            
            // Use Indicator Jummy cell
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellReuseIdentifier forIndexPath:indexPath];
            UIActivityIndicatorView *indicatorV = (UIActivityIndicatorView *)[cell viewWithTag:12];
            
            if (totalActivity > _activityList.count - 1) {
                [indicatorV startAnimating];
            } else {
                [indicatorV stopAnimating];
            }
            
            return cell;
            
        } else {
            
            NSMutableDictionary *activityInfo = [_activityList objectAtIndex:indexPath.row];
            
            ActivityCell *activityCell = [tableView dequeueReusableCellWithIdentifier:ActivityCellReuseIdentifier forIndexPath:indexPath];
            activityCell.isNewActivityCell = (indexPath.row < newActivityCount);
            activityCell.delegate = self;
            [activityCell fillActivityInfoToView:activityInfo];

            return activityCell;
        }
        
    } else {
    
        if (indexPath.section == _postsList.count - 1) {
            
            //  Use Indicator Jummy cell
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellReuseIdentifier forIndexPath:indexPath];
            UIActivityIndicatorView *indicatorV = (UIActivityIndicatorView *)[cell viewWithTag:12];
            
            if (totalPostInCurrentRegion > _postsList.count - 1) {
                [indicatorV startAnimating];
            } else {
                [indicatorV stopAnimating];
            }
            
            return cell;
            
        } else {
            
            NSMutableDictionary *postInfo = [_postsList objectAtIndex:indexPath.section];
            
            NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
            
            if (indexPath.row == 0) {
                
                //  Normal Post cell
                
                if (totalComments > 0) {
                    
                    ProfilePostCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfilePostCellReuseIdentifier forIndexPath:indexPath];
                    
                    cell.isOnMyProfileCell = YES;
                    
                    [cell configureCellDisplayWithPostInfo:postInfo tableViewWidth:tableView.bounds.size.width indexPath:indexPath nodeConstructionQueue:[Common sharedBackgroundOperationQueue]];//[[UIScreen mainScreen] bounds].size.width - 2*kCellContentLeftPadding - 16
                    
                    [cell setDelegate:self];
                    
                    return cell;
                    
                } else {
                    
                    ProfilePostCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfilePostCellLastSectionNoCommentIdentifier forIndexPath:indexPath];
                    
                    cell.isOnMyProfileCell = YES;
                    
                    [cell configureCellDisplayWithPostInfo:postInfo tableViewWidth:tableView.bounds.size.width indexPath:indexPath nodeConstructionQueue:[Common sharedBackgroundOperationQueue]];//[[UIScreen mainScreen] bounds].size.width - 2*kCellContentLeftPadding - 16
                    
                    [cell setDelegate:self];
                    return cell;
                }
                
            } else {
                
                //  Comment cell and Post last cell
                
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
                                
                                //  Normal Comment cell
                                
                                CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier forIndexPath:indexPath];
                                NSDictionary *commentInfo = comments[indexPath.row - 1];
                                [commentCell fillCommentInfoToView:commentInfo];
                                commentCell.delegate = self;
                                
                                return commentCell;
                                
                            }
                            
                        } else {
                            
                            if (indexPath.row == comments.count + 1) {
                                
                                //  Load more cell
                                
                                ShowMoreCommentTableViewCell *showmoreCell = [tableView dequeueReusableCellWithIdentifier:ShowMoreCellReuseIdentifier forIndexPath:indexPath];
                                showmoreCell.delegate = self;
                                
                                return showmoreCell;
                                
                            } else {
                                
                                //  Normal Comment cell
                                
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
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!activityTabActive && indexPath.section ==  _postsList.count - 2 && totalPostInCurrentRegion >= _postsList.count && !isloading) {
        isloading = YES;
        [self getPostOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_POST];
    }
    
    if (activityTabActive && indexPath.row ==  _activityList.count - 2 && totalActivity >= _activityList.count && !isActivityloading) {
        isActivityloading = YES;
        [self getActivityOfUser:[UserDefault currentUser].u_id limit:LIMIT_LIST_ACVITITY];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (activityTabActive) {
        
        NSDictionary *activityObj = [_activityList objectAtIndex:indexPath.row];
        NSString *postID = activityObj[@"object_id"];
        
        SinglePostVC *singlePostVC = [[SinglePostVC alloc] initWithNibName:@"SinglePostVC" bundle:nil];
        [singlePostVC setPostID:postID];
        
        [self.navigationController pushViewController:singlePostVC animated:YES];
        
    }
}

#pragma mark - SHOW MORE COMMENT CELL DELEGATE

- (void)ShowMoreCommentTableViewCell:(ShowMoreCommentTableViewCell*)cell didClickedSeeMoreCommentButton:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSMutableDictionary *postInfo = [_postsList objectAtIndex:indexPath.section];
    [self fetchMoreCommentForPost:postInfo withLimit:LIMIT_LIST_COMMENT forCell:cell];//insection:indexPath.section];
}


#pragma mark - UITEXTFIELD FROM infoBarView DELEGATE

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (self.infoBarView != nil) {
        
        _infoBarView.tf_UserName.userInteractionEnabled = NO;
        if (_infoBarView.tf_UserName.text.length > 0) {
            _strNameTemp = _infoBarView.tf_UserName.text;
            [self changeProfileUserName:_infoBarView.tf_UserName.text];
        } else {
            _infoBarView.tf_UserName.text = _strNameTemp;
        }
        [_infoBarView.tf_UserName resignFirstResponder];
    }
    return YES;
}

#pragma mark - ACTION ON POST CELL

- (void)PostCell:(MyProfileInfoCell*)cell didClickedReportButton:(id)sender {
    
    activeIndexPath = [_tableView indexPathForCell:cell];
    
    [Common showAlertView:APP_NAME message:@"Do you really want to delete this post?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertDeletePostTag];
}

- (void)PostCell:(ProfilePostCell *)cell didClickedShowFullPostContentButton:(id)sender {
    
    NSIndexPath *selectedIndexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:selectedIndexPath.section];
    
    if ([postInfo[@"show_full_content"] isEqualToString:@"false"]) {
        postInfo[@"show_full_content"] = @"true";
    } else {
        postInfo[@"show_full_content"] = @"false";
    }
    
    [self.cellSizeManager invalidateCellSizeAtIndexPath:selectedIndexPath];
    [_tableView reloadRowsAtIndexPaths:@[selectedIndexPath]
                      withRowAnimation:UITableViewRowAnimationFade];
    [cell.contentView updateConstraints];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
}

- (void)PostCell:(ProfilePostCell *)cell didClickedAddCommentButton:(id)sender {
    
    NSIndexPath *selectedIndexPath = [_tableView indexPathForCell:cell];

    addCommentAtCellIndexPath = selectedIndexPath.section;
    _composeBarView.textView.text = @"";
    _container.hidden = NO;
    [_composeBarView.textView becomeFirstResponder];
    [_composeBarView setUtilityButtonImage:nil];
    
}

- (void)PostCell:(ProfilePostCell *)cell didClickedLikePostButton:(id)sender {
    
    NSIndexPath *selectedIndexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:selectedIndexPath.section];
    
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
        
        [self addVoteActionForPost:postInfo andLikeDislike:@"like" andIndexPath:selectedIndexPath];
    }
}

- (void)PostCell:(ProfilePostCell *)cell didClickedDislikePostButton:(id)sender {

    NSIndexPath *selectedIndexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:selectedIndexPath.section];
    
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

        [self addVoteActionForPost:postInfo andLikeDislike:@"dislike" andIndexPath:selectedIndexPath];
    }
}

- (void)PostCell:(ProfilePostCell *)cell didClickedShowPostImageButton:(id)sender {
    
    ButtonShowImageSlide *button = (ButtonShowImageSlide *)sender;
    
    NSArray *arrMedia = [_postsList objectAtIndex:button.indexPathCell.section][@"media"];
    
    if ([arrMedia count] > 0 && [arrMedia objectAtIndex:(int)button.indexImageSelected]!=nil) {
        
        NSDictionary *objSelected = [arrMedia objectAtIndex:(int)button.indexImageSelected];
        if ([objSelected[@"type"] isEqualToString:@"video"]) {
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
            
            //  Choose array has only images
            
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
    
}

- (void)PostCell:(id)cell wantToOpenURL:(NSURL *)url {
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[url absoluteString]];
    [self presentViewController:webViewController animated:YES completion:NULL];
    
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
        
        __block UIViewController *parentVC = self.presentingViewController;
        
        if (parentVC) {
            [parentVC dismissViewControllerAnimated:NO completion:^{
                [parentVC presentViewController:myProfileVC animated:YES completion:nil];
            }];
        } else {
            [self presentViewController:myProfileVC animated:YES completion:nil];
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



#pragma mark - ACTION

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.infoBarView != nil) {
        _infoBarView.tf_UserName.userInteractionEnabled = NO;
        [_infoBarView.tf_UserName resignFirstResponder];
        _infoBarView.tf_UserName.text = _strNameTemp;
    }
}

- (IBAction)actionHideKeyboard:(id)sender {
    [_composeBarView resignFirstResponder];
    _container.hidden = YES;
}

- (IBAction)actionBack:(id)sender {
    
    if (activitySelected) {
        
        //  Reset new like + new comment when user click Activity tab
        
        [self refreshBagedNumber];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)actionLogout:(id)sender {
    
    if (activitySelected) {
        
        //  Reset new like + new comment when user click Activity tab
        
        [self refreshBagedNumber];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_OUT object:nil userInfo:nil];
        
    }];

}

- (void)actionChangeAvatar:(id)sender {
    
    //  showActionSheetOptionComposeImage
    
    /*
    UIActionSheet *actionSheetRightMenu = [[UIActionSheet alloc] initWithTitle:APP_NAME delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    actionSheetRightMenu.tag = 1;
    [actionSheetRightMenu showInView:[UIApplication sharedApplication].keyWindow];
     */
    
    
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:APP_NAME message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Get the popover presentation controller and configure it for iPad
    
    alertcontroller.modalPresentationStyle = IS_IPAD?UIModalPresentationPopover:UIModalPresentationCurrentContext;
    UIPopoverPresentationController *presentationController = [alertcontroller popoverPresentationController];
    presentationController.delegate = self;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.sourceView = self.view;
    presentationController.sourceRect = self.view.bounds;
    
    // Cancel action
    
    UIAlertAction *cancel_action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //[selfBlock dismissViewControllerAnimated:YES completion:^{ }];
    }];
    [alertcontroller addAction:cancel_action];
    
    // Action open camera
    
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self startCameraControllerFromViewController:self usingDelegate:self fromPhotoAlbum:NO];
        
        
    }];
    [alertcontroller addAction:actionCamera];
    
    // Action Chose Existing picture
    
    UIAlertAction *actionPhotoLibrary = [UIAlertAction actionWithTitle:@"Choose Existing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self startCameraControllerFromViewController:self usingDelegate:self fromPhotoAlbum:YES];
    }];
    [alertcontroller addAction:actionPhotoLibrary];
    
    // Present alertController to view
    
    [self presentViewController:alertcontroller animated:YES completion:^{ }];
    
}


#pragma -mark ACTIONSHEET DELEGATE

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {
        case 1:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [self startCameraControllerFromViewController:self usingDelegate:self fromPhotoAlbum:NO];
                }
                    break;
                case 1:
                {
                    [self startCameraControllerFromViewController:self usingDelegate:self fromPhotoAlbum:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}


- (void)actionEditName:(id)sender {
    
    if (self.infoBarView != nil) {
        _infoBarView.tf_UserName.userInteractionEnabled = YES;
        _strNameTemp = _infoBarView.tf_UserName.text;
        [_infoBarView.tf_UserName becomeFirstResponder];
    }
}

#pragma mark - CAMERA DELEGATE

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate fromPhotoAlbum:(BOOL)fromPhotoAlbum
{
    if (controller == nil || controller == nil) {
        return NO;
    }
    
    if (fromPhotoAlbum) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            return NO;
    } else {
        if (![UIImagePickerController isSourceTypeAvailable:
              UIImagePickerControllerSourceTypeCamera])
            return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if (fromPhotoAlbum) {
        //cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    } else {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.mediaTypes =
        [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    cameraUI.videoQuality = UIImagePickerControllerQualityTypeMedium;
    cameraUI.videoMaximumDuration = 10;
    
    cameraUI.delegate = delegate;
    
    //[controller presentModalViewController: cameraUI animated: YES];
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

// For responding to the user tapping Cancel.

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// For responding to the user accepting a newly-captured picture or movie

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    imageToSave = nil;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }

        //  Upload image to server
        
        if (self.infoBarView != nil) {
            [self uploadNewUserAvatar:imageToSave];
        }
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
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
                        
                        totalPostInCurrentRegion--;
                        paging_offset--;
                        
                        [_tableView beginUpdates];
                        [_postsList removeObjectAtIndex:activeIndexPath.section];
    
                        NSIndexSet *deleteSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(activeIndexPath.section, 1)];
                        [_tableView deleteSections:deleteSection withRowAnimation:UITableViewRowAnimationFade];
                        
                        [_cellSizeManager invalidateCellSizeCache];
                        [_tableView endUpdates];
                        
                        NSString* successMsg = responseObject[@"data"][@"message"];
                        if (!successMsg || successMsg.length == 0) {
                            successMsg = @"Post was deleted!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:successMsg];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:POST_HIDDEN_DELETED_NOTIFICATION object:nil];
                        
                    } else {
                        
                        NSString* errorMsg = responseObject[@"data"][@"message"];
                        
                        if (!errorMsg || errorMsg.length == 0) {
                            
                            errorMsg = @"There was an issue while delete your post!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];

                    }
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while delete your post!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while delete your post!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];

            }
            default:
                break;
        }
    }
}


#pragma mark - MyProfileInfoHeaderViewDelegate

- (void)MyProfileInfoHeaderViewDidSelectMyPost:(UIButton*)sender {
    
    if (activityTabActive) {
        
        activityTabActive = NO;
        
        lastActivityContentOffset = _tableView.contentOffset;
        
        [_tableView reloadData];
        
        [UIView transitionWithView:_tableView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{

            [_tableView setContentOffset:lastMyPostContentOffset animated:YES];
            
        } completion:^(BOOL finished) {

        }];
    }
}


- (void)MyProfileInfoHeaderViewDidSelectActivity:(UIButton*)sender {
    
    if (!activityTabActive) {
        
        //  Reload data for table
        
        activityTabActive = YES;
        
        activitySelected = YES;
        
        lastMyPostContentOffset = _tableView.contentOffset;
        
        [_tableView reloadData];
        
        [UIView transitionWithView:_tableView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{

            [_tableView setContentOffset:lastActivityContentOffset animated:YES];
            
        } completion:^(BOOL finished) {
  
        }];
    }
}

- (void)MyProfileInfoHeaderViewDidClickShowAvatar:(UIButton*)sender {
    
    BOOL displayActionButton = kAllowUserSaveOtherUserAvatar;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    NSString* userAvatar = [UserDefault currentUser].avatar;
    
    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:userAvatar]]];
    
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
    [browser setCurrentPhotoIndex:0];
    
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
    
}


#pragma mark - ActivityCellDelegate

- (void)ActivityCell:(id)cell didClickedOnUserAvatar:(id)sender {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* activityInfo = [_activityList objectAtIndex:indexPath.row];
    NSDictionary *userInfo = activityInfo[@"user"];
    
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


@end
