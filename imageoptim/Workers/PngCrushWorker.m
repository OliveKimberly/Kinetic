//
//  PngCrushWorker.m
//
//  Created by porneL on 1.paź.07.
//

#import "PngCrushWorker.h"
#import "../File.h"

@implementation PngCrushWorker
- (instancetype)initWithDefaults:(NSUserDefaults *)defaults file:(File *)aFile {
    if ((self = [super initWithDefaults:defaults file:aFile])) {
        strip = [defaults boolForKey:@"PngOutRemoveChunks"];
    }
    return self;
}

-(NSInteger)settingsIdentifier {
    return strip;
}

-(BOOL)runWithTempPath:(NSURL *)temp {
    NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-nofilecheck",@"-bail",@"-blacken",@"-reduce",@"-cc",@"--",file.filePathOptimized.path,temp.path,nil];

    // Reusing PngOut config here
    if (strip) {
        [args insertObject:@"-rem" atIndex:0];
        [args insertObject:@"alla" atIndex:1];
    }

    if ([file isSmall]) {
        [args insertObject:@"-brute" atIndex:0];
    }

    if (![self taskForKey:@"PngCrush" bundleName:@"pngcrush" arguments:args]) {
        return NO;
    }

    NSPipe *commandPipe = [NSPipe pipe];
    NSFileHandle *commandHandle = [commandPipe fileHandleForReading];

    [task setStandardOutput: commandPipe];
    [task setStandardError: commandPipe];

    [self launchTask];

    [commandHandle readToEndOfFileInBackgroundAndNotify];

    [task waitUntilExit];

    [commandHandle closeFile];

    if ([task terminationStatus]) return NO;

    NSUInteger fileSizeOptimized;
    // pngcrush sometimes writes only PNG header (70 bytes)!
    if ((fileSizeOptimized = [File fileByteSize:temp]) && fileSizeOptimized > 70) {
        return [file setFilePathOptimized:temp  size:fileSizeOptimized toolName:@"Pngcrush"];
    }
    return NO;
}

-(BOOL)makesNonOptimizingModifications {
    return strip;
}

@end
