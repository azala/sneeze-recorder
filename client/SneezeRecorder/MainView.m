//
//  MainView.m
//  SneezeRecorder
//
//  Created by Michel D'Sa on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@implementation MainView

@synthesize ipTextField, ipTextFieldEntry;

//- (id)init {
//    self = [super init];
//    if (self) {
//        
//    }
//    return self;
//}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)oldInit {

    
    
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

- (void)postResult:(double)pwr withDateString:(NSString*)dateString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"EEE_MMM_d_YYYY_'at'_HH'h'mm'm'ss's'_zzz"];
//    NSString *dateString = [dateFormat stringFromDate:date];
    [dateFormat release];
    
    NSString *post = [NSString stringWithFormat:@"power=%0.1f&date=%@&user=%@",round(100*pwr)/10.0f,dateString,NSUserName()]; //@"key1=val1&key2=val2"
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *ip = self.ipTextField.stringValue;
    NSString *finalString = [NSString stringWithFormat:@"http://%@/sneeze/index.php",ip];
    [request setURL:[NSURL URLWithString:finalString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    //    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error:&error];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)postResult:(double)pwr {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE_MMM_d_YYYY_'at'_HH'h'mm'm'ss's'_zzz"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    [self postResult:pwr withDateString:dateString];
}

-(void)readFile:(NSString*)fn {
    NSString *stringData;
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:fn];
    if (!fh) {
        NSLog(@"I can't read.");
        NSFileManager *fm = [[NSFileManager alloc] init];
        [fm createFileAtPath:fn contents:[NSData data] attributes:nil];
        [fm release];
        stringData = @"";
    } else {
        stringData = [[NSString alloc] initWithData:[fh readDataToEndOfFile] encoding:NSASCIIStringEncoding];
    }
    
    NSArray *entries = [stringData componentsSeparatedByString:@"\n"];
    for (NSString *entry in entries) {
        if ([entry isEqualToString:@""])
            continue;
        NSArray *args = [entry componentsSeparatedByString:@"\t"];
        float power = [[args objectAtIndex:0] floatValue];
        NSString *dateString = [args objectAtIndex:1];
        [self postResult:power withDateString:dateString];
    }
}

#pragma mark NSURLConnection delegate methods

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    //    _data = [[NSMutableData alloc] init]; // _data being an ivar
    data = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)d
{
    [data appendData:d];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    NSLog(@"Le fail");
    // Handle the error properly
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    //    [self handleData]; // Deal with the data
    NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@", receivedString);
}

- (void)levelTimerCallback:(NSTimer *)timer {
    cooldown -= timer.timeInterval;
    if (maxpp != 0 && cooldown <= 0) {
        [self postResult:maxpp];
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


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self oldInit];
    }
    return self;
}

#pragma mark NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    self.ipTextField.stringValue = fieldEditor.string;
    return YES;
}

- (IBAction)submit:(id)sender {
    self.ipTextField.stringValue = self.ipTextFieldEntry.stringValue;
    [self readFile:@"/Users/mdsa/Desktop/foo.txt"];
}

- (IBAction)fakeRecord:(id)sender {
    [self postResult:5];
}

@end
