//
//  MainView.h
//  SneezeRecorder
//
//  Created by Michel D'Sa on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AVAudioRecorder;

@interface MainView : NSView <NSTextFieldDelegate, NSURLConnectionDelegate> {
    AVAudioRecorder *recorder;
    NSTimer *levelTimer;
    double lowPassResults;
    double cooldown;
    double maxpp;
    NSMutableData *data;
}

@property (nonatomic, retain) IBOutlet NSTextField *ipTextField;
@property (nonatomic, retain) IBOutlet NSTextField *ipTextFieldEntry;

- (IBAction)submit:(id)sender;
- (void)readFile:(NSString*)fn;


@end
