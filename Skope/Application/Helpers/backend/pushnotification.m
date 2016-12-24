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

#import <Parse/Parse.h>

#import "Define.h"

#import "pushnotification.h"

void		ParsePushUserAssign		(void)
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [PFUser currentUser];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserAssign save error.");
            PFUser *user = [PFUser currentUser];
            if (user) {
                [PFUser logInWithUsernameInBackground:user.username password:PARSE_DEFAULT_PASSWORD block:^(PFUser *user, NSError *error){
                    if (error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_OUT object:nil userInfo:nil];
                    }
                }];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_OUT object:nil userInfo:nil];
            }
		}
	}];
}

void		ParsePushUserResign		(void)
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	[installation removeObjectForKey:PF_INSTALLATION_USER];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserResign save error.");
		}
	}];
}

void		SendPushNotification	(NSString *groupId, NSString *text)
{
	PFUser *user = [PFUser currentUser];
    
    NSUInteger maxCharPush = 100;
    NSUInteger titleLength = text.length;
    NSString *trimedText = [NSString stringWithFormat:@"%@%@",[text substringToIndex:MIN(maxCharPush, titleLength)],maxCharPush<titleLength?@"...":@""];
	NSString *message = [NSString stringWithFormat:@"%@: %@", user[PF_USER_FULLNAME], trimedText];

	PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
	[query whereKey:PF_MESSAGES_GROUPID equalTo:groupId];
	[query whereKey:PF_MESSAGES_USER notEqualTo:user];
	[query includeKey:PF_MESSAGES_USER];
	[query setLimit:1000];

	PFQuery *queryInstallation = [PFInstallation query];
	[queryInstallation whereKey:PF_INSTALLATION_USER matchesKey:PF_MESSAGES_USER inQuery:query];

    NSDictionary *aps = @{
        @"alert": message,
        @"sound": @"default",
        @"badge": @"Increment",
        };
    NSString *type = @"new-message";
    
	PFPush *push = [[PFPush alloc] init];
	[push setQuery:queryInstallation];
    [push setData:@{@"aps":aps,@"type":type}];

    //[push sendPushInBackground];
    
    
	[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"SendPushNotification send error.");
		}
	}];
}

void        SendPushMessageNotificationToReceiverUserEmailAndMessage   (NSString *userEmail, NSString *message) {
    
    NSString *accessToken = [UserDefault currentUser].server_access_token;
    
    if (accessToken && accessToken.length > 0) {
        
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        
        NSDictionary *request_param = @{@"access_token":accessToken,@"message":message/*,@"email":[UserDefault currentUser].email*/};
        
        NSString *path = [URL_SERVER_API(API_PUSH_MSG_NOTIFICATION_EMAIL) stringByAppendingString:[NSString stringWithFormat:@"?email=%@",userEmail]];
        
        [manager POST:path parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Push response: %@",responseObject);
            
            if ([Common validateResponse:responseObject])
            {

            }
            else
            {
                
                switch ([Common responseStatusCode:responseObject]) {
                        
                    case 400: //Authorization required
                        NSLog(@"Authorization required");
                        break;
                        
                    case 403: //Invalid parameters supplied
                        NSLog(@"Invalid parameters supplied");
                        break;
                        
                    case 406: //The recipient didn't has device token
                        NSLog(@"The recipient didn't has device token");
                        break;
                        
                    default:
                        break;
                }
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}
