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

#import "converters.h"
#import "MessagesCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MessagesCell()
{
	PFObject *message;
}

@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelSenderName;
@property (strong, nonatomic) IBOutlet UILabel *labelLastMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelElapsed;
@property (strong, nonatomic) IBOutlet UILabel *labelCounter;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MessagesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _imageUser.layer.cornerRadius = 35.0;
    _imageUser.layer.masksToBounds = YES;
    _imageUser.contentMode = UIViewContentModeScaleAspectFit;
    //[Common circleImageView:_imageUser];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _labelSenderName.text = @"";
    _labelLastMessage.text = @"";
    _labelElapsed.text = @"";
    _labelCounter.text = @"";
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(PFObject *)message_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	message = message_;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *lastUser = message[PF_MESSAGES_LASTUSER];
//    PFUser *currentUser = message[PF_MESSAGES_USER];
//    NSLog(@"currentUser - %@",currentUser);
//    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
//    [query whereKey:@"objectId" equalTo:currentUser.objectId];
//    
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (error) {
//            // There was an error
//            NSLog(@"%@",error);
//        } else {
//            NSLog(@" result - %@",object);
//        }
//    }];
    
	[_imageUser setFile:lastUser[PF_USER_PICTURE]];
	[_imageUser loadInBackground];

	//---------------------------------------------------------------------------------------------------------------------------------------------
    
    _labelSenderName.text = [[message objectForKey:@"lastUser"] objectForKey:@"fullname"];//[Common hiddenName:[[message objectForKey:@"lastUser"] objectForKey:@"fullname"]];
	_labelLastMessage.text = message[PF_MESSAGES_LASTMESSAGE];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:message[PF_MESSAGES_UPDATEDACTION]];
	_labelElapsed.text = TimeElapsed(seconds);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	int counter = [message[PF_MESSAGES_COUNTER] intValue];
	_labelCounter.text = (counter == 0) ? @"" : [NSString stringWithFormat:@"%d new", counter];
}

@end
