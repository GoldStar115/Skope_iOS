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

#import "messages.h"
#import "utilities.h"
#import "MessagesListVC.h"
#import "MessagesCell.h"
#import "ChatViewController.h"
#import "UIViewController+IsVisible.h"

#define kUINavigationBarBackgroundColor [UIColor colorWithRed:35.0/255.0 green:153.0/255.0 blue:224.0/255.0 alpha:1.0]
#define kMessageCellIdentifier          @"MessagesCell"



//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MessagesListVC()
{
	NSMutableArray *messages;
    NSIndexPath      *activeIndexPath;
}
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MessagesListVC

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Messages";

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    [self.tableView registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kMessageCellIdentifier];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(loadUnReadReceivedMessages) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:_refreshControl atIndex:0];

	messages = [[NSMutableArray alloc] init];
    [self addBackButtonWithTitle:@"Back"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadUnReadReceivedMessages)
                                                 name:NEW_MSG_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appActiveRefreshBagedNumber)
                                                 name:APP_DID_ACTIVE_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userBlockedPerson:) name:kUserBlockedPersonNotification object:nil];
    
    [self loadUnReadReceivedMessages];
    
}

//Added by Nguyen Truong Luu to Custom NavigationBar Color
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBar.barTintColor = kUINavigationBarBackgroundColor;
    }];
    
}


- (void)addBackButtonWithTitle:(NSString *)title {
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back_ml.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewDidAppear:(BOOL)animated {
    
	[super viewDidAppear:animated];

    [self appActiveRefreshBagedNumber];

//	else LoginUser(self);
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)userBlockedPerson:(NSNotification *)notification {

    NSString *blockedUserEmail = [[notification userInfo] valueForKey:@"blockedUserEmail"];
    
    if (![self isVisible]) {
        //If viewcontroller is not display , remove user from old data
        if (blockedUserEmail) {
            
            for (NSInteger i = 0; i < messages.count; i++) {
                
                PFObject *message = messages[i];
                
                PFUser *chat_user = message[PF_MESSAGES_LASTUSER];
                
                NSString* userEmail = chat_user[PF_USER_EMAILCOPY];
                
                if ([userEmail isEqualToString:blockedUserEmail]) {
                    //Remove
                    
                    NSIndexPath *blockedUserIndexPath = [NSIndexPath indexPathForRow:i inSection:0];

                    [_tableView beginUpdates];
                    [messages removeObjectAtIndex:i];
                    [_tableView deleteRowsAtIndexPaths:@[blockedUserIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView endUpdates];
                    
                    [[ISDiskCache sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,userEmail]];
                    DeleteMessageItem(message);
                    
                    break;
                }
            }
        }
    }
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


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
     */
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    /*
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
     */
}

#pragma mark - Backend methods

- (void)loadUnReadReceivedMessages
{
    if ([PFUser currentUser] == nil)
    {
        return;
    }
    
    PFQuery *me_blocked_query = [PFQuery queryWithClassName:PF_ACTIVITY_CLASS_NAME];
    //[me_blocked_query selectKeys:@[PF_ACTIVITY_FROMUSERKEY]];
    [me_blocked_query whereKey:PF_ACTIVITY_FROMUSERKEY equalTo:[PFUser currentUser]];
    [me_blocked_query whereKey:PF_ACTIVITY_TYPEKEY equalTo:PF_ACTIVITY_TypeBlock];
    
    PFQuery *blocked_me_query = [PFQuery queryWithClassName:PF_ACTIVITY_CLASS_NAME];
    //[me_blocked_query selectKeys:@[PF_ACTIVITY_TOUSERKEY]];
    [blocked_me_query whereKey:PF_ACTIVITY_TOUSERKEY equalTo:[PFUser currentUser]];
    [blocked_me_query whereKey:PF_ACTIVITY_TYPEKEY equalTo:PF_ACTIVITY_TypeBlock];
    
    PFQuery *blocked_query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:me_blocked_query,blocked_me_query,nil]];
    [blocked_query includeKey:PF_ACTIVITY_FROMUSERKEY];
    [blocked_query includeKey:PF_ACTIVITY_TOUSERKEY];
    
    [blocked_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         
         NSMutableArray *users = [NSMutableArray new];
         
         [objects enumerateObjectsUsingBlock:^(PFObject *activity, NSUInteger idx, BOOL *stop) {
             if (![users containsObject:activity[PF_ACTIVITY_FROMUSERKEY]]) {
                 [users addObject:activity[PF_ACTIVITY_FROMUSERKEY]];
             }
             
             if (![users containsObject:activity[PF_ACTIVITY_TOUSERKEY]]) {
                 [users addObject:activity[PF_ACTIVITY_TOUSERKEY]];
             }
         }];
         
         PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
         [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
         //Need to remove message from blocked users and users that blocked me
         [query whereKey:PF_MESSAGES_LASTUSER notContainedIn:users];
         
         [query whereKey:PF_MESSAGES_STATUS equalTo:@"show"];
         [query includeKey:PF_MESSAGES_LASTUSER];
         [query orderByDescending:PF_MESSAGES_UPDATEDACTION];
         [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
          {
              if (error == nil)
              {
                  [messages removeAllObjects];
                  [messages addObjectsFromArray:objects];
                  [self.tableView reloadData];
              }
              else NSLog(@"Network error.");
              [self.refreshControl endRefreshing];
          }];
         
         [self appActiveRefreshBagedNumber];
         
     }];

}

- (IBAction)backToHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - User actions

- (void)startChatWithUser:(PFUser*)user groupID:(NSString *)groupId
{
    ChatViewController *chatView = [[ChatViewController alloc] initWithReceiverEmail:user[PF_USER_EMAILCOPY] groupID:groupId];
    chatView.fromVCtype = FromMessageListVC;
    chatView.chattingUser = user;
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

- (void)actionCleanup
{
	[messages removeAllObjects];
	[self.tableView reloadData];
}

#pragma mark - SelectSingleDelegate

- (void)didSelectSingleUser:(PFUser *)user2
{
	PFUser *user1 = [PFUser currentUser];
	NSString *groupId = StartPrivateChat(user1, user2);
	[self startChatWithUser:user2 groupID:groupId];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MessagesCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier forIndexPath:indexPath];
	[cell bindData:messages[indexPath.row]];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *lastUser = messages[indexPath.row][PF_MESSAGES_LASTUSER];
    [[ISDiskCache sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,lastUser[PF_USER_EMAILCOPY]]];
	DeleteMessageItem(messages[indexPath.row]);
	[messages removeObjectAtIndex:indexPath.row];
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	PFObject *message = messages[indexPath.row];
    [message setObject:@0 forKey:PF_MESSAGES_COUNTER];
    PFUser *chatingUser = message[PF_MESSAGES_LASTUSER];
    NSString* groupID = message[PF_MESSAGES_GROUPID];
	[self startChatWithUser:chatingUser groupID:groupID];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
    
}

#pragma mark - back action

- (void)back:(id)sender {
    //    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion: nil];
}

@end
