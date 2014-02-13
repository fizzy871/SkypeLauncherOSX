//
//  userView.m
//  SkypeLauncher
//
//  Created by Алексей Саечников on 12.02.14.
//  Copyright (c) 2014 unknown corp. All rights reserved.
//

#import "userView.h"

@interface userView (){
    userViewState _buttonState;
    NSButton *actionButton;
    NSString *_username;
    NSTextField *usernameTextField;
}

@end

@implementation userView

@synthesize state = _buttonState;
@synthesize username = _username;

//- (void)drawRect:(NSRect)dirtyRect {
//    // set any NSColor for filling, say white:
//    [[NSColor redColor] setFill];
//    NSRectFill(dirtyRect);
//    [super drawRect:dirtyRect];
//}

-(void)setState:(userViewState)state{
    _buttonState = state;
    if (!actionButton)
    {
        actionButton = [NSButton new];
        [actionButton setFrame:NSMakeRect(200, self.frame.size.height/2-30/2, self.frame.size.width-200, 30)];
        [actionButton setTarget:self];
        [actionButton setAction:@selector(actionButtonAction:)];
        [actionButton setAutoresizingMask:NSViewMinYMargin | NSViewMaxYMargin | NSViewWidthSizable];
        [actionButton setButtonType:NSMomentaryLightButton];
        [actionButton setBezelStyle:NSRoundedBezelStyle];
        [self addSubview:actionButton];
    }
    switch (state) {
        case userViewStateAutologin:
        {
            [actionButton setTitle:@"Autologin"];
        }
            break;
            
        case userViewStateLogin:
        {
            [actionButton setTitle:@"Login"];
//            dfsgfsdfg
        }
            break;
            
        case userViewStateSaveForAutologin:
        {
            [actionButton setTitle:@"save for autologin"];
        }
            break;
            
        default:
            break;
    }
}

-(void)setUsername:(NSString *)username{
    _username = username;
    if (!usernameTextField)
    {
        usernameTextField = [NSTextField new];
        [usernameTextField setStringValue:username];
        [usernameTextField setFrame:NSMakeRect(0, self.frame.size.height/2-10, 180, 20)];
        [usernameTextField setAutoresizingMask:NSViewHeightSizable];
        [usernameTextField setBezeled:NO];
        [usernameTextField setDrawsBackground:NO];
        [usernameTextField setEditable:NO];
        [usernameTextField setSelectable:NO];
        [usernameTextField setAlignment:NSRightTextAlignment];
        [self addSubview:usernameTextField];
    }
}

-(void)actionButtonAction:(id)sender{
    if (self.delegate)
        [self.delegate performSelector:@selector(buttonPressedInView:) withObject:self];
}

@end
