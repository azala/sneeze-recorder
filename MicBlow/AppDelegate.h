//
//  AppDelegate.h
//  MicBlow
//
//  Created by Michel D'Sa on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AVAudioRecorder;

@interface AppDelegate : NSObject <NSApplicationDelegate> {

    AVAudioRecorder *recorder;
    NSTimer *levelTimer;
    double lowPassResults;
    double cooldown;
    double maxpp;
}

@property (assign) IBOutlet NSWindow *window;

@end
