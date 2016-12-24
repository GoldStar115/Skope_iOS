//
//  HomeVC.m
//  Skope
//
//  Created by CHAU HUYNH on 2/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "HomeVC.h"
#import "MyProfileVC.h"
#import "MessagesListVC.h"
#import "NSString+Utilities.h"
#import "CustomLocationView.h"
#import "UIViewController+Utils.h"
#import "MKMapView+ZoomLevel.h"
#import "UIImage+RoundedCorner.h"
#import "lelib.h"

CGRect const kInitialViewFrame = { 0.0f, 0.0f, 320.0f, 480.0f };

#define kPhotoShowScrollViewHeight          80
#define image_scale_default_camera          200
#define kCircleSlideMinRadius               0.0
#define kCircleSlideDefaultRadius           50.0
#define kCircleWorldMapRadiusForQuery       42000.0
#define kCircleSlideMaxRadius               7000.0
#define kCircleSlideWorlRadius              6000.0


#define kMaxRadiusGetNotification           200

@interface HomeVC () <QBImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIPopoverPresentationControllerDelegate,UIActionSheetDelegate>
{
    NSInteger selectedIndexPath;
    NSInteger selectedFullContentIndexPath;
    CGFloat radiusUpdate;
    BOOL keepGoing;
    dispatch_semaphore_t semaphore;
    NSUInteger totalPostCount;
    NSUInteger totalUserCount;
    
}

@property (nonatomic, strong) JSBadgeView *msg_badgeView;
@property (nonatomic, strong) JSBadgeView *prf_badgeView;

@property (nonatomic, strong) NSMutableArray        *arr_data_media;
@property (nonatomic, strong) NSTimer               *timerUpdateUserLocation;
@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;

@property (nonatomic, strong) UIView                *viewCameraChoosing;
@property (nonatomic, strong) PHFComposeBarView     *composeBarView;
@property (nonatomic, strong) UIView                *container;
@property (nonatomic, strong) UICollectionView      *collectionViewPhotoShow;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (weak, nonatomic) IBOutlet UICircularSlider *circular_slider;
@property (weak, nonatomic) IBOutlet MKMapView      *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView   *scrDashboard;
@property (weak, nonatomic) IBOutlet UIButton       *btGoMyProfile;
@property (weak, nonatomic) IBOutlet UIView         *viewRadiusMap;
@property (weak, nonatomic) IBOutlet UILabel        *lblRadiusMap;
@property (weak, nonatomic) IBOutlet UILabel        *lblNumberUsers;
@property (weak, nonatomic) IBOutlet UILabel        *lblNumberPosts;
@property (weak, nonatomic) IBOutlet UIButton       *btHideCompose;
@property (weak, nonatomic) IBOutlet UIButton       *btComposePost;
@property (weak, nonatomic) IBOutlet UIButton       *btMessage;

@property (weak, nonatomic) IBOutlet UILabel *lblServerUsed;

@property (nonatomic, strong) AFHTTPRequestOperation *updatePostUserCountOperation;
@property (nonatomic, strong) NSDictionary *RadiusStringTextAttributes;
@property (nonatomic, strong) NSDictionary *KilometStringTextAttributes;

@property (nonatomic, strong) ASNetworkImageNode *avatar;

@end

@implementation HomeVC

- (void)updateNewMessageBagedNumber {
    
    NSUInteger count = [[UserDefault currentUser].messageBagedNumber integerValue];
    _msg_badgeView.badgeText = [NSString stringWithFormat:@"%ld",(long)count];
    [_msg_badgeView setHidden:count==0];
}

- (void)updateNewCommentBagedNumber {
    
    NSUInteger count = [[UserDefault currentUser].commentBagedNumber integerValue];
    _prf_badgeView.badgeText = [NSString stringWithFormat:@"%ld",(long)count];
    [_prf_badgeView setHidden:count==0];
}

- (void)stopAnimation {
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    keepGoing = NO;
    [self.mapView.layer removeAllAnimations];
    dispatch_semaphore_signal(semaphore);
}

- (BOOL)getGoingStatusForReady {
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    BOOL available = NO;
    if (!keepGoing) {
        keepGoing = YES;
        available = YES;
    }
    dispatch_semaphore_signal(semaphore);
    return available;
}

- (void)goforWorldMap {
    
    [UIView animateWithDuration:20.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CLLocationCoordinate2D currentCordinate = self.mapView.centerCoordinate;
        currentCordinate.longitude -=179; // < 180 for rotate from WEST to EAST, >=180 => rotate from EAST to WEST
        if (currentCordinate.longitude < -180) {
            currentCordinate.longitude = 360 + currentCordinate.longitude;
        }
        self.mapView.centerCoordinate = currentCordinate;
    } completion:^(BOOL finished) {
        if (keepGoing && [UIViewController isVisible:self]) {
            [self performSelector:@selector(goforWorldMap) withObject:nil afterDelay:0.05];
        }
    }];
}


- (CGFloat)recalculatedRadiusUpdate {
    
    if (radiusUpdate > kCircleSlideWorlRadius) {
        
        return kCircleWorldMapRadiusForQuery;
        
    } else {
        
        return radiusUpdate;
        
    }
    
}

- (NSDictionary*)RadiusStringTextAttributes {
    
    if (!_RadiusStringTextAttributes) {
        NSMutableParagraphStyle *centerAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        centerAlign_paragraphStyle.alignment = NSTextAlignmentCenter;
        _RadiusStringTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0],
                                         NSForegroundColorAttributeName : [UIColor whiteColor],
                                         NSParagraphStyleAttributeName : centerAlign_paragraphStyle, NSBaselineOffsetAttributeName:[NSNumber numberWithFloat:3.0]};
    }
    return _RadiusStringTextAttributes;
}

- (NSDictionary*)KilometStringTextAttributes {
    
    if (!_KilometStringTextAttributes) {
        NSMutableParagraphStyle *centerAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        centerAlign_paragraphStyle.alignment = NSTextAlignmentCenter;
        _KilometStringTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0], NSForegroundColorAttributeName : [UIColor whiteColor], NSParagraphStyleAttributeName : centerAlign_paragraphStyle};
    }
    return _KilometStringTextAttributes;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        //[self locationCurrentInit];
        selectedIndexPath = -1;
        isMyProfile = false;
        radiusUpdate = kCircleSlideMinRadius;
        _arr_data_media = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
   
    self.navigationController.navigationBar.hidden = YES;
    
    semaphore = dispatch_semaphore_create(1);
    
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    
    CGRect frRM = _viewRadiusMap.frame;
    CGFloat screenWidth = SCREEN_WIDTH_CALCULATED;
    CGFloat heightRemain = CGRectGetMinY(_btComposePost.frame) - CGRectGetMaxY(_lblRadiusMap.frame);
    CGFloat mapViewWidth = MIN(heightRemain,screenWidth) * 0.85;
    frRM.size = CGSizeMake(mapViewWidth, mapViewWidth);
    frRM.origin.x = (screenWidth - mapViewWidth)/2;
    frRM.origin.y = CGRectGetMaxY(_lblRadiusMap.frame) + (heightRemain - mapViewWidth) / 2;
    _viewRadiusMap.frame = frRM;
    
    [Common circleImageView:_mapView];
    [self.locationManager startUpdatingLocation];
    [self startUpdateUserLocationTimer];
    
    [self prepareForSubViews];
    
}

- (void)prepareForSubViews {
    
    //===Composerpost Container
    
    _container = [self container];
    [_container addSubview:[self composeBarView]];
    [self.view addSubview:_container];
    _container.hidden = YES;
    
    //===Config circle view
    
    [self circleViewConfig];
    
    self.msg_badgeView = [[JSBadgeView alloc] initWithParentView:_btMessage alignment:JSBadgeViewAlignmentTopRight];
    _msg_badgeView.badgeText = [UserDefault currentUser].messageBagedNumber;
    _msg_badgeView.badgeTextFont = FONT_NOTIFICATION_BAGED;
    [_msg_badgeView setHidden:[[UserDefault currentUser].messageBagedNumber integerValue] == 0];
    
    self.prf_badgeView = [[JSBadgeView alloc] initWithParentView:_btGoMyProfile alignment:JSBadgeViewAlignmentTopRight];
    _prf_badgeView.badgeText = [UserDefault currentUser].commentBagedNumber;
    _prf_badgeView.badgeTextFont = FONT_NOTIFICATION_BAGED;
    [_prf_badgeView setHidden:[[UserDefault currentUser].commentBagedNumber integerValue] == 0];
    
    //===Notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCountChanged)
                                                 name:BAGED_COUNT_CHANGED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopAnimation)
                                                 name:APP_DID_BACKGROUND_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUI)
                                                 name:APP_DID_ACTIVE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_have_a_post_deleted)
                                                 name:POST_HIDDEN_DELETED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_have_a_user_blocked)
                                                 name:kDecreaseUsersCountNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataWhenHaveInternetConnection)
                                                 name:kInternetConnectionIsEnableNotification
                                               object:nil];
    
    
    
    //Set start value for circleSlider
    
    CGFloat lastRadius = [[[UserDefault currentUser] lastRadius] floatValue];
    
    if (lastRadius == 0) {
        lastRadius = kCircleSlideDefaultRadius;
    }
    [_circular_slider setStartValue:lastRadius * 1000.0f / unitRadiusCircleSlider];
    [self updateprogress:_circular_slider];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self refreshUI];
    
#ifdef DEBUG
    [self.lblServerUsed setHidden:NO];
    [self.lblServerUsed setText:SERVER_IP];
#else
    [self.lblServerUsed setHidden:YES];
#endif
    
    //[self applyMapViewMemoryHotFix];
}

- (void)refreshUI {
    
    if (!_avatar) {
        
        ASNetworkImageNode *avatar = [[ASNetworkImageNode alloc] initWithWebImage];
        avatar.layerBacked = YES;
        avatar.borderColor = [UIColor whiteColor].CGColor;
        avatar.borderWidth = 2.0f;
        avatar.cornerRadius = CGRectGetHeight(_btGoMyProfile.bounds)/2.0;
        avatar.layer.masksToBounds = YES;
        avatar.frame = _btGoMyProfile.bounds;
        [_btGoMyProfile.layer insertSublayer:avatar.layer atIndex:0];
        self.avatar = avatar;
    }
    
    self.avatar.URL = [NSURL URLWithString:[UserDefault currentUser].avatar];
    
    
//    if ([[[ISDiskCache sharedCache] objectForKey:[UserDefault currentUser].avatar] isKindOfClass:[UIImage class]]) {
//        
//        UIImage *avatar = [[ISDiskCache sharedCache] objectForKey:[UserDefault currentUser].avatar];
//        
//        [_btGoMyProfile setBackgroundImage:avatar forState:UIControlStateNormal];
//        
//    } else {
//        
//        UIImage *roundedImage = [[USER_DEFAULT_AVATAR scaleToSize:_btGoMyProfile.bounds.size] imageByCenterSquareCircleImageToFitSquare:_btGoMyProfile.bounds.size.width borderWidth:2.0 borderColor:[UIColor whiteColor]];
//        
//        [_btGoMyProfile setBackgroundImage:roundedImage forState:UIControlStateNormal];
//    }
//    
//    
//    [[UIImageView new] sd_setImageWithURL:[NSURL URLWithString:[UserDefault currentUser].avatar] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageContinueInBackground completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        
//        UIImage *roundedImage = [[image?image:USER_DEFAULT_AVATAR scaleToSize:_btGoMyProfile.bounds.size] imageByCenterSquareCircleImageToFitSquare:_btGoMyProfile.bounds.size.width borderWidth:2.0 borderColor:[UIColor whiteColor]];
//        
//        [[ISDiskCache sharedCache] setObject:roundedImage forKey:[UserDefault currentUser].avatar];
//        
//        [_btGoMyProfile setBackgroundImage:roundedImage forState:UIControlStateNormal];
//        
//    }];
    
    if (radiusUpdate > kCircleSlideWorlRadius && [self getGoingStatusForReady]) {
        
        // TODO:
        
        //  Remove animation when zoom to world map
        
        // [self goforWorldMap];
    }
    
    [self notificationCountChanged];
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopAnimation];
    _container.hidden = YES;
}

- (void)dealloc {
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    [self stopUpdateUserLocationTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applyMapViewMemoryHotFix{
    switch (self.mapView.mapType) {
        case MKMapTypeHybrid:
        {
            self.mapView.mapType = MKMapTypeStandard;
        }
            
            break;
        case MKMapTypeStandard:
        {
            self.mapView.mapType = MKMapTypeHybrid;
        }
            
            break;
        default:
            break;
    }
    self.mapView.mapType = MKMapTypeStandard;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stopUpdateUserLocationTimer {
    if ([self.timerUpdateUserLocation isValid]){
        [self.timerUpdateUserLocation invalidate];
        self.timerUpdateUserLocation = nil;
    }
}

- (void)startUpdateUserLocationTimer{
    [self stopUpdateUserLocationTimer];
    self.timerUpdateUserLocation = [NSTimer scheduledTimerWithTimeInterval:TIME_TO_RECALL_WS_UPDATE_LOCATION
                                                                    target:self
                                                                  selector:@selector(postCurrentUserLocationToServer)
                                                                  userInfo:nil
                                                                   repeats:YES];
}

#pragma mark ACTIONS

- (void)notificationCountChanged {
    
    [self updateNewMessageBagedNumber];
    [self updateNewCommentBagedNumber];
}

- (IBAction)actionGoUsersView:(id)sender {
    if([_delegate respondsToSelector:@selector(homeListActionShowUser:)])
    {
        [_delegate homeListActionShowUser:[self recalculatedRadiusUpdate]];
    }
}

- (IBAction)actionGoPostsView:(id)sender {
    if([_delegate respondsToSelector:@selector(homeListActionShowPost:)])
    {
        [_delegate homeListActionShowPost:[self recalculatedRadiusUpdate]];
    }
}

- (IBAction)actionGoProfile:(id)sender {
    
    MyProfileVC *myProfileVC = [[MyProfileVC alloc] initWithNibName:@"MyProfileVC" bundle:nil];//[Main_Storyboard instantiateViewControllerWithIdentifier:@"MyProfileVC"];
    UINavigationController *profileNavVC = [[UINavigationController alloc] initWithRootViewController:myProfileVC];
    
//    ADTransition * animation = [[ADModernPushTransition alloc] initWithDuration:0.4 orientation:ADTransitionBottomToTop sourceRect:self.view.frame];
//    if (IS_OS_7_OR_LATER) {
//        myProfileVC.transition = animation;
//        [self.navigationController pushViewController:myProfileVC animated:YES];
//    } else {
//        [self.transitionController pushViewController:myProfileVC withTransition:animation];
//    }
    
    [self presentViewController:profileNavVC animated:YES completion:^{
        //
    }];
}

- (IBAction)actionCompose:(id)sender {
    _container.hidden = NO;
    _collectionViewPhotoShow.hidden = !_arr_data_media.count > 0;
    _composeBarView.button.enabled = YES;
    [_composeBarView.textView becomeFirstResponder];
}

- (void)actionTakePhotoVideo:(id)sender {
    if (_viewCameraChoosing != nil) {
        _viewCameraChoosing.hidden = YES;
    }
    if (![self startCameraControllerFromViewController:self usingDelegate:self fromPhotoAlbum:NO]) {
        //NSLog(@"Failed!");
    }
}

- (void)actionChooseExisting:(id)sender {
    
    if (_viewCameraChoosing != nil) {
        _viewCameraChoosing.hidden = YES;
    }
    
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 6;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
    
}

- (void)actionCancelTakePhoto:(id)sender {
    //_viewTakeOrChooseExisting.hidden = YES;
    if (_viewCameraChoosing != nil) {
        _viewCameraChoosing.hidden = YES;
    }
}

- (IBAction)actionHideCompose:(id)sender {
    
    [UIView animateWithDuration:0.4 animations:^{
        [_composeBarView resignFirstResponder];
        _container.hidden = YES;
        _collectionViewPhotoShow.hidden = YES;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)actionShowMessageList:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MessagesListVC *messageView = [storyboard instantiateViewControllerWithIdentifier:@"MESSAGES_VIEW"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:messageView];
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (BOOL) deleteFileTemp:(NSURL *) urlPathFile {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[urlPathFile path] error:&error];
    if (error){
        //NSLog(@"error: %@", error.description);
        return false;
    }
    return true;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case 1:
            switch (buttonIndex) {
                case 0:
                    [self actionTakePhotoVideo:nil];
                    break;
                case 1:
                    [self actionChooseExisting:nil];
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}


#pragma mark - WEBSERVICE

- (void) callWSPostComposeWithContent:(NSString*)content mediaArr:(NSMutableArray*)mediaArr {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *latitude = [NSString stringWithFormat:@"%f",_userLocation.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",_userLocation.longitude];
    
    if (access_token && content && latitude && longitude) {
        
        [Common showNetworkActivityIndicator];
        [Common showLoadingViewGlobal:@"Posting..."];
        
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        
        NSDictionary *request_param = @{@"access_token":access_token,
                                        @"content":content,
                                        @"latitude":latitude,
                                        @"longitude":longitude,
                                        };
        
        __weak __typeof(self)weakSelf = self;
        typeof(self) selfBlock = weakSelf;
        
        [manager POST:URL_SERVER_API(API_COMPOSE_POST) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [_composeBarView setText:@"" animated:YES];
            
            if ([Common validateResponse:responseObject])
            {
                NSString *strPostId = responseObject[@"data"][@"post"][@"id"];
                
                if (strPostId && strPostId.length > 0 && [mediaArr count] > 0) {
                    
                    [selfBlock uploadMediaArray:mediaArr withPostID:strPostId completion:^{
                        
                        [Common hideLoadingViewGlobal];
                        [Common hideNetworkActivityIndicator];
                        
                        if([_delegate respondsToSelector:@selector(homePostDone:)])
                        {
                            [_delegate homePostDone:[self recalculatedRadiusUpdate]];
                        }
                        
                        [mediaArr enumerateObjectsUsingBlock:^(NSDictionary *media, NSUInteger idx, BOOL *stop) {
                            
                            id mediaContent = [media objectForKey:@"media"];
                            if ([mediaContent isKindOfClass:[NSURL class]]) {
                                
                                //[Common removeFileFromAppDirectoryAtPath:[(NSURL*)mediaContent path]];
                                
                                [Common removeFile:(NSURL*)mediaContent];
                            }
                        }];
                        
                        [mediaArr removeAllObjects];
                        
                    }];
                } else {
                    
                    if([_delegate respondsToSelector:@selector(homePostDone:)])
                    {
                        [_delegate homePostDone:[self recalculatedRadiusUpdate]];
                    }
                }
                
                totalPostCount++;
                
                [self updatePersonPostCountToUI];
                
            }
            else
            {
                
                [Common hideLoadingViewGlobal];
                [Common hideNetworkActivityIndicator];
                
                NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
                if (errorMsg) {
                    [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [_composeBarView setText:@"" animated:YES];
            
            [Common hideLoadingViewGlobal];
            [Common hideNetworkActivityIndicator];
            
        }];
    }
}

- (void) uploadMediaArray:(NSArray*)medias withPostID:(NSString*)postID completion:(dispatch_block_t)completion{
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSBlockOperation *compliteUploadMediaOperation = [[NSBlockOperation alloc] init];
    [compliteUploadMediaOperation addExecutionBlock:^{
        runOnMainQueueWithoutDeadlocking(^{
            completion();
        });
    }];
    
    [medias enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj != [NSNull null]) {
            AFHTTPRequestOperation *op = [self uploadMedia:obj withPostId:postID operationManager:manager];
            [compliteUploadMediaOperation addDependency:op];
        }
    }];
    
    [manager.operationQueue addOperation:compliteUploadMediaOperation];
}

- (AFHTTPRequestOperation *) uploadMedia:(id)media withPostId:(NSString *)postId operationManager:(AFHTTPRequestOperationManager *)manager{
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    
    AFHTTPRequestOperation *requestOperation;
    
    if (!access_token) {
        return nil;
    }
    
    NSString *strTypeMedia = @"image/jpeg";
    NSString *strNameMedia = @"photo.jpg";
    
    id mediaContent = [media objectForKey:@"media"];
    
    NSDictionary *sizeParam = @{@"access_token":access_token,
                                };
    
    if ([mediaContent isKindOfClass:[NSURL class]]) {
        
        strTypeMedia = @"video/mp4";
        strNameMedia = @"video.mp4";
        
        requestOperation = [manager POST:URL_SERVER_API(API_UPLOAD_MEDIA(postId)) parameters:sizeParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            NSError *error;
            [formData appendPartWithFileURL:mediaContent name:@"file" fileName:strNameMedia mimeType:strTypeMedia error:&error];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //NSLog(@"Error: %@",error.localizedDescription);
        }];
        
        return requestOperation;
        
    } else if ([mediaContent isKindOfClass:[UIImage class]]) {

        UIImage *scaledImage =
        
        //[(UIImage*)mediaContent scaleAndRotateImageMaxResolution:SIZE_IMAGE_AFTER_CAPTURE.width];

        [[(UIImage *)mediaContent scaleToAspectFitSize:SIZE_IMAGE_AFTER_CAPTURE upScale:NO] fixOrientation];

        //[(UIImage *)mediaContent scaleToAspectFitSize:SIZE_IMAGE_AFTER_CAPTURE upScale:NO];
        
        requestOperation = [manager POST:URL_SERVER_API(API_UPLOAD_MEDIA(postId)) parameters:sizeParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:UIImageJPEGRepresentation(scaledImage, kImageEncodeQualityForUpload) name:@"file" fileName:strNameMedia mimeType:strTypeMedia];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //NSLog(@"Error: %@",error.localizedDescription);
        }];
        
        return requestOperation;
        
    }
    
    return nil;
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
    
    CGRect newDaskBoardFrame = [_scrDashboard frame];
    if (endFrame.origin.y >= SCREEN_HEIGHT_CALCULATED) {
        
        //  Keyboard will hide
        
        newDaskBoardFrame.origin.y = 0;
        
    } else {
        
        //  Keyboard will show
        
        newDaskBoardFrame.origin.y = endFrame.origin.y - newDaskBoardFrame.size.height;
    }
    
    CGRect newContainerFrame = [[self container] frame];
    //newContainerFrame.size.height += sizeChange;
    newContainerFrame.origin.y = endFrame.origin.y - newContainerFrame.size.height;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [_scrDashboard setFrame:newDaskBoardFrame];
                         [_container setFrame:newContainerFrame];
                     }
                     completion:NULL];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    
    //===Only allow compose new post if have text or image
    
    if (composeBarView.textView.text.length > 0 || _arr_data_media.count > 0) {
        
        [composeBarView resignFirstResponder];
        
        _container.hidden = YES;
        _collectionViewPhotoShow.hidden = YES;
        
        [[_collectionViewPhotoShow subviews] enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
            [view removeFromSuperview];
        }];
        
        [self callWSPostComposeWithContent:composeBarView.textView.text mediaArr:_arr_data_media];

    }
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView {
    
    //  showActionSheetOptionComposeImage
    
    /*
    UIActionSheet *actionCP = [[UIActionSheet alloc] initWithTitle:APP_NAME delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo or Video", @"Choose Existing", nil];
    actionCP.tag = 1;
    [actionCP showInView:[UIApplication sharedApplication].keyWindow];
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
     
     UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"Take Photo or Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
     [self actionTakePhotoVideo:nil];
     
     }];
     [alertcontroller addAction:actionCamera];
     
     // Action Chose Existing picture
     
     UIAlertAction *actionPhotoLibrary = [UIAlertAction actionWithTitle:@"Choose Existing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
     [self actionChooseExisting:nil];
     }];
     [alertcontroller addAction:actionPhotoLibrary];
     
     // Present alertController to view
     
     [self presentViewController:alertcontroller animated:YES completion:^{ }];
    
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve
{
    CGRect _collectionViewPhotoShowFrame = _collectionViewPhotoShow.frame;
    _collectionViewPhotoShowFrame.origin.y = endFrame.origin.y - _collectionViewPhotoShow.bounds.size.height;
    _collectionViewPhotoShow.frame = _collectionViewPhotoShowFrame;
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
{
    
}


//@synthesize container = _container;
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_CALCULATED, SCREEN_HEIGHT_CALCULATED)];
        [_container setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        _container.backgroundColor = [UIColor clearColor];
        [_container addSubview:_btHideCompose];
    }
    
    return _container;
}


- (PHFComposeBarView *) composeBarView {
    if (!_composeBarView) {
        
        CGRect frame = CGRectMake(0.0f,
                                  SCREEN_HEIGHT_CALCULATED - PHFComposeBarViewInitialHeight,
                                  SCREEN_WIDTH_CALCULATED,
                                  PHFComposeBarViewInitialHeight);
        
        _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
        [_composeBarView setBackgroundColor:[UIColor whiteColor]];
        _composeBarView.buttonTintColor = COLOR_BUTTON_POST_SEND;
        [_composeBarView.textView setFont:FONT_TEXT_COMPOSE_BAR];
        [_composeBarView setMaxCharCount:2000];
        //[_composeBarView setMaxLinesCount:63];
        [_composeBarView setMaxHeight:140];
        [_composeBarView setButtonTitle:@"Post"];
        [_composeBarView setPlaceholder:@"Type something..."];
        [_composeBarView setUtilityButtonImage:[UIImage imageNamed:@"Camera"]];
        
        /* Change frame of button */
        [Common changeWidthForView:_composeBarView.utilityButton width:40];
        [Common changeHeightForView:_composeBarView.utilityButton height:30];
        [Common changeYposisionForView:_composeBarView.utilityButton Yposision:8];
        [Common changeXposisionForView:_composeBarView.utilityButton Xposision:-2];
        
        [_composeBarView.button setTitleColor:COLOR_BUTTON_POST_SEND forState:UIControlStateDisabled];
        _composeBarView.maxCharCount = 0;
        _composeBarView.button.enabled = YES;
        [_composeBarView setDelegate:self];
    }
    
    return _composeBarView;
}

- (void) prepareforComposePhotoView {
    
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //self.collectionViewLayout.minimumInteritemSpacing = 3.0;
    self.collectionViewLayout.minimumLineSpacing = 5.0;
    
    CGFloat photoShowY = _container.bounds.size.height - kPhotoShowScrollViewHeight - PHFComposeBarViewInitialHeight;
    _collectionViewPhotoShow = [[UICollectionView alloc] initWithFrame:CGRectMake(0, photoShowY, _container.bounds.size.width , kPhotoShowScrollViewHeight) collectionViewLayout:self.collectionViewLayout];
    [_collectionViewPhotoShow registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
    [_collectionViewPhotoShow setContentInset:UIEdgeInsetsMake(0, 5, 0, 5)];
    [_collectionViewPhotoShow setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    _collectionViewPhotoShow.dataSource = self;
    _collectionViewPhotoShow.delegate = self;
    _collectionViewPhotoShow.collectionViewLayout = self.collectionViewLayout;
    _collectionViewPhotoShow.showsHorizontalScrollIndicator = NO;
    _collectionViewPhotoShow.showsVerticalScrollIndicator = NO;
    _collectionViewPhotoShow.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.5];
    
    [_container addSubview:_collectionViewPhotoShow];
}

#pragma mark - CAMERA DELEGATE

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate fromPhotoAlbum:(BOOL)fromPhotoAlbum
{
    if (controller == nil || controller == nil) {
        return NO;
    }
    
    if (fromPhotoAlbum) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
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
        cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                               UIImagePickerControllerSourceTypePhotoLibrary];//[[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie, nil];
        cameraUI.allowsEditing = YES;
        
    } else {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        cameraUI.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        cameraUI.allowsEditing = NO;
        cameraUI.videoQuality = UIImagePickerControllerQualityTypeHigh;
        cameraUI.videoMaximumDuration = 10;
    }
    
    
    cameraUI.delegate = delegate;
    
    //[controller presentModalViewController: cameraUI animated: YES];
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:^{
        if (_composeBarView.textView.text.length > 0 || _arr_data_media.count > 0) {
            _collectionViewPhotoShow.hidden = !(_arr_data_media.count > 0);
            _container.hidden = NO;
            [_composeBarView.textView becomeFirstResponder];
        } else {
            _collectionViewPhotoShow.hidden = YES;
            _container.hidden = YES;
            [_composeBarView.textView resignFirstResponder];
        }
    }];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    NSURL *videoURL = nil;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (originalImage) {
            imageToSave = originalImage;
        } else {
            imageToSave = originalImage;
        }
        
        [dic setObject:imageToSave forKey:@"media"];
        [dic setObject:imageToSave forKey:@"thumbnail"];
        
        //Save image to array TODO add
        [_arr_data_media addObject:dic];
        
    } else  if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
                == kCFCompareEqualTo) {
        videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        if (videoURL != nil) {
            
            [dic setObject:[Common thumbnailImageForVideo:videoURL atTime:1] forKey:@"thumbnail"];
            
            [dic setObject:videoURL forKey:@"media"];
        }
        
        //Save image to array TODO add
        [_arr_data_media addObject:dic];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^(void) {
        
        _container.hidden = NO;
        [_composeBarView.textView becomeFirstResponder];
        
        if (!_collectionViewPhotoShow) {
            [self prepareforComposePhotoView];
        }
        
        [_collectionViewPhotoShow reloadData];
        
        /*
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         
         [_container setFrame:CGRectMake(0, 0, SCREEN_WIDTH_CALCULATED, SCREEN_HEIGHT_CALCULATED)];
         _container.hidden = NO;
         [_composeBarView.textView becomeFirstResponder];
         if (!_collectionViewPhotoShow) {
         [self prepareforComposePhotoView];
         }
         
         if (videoURL != nil) {
         AVAsset *video = [AVAsset assetWithURL:videoURL];
         AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video presetName:AVAssetExportPresetMediumQuality];
         exportSession.shouldOptimizeForNetworkUse = YES;
         exportSession.outputFileType = AVFileTypeQuickTimeMovie;
         
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
         basePath = [basePath stringByAppendingPathComponent:@"videos"];
         if (![[NSFileManager defaultManager] fileExistsAtPath:basePath])
         [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
         
         NSURL *compressedVideoUrl=nil;
         compressedVideoUrl = [NSURL fileURLWithPath:basePath];
         long CurrentTime = [[NSDate date] timeIntervalSince1970];
         NSString *strImageName = [NSString stringWithFormat:@"%ld",CurrentTime];
         compressedVideoUrl=[compressedVideoUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",strImageName]];
         
         exportSession.outputURL = compressedVideoUrl;
         [exportSession exportAsynchronouslyWithCompletionHandler:^{
         switch ([exportSession status])
         {
         case AVAssetExportSessionStatusCompleted:{
         NSLog(@"MP4 Successful!");
         
         [dic setObject:compressedVideoUrl forKey:@"media"];
         
         }
         break;
         case AVAssetExportSessionStatusFailed:
         {
         NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
         }
         break;
         case AVAssetExportSessionStatusCancelled:
         NSLog(@"Export canceled");
         break;
         default:
         break;
         }
         }];
         }
         });
         */
    }];
}

#pragma mark QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset{
    
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    
    NSBlockOperation *assetsProcessor = [NSBlockOperation blockOperationWithBlock:^{
        
        runOnMainQueueWithoutDeadlocking(^{
            [Common showLoadingViewGlobal:@"Processing..."];
        });
        
        for (ALAsset *asset in assets) {
            // Do something with the asset
            
            NSString *mediaType = [asset valueForProperty:ALAssetPropertyType];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            
            if ([mediaType isEqualToString:ALAssetTypePhoto]) {
                //If image
                
                CGImageRef iref = [asset.defaultRepresentation fullResolutionImage];
                
                if (iref) {
                    
                    // Retrieve the image orientation from the ALAsset
                    UIImageOrientation orientation = UIImageOrientationUp;
                    NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
                    if (orientationValue != nil) {
                        orientation = [orientationValue intValue];
                    }
                    
                    UIImage *originalImage = [UIImage imageWithCGImage:iref scale:1.0 orientation:orientation];
                    
                    [dic setObject:originalImage forKey:@"media"];
                    
                    CGImageRef thumbnailref = [asset thumbnail];
                    
                    if (thumbnailref) {
                        
                        UIImage *thumnail = [UIImage imageWithCGImage:thumbnailref];
                        [dic setObject:thumnail forKey:@"thumbnail"];
                        
                    }
                    
                    [_arr_data_media addObject:dic];
                    
                    //CGImageRelease(thumbnailref);
                    
                }
                
                //CGImageRelease(iref);
                
            } else if ([mediaType isEqualToString:ALAssetTypeVideo])
            {
                //If video
                
                NSURL *videoURL = asset.defaultRepresentation.url;
                
                if (videoURL != nil) {
                    
                    UIImage *thumbnail = asset.thumbnail ? [UIImage imageWithCGImage:asset.thumbnail] : nil;
                    
                    [dic setObject:thumbnail forKey:@"thumbnail"];
                    
                    NSString *tempPath = [self tempAssetToFilePath:asset];//[self videoAssetURLToTempFile:asset];
                    
                    if ([self writeDataToPath:tempPath andAsset:asset]) {
                        [dic setObject:[NSURL fileURLWithPath:tempPath] forKey:@"media"];
                        [_arr_data_media addObject:dic];
                    }
                }
            }
        }
    }];
    
    [assetsProcessor setCompletionBlock:^{
        runOnMainQueueWithoutDeadlocking(^{
            [Common hideLoadingViewGlobal];
            [_collectionViewPhotoShow reloadData];
        });
    }];
    
    [[Common sharedBackgroundOperationQueue] addOperation:assetsProcessor];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        _container.hidden = NO;
        [_composeBarView.textView becomeFirstResponder];
        
        if (!_collectionViewPhotoShow) {
            [self prepareforComposePhotoView];
        }
        
        [_collectionViewPhotoShow reloadData];
        
    }];
}

- (BOOL)writeDataToPath:(NSString*)filePath andAsset:(ALAsset*)asset
{
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!handle) {
        return NO;
    }
    static const NSUInteger BufferSize = 1024*1024;
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
    NSUInteger offset = 0, bytesRead = 0;
    
    do {
        @try {
            bytesRead = [rep getBytes:buffer fromOffset:offset length:BufferSize error:nil];
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            offset += bytesRead;
        } @catch (NSException *exception) {
            free(buffer);
            
            return NO;
        }
    } while (bytesRead > 0);
    
    free(buffer);
    return YES;
}

- (NSString*) videoAssetURLToTempFile:(ALAsset*)asset path:(NSString*)path
{
    /*
     NSString * surl = [asset.defaultRepresentation.url absoluteString];
     NSString * ext = [surl substringFromIndex:[surl rangeOfString:@"ext="].location + 4];
     NSTimeInterval ti = [[NSDate date]timeIntervalSinceReferenceDate];
     NSString * filename = [NSString stringWithFormat: @"%.0f.%@",ti,ext];
     NSString * tmpfile = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
     */
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        
        ALAssetRepresentation * rep = [myasset defaultRepresentation];
        
        long long size = [rep size];
        const int bufferSize = 8192;
        
        FILE* f = fopen([path cStringUsingEncoding:1], "wb+");
        if (f == NULL) {
            //NSLog(@"Can not create tmp file.");
            return;
        }
        
        Byte * buffer = (Byte*)malloc(bufferSize);
        int read = 0, offset = 0, written = 0;
        NSError* err;
        if (size != 0) {
            do {
                read = [rep getBytes:buffer
                          fromOffset:offset
                              length:bufferSize
                               error:&err];
                written = fwrite(buffer, sizeof(char), read, f);
                offset += read;
            } while (read != 0);
            
            
        }
        fclose(f);
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        //NSLog(@"Can not get asset - %@",[myerror localizedDescription]);
        
    };
    
    if(asset.defaultRepresentation.url)
    {
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:asset.defaultRepresentation.url
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
    
    return path;
}

- (NSString*)tempAssetToFilePath:(ALAsset*)asset {
    
    NSString *assetFileName = asset.defaultRepresentation.filename;
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //path = [[paths objectAtIndex:0] stringByAppendingPathComponent:assetFileName];
    path = [paths objectAtIndex:0];
    NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%.0f.mov",assetFileName,ti]];
    
    return path;
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (_composeBarView.textView.text.length > 0 || _arr_data_media.count > 0) {
            _collectionViewPhotoShow.hidden = !(_arr_data_media.count > 0);
            _container.hidden = NO;
            [_composeBarView.textView becomeFirstResponder];
        } else {
            _collectionViewPhotoShow.hidden = YES;
            _container.hidden = YES;
            [_composeBarView.textView resignFirstResponder];
        }
    }];
}

- (BOOL)qb_imagePickerController:(QBImagePickerController *)imagePickerController shouldSelectAsset:(ALAsset *)asset
{
    return YES;
}

#pragma mark CIRCLE VIEW
- (void) circleViewConfig {
    _circular_slider.minimumTrackTintColor = [UIColor clearColor];
    _circular_slider.maximumTrackTintColor = [UIColor clearColor];
    _circular_slider.thumbTintColor = [UIColor whiteColor];
    
    //    _circular_slider.minimumValue = minximumCircleSlider;
    //    _circular_slider.maximumValue = maximumCircleSlider;
    
    //_circular_slider.minimum = kCircleSlideMinRadius;
    //_circular_slider.maximum = kCircleSlideMaxRadius;
    
    _circular_slider.rotationLimits = @[[NSNumber numberWithFloat:kCircleSlideMinRadius],
                                        [NSNumber numberWithFloat:100.0],
                                        [NSNumber numberWithFloat:250.0],
                                        [NSNumber numberWithFloat:500.0],
                                        [NSNumber numberWithFloat:1000.0],
                                        [NSNumber numberWithFloat:3000.0],
                                        [NSNumber numberWithFloat:6000.0],
                                        [NSNumber numberWithFloat:kCircleSlideMaxRadius]
                                        ];
    _circular_slider.continuous = YES;
    [_circular_slider addTarget:self action:@selector(updateprogress:) forControlEvents:UIControlEventValueChanged];
    [_circular_slider addTarget:self action:@selector(touchupinside:) forControlEvents:UIControlEventTouchUpInside];
    [_circular_slider addTarget:self action:@selector(touchupinside:) forControlEvents:UIControlEventTouchUpOutside];
}


- (void) updateprogress:(UICircularSlider *)sender {
    
    radiusUpdate = (round((sender.value * unitRadiusCircleSlider / 1000.0f)*100)) / 100.0;
    
    //NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"Radius" attributes:self.RadiusStringTextAttributes];
    //[attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ldkm", (long)radiusUpdate] attributes:self.KilometStringTextAttributes]];
    //_lblRadiusMap.attributedText = attrString;
    
    if (radiusUpdate > kCircleSlideWorlRadius) {
        
        if ([self getGoingStatusForReady]) {
            
            _lblRadiusMap.text = @"World";
            [self updateUserPostCountForCurrentLocation:_userLocation withRadius:kCircleWorldMapRadiusForQuery];
            
            //MKCoordinateRegion worldRegion = MKCoordinateRegionForMapRect(MKMapRectWorld);
            //MKCoordinateRegion worldRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(20, _mapView.centerCoordinate.longitude), MKCoordinateSpanMake(180, 360));
            
            [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(20, _mapView.centerCoordinate.longitude) zoomLevel:0 animated:YES];
            
            // TODO
            
            // Remove rotate animation when zoom to world map
            
            //            [UIView animateWithDuration:0.8 animations:^{
            //                [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(20, _mapView.centerCoordinate.longitude) zoomLevel:0 animated:YES];
            //            } completion:^(BOOL finished) {
            //                [self goforWorldMap];
            //            }];
            
        }
    } else {
        _lblRadiusMap.text = [NSString stringWithFormat:@"%ldkm", (long)radiusUpdate];
        [self stopAnimation];
        if ([Common validateLocationCoordinate2DIsValid:_userLocation]) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_userLocation, radiusUpdate * 1000.0f, radiusUpdate * 1000.0f);
            [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:radiusUpdate] forKey:@"regionMap"];
            [self updateUserPostCountForCurrentLocation:_userLocation withRadius:[self recalculatedRadiusUpdate]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserChangedCurrentRegionMapNotification object:nil userInfo:dictionary];
        }
    }
}

- (void) touchupinside:(id) sender {
    if (radiusUpdate > 6000) {
        radiusUpdate = 6000;
    }
}

#pragma mark LOCATION DELEGATE

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (fabs(howRecent) < 15.0) {
        
        //NSLog(@"Location Update: %@ %f", locations, location.horizontalAccuracy);
        
        _userLocation.latitude = location.coordinate.latitude;
        _userLocation.longitude = location.coordinate.longitude;
        [UserDefault currentUser].strLat = [NSString stringWithFormat:@"%g", location.coordinate.latitude];
        [UserDefault currentUser].strLong = [NSString stringWithFormat:@"%g", location.coordinate.longitude];
        [UserDefault performCache];
        
        if (radiusUpdate < kCircleSlideWorlRadius) {
            [self updateMapViewRegionWithUserLocation:_userLocation region:CGSizeMake(radiusUpdate * 1000.0f, radiusUpdate * 1000.0f)];
        }
        
        //_lblRadiusMap.text = [NSString stringWithFormat:@"%dkm", (int)(radiusUpdate)];
        
        if (CLLocationCoordinate2DIsValid(_userLocation) && [[UserDefault currentUser].server_access_token length] > 0) {
            [self updateUserPostCountForCurrentLocation:_userLocation withRadius:[self recalculatedRadiusUpdate]];
        }
    }
    //[locationManager stopUpdatingLocation];
}

#pragma mark MAP DELEGATE

-(void)removeAllAnnotations
{
    id userAnnotation = _mapView.userLocation;
    
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:_mapView.annotations];
    [annotations removeObject:userAnnotation];
    
    [_mapView removeAnnotations:annotations];
}

- (void)updateMapViewRegionWithUserLocation:(CLLocationCoordinate2D)userlocation region:(CGSize)regionSize{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userlocation, regionSize.width, regionSize.height);
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString* UserAnnotationIdentifier = @"UserAnnotationView";
    static NSString* NormalAnnotationIdentifier = @"NormalAnnotationView";
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        CustomLocationView *locationView = (CustomLocationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:UserAnnotationIdentifier];
        if (!locationView) {
            locationView = [[CustomLocationView alloc] initWithAnnotation:annotation reuseIdentifier:UserAnnotationIdentifier];
            locationView.canShowCallout = NO;
        }
        return locationView;
    } else {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NormalAnnotationIdentifier];
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NormalAnnotationIdentifier];
            pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.animatesDrop = NO;
            pinView.canShowCallout = NO;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //[self applyMapViewMemoryHotFix];
}


#pragma mark - USERLOCATION TRACKER

- (CLLocationManager*)locationManager {
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 30.0;//kCLDistanceFilterNone; // whenever we move
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
        _locationManager.headingFilter = 5;
        if(IS_OS_8_OR_LATER) {
            [_locationManager requestAlwaysAuthorization];
        }
    }
    
    return _locationManager;
}

#pragma mark - WEBSERVICE FUNCTIONS

- (void) postCurrentUserLocationToServer {
    
    //NSLog(@"Post user location to server");
    
    if (CLLocationCoordinate2DIsValid(_userLocation) && [[UserDefault currentUser].server_access_token length] > 0) {
        
        NSString *strStatus = @"unknow";
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        {
            strStatus = @"background_mode";
        } else {
            strStatus = @"open_app";
        }
        
        [Common showNetworkActivityIndicator];
        
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        NSDictionary *request_param = @{@"access_token":[UserDefault currentUser].server_access_token,
                                        @"latitude":@(_userLocation.latitude),
                                        @"longitude":@(_userLocation.longitude),
                                        @"status":strStatus,
                                        @"created_date":[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000],
                                        };
        
        //[[LELog sharedInstance] log:[NSString stringWithFormat: @"postCurrentUserLocationToServer : %@",request_param]];
        
        [manager PUT:URL_SERVER_API(API_UPDATE_LOCATION) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [Common hideNetworkActivityIndicator];
            
            if ([Common validateResponse:responseObject]) {
                
                [UserDefault currentUser].strLat = [NSString stringWithFormat:@"%g", _userLocation.latitude];
                [UserDefault currentUser].strLong = [NSString stringWithFormat:@"%g", _userLocation.longitude];
                [UserDefault performCache];
                
            } else {
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [Common hideNetworkActivityIndicator];
        }];
    }
}

- (void) updateUserPostCountForCurrentLocation:(CLLocationCoordinate2D)location withRadius:(CGFloat)radius {
    
    //NSLog(@"Call update post count and user count");
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *latitude = [NSString stringWithFormat:@"%f",location.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",location.longitude];
    NSString *str_radius = [NSString stringWithFormat:@"%f",radius];
    
    if (CLLocationCoordinate2DIsValid(location) && access_token && latitude && longitude && str_radius) {
        
        [Common showNetworkActivityIndicator];
        
        [self.updatePostUserCountOperation cancel];
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        
        NSDictionary *request_param = @{@"access_token":access_token,
                                        @"latitude":latitude,
                                        @"longitude":longitude,
                                        @"distance":str_radius,
                                        };
        
        self.updatePostUserCountOperation = [manager GET:URL_SERVER_API(API_GET_USER_POST_LIST) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [[UserDefault currentUser] setLastRadius:[NSString stringWithFormat:@"%f",radiusUpdate]];
            
            [Common hideNetworkActivityIndicator];
            
            if ([Common validateResponse:responseObject]) {
                
                if (responseObject[@"data"][@"post"][@"total"]) {
                    
                    totalPostCount = [responseObject[@"data"][@"post"][@"total"] integerValue];
                    
                } else {
                    
                    totalPostCount = 0;
                    
                }
                
                if (responseObject[@"data"][@"user"][@"total"]) {
                    
                    totalUserCount = [responseObject[@"data"][@"user"][@"total"] integerValue];
                    
                } else {
                    
                    totalUserCount = 0;
                    
                }
                
                
                [self updatePersonPostCountToUI];
                
            } else {
                
            }
            
            //===TODO===Update user radius to server
            
            [self _sendUserRadiusToServer:[NSString stringWithFormat:@"%ld", MIN((long)radiusUpdate, kMaxRadiusGetNotification)]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [Common hideNetworkActivityIndicator];
            
            //NSLog(@"Error: %@",error.localizedDescription);
            
        }];
    }
}

- (void)_sendUserRadiusToServer:(NSString*)radius {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    
    if (access_token && access_token.length > 0 && radius) {
        
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        
        NSDictionary *request_param = @{@"access_token":access_token,
                                        @"distance":radius};
        
        [manager PUT:URL_SERVER_API(API_USER_RADIUS) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //NSLog(@"Response radius: %@",responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
        }];
    }
}


- (void)_have_a_post_deleted {
    
    totalPostCount --;
    [self updatePersonPostCountToUI];
}

- (void)_have_a_user_blocked {
    
    totalUserCount --;
    [self updateUserPostCountForCurrentLocation:_userLocation withRadius:[self recalculatedRadiusUpdate]];
    [self updatePersonPostCountToUI];
}

- (void) updatePersonPostCountToUI {
    
    _lblNumberPosts.text = [NSString stringWithFormat:@"%@", [NSString abbreviateNumber:totalPostCount]];
    _lblNumberUsers.text = [NSString stringWithFormat:@"%@", [NSString abbreviateNumber:totalUserCount]];
}

- (void)reloadDataWhenHaveInternetConnection {
    [self refreshUI];
    [self updateUserPostCountForCurrentLocation:_userLocation withRadius:[self recalculatedRadiusUpdate]];
}

#pragma mark - UIcolletionView

- (void) actionTapDeleteImgPost:(id)sender {
    UIButton *button = (UIButton *)sender;
    UICollectionViewCell *cell = (UICollectionViewCell *)[[button superview] superview];
    NSIndexPath *indexPath = [_collectionViewPhotoShow indexPathForCell:cell];
    NSDictionary *media = [_arr_data_media objectAtIndex:indexPath.item];
    
    id mediaContent = [media objectForKey:@"media"];
    
    if ([mediaContent isKindOfClass:[NSURL class]]) {
        
        [self deleteFileTemp:(NSURL *)mediaContent];
    }
    
    [self.collectionViewPhotoShow performBatchUpdates:^{
        
        NSDictionary *media = [_arr_data_media objectAtIndex:indexPath.item];
        
        id mediaContent = [media objectForKey:@"media"];
        
        if ([mediaContent isKindOfClass:[NSURL class]]) {
            
            //[Common removeFileFromAppDirectoryAtPath:[(NSURL*)mediaContent path]];
            
            [Common removeFile:(NSURL*)mediaContent];
        }
        
        [_arr_data_media removeObjectAtIndex:indexPath.item];
        [self.collectionViewPhotoShow deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSUInteger numOfCell = [_arr_data_media count];
    
    [UIView animateWithDuration:0.5 animations:^{
        [collectionView setHidden:numOfCell == 0];
    }];
    
    return numOfCell;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, WIDTH_A_IMAGE_VIDEO_POST, WIDTH_A_IMAGE_VIDEO_POST)];
    }
    NSDictionary *media = [_arr_data_media objectAtIndex:indexPath.item];
    UIImage *thumbnail = [media objectForKey:@"thumbnail"];
    UIImageView *imagePost = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_A_IMAGE_VIDEO_POST, WIDTH_A_IMAGE_VIDEO_POST)];
    imagePost.contentMode = UIViewContentModeScaleAspectFill;
    imagePost.layer.masksToBounds = YES;
    imagePost.image = thumbnail;
    UIButton *deleteMediaButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 4, 26, 26)];
    [deleteMediaButton setBackgroundImage:[UIImage imageNamed:@"bt_img_cancel"] forState:UIControlStateNormal];
    [deleteMediaButton addTarget:self action:@selector(actionTapDeleteImgPost:) forControlEvents:UIControlEventTouchUpInside];
    deleteMediaButton.tag = 7777;
    [cell.contentView addSubview:imagePost];
    [cell.contentView addSubview:deleteMediaButton];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(WIDTH_A_IMAGE_VIDEO_POST, WIDTH_A_IMAGE_VIDEO_POST);
}

@end
