//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <MediaPlayer/MediaPlayer.h>
#import "camera.h"
#import "messages.h"
#import "ReportUserView.h"
#import "pushnotification.h"
#import "ChatViewController.h"
#import "UIViewController+IsVisible.h"
#import "UIBarButtonItem+Categories.h"


#define AlertBlockUserTag           66
#define AlertReportUserTag          88

@interface ChatViewController() <ReportUserViewDelegate,PopoverViewDelegate>
{

    BOOL initialized;
    
    NSMutableArray *users;
    NSMutableArray *messages;
    NSMutableDictionary *avatars;
    
    JSQMessagesBubbleImage *bubbleImageOutgoing;
    JSQMessagesBubbleImage *bubbleImageIncoming;
    JSQMessagesAvatarImage *avatarImageBlank;
}

//Changing by Nguyen Truong Luu
@property (nonatomic, strong) NSString      *groupId;
@property (nonatomic, strong) NSString      *receiverEmail;
@property (nonatomic, strong) NSDictionary *InComingsenderNameTextAttributes;
@property (nonatomic, strong) NSDictionary *InComingtimeTextAttributes;
@property (nonatomic, strong) NSDictionary *OutComingsenderNameTextAttributes;
@property (nonatomic, strong) NSDictionary *OutComingtimeTextAttributes;
@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, strong) PFQuery *messageQuery;
@end

@implementation ChatViewController

- (NSDictionary*)InComingsenderNameTextAttributes {
    if (!_InComingsenderNameTextAttributes) {
        NSMutableParagraphStyle *rightAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        rightAlign_paragraphStyle.alignment = NSTextAlignmentRight;
        rightAlign_paragraphStyle.firstLineHeadIndent = 15.0f;
        rightAlign_paragraphStyle.headIndent = 15.0f;
        rightAlign_paragraphStyle.tailIndent = -15.0f;
        _InComingsenderNameTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0f],
                                               NSForegroundColorAttributeName : [UIColor colorWithRed:0.639 green:0.796 blue:0.847 alpha:1.0],
                                               NSParagraphStyleAttributeName : rightAlign_paragraphStyle };
    }
    return _InComingsenderNameTextAttributes;
}

- (NSDictionary*)OutComingsenderNameTextAttributes {
    if (!_OutComingsenderNameTextAttributes) {
        NSMutableParagraphStyle *leftAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        leftAlign_paragraphStyle.alignment = NSTextAlignmentLeft;
        leftAlign_paragraphStyle.firstLineHeadIndent = 15.0f;
        leftAlign_paragraphStyle.headIndent = 15.0f;
        leftAlign_paragraphStyle.tailIndent = -15.0f;
        
        _OutComingsenderNameTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0f],
                                                NSForegroundColorAttributeName : [UIColor colorWithRed:0.639 green:0.796 blue:0.847 alpha:1.0],
                                                NSParagraphStyleAttributeName : leftAlign_paragraphStyle };
    }
    return _OutComingsenderNameTextAttributes;
}

- (NSDictionary*)InComingtimeTextAttributes {
    if (!_InComingtimeTextAttributes) {
        NSMutableParagraphStyle *rightAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        rightAlign_paragraphStyle.alignment = NSTextAlignmentRight;
        rightAlign_paragraphStyle.firstLineHeadIndent = 15.0f;
        rightAlign_paragraphStyle.headIndent = 15.0f;
        rightAlign_paragraphStyle.tailIndent = -15.0f;
        
        _InComingtimeTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12.0f],
                                         NSForegroundColorAttributeName : [UIColor colorWithRed:0.639 green:0.796 blue:0.847 alpha:1.0],
                                         NSParagraphStyleAttributeName : rightAlign_paragraphStyle };
    }
    return _InComingtimeTextAttributes;
}

- (NSDictionary*)OutComingtimeTextAttributes {
    if (!_OutComingtimeTextAttributes) {
        NSMutableParagraphStyle *leftAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        leftAlign_paragraphStyle.alignment = NSTextAlignmentLeft;
        leftAlign_paragraphStyle.firstLineHeadIndent = 15.0f;
        leftAlign_paragraphStyle.headIndent = 15.0f;
        leftAlign_paragraphStyle.tailIndent = -15.0f;
        
        _OutComingtimeTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12.0f],
                                          NSForegroundColorAttributeName : [UIColor colorWithRed:0.639 green:0.796 blue:0.847 alpha:1.0],
                                          NSParagraphStyleAttributeName : leftAlign_paragraphStyle };
    }
    return _OutComingtimeTextAttributes;
}


- (id)initWithReceiverEmail:(NSString *)receiverEmail groupID:(NSString *)groupId
{
    self = [super init];
    if (self) {
        [self setGroupId:groupId];
        [self setReceiverEmail:receiverEmail];
    }
    return self;
}

//Added by Nguyen Truong Luu

- (void)setReceiverEmail:(NSString*)receiverEmail {
    _receiverEmail = receiverEmail;
    [self loadChattingUser];
}

- (void)setGroupId:(NSString *)groupId {
    
    _groupId = groupId;
    
    if (_groupId) {
        
        //clear all old data
        [self clearOldData];

        //Do something after have group IDNSLog(@"Group ID: %@",groupId);
        
        [self loadMessages];

        [Common hideLoadingViewGlobal];
    }
}

- (void)clearOldData {
    if (_groupId) {
        ClearMessageCounter(_groupId);
    }
    
    [users removeAllObjects];
    [messages removeAllObjects];
    [avatars removeAllObjects];
    
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController enabledMLBlackTransition:YES];
    
    //Add by Nguyen Truong Luu for resize avatar size
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = kAvatarViewSize;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = kAvatarViewSize;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:kOutcomingMessageBackground];
    bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:kIncomingMessageBackground];
    
    avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:kAvatarViewSize.width];
    
    initialized = NO;
    
    users = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    avatars = [[NSMutableDictionary alloc] init];
    
    PFUser *user = [PFUser currentUser];
    self.senderId = user.objectId;
    self.senderDisplayName = user[PF_USER_FULLNAME];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMessages)
                                                 name:NEW_MSG_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appActiveRefreshBagedNumber)
                                                 name:APP_DID_ACTIVE_NOTIFICATION
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Added by Nguyen Truong Luu - Change navigationBar color to whiteColor
    if (self.navigationController.navigationBar.barTintColor != [UIColor whiteColor]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        }];
    }
    
    [self addBackButtonWithTitle:@"Back"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    
    [self appActiveRefreshBagedNumber];
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)appActiveRefreshBagedNumber {
    
    if ([self isVisible]) {
        [self refreshBagedNumber];
    }
}

- (void)refreshBagedNumber {
    
    [[UserDefault currentUser] setMessageBagedNumber:@"0"];
    [UserDefault performCache];
        
    [AppDelegate resetNotificationBagedNumberToServerWithType:kNotificationNewMessage];
    [AppDelegate updateAppIconBadgedNumber];

}


- (void)addBackButtonWithTitle:(NSString *)title
{
    //Chagned by Nguyen Truong Luu
    switch (_fromVCtype) {
        case FromMessageListVC:
        {
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back_ml.png"] style:UIBarButtonItemStylePlain target:self action:@selector(action_back:)];
            backButton.tintColor = [UIColor redColor];
            self.navigationItem.leftBarButtonItem = backButton;
            
            UIBarButtonItem *reportButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"down_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(action_report_block:)];
            reportButton.tintColor = [UIColor redColor];
            self.navigationItem.rightBarButtonItem = reportButton;
            
        }
            break;
        case FromUserProfileVC:
        {
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back_ul.png"] style:UIBarButtonItemStylePlain target:self action:@selector(action_back:)];
            backButton.tintColor = [UIColor redColor];
            self.navigationItem.rightBarButtonItem = backButton;

            UIBarButtonItem *reportButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"down_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(action_report_block:)];
            reportButton.tintColor = [UIColor redColor];
            self.navigationItem.leftBarButtonItem = reportButton;
        }
            break;
        default:
            break;
    }
}

- (UIBarButtonItem*)barItemWithImage:(UIImage*)image title:(NSString*)title target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

#pragma mark - Backend methods

- (void)loadChattingUser {
    if (!_chattingUser) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"emailCopy" equalTo:_receiverEmail];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
            
            PFUser *user = (PFUser *)object;
            if (user) {
                [self setChattingUser:user];
            } else {
                
            }
        }];
    }
}

- (void)loadMessages
{
    [self.messageQuery cancel];
    
    JSQMessage *message_last = [messages lastObject];
    
    self.messageQuery = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [_messageQuery whereKey:PF_CHAT_GROUPID equalTo:_groupId];
    
    if (message_last != nil) [_messageQuery whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
    [_messageQuery includeKey:PF_CHAT_USER];
    [_messageQuery orderByDescending:PF_CHAT_CREATEDAT];
    [_messageQuery setLimit:50];
    
    [_messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             BOOL incoming = NO;
             self.automaticallyScrollsToMostRecentMessage = NO;
             for (PFObject *object in [objects reverseObjectEnumerator])
             {                 
                 JSQMessage *message = [self addMessage:object];
                 
                 if ([self incoming:message]) {
                     incoming = YES;
                 }
             }
             if ([objects count] != 0)
             {
                 if (initialized && incoming) {
                     [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                 }
                 
                 [super finishReceivingMessage];
                 [super scrollToBottomAnimated:NO];
             }
             self.automaticallyScrollsToMostRecentMessage = YES;
             initialized = YES;
         }
         else {
             
             //NSLog(@"Network error.");
         }
         
     }];
    
    [self appActiveRefreshBagedNumber];
    
}

- (JSQMessage *)addMessage:(PFObject *)object
{
    JSQMessage *message;
    PFUser *user = object[PF_CHAT_USER];
    NSString *name = user[PF_USER_FULLNAME];
    
    PFFile *fileVideo = object[PF_CHAT_VIDEO];
    PFFile *filePicture = object[PF_CHAT_PICTURE];
    
    if ((filePicture == nil) && (fileVideo == nil))
    {
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt text:object[PF_CHAT_TEXT]];
    }
    
    if (fileVideo != nil)
    {
        JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:fileVideo.url] isReadyToPlay:YES];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
    }
    
    if (filePicture != nil)
    {
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
        
        [filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 mediaItem.image = [UIImage imageWithData:imageData];
                 [self.collectionView reloadData];
             }
         }];
    }
    
    [users addObject:user];
    [messages addObject:message];
    
    return message;
}


- (void)sendMessage:(NSString *)message Video:(NSURL *)video Picture:(UIImage *)picture

{
    if (!_groupId || _groupId.length == 0) {
        
        //===Not alow send message if have no groupID
        
        return;
    }
    
    PFFile *fileVideo = nil;
    PFFile *filePicture = nil;

    if (video != nil)
    {
        message = @"[Video message]";
        fileVideo = [PFFile fileWithName:@"video.mp4" data:[[NSFileManager defaultManager] contentsAtPath:video.path]];
        [fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) {
                 //NSLog(@"Network error.");
             }
         }];
    }

    if (picture != nil)
    {
        message = @"[Picture message]";
        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImagePNGRepresentation(picture)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil)
             {
                 //NSLog(@"Picture save error.");
             }
         }];
    }

    PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    object[PF_CHAT_USER] = [PFUser currentUser];
    object[PF_CHAT_GROUPID] = _groupId;
    object[PF_CHAT_TEXT] = message;
    
    if (fileVideo != nil) object[PF_CHAT_VIDEO] = fileVideo;
    if (filePicture != nil) object[PF_CHAT_PICTURE] = filePicture;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             [self loadMessages];
         }
         else  {
             //NSLog(@"Network error.");
         }
     }];

    //===Notification
    
    //SendPushNotification(_groupId, message);
    
    SendPushMessageNotificationToReceiverUserEmailAndMessage(_receiverEmail, message);
    
    UpdateMessageCounter(_groupId, message);

    [self finishSendingMessage];
}

#pragma mark - JSQMessagesViewController method overrides


- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date

{
    [self sendMessage:text Video:nil Picture:nil];
}


- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Take photo or video", @"Choose existing photo", @"Choose existing video", nil];
    //[action showInView:self.view];
    [action showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    if ([self outgoing:messages[indexPath.item]])
    {
        return bubbleImageOutgoing;
    }
    else return bubbleImageIncoming;
}


- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = users[indexPath.item];
    
    if (avatars[user.objectId] == nil)
    {
        PFFile *file = user[PF_USER_PICTURE];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:kAvatarViewSize.width];
                 [self.collectionView reloadData];
             }
         }];
        return avatarImageBlank;
    }
    else return avatars[user.objectId];
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message]) {
        return nil;
    } else {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:message.senderDisplayName attributes:self.OutComingsenderNameTextAttributes];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" | "]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[message.date formattedAsTimeAgo] attributes:self.OutComingtimeTextAttributes]];
        return attrString;
        //return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}



- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message]) {
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:/*[Common hiddenName:message.senderDisplayName]*/message.senderDisplayName attributes:self.InComingsenderNameTextAttributes];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" | "]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[message.date formattedAsTimeAgo] attributes:self.InComingtimeTextAttributes]];
        return attrString;
        //return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    } else {
        return nil;
    }
}



- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    /*
     JSQMessage *message = messages[indexPath.item];
     if ([self incoming:message])
     {
     if (indexPath.item > 0)
     {
     JSQMessage *previous = messages[indexPath.item-1];
     if ([previous.senderId isEqualToString:message.senderId])
     {
     return nil;
     }
     }
     return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
     }
     else return nil;
     */
}

#pragma mark - UICollectionView DataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = messages[indexPath.item];
    if (!message.isMediaMessage) {
        
        if ([self outgoing:message])
        {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else
        {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = messages[indexPath.item];
    JSQMessage *nextMsg,*prevMsg;
    
    if (indexPath.item < messages.count - 1) {
        
        nextMsg = messages[indexPath.item + 1];
    }
    
    if (indexPath.item > 0) {
        
        prevMsg = messages[indexPath.item - 1];
    }
    
    if ([self incoming:message]) {
        
        return 0;
        
    } else {
        
        NSAttributedString *attributeStringTopLabel = [self collectionView:collectionView attributedTextForCellTopLabelAtIndexPath:indexPath];
        NSString* string = attributeStringTopLabel.string;
        CGFloat textHeight = [Common getHeightString:string withAttribute:self.OutComingsenderNameTextAttributes widthConstraint:collectionView.bounds.size.width - 85];
        return textHeight + 10;
        
        //return kJSQMessagesCollectionViewCellLabelHeightDefault;
        /*
         if ([prevMsg.senderId isEqualToString:message.senderId])
         {
         return 0;
         } else {
         return kJSQMessagesCollectionViewCellLabelHeightDefault;
         }
         */
    }
    
    /*
     if (indexPath.item % 3 == 0)
     {
     JSQMessage *message = messages[indexPath.item];
     if ([self incoming:message]) {
     return 0;
     } else {
     return kJSQMessagesCollectionViewCellLabelHeightDefault;
     }
     }
     else return 0;
     */
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
    
    /*
     JSQMessage *message = messages[indexPath.item];
     if ([self incoming:message])
     {
     if (indexPath.item > 0)
     {
     JSQMessage *previous = messages[indexPath.item-1];
     if ([previous.senderId isEqualToString:message.senderId])
     {
     return 0;
     }
     }
     return kJSQMessagesCollectionViewCellLabelHeightDefault;
     }
     else return 0;
     */
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = messages[indexPath.item];
    JSQMessage *nextMsg,*prevMsg;
    
    if (indexPath.item < messages.count - 1) {
        nextMsg = messages[indexPath.item + 1];
    }
    
    if (indexPath.item > 0) {
        prevMsg = messages[indexPath.item - 1];
    }
    
    if ([self incoming:message]) {

        NSAttributedString *attributeStringTopLabel = [self collectionView:collectionView attributedTextForCellBottomLabelAtIndexPath:indexPath];
        NSString* string = attributeStringTopLabel.string;
        CGFloat textHeight = [Common getHeightString:string withAttribute:self.InComingsenderNameTextAttributes widthConstraint:collectionView.bounds.size.width - 85];
        return textHeight + 10;
        
        //return kJSQMessagesCollectionViewCellLabelHeightDefault;
        /*
         if ([nextMsg.senderId isEqualToString:message.senderId])
         {
         return 0;
         } else {
         return kJSQMessagesCollectionViewCellLabelHeightDefault;
         }
         */
    } else {
        
        return 0;
        
    }
    
    /*
     if (indexPath.item % 3 == 0) {
     JSQMessage *message = messages[indexPath.item];
     if ([self incoming:message]) {
     return kJSQMessagesCollectionViewCellLabelHeightDefault;
     } else {
     return 0;
     }
     } else
     return 0;
     */
}

#pragma mark - Responding to collection view tap events


- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    //NSLog(@"didTapLoadEarlierMessagesButton");
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"didTapAvatarImageView");
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = messages[indexPath.item];
    if (message.isMediaMessage)
    {
        if ([message.media isKindOfClass:[JSQVideoMediaItem class]])
        {
            JSQVideoMediaItem *mediaItem = (JSQVideoMediaItem *)message.media;
            MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayer];
            [moviePlayer.moviePlayer play];
        }
    }
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    //NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (buttonIndex == 0)	ShouldStartMultiCamera(self, YES);
        if (buttonIndex == 1)	ShouldStartPhotoLibrary(self, YES);
        if (buttonIndex == 2)	ShouldStartVideoLibrary(self, YES);
    }
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *video = info[UIImagePickerControllerMediaURL];
    UIImage *picture = info[UIImagePickerControllerEditedImage];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self sendMessage:nil Video:video Picture:picture];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

- (BOOL)incoming:(JSQMessage *)message
{
    return ([message.senderId isEqualToString:self.senderId] == NO);
}


- (BOOL)outgoing:(JSQMessage *)message
{
    return ([message.senderId isEqualToString:self.senderId] == YES);
}

#pragma mark - ACTION
- (void)backAfterBlockUser:(NSString*)status {
    if (_fromVCtype == FromUserProfileVC) {
        if ([_delegate respondsToSelector:@selector(chatViewActionBlockUserSuccess:status:)]) {
            [_delegate chatViewActionBlockUserSuccess:self status:status];
        }
    } else {
        
        if (self.navigationController.presentingViewController) {
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [SVProgressHUD showInfoWithStatus:status];
            }];
        } else if (self.navigationController && [[self.navigationController.viewControllers lastObject] isKindOfClass:[self class]]) {
            [self.navigationController popViewControllerAnimated:YES];
            [SVProgressHUD showInfoWithStatus:status];
        }
    }
}

- (IBAction)action_back:(id)sender {
    if ([_delegate respondsToSelector:@selector(chatViewActionBack:)]) {
        [_delegate chatViewActionBack:self];
    } else {
        if (self.navigationController && [[self.navigationController.viewControllers lastObject] isKindOfClass:[self class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion: nil];
        }

    }
}

- (IBAction)action_report_block:(UIBarButtonItem*)sender {
    
    CGRect showRect = [sender frameInView:self.view];
    CGPoint showPoint = CGPointMake(CGRectGetMidX(showRect), CGRectGetMidY(showRect));
    
    ReportUserView *reportView = [[ReportUserView alloc] init];
    reportView.delegate = self;
    self.popoverView = [PopoverView showPopoverAtPoint:showPoint
                                                inView:self.view
                                              maskType:PopoverMaskTypeGradient
                                       withContentView:reportView
                                              delegate:self];
}


- (IBAction)action_report_block_button:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    
    CGRect showRect = [button.superview convertRect:button.frame toView:self.view];
    
    CGPoint showPoint = CGPointMake(CGRectGetMidX(showRect), CGRectGetMidY(showRect));
    
    ReportUserView *reportView = [[ReportUserView alloc] init];
    reportView.delegate = self;
    self.popoverView = [PopoverView showPopoverAtPoint:showPoint
                                                inView:self.view
                                              maskType:PopoverMaskTypeGradient
                                       withContentView:reportView
                                              delegate:self];
}


#pragma mark - ReportViewDelegate

- (void)reportpostView:(ReportUserView*)view didPressedReportButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to report this user?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertReportUserTag];
    }];
}

- (void)reportpostView:(ReportUserView*)view didPressedBlockUserButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to block user and remove all posts?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertBlockUserTag];
    }];
}


#pragma mark - PopoverViewDelegate Methods

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.popoverView = nil;
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
                
            case AlertReportUserTag:
            {
                //===Report this user
                
                NSString *reported_user_email = _receiverEmail;
                
                if (!reported_user_email) {
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while report this user!\nPlease try again later!"];
                    return;
                }
                
                [Common showNetworkActivityIndicator];
                
                AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                NSDictionary *request_param = @{@"access_token":access_token,
                                                @"email":reported_user_email,
                                                };
                
                [manager PUT:URL_SERVER_API(API_REPORT_EMAIL(reported_user_email,access_token)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
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
                            errorMsg = @"There was an issue while report this user!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                        
                        //[Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    //completion(NO,nil);
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while report this user!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while report this user!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];
                
            }
                break;
                
            case AlertBlockUserTag:
            {
                
                //===Block this user
                
                NSString *blocked_user_email = _receiverEmail;
                
                if (!blocked_user_email || !_chattingUser) {
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while block this user!\nPlease try again later!"];
                    return;
                }

                [Common showNetworkActivityIndicator];
                
                [PAPUtility blockUserEventually:_chattingUser block:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        
                        //Sync Block status to main Server
                        
                        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                        NSDictionary *request_param = @{@"access_token":access_token,
                                                        @"email":blocked_user_email,
                                                        };
                        
                        [manager PUT:URL_SERVER_API(API_BLOCK_EMAIL(blocked_user_email,access_token)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            [Common hideNetworkActivityIndicator];
                            
                            if ([Common validateResponse:responseObject]) {
                                
                                NSString* successMsg = responseObject[@"data"][@"message"];
                                if (!successMsg || successMsg.length == 0) {
                                    successMsg = @"User was blocked!";
                                }
                                
                                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                                NSDictionary *userInfo = @{ @"blockedUserEmail": blocked_user_email };
                                [notificationCenter postNotificationName:kUserBlockedPersonFromChatVCNotification object:nil userInfo:userInfo];
                                [notificationCenter postNotificationName:kUserBlockedPersonNotification object:nil userInfo:userInfo];
                                [notificationCenter postNotificationName:kDecreaseUsersCountNotification object:nil];
                                
                                [self backAfterBlockUser:successMsg];
   
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
                        
                    } else {
                        
                    }
                }];
                
                //NSLog(@"Block user");
            }
                break;
            default:
                break;
        }
    }
}

@end
