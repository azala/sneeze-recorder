//
//  MainView.m
//  SneezeRecorder
//
//  Created by Michel D'Sa on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"

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

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//    }
//    return self;
//}

#pragma mark NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    self.ipTextField.stringValue = fieldEditor.string;
    return YES;
}

- (IBAction)submit:(id)sender {
    self.ipTextField.stringValue = self.ipTextFieldEntry.stringValue;
}

@end
