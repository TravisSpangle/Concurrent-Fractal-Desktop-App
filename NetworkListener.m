//
//  Listener.m
//  DesktopAppService
//
//  Created by Travis Spangle on 4/26/11.
//  Copyright 2011 Peak Systems. All rights reserved.
//

#import "NetworkListener.h"
#include <sys/socket.h>
#include <netinet/in.h>

#include <unistd.h>
#import <arpa/inet.h>

@implementation NetworkListener

@synthesize socket_;

NSString* const	kServiceTypeString = @"_tkslistener._tcp.";
NSString* const	kServiceNameString = @"HW3 listen service";
const int kListenPort = 8081;

- (void)dealloc
{
    [netService setDelegate:nil];
    [netService stop];
    [netService release];
    
    [super dealloc];
}

- (void)startService;
{
    [self configureService];
    
    netService = [[NSNetService alloc] initWithDomain:@"" 
                                                 type:kServiceTypeString
                                                 name: kServiceNameString 
                                                 port:kListenPort];
    
    [self sendMessage:[NSString stringWithFormat:@"%@ is now listening on %@:%d",kServiceNameString, kServiceTypeString, kListenPort]];    
     
    [netService setDelegate:self];
    [netService publish];
}

- (void)configureService;
{
    socket_ = CFSocketCreate
    (
     kCFAllocatorDefault,
     PF_INET,
     SOCK_STREAM,
     IPPROTO_TCP,
     0,
     NULL,
     NULL
     ); 
    
    int resuse = 1;
    int fileDescriptor = CFSocketGetNative(socket_);
    setsockopt(
               fileDescriptor,
               SOL_SOCKET,
               SO_REUSEADDR,
               (void *)&resuse,
               sizeof(resuse)
               );
    
    struct sockaddr_in address;
	memset(&address, 0, sizeof(address));
	address.sin_len = sizeof(address);
	address.sin_family = AF_INET;
	address.sin_addr.s_addr = htonl(INADDR_ANY);
	address.sin_port = htons(8081);
    
    //Create address
    CFDataRef addressData = CFDataCreate(NULL, (const UInt8 *)&address, sizeof(address));
	
	[(id)addressData autorelease];
	
	
	// binding socket to to address
	if (CFSocketSetAddress(socket_, addressData) != kCFSocketSuccess)
	{
        [self sendMessage:@"Error: Unable to bind socket to address"];
        
		return;
	}
    
    
	connectionFileHandle_ = [[NSFileHandle alloc] initWithFileDescriptor:fileDescriptor closeOnDealloc:YES];
	
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleIncomingConnection:) 
     name:NSFileHandleConnectionAcceptedNotification
     object:nil];
	
	[connectionFileHandle_ acceptConnectionInBackgroundAndNotify];
    
}

-(void) handleIncomingConnection:(NSNotification*)notification
{
	NSDictionary*	userInfo			=	[notification userInfo];
	NSFileHandle*	readFileHandle		=	[userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
    
    if(readFileHandle)
	{
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(readIncomingData:)
		 name:NSFileHandleDataAvailableNotification
		 object:readFileHandle];

        [self sendMessage:@"Opened incoming connection"];
		
        [readFileHandle waitForDataInBackgroundAndNotify];
    }
	
	[connectionFileHandle_ acceptConnectionInBackgroundAndNotify];
}

- (void) readIncomingData:(NSNotification*) notification
{
	NSFileHandle*	readFileHandle	= [notification object];
	NSData*			data			= [readFileHandle availableData];
	
	if ([data length] == 0)
	{
        [self sendMessage:@"No more data in file handle, closing"];
        [self stopReceivingForFileHandle:readFileHandle closeFileHandle:YES];
		return;
	}	
	
    [self sendMessage:[NSString stringWithUTF8String:[data bytes]]];

    //waiting to read again
	[readFileHandle waitForDataInBackgroundAndNotify];	
}

- (void) stopReceivingForFileHandle:(NSFileHandle *)readFileHandle closeFileHandle:(BOOL)close
{
    if(close){
        [readFileHandle closeFile];
    }
    
    [[NSNotificationCenter defaultCenter] remove:readFileHandle];
    
}

- (void) sendMessage:(NSString *)messageToPass {
    
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    
    [message setObject:messageToPass forKey:@"message"];
    
    NSNotificationCenter *notification_ = [NSNotificationCenter defaultCenter];
    [notification_ postNotificationName:@"NetworkListenerMessage" object:self  userInfo:message];
    
    [message release];
}




@end
