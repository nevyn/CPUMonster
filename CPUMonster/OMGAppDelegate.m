#import "OMGAppDelegate.h"
#import <CommonCrypto/CommonDigest.h>



@interface OMGAppDelegate ()
-(IBAction)setJobAmount:(id)sender;
-(IBAction)setJobTime:(id)sender;
-(IBAction)setJobSize:(id)sender;
@end

@implementation OMGAppDelegate {
	NSTimer *dispatchJobTimer;
	NSTimeInterval time;
	float size;
	UILabel *txtAmount, *txtSize, *txtTime;
	UIButton *bgButton;
	UIBackgroundTaskIdentifier bgTask;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	UISlider *jobAmount = [[UISlider alloc] initWithFrame:CGRectMake(10, 30, 200, 40)];
	txtAmount = [[UILabel alloc] initWithFrame:CGRectMake(220, 30, 100, 40)];
	jobAmount.value = 1;
	jobAmount.minimumValue = 0.1;
	jobAmount.maximumValue = 1000;
	[jobAmount addTarget:self action:@selector(setJobAmount:) forControlEvents:UIControlEventValueChanged];
	UISlider *jobSize = [[UISlider alloc] initWithFrame:CGRectMake(10, 80, 200, 40)];
	txtSize = [[UILabel alloc] initWithFrame:CGRectMake(220, 80, 100, 40)];
	jobSize.value = 100;
	jobSize.maximumValue = 10000;
	[jobSize addTarget:self action:@selector(setJobSize:) forControlEvents:UIControlEventValueChanged];
	
	UISlider *jobTime = [[UISlider alloc] initWithFrame:CGRectMake(10, 130, 200, 40)];
	txtTime = [[UILabel alloc] initWithFrame:CGRectMake(220, 130, 100, 40)];
	jobTime.value = time = 0.01;
	jobTime.maximumValue = 0.1;
	[jobTime addTarget:self action:@selector(setJobTime:) forControlEvents:UIControlEventValueChanged];
	
	[self.window addSubview:jobAmount];
	[self.window addSubview:txtAmount];
	[self.window addSubview:jobSize];
	[self.window addSubview:txtSize];
	[self.window addSubview:jobTime];
	[self.window addSubview:txtTime];
	
	[self setJobSize:jobSize];
	[self setJobTime:jobTime];
	[self setJobAmount:jobAmount];
	
	bgButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bgButton.frame = CGRectMake(10, 190, 200, 50);
	[bgButton setTitle:@"Not backgrounded" forState:UIControlStateNormal];
	[bgButton setTitle:@"Backgrounded" forState:UIControlStateSelected];
	[bgButton addTarget:self action:@selector(toggleBg) forControlEvents:UIControlEventTouchUpInside];
	
	[self.window addSubview:bgButton];
	
    return YES;
}
-(IBAction)setJobAmount:(UISlider*)sender;
{
	[dispatchJobTimer invalidate]; dispatchJobTimer = nil;
	dispatchJobTimer = [NSTimer scheduledTimerWithTimeInterval:1./[sender value] target:self selector:@selector(dispatch) userInfo:nil repeats:YES];
	txtAmount.text = [NSString stringWithFormat:@"%.0f jobs/s", [sender value]];
	NSLog(@"%.0f jobs per second", [sender value]);
}
-(IBAction)setJobSize:(UISlider*)sender;
{
	size = [sender value];
	txtSize.text = [NSString stringWithFormat:@"%.0fb/job", [sender value]];
	NSLog(@"New job size: %.0f", size);
}
-(IBAction)setJobTime:(UISlider*)sender;
{
	time = [sender value];
	txtTime.text = [NSString stringWithFormat:@"%.3fs/job", [sender value]];
	NSLog(@"Work for %.3f seconds per job", time);
}
-(void)dispatch;
{
	NSTimeInterval started = [NSDate timeIntervalSinceReferenceDate];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		char *mdata = malloc(size);
		NSData *data = [[NSData alloc] initWithBytesNoCopy:mdata length:size freeWhenDone:YES];
		
		while([NSDate timeIntervalSinceReferenceDate] < started + time) {
		  unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
		  CC_MD5(data.bytes, data.length, md5Buffer);
		}
	});
}
-(void)toggleBg;
{
	if(bgTask) {
		[[UIApplication sharedApplication] endBackgroundTask:bgTask];
		bgTask = 0;
	} else
		bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			[[UIApplication sharedApplication] endBackgroundTask:bgTask];
			bgTask = 0;
			bgButton.selected = NO;
		}];
	bgButton.selected = bgTask != 0;
}
@end
