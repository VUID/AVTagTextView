//
//  UITextField+AVTagTextView.h
//  AVTagTextView
//
//  Created by Arseniy Vershinin on 9/13/13.
//

#import <UIKit/UIKit.h>

#import "AVTagTableViewControllerProtocol.h"

#define DEFAULT_TABLE_VIEW_HEIGHT 100.
#define DEFAULT_TABLE_VIEW_OFFSET 0.

/*****************************************************/
//             AVTagTextViewDelegate
/*****************************************************/

@protocol AVTagTextViewDelegate <NSObject>
@optional
/**
 * The receiver should return an array of matching string 
 * tags without the leading # symbol. If the array is not 
 * empty, the list of provided tags will be displayed in 
 * the hashTagsTableViewController
 */
- (NSArray *)tagsForQuery:(NSString *)query;
@end

/*****************************************************/
//           UITextView+AVTagTextView
/*****************************************************/

@interface UITextView (AVTagTextView)<AVTagTableViewControllerDelegate>
@property (nonatomic, weak)  id<AVTagTextViewDelegate> hashTagsDelegate;

/**
 * Table view controller instance that will be displayed 
 * when the tags are provided for the current user input. 
 * It defaults to a generic table view controller 
 * (AVHashTagsTableViewController instance), when no other
 * implementation is provided
 */
@property (nonatomic, strong) UITableViewController<AVTagTableViewControllerProtocol> *hashTagsTableViewController;

/**
 * The height of the displayed hash tags table view controller, 
 * measured from the bottom of the iDevice keyboard. Defaults 
 * to DEFAULT_TABLE_VIEW_HEIGHT
 */
@property (nonatomic, assign) CGFloat hashTagsTableViewHeight;

/**
 * The offset distance to set the table above the keyboard.
 * Defaults to DEFAULT_TABLE_VIEW_OFFSET
 */
@property (nonatomic, assign) CGFloat hashTagsTableViewOffset;

/**
 * Hash tags, encountered in the current TextView's text. 
 * The hash tags do not include the "#" symbol
 */
@property (nonatomic, readonly) NSArray *hashTags;

@end

@interface UITextView (AVTagTextViewTesting)
- (void)simulteUserInput:(NSString *)input;
@end