//
//  Listener.h
//  DesktopAppService
//
//  Created by Travis Spangle on 4/26/11.
//  Copyright 2011 Peak Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkListener : NSObject <NSNetServiceDelegate> {
    CFSocketRef socket_;
    NSFileHandle *connectionFileHandle_ ;
    
    NSNetService* netService;
}

@property (assign) CFSocketRef socket_;

- (void)startService;
- (void)configureService;
- (void) handleIncomingConnection:(NSNotification*)notification;
- (void) stopReceivingForFileHandle:(NSFileHandle *)readFileHandle closeFileHandle:(BOOL)close;
- (void) sendMessage:(NSString *)messageToPass;

@end
