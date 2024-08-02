//
//  Worker.m
//  ImageOptim
//
//  Created by porneL on 30.wrz.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Worker.h"
#import "WorkerQueue.h"

@implementation Worker

-(id)delegate
{
	return nil;
}

-(void)run
{
	NSLog(@"Run and did nothing %@",[self className]);
}

-(BOOL)makesNonOptimizingModifications
{
	return NO;
}

-(void)setDependsOn:(Worker *)w
{
	[dependsOn release];
	dependsOn = [w retain];
}

-(Worker *)dependsOn
{
	return dependsOn;
}

-(void)dealloc 
{
	[dependsOn release];
	[super dealloc];
}

@end
