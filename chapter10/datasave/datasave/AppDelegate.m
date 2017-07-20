/**
 *
 * LICENSE: GNU Affero General Public License, version 3 (AGPLv3)
 * Copyright 2016 - 2017 fei_cong@hotmail.com 67541967@qq.com
 *
 * This file is part of macbook.
 *   https://github.com/feicong/macbook
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "AppDelegate.h"
#import "SSKeychain/SSKeychain.h"
#import "USERINFO.h"
#import "USERINFO+CoreDataProperties.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *edtUserName;

@property (weak) IBOutlet NSTextField *edtSN;


- (IBAction)saveAction:(id)sender;

@end

@implementation AppDelegate

- (IBAction)onAbout:(id)sender {
    NSAlert *msg = [[NSAlert alloc] init];
    [msg setMessageText:@"crackme by fei_cong@hotmail.com"];
    [msg addButtonWithTitle:@"ok"];
    [msg runModal];
    exit(0);
}

- (IBAction)onNSUserDefaultsWrite:(id)sender {
    NSString *username = [_edtUserName stringValue];
    NSString *sn = [_edtSN stringValue];
    
    if ([username length] > 0 && [sn length] > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:username forKey:@"username"];
        [defaults setObject:sn forKey:@"sn"];
        [defaults synchronize];
        
        NSAlert *msg = [[NSAlert alloc] init];
        [msg setMessageText:@"done!"];
        [msg addButtonWithTitle:@"ok"];
        [msg runModal];
    } else {
        NSAlert *err = [[NSAlert alloc] init];
        [err setMessageText:@"username or serinal is empty!"];
        [err addButtonWithTitle:@"ok"];
        [err runModal];
    }
}

- (IBAction)onNSUserDefaultsRead:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (([defaults objectForKey:@"username"] != NULL) && ([defaults objectForKey:@"sn"] != NULL)) {
        NSString *username = [defaults objectForKey:@"username"];
        NSString *sn = [defaults objectForKey:@"sn"];
        [_edtUserName setStringValue:username];
        [_edtSN setStringValue:sn];
        
        NSAlert *msg = [[NSAlert alloc] init];
        [msg setMessageText:@"done!"];
        [msg addButtonWithTitle:@"ok"];
        [msg runModal];
    } else {
        NSAlert *err = [[NSAlert alloc] init];
        [err setMessageText:@"username or serinal is empty!"];
        [err addButtonWithTitle:@"ok"];
        [err runModal];
    }
}

- (IBAction)onCoreDataWrite:(id)sender {
    NSString *username = [_edtUserName stringValue];
    NSString *sn = [_edtSN stringValue];
    
    if ([username length] > 0 && [sn length] > 0) {
        NSFetchRequest * fReq = [NSFetchRequest fetchRequestWithEntityName:@"USERINFO"];
        NSArray *result = [[self managedObjectContext] executeFetchRequest:fReq error:NULL];
        //remove all first
        for (NSObject *resultItem in result) {
            USERINFO *userinfoItem = (USERINFO *)resultItem;
            [[self managedObjectContext] deleteObject:userinfoItem];
        }
        
        USERINFO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"USERINFO" inManagedObjectContext:[self managedObjectContext]];
        [newItem setUsername:username];
        [newItem setSn:sn];
        
        NSAlert *msg = [[NSAlert alloc] init];
        [msg setMessageText:@"done!"];
        [msg addButtonWithTitle:@"ok"];
        [msg runModal];
    } else {
        NSAlert *err = [[NSAlert alloc] init];
        [err setMessageText:@"username or serinal is empty!"];
        [err addButtonWithTitle:@"ok"];
        [err runModal];
    }
}

- (IBAction)onCoreDataRead:(id)sender {
    NSFetchRequest *fReq = [[NSFetchRequest fetchRequestWithEntityName:@"USERINFO"] init];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:fReq error:NULL];
    if ([result count] > 0) {
        for (NSObject *resultItem in result) {
            USERINFO *userinfoItem = (USERINFO *)resultItem;
            [_edtUserName setStringValue:[userinfoItem username]];
            [_edtSN setStringValue:[userinfoItem sn]];
            //NSLog(@"%@", [userinfoItem username]);
            //NSLog(@"%@", [userinfoItem sn]);
            
            NSAlert *msg = [[NSAlert alloc] init];
            [msg setMessageText:@"done!"];
            [msg addButtonWithTitle:@"ok"];
            [msg runModal];
            return;
        }
    } else {
        NSAlert *err = [[NSAlert alloc] init];
        [err setMessageText:@"username or serinal is empty!"];
        [err addButtonWithTitle:@"ok"];
        [err runModal];
    }
}

- (IBAction)onPlistfileWrite:(id)sender {
    NSString *username = [_edtUserName stringValue];
    NSString *sn = [_edtSN stringValue];
    
    if ([username length] > 0 && [sn length] > 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"userinfo.plist"];
        NSMutableDictionary *plist = [[NSMutableDictionary alloc] init];
        [plist setValue:username forKey:@"username"];
        [plist setValue:sn forKey:@"sn"];
        [plist writeToFile:filePath atomically:YES];
        
        NSAlert *msg = [[NSAlert alloc] init];
        [msg setMessageText:@"done!"];
        [msg addButtonWithTitle:@"ok"];
        [msg runModal];
    } else {
        NSAlert *err = [[NSAlert alloc] init];
        [err setMessageText:@"username or serinal is empty!"];
        [err addButtonWithTitle:@"ok"];
        [err runModal];
    }
}

- (IBAction)onPlistfileRead:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"userinfo.plist"];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (exists == FALSE) {
        NSAlert *err = [[NSAlert alloc] init];
        [err setMessageText:@"userinfo.plist not exists!"];
        [err addButtonWithTitle:@"ok"];
        [err runModal];
        return;
    }
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    NSString *username = [plist valueForKey:@"username"];
    NSString *sn = [plist valueForKey:@"sn"];
    if (([username length] > 0) && ([sn length] > 0)) {
        [_edtUserName setStringValue:username];
        [_edtSN setStringValue:sn];
        
        NSAlert *msg = [[NSAlert alloc] init];
        [msg setMessageText:@"done!"];
        [msg addButtonWithTitle:@"ok"];
        [msg runModal];
    } else {
        NSAlert *err = [[NSAlert alloc] init];
        [err setMessageText:@"username or serinal is empty!"];
        [err addButtonWithTitle:@"ok"];
        [err runModal];
    }
}

- (IBAction)onKeychainWrite:(id)sender {
    NSString *username = [_edtUserName stringValue];
    NSString *sn = [_edtSN stringValue];
    
    if ([username length] > 0 && [sn length] > 0) {
        BOOL b1 = [SSKeychain setPassword:username forService:@"userinfo" account:@"username"];
        BOOL b2 = [SSKeychain setPassword:sn forService:@"userinfo" account:@"sn"];
        if (b1 && b2) {
            NSAlert *msg = [[NSAlert alloc] init];
            [msg setMessageText:@"done!"];
            [msg addButtonWithTitle:@"ok"];
            [msg runModal];
        } else {
            NSAlert *err = [[NSAlert alloc] init];
            [err setMessageText:@"save error!"];
            [err addButtonWithTitle:@"ok"];
            [err runModal];
        }
    } else {
        NSAlert *err = [[NSAlert alloc] init];
        [err setMessageText:@"username or serinal is empty!"];
        [err addButtonWithTitle:@"ok"];
        [err runModal];
    }
}

- (IBAction)onKeychainRead:(id)sender {
    NSString *username = [SSKeychain passwordForService:@"userinfo" account:@"username"];
    NSString *sn = [SSKeychain passwordForService:@"userinfo" account:@"sn"];
    
    if (([username length] > 0) && ([sn length] > 0)) {
        [_edtUserName setStringValue:username];
        [_edtSN setStringValue:sn];
        
        NSAlert *msg = [[NSAlert alloc] init];
        [msg setMessageText:@"done!"];
        [msg addButtonWithTitle:@"ok"];
        [msg runModal];
    } else {
        NSAlert *err = [[NSAlert alloc] init];
        [err setMessageText:@"username or serinal is empty!"];
        [err addButtonWithTitle:@"ok"];
        [err runModal];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "fc.datasave" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"fc.datasave"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"datasave" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"OSXCoreDataObjC.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
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
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return TRUE;
}

@end
