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

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import "MLBlackTransition.h"

#define kAvatarViewSize                 CGSizeMake(73.0, 73.0)
#define kIncomingMessageBackground      [UIColor colorWithRed:0.082 green:0.635 blue:0.874 alpha:1.0]
#define kOutcomingMessageBackground     [UIColor colorWithRed:0.576 green:0.780 blue:0.168 alpha:1.0]

typedef NS_ENUM(NSUInteger, FromControllerType) {
    FromMessageListVC = 0,
    FromUserProfileVC
};

@class ChatViewController;
@protocol ChatViewDelegate <NSObject>
- (void) chatViewActionBack:(ChatViewController*)chatView;
- (void) chatViewActionBlockUserSuccess:(ChatViewController *)chatView status:(NSString*)status;
@end

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatViewController : JSQMessagesViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (id)initWithReceiverEmail:(NSString *)receiverEmail groupID:(NSString *)groupId;

//Adding by Nguyen Truong Luu
@property (nonatomic, strong) id <ChatViewDelegate> delegate;
@property (nonatomic, strong) PFUser *chattingUser;
//@property (nonatomic, strong) NSDictionary* dicProfile;
@property (nonatomic, assign) FromControllerType fromVCtype;
- (void)setReceiverEmail:(NSString*)receiverEmail;
- (void)setGroupId:(NSString *)groupId;
- (void)clearOldData;

@end
