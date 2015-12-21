//
//  LSBaseRequest.m
//  LSNetworkManager
//
//  Created by StephenChen on 15/9/21.
//  Copyright (c) 2015年 Lansion. All rights reserved.
//

#import "LSBaseRequest.h"

@implementation LSBaseRequest
@synthesize params;

-(instancetype)init:(NSString*)path method:(enum Method) method{
    self = [super init];
    if (self) {
        params = [NSMutableDictionary dictionary];
        self.baseUrl = BASE_URL;
        self.path = path;
        self.method = method;
    }
    return self;
}

-(void) go{
    [LSNetworkManager send:self];
}

@end
