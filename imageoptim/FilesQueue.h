//
//  FilesQueue.h
//
//  Created by porneL on 23.wrz.07.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class File;

@interface FilesQueue : NSArrayController <NSTableViewDelegate,NSTableViewDataSource> {
	NSTableView *tableView;
	NSArrayController *filesController;
	BOOL isEnabled, isBusy;
	NSInteger nextInsertRow;
	NSOperationQueue *cpuQueue;
    NSOperationQueue *fileIOQueue;
	NSOperationQueue *dirWorkerQueue;	
	
    NSHashTable *seenPathHashes;
    
    NSLock *queueWaitingLock;
}

-(id)configureWithTableView:(NSTableView*)a;

- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(int)row mouseLocation:(NSPoint)mouseLocation;
-(BOOL)addPaths:(NSArray *)paths;
-(BOOL)addPaths:(NSArray *)paths filesOnly:(BOOL)t;

-(void) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)indexSet
										toIndex:(NSUInteger)insertIndex;
- (NSUInteger)rowsAboveRow:(NSUInteger)row inIndexSet:(NSIndexSet *)indexSet;
- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableview;

-(void)startAgainOptimized:(BOOL)optimized;
-(BOOL)canStartAgainOptimized:(BOOL)optimized;
-(void)clearComplete;
-(BOOL)canClearComplete;
-(IBAction)delete:(id)sender;
-(BOOL)copyObjects;
-(void)cutObjects;
-(void)pasteObjectsFrom:(NSPasteboard *)pb;
-(void)cleanup;
-(void)setRow:(NSInteger)row;
-(void)openRowInFinder:(NSInteger)row withPreview:(BOOL)preview;

-(NSArray *)fileTypes;

@property (readonly, nonatomic) NSNumber *queueCount;
@property (readonly) BOOL isBusy;

@end
