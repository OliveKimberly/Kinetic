//
//  PngCrushWorker.h
//
//  Created by porneL on 1.paź.07.
//

#import <Cocoa/Cocoa.h>
#import "CommandWorker.h"

@interface PngCrushWorker : CommandWorker {    
	int firstIdatSize;	
    BOOL strip;
}

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults file:(File *)aFile;
@property (readonly) BOOL makesNonOptimizingModifications;

@end
