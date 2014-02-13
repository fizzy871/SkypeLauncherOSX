//
//  skypeLauncher.h
//  test
//
//  Created by Алексей Саечников on 10.02.14.
//  Copyright (c) 2014 unknown corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface skypeLauncher : NSObject{
    @private
    IBOutlet NSView *contentView;
    IBOutlet NSWindow *window;
}

+(NSArray*)users;

@end
