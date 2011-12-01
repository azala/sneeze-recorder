//
//  MainView.h
//  MicBlow
//
//  Created by Michel D'Sa on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainView : NSView <NSTextFieldDelegate>

@property (nonatomic, retain) IBOutlet NSTextField *ipTextField;
@property (nonatomic, retain) IBOutlet NSTextField *ipTextFieldEntry;

- (IBAction)submit:(id)sender;

@end
