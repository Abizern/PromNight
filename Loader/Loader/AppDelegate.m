//
//  AppDelegate.m
//  Loader
//
//  Created by Abizer Nasir on 30/03/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSURL *storeURL;

- (void)parseFileAtURL:(NSURL *)url;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize storeURL = _storeURL;
@synthesize recordsToProcessLabel = _recordsToProcessLabel;
@synthesize recordsProcessedLabel = _recordsProcessedLabel;
@synthesize storeLocationLabel = _storeLocationLabel;

#pragma mark - Application life cycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    // When the window is closed, terminate the app
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!__managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

#pragma mark - Actions

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)loadData:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    panel.allowedFileTypes = [NSArray arrayWithObject:@"csv"];
    panel.canChooseDirectories = NO;

    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self parseFileAtURL:panel.URL];
        } else {
            DLog(@"File selection cancelled");
        }
    }];

}

#pragma mark - Data methods

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.junglecandy.Loader" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.junglecandy.Loader"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PromNight" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![[properties objectForKey:NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"PromNight.sqlite"];
    
    // Keep a reference to the URL for the store
    self.storeURL = url;
    
    // If a store already exists - we want to delete it so we are always creating a new store rather than appending to it.
    if ([url checkResourceIsReachableAndReturnError:nil]) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        if (![fm removeItemAtURL:url error:&error]) {
            DLog(@"Can't remove existing store because: %@", error);
            abort(); // Harsh, but no point carrying on if we can't remove the existing store.
        }
    }
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __persistentStoreCoordinator = coordinator;
    
    return __persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

#pragma mark - Private Methods

- (void)parseFileAtURL:(NSURL *)url {
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    if (!fileContents) {
        DLog(@"Error reading file: %@", error);
        abort(); // Bit harsh - but if we can't read the file, there's not much the app can do.
    }
    
    NSMutableArray *arrayOfLines = [[fileContents componentsSeparatedByString:@"\n"] mutableCopy];
    
    // Remove the first line, which just contains the headers
    [arrayOfLines removeObjectAtIndex:0];
    
    NSInteger numberOfRecordsToProcess = [arrayOfLines count];
    NSInteger numberOfRecordsSuccessfullyProcessed = 0;
    for (NSString *line in arrayOfLines) {
        // Split the line into an array
        NSArray *attendeeElements = [line componentsSeparatedByString:@","];
        
        // Since we know that the order is firstName, lastName, Number we can create an object from this
        
        // Create a new entity in the managed object context
        NSManagedObjectContext *moc = self.managedObjectContext;
        NSManagedObject *attendee = [NSEntityDescription insertNewObjectForEntityForName:@"Attendee" inManagedObjectContext:moc];
        
        // Set the values of the the element.
        // We don't need to set the `arrived` value because that defaults to NO, which is correct
        [attendee setValue:[attendeeElements objectAtIndex:0] forKey:@"firstName"];
        [attendee setValue:[attendeeElements objectAtIndex:1] forKey:@"lastName"];
        [attendee setValue:[NSNumber numberWithInteger:[[attendeeElements objectAtIndex:2] integerValue]] forKey:@"ticketNumber"];
        
        // Save the new object to the store.
        if (![moc save:&error]) {
            DLog(@"Unable to save record: %@, because: %@", line, error);
        } else {
            numberOfRecordsSuccessfullyProcessed++;
        }
        [self.recordsToProcessLabel setStringValue:[NSString stringWithFormat:@"%lu", numberOfRecordsToProcess]];
        [self.recordsProcessedLabel setStringValue:[NSString stringWithFormat:@"%lu", numberOfRecordsSuccessfullyProcessed]];
        [self.storeLocationLabel setStringValue:[self.storeURL path]];
        
    }
        
        
}


@end
