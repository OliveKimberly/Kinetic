//
//  JpegoptimWorker.m
//
//  Created by porneL on 7.paź.07.
//

#import "JpegoptimWorker.h"
#import "../File.h"
#import "../log.h"

@implementation JpegoptimWorker

-(NSInteger)settingsIdentifier {
    return maxquality*2 + strip;
}

-(instancetype)initWithDefaults:(NSUserDefaults *)defaults file:(File *)aFile {
    if (self = [super initWithFile:aFile]) {
        // Sharing setting with jpegtran
        strip = [defaults boolForKey:@"JpegTranStripAll"];
        maxquality = [defaults boolForKey:@"LossyEnabled"] ? [defaults integerForKey:@"JpegOptimMaxQuality"] : 100;
    }
    return self;
}

-(BOOL)makesNonOptimizingModifications {
    return maxquality < 100;
}

-(BOOL)runWithTempPath:(NSURL *)temp {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;

    if (![fm copyItemAtURL:file.filePathOptimized toURL:temp error:&error]) {
        IOWarn("Can't make temp copy of %@ in %@", file.filePathOptimized.path, temp.path);
    }

    BOOL lossy = maxquality > 10 && maxquality < 100;

    NSMutableArray *args = [NSMutableArray arrayWithObjects:
                            strip ? @"--strip-all" : @"--strip-none",
                            lossy ? @"--all-progressive" : @"--all-normal", // lossless progressive is redundant with jpegtran, but lossy baseline would prevent parallelisation
                            @"-v", // needed for parsing output size
                            @"--", temp.path, nil];

    if (lossy) {
        [args insertObject:[NSString stringWithFormat:@"-m%d",(int)maxquality] atIndex:0];
    }

    if (![self taskForKey:@"JpegOptim" bundleName:@"jpegoptim" arguments:args]) {
        return NO;
    }

    NSPipe *commandPipe = [NSPipe pipe];
    NSFileHandle *commandHandle = [commandPipe fileHandleForReading];

    [task setStandardOutput: commandPipe];
    [task setStandardError: commandPipe];

    [self launchTask];

    [self parseLinesFromHandle:commandHandle];
    [task waitUntilExit];

    [commandHandle closeFile];

    BOOL isSignificantlySmaller;
    @synchronized(file) {
        // require at least 5% gain when doing lossy optimization
        isSignificantlySmaller = file.byteSizeOptimized*0.95 > fileSizeOptimized;
    }

    if (![self makesNonOptimizingModifications] || isSignificantlySmaller) {
        return [file setFilePathOptimized:temp size:fileSizeOptimized toolName:lossy ? [NSString stringWithFormat: @"JpegOptim %d%%", (int)maxquality] : @"JpegOptim"];
    }
    return NO;
}

-(BOOL)parseLine:(NSString *)line {
    NSInteger size;
    if ((size = [self readNumberAfter:@" --> " inLine:line])) {
        fileSizeOptimized = size;
        return YES;
    }
    return NO;
}


@end
