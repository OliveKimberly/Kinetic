
#import "ZopfliWorker.h"
#import "../File.h"

@implementation ZopfliWorker

@synthesize alternativeStrategy;

-(id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        iterations = (int)[defaults integerForKey:@"ZopfliIterations"];
        strip = [[NSUserDefaults standardUserDefaults] boolForKey:@"PngOutRemoveChunks"];
    }
    return self;
}

-(id)settingsIdentifier {
    return @(iterations*4+strip*2+alternativeStrategy);
}

-(BOOL)runWithTempPath:(NSString *)temp {
    NSMutableArray *args = [NSMutableArray arrayWithObjects: @"--lossy_transparent",@"-y",/*@"--",*/file.filePathOptimized,temp,nil];

    if (!strip) {
        // FIXME: that's crappy. Should list actual chunks in file :/
        [args insertObject:@"--keepchunks=tEXt,zTXt,iTXt,gAMA,sRGB,iCCP,bKGD,pHYs,sBIT,tIME,oFFs,acTL,fcTL,fdAT,prVW,mkBF,mkTS,mkBS,mkBT" atIndex:0];
    }

    int actualIterations = iterations;
    unsigned long timelimit = 10 + [file byteSizeOriginal]/1024;
    if (timelimit > 60) timelimit = 60;

    if ([file isLarge]) {
        actualIterations /= 2; // use faster setting for large files
    }

    if ([file isSmall]) {
        actualIterations *= 2;
        [args insertObject:@"--splitting=3" atIndex:0]; // try both splitting strategies
    } else if (alternativeStrategy) {
        [args insertObject:@"--splitting=2" atIndex:0]; // by default splitting=1, so make second run use different split
    }

    if (actualIterations) {
        [args insertObject:[NSString stringWithFormat:@"--iterations=%d", actualIterations] atIndex:0];
    }

    [args insertObject:[NSString stringWithFormat:@"--timelimit=%lu", timelimit] atIndex:0];

    if (![self taskForKey:@"Zopfli" bundleName:@"zopflipng" arguments:args]) {
        return NO;
    }

    NSPipe *commandPipe = [NSPipe pipe];
    NSFileHandle *commandHandle = [commandPipe fileHandleForReading];

    [task setStandardOutput: commandPipe];
    [task setStandardError: commandPipe];

    [self launchTask];

    [commandHandle readInBackgroundAndNotify];
    [task waitUntilExit];

    [commandHandle closeFile];

    if ([task terminationStatus]) return NO;

    NSInteger fileSizeOptimized = [File fileByteSize:temp];
    if (fileSizeOptimized > 70) {
        return [file setFilePathOptimized:temp size:fileSizeOptimized toolName:@"Zopfli"];
    }
    return NO;
}

-(BOOL)isIdempotent {
    return NO;
}

-(BOOL)makesNonOptimizingModifications {
    return YES;
}

@end
