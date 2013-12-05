//
//  ViewController.m
//  RAIIExample
//
//  Created by goro-fuji on 12/5/13.
//  Copyright (c) 2013 goro-fuji. All rights reserved.
//

#import "ViewController.h"

@interface NetworkActivityGuard : NSObject
@end

@implementation NetworkActivityGuard

- (id)init
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    return [super init];
}

- (void)dealloc
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end

@interface ScopeGuard : NSObject
@end

typedef void (^voidBlock)();

@implementation ScopeGuard {
    voidBlock _block;
}

- (id)initWithBlock: (voidBlock)block
{
    self = [super init];
    self->_block = [block copy];
    return self;
}

- (void)dealloc
{
    _block();
}

+(id)newWitBlock:(voidBlock)block
{
    return [[self alloc] initWithBlock:block];
}

@end // ScopeGuard


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

// good
- (IBAction)startAction:(id)sender {
    NSLog(@"started");

    self.label.text = @"Working In Progress";
    
    NSMutableArray * const guards = [NSMutableArray new];
    [guards addObject: [ScopeGuard newWitBlock:^{
        self.label.text = @"Hello, world!";
    }]];
    [guards addObject:[NetworkActivityGuard new]];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    double const delayInSeconds = 1.5;
    dispatch_time_t const popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"finished");
        if (YES) {
            // no need to release guards!
            return;
        }
        
        (void)guards;
    });
}




// bad
- (IBAction)_startAction:(id)sender {
    self.label.text = @"Working In Progress";
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    double const delayInSeconds = 1.5;
    dispatch_time_t const popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        self.label.text = @"Hello, world!";
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    });
}


@end
