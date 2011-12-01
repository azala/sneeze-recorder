//
//  AppDelegate.m
//  SneezeRecorder
//
//  Created by Michel D'Sa on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    maxpp = 0;
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
    
	NSError *error;
    
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
	if (recorder) {
		[recorder prepareToRecord];
		recorder.meteringEnabled = YES;
		[recorder record];
		levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
	} else
		NSLog(@"%@",[error description]);	
}

- (void)postResult {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE_MMM_d_YYYY_'at'_HH'h'mm'm'ss's'_zzz"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    [dateFormat release];
    
    NSString *post = [NSString stringWithFormat:@"power=%.1f&date=%@",round(100*maxpp)/10.0f,dateString]; //@"key1=val1&key2=val2"
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *ip = ((MainView*)self.window.contentView).ipTextField.stringValue;
    NSString *finalString = [NSString stringWithFormat:@"http://%@/sneeze/index.php",ip];
    [request setURL:[NSURL URLWithString:finalString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error:&error];
    if (error != 0) {
        NSLog(@"no error");
    } else {
        NSLog(@"%@",[error description]);
    }

}

- (void)levelTimerCallback:(NSTimer *)timer {
    cooldown -= timer.timeInterval;
    if (maxpp != 0 && cooldown <= 0) {
        [self postResult];
        maxpp = 0;
        return;
    }
    
	[recorder updateMeters];
    
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
//    NSLog(@"%f",peakPowerForChannel);
    if (peakPowerForChannel > MAX(0.3, maxpp)) {
        maxpp = peakPowerForChannel;
        NSLog(@"%f",maxpp);
        cooldown = 1;
    }
}

@end
