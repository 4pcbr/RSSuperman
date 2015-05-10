//
//  MasterViewController.m
//  RSSuperman
//
//  Created by Olegs on 04/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <PromiseKit/Promise.h>
#import <MWFeedParser.h>
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "TextInputViewController.h"
#import "FeedViewCell.h"
#import "Feed.h"
#import "Post.h"

#import "RSSController.h"

@interface MasterViewController ()
@property (strong, nonatomic) RSSController *rssController;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)displayTextInput:(id)sender {
    UIStoryboard *textInputStoryBoard = [UIStoryboard storyboardWithName:@"TextInput" bundle:[NSBundle mainBundle]];
    UINavigationController *navController = [textInputStoryBoard instantiateInitialViewController];
    TextInputViewController *textInputVC = navController.childViewControllers[0];

    textInputVC.pageTitle = @"New RSS feed";
    textInputVC.placeholderText = @"Type in a new RSS/ATOM feed link";

    textInputVC.cancel = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };

    __weak MasterViewController *weakSelf = self;

    textInputVC.save = ^(NSString *feedURL) {
        [self dismissViewControllerAnimated:YES completion:nil];
        weakSelf.rssController = [[RSSController alloc] initWithFeedURL:feedURL];
        Feed *feed = [weakSelf insertNewFeedWithURL:feedURL andTitle:feedURL];
        
        [weakSelf.rssController fetch].then(^{
            [weakSelf updateFeed:feed
                        feedInfo:weakSelf.rssController.feedInfo
                       feedItems:weakSelf.rssController.feedItems
             ];
        }).catch(^(NSError *fetchError) {
            NSLog(@"FetchError: %@", fetchError);
        });
    };

    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(displayTextInput:)
                                  ];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (Feed *)insertNewFeedWithURL:(NSString *)feedURL andTitle:(NSString *)feedTitle {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                               inManagedObjectContext:context
                  ];
    feed.link  = feedURL;
    feed.title = feedTitle;
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return feed;
}

- (void) updateFeed:(Feed *)feed feedInfo:(MWFeedInfo *)feedInfo feedItems:(NSArray *)feedItems {

    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    feed.title     = feedInfo.title;
    feed.summary   = feedInfo.summary;
    feed.updatedAt = [NSDate new];
    
    for (MWFeedItem *feedItem in feedItems) {
        Post *feedPost = [self insertOrUpdateFeedPost:feedItem];
        [feed addPostsObject:feedPost];
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [self.tableView reloadData];
}

- (Post *)insertOrUpdateFeedPost:(MWFeedItem *)feedItem {
    
    NSString *entityName = @"Post";
    NSString *sortAttr = @"date";
    
    NSFetchRequest *fetchRequest    = [NSFetchRequest new];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity     = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:context
                                       ];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", feedItem.identifier];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortAttr
                                                                   ascending:NO
                                        ];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    Post *post;
    
    if (result == nil) {
        NSLog(@"Error while retrieving a post item");
        abort();
    } else {
        if ([result count] == 0) {
            post = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                 inManagedObjectContext:context
                    ];
        } else {
            post = result[0];
        }
    }
    
    post.title      = feedItem.title;
    post.link       = feedItem.link;
    post.author     = feedItem.author;
    post.date       = feedItem.date;
    post.summary    = feedItem.summary;
    post.content    = feedItem.content;
    post.identifier = [feedItem.identifier length] ? feedItem.identifier : feedItem.link;
    
    return post;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Feed *feed = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setFeed:feed];
        __weak Feed *weakFeed = feed;
        __weak MasterViewController *weakSelf = self;
        controller.onFeedUpdated = ^(MWFeedInfo *feedInfo, NSArray *feedItems) {
            if (weakFeed) {
                [weakSelf updateFeed:weakFeed feedInfo:feedInfo feedItems:feedItems];
            } else {
                NSLog(@"Couldn't find the feed instance. Probably it's been released already");
            }
        };
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(FeedViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell displayContentForFeed:feed];
//    NSLog(@"Feed favicon URL: %@", [feed getFeedFavIconURL]);
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
