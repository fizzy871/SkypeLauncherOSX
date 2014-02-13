//
//  userView.h
//  SkypeLauncher
//
//  Created by Алексей Саечников on 12.02.14.
//  Copyright (c) 2014 unknown corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef enum
{
    userViewStateAutologin,
    userViewStateSaveForAutologin,
    userViewStateLogin
}userViewState;

@class userView;

@protocol userViewDelegale <NSObject>

@required
-(void)buttonPressedInView:(userView*)view;
@end

@interface userView : NSView

@property (nonatomic, strong) NSString *username;
@property (nonatomic) userViewState state;
@property (nonatomic, weak) id<userViewDelegale>delegate;

//-(void) setState:(userViewState)state;

@end
