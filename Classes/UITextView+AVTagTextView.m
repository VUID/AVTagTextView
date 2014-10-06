//
//  UITextField+AVTagTextView.m
//  AVTagTextView
//
//  Created by Arseniy Vershinin on 9/13/13.
//

#import "UITextView+AVTagTextView.h"

#import "AVHashTagsTableViewController.h"

#import <objc/runtime.h>

#import "NSString+AVTagAdditions.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/NSNotificationCenter+RACSupport.h>

@implementation UITextView (AVTagTextView)

/*****************************************************/
#pragma mark - Properties
/*****************************************************/

static const char *kHashTagsDelegateKey = "hashTagsDelegate";

- (void)setHashTagsDelegate:(id<AVTagTextViewDelegate>)hashTagsDelegate{
    if(self.hashTagsDelegate != hashTagsDelegate) {
        //Adding the hash delegate initializes user input observation process:
        [self addSignals];
        objc_setAssociatedObject(self, kHashTagsDelegateKey, hashTagsDelegate, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (id<AVTagTextViewDelegate>)hashTagsDelegate{
    return objc_getAssociatedObject(self, kHashTagsDelegateKey);
}

static const char *kHashTagsTableViewControllerKey = "hashTagsTableViewControllerKey";

- (void)setHashTagsTableViewController:(UITableViewController<AVTagTableViewControllerProtocol> *)hashTagsTableViewController{
    if(self.hashTagsTableViewController != hashTagsTableViewController) {
        
        hashTagsTableViewController.tagsDelegate = self;
        objc_setAssociatedObject(self, kHashTagsTableViewControllerKey, hashTagsTableViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (UITableViewController<AVTagTableViewControllerProtocol> *)hashTagsTableViewController{
    //lazily create a table view controller if there isn't one
    UITableViewController<AVTagTableViewControllerProtocol> *controller = objc_getAssociatedObject(self, kHashTagsTableViewControllerKey);
    if(!controller) {
        controller = [AVHashTagsTableViewController new];
        controller.tagsDelegate = self;
        objc_setAssociatedObject(self, kHashTagsTableViewControllerKey, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return controller;
}

static const char *kHashTagsTableViewHeightKey = "hashTagsTableViewHeightKey";

- (void)setHashTagsTableViewHeight:(CGFloat)hashTagsTableViewHeight{
    objc_setAssociatedObject(self, kHashTagsTableViewHeightKey, @(hashTagsTableViewHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)hashTagsTableViewHeight{
    CGFloat height = [objc_getAssociatedObject(self, kHashTagsTableViewHeightKey) floatValue];
    if(height <= 0) {
        height = DEFAULT_TABLE_VIEW_HEIGHT;
    }

    return height;
}

static const char *kHashTagsTableViewOffsetKey = "hashTagsTableViewOffsetKey";

- (void)setHashTagsTableViewOffset:(CGFloat)hashTagsTableViewOffset {
	objc_setAssociatedObject(self, kHashTagsTableViewOffsetKey, @(hashTagsTableViewOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)hashTagsTableViewOffset{
	CGFloat offset = [objc_getAssociatedObject(self, kHashTagsTableViewOffsetKey) floatValue];
	if (offset <= 0) {
		offset = DEFAULT_TABLE_VIEW_OFFSET;
	}
	
	return offset;
}

- (NSArray *)hashTags{
    return [self.text hashTags];
}

/*****************************************************/
#pragma mark - Helpers
/*****************************************************/

- (void)addTextSignal{
    [[self rac_textSignal] subscribeNext:^(NSString *input) {
        [self reactOnUserInput:input];
    }];
}

- (void)addSignals{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(id x) {
        
        self.hashTagsTableViewController.view.hidden = YES;
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidShowNotification object:nil] subscribeNext:^(NSNotification *notification) {
        
        CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect tableViewFrame = CGRectMake(0,
                                           keyboardRect.origin.y - self.hashTagsTableViewHeight - self.hashTagsTableViewOffset,
                                           keyboardRect.size.width,
                                           self.hashTagsTableViewHeight);
        
        self.hashTagsTableViewController.view.frame = tableViewFrame;
    }];
    
    //The following code allows the user to reassign the delegate
    //without hindering reactive cocoa's input observation.
    //startWith guarantees that the block will be ran the first
    //time without wating for the delegate property to change
    [[RACObserve(self, delegate) startWith:nil] subscribeNext:^(id x) {
        [self addTextSignal];
    }];
}

- (void)updateHashTagsTableViewControllerWithTags:(NSArray *)tags andType:(AVTagTextViewTagTypes) type{
    UITableViewController<AVTagTableViewControllerProtocol> *controller = self.hashTagsTableViewController;
    
    //Add the controller to the current root view controller if it hasn't been added anywhere so far
    if(!controller.tableView.superview){
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        [controller willMoveToParentViewController:rootViewController];
        [rootViewController.view addSubview:controller.view];
        [controller didMoveToParentViewController:rootViewController];
    }
    controller.view.hidden =  tags.count == 0;
    controller.tagsToDisplay = tags;
	controller.tagsToDisplayType = type;
}

#pragma mark AVTagTableViewDelegate

- (void)tagSelected:(NSString *)tag andType:(AVTagTextViewTagTypes)type{
    NSString *replaceString = [NSString stringWithFormat:
							   @"%@%@ ",
							   type==AVTagTextViewHashtags?@"#":@"@",
							   tag];
    NSMutableString *mutableText = [NSMutableString stringWithString:self.text];
    
    [[NSString endOfStringTagRegex] replaceMatchesInString:mutableText options:0 range:[self.text wholeStringRange] withTemplate:replaceString];
    self.text = mutableText;
    
    self.hashTagsTableViewController.view.hidden = YES;
}

/*****************************************************/
#pragma mark - Interface
/*****************************************************/

- (void)reactOnUserInput:(NSString *)input{
	NSDictionary *tagInfo = [input endOfStringTag];
	NSString *tag = [tagInfo objectForKey:@"tag"];
	NSString *typeStr = [tagInfo objectForKey:@"type"];
	AVTagTextViewTagTypes type = [typeStr isEqualToString:@"#"]?AVTagTextViewHashtags:AVTagTextViewTags;
	
    if(tagInfo != nil &&
       input.length > 0 &&
       [self.hashTagsDelegate respondsToSelector:@selector(performSearchForTextView:type:query:withCompletionHandler:)]) {
		[self.hashTagsDelegate performSearchForTextView:self type:type query:tag withCompletionHandler:^(NSArray *results) {
			[self updateHashTagsTableViewControllerWithTags:results andType:type];
		}];
    }
    else{
        self.hashTagsTableViewController.view.hidden = YES;
    }
}

/*****************************************************/
#pragma mark - Test Methds
/*****************************************************/

- (void)simulteUserInput:(NSString *)input{
    self.text = self.text?:@"";
    self.text = [self.text stringByAppendingString:input];
    [self reactOnUserInput:self.text];
}

@end