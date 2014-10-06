//
//  AVTagTableViewControllerProtocol.h
//  AVTagTextField
//
//  Created by Arseniy Vershinin on 10/7/13.
//

#import <Foundation/Foundation.h>

typedef enum {
	AVTagTextViewAll,
	AVTagTextViewHashtags,
	AVTagTextViewTags
} AVTagTextViewTagTypes;

@protocol AVTagTableViewControllerDelegate <NSObject>
/**
 * Should be called when a tag cell is selected
 */
- (void)tagSelected:(NSString *)tag andType:(AVTagTextViewTagTypes)type;
@end

@protocol AVTagTableViewControllerProtocol <NSObject>

/**
 * A list of hashtags (without the leading "#" symbol) 
 * that should be displayed by the table view controller,
 * implementing the AVTagTableViewControllerProtocol.
 * The default implementation is the following:
 *
 *- (void)setHashTagsToDisplay:(NSArray *)hashTagsToDisplay{
    if(_hashTagsToDisplay != hashTagsToDisplay) {
        _hashTagsToDisplay = hashTagsToDisplay;
        //Reload the table view as soon as the data source
        //has been updated:
        [self.tableView reloadData];
    }
 }
 */
@property (nonatomic, strong) NSArray *tagsToDisplay;

/**
 * A enum to set the current tag type
 *
 */
@property (assign) AVTagTextViewTagTypes tagsToDisplayType;

/**
 * The delegate, which responds to the table view hash
 * tags related changes (f.e. hash tags selection). 
 * This is normally a UITextView+AVTagTextView instance
 */
@property (nonatomic, weak) id<AVTagTableViewControllerDelegate> tagsDelegate;

@end
