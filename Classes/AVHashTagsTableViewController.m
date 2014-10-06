//
//  AVHashTagsTableViewController.m
//  AVTagTextView
//
//  Created by Arseniy Vershinin on 9/14/13.
//

#import "AVHashTagsTableViewController.h"

@interface AVHashTagsTableViewController ()

@end

@implementation AVHashTagsTableViewController
@synthesize tagsDelegate = _tagsDelegate;
@synthesize tagsToDisplay = _tagsToDisplay;
@synthesize tagsToDisplayType = _tagsToDisplayType;

/*****************************************************/
#pragma mark - UIView Lifecycle
/*****************************************************/

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.bounces = NO;
}

/*****************************************************/
#pragma mark - AVTagTableViewControllerProtocol
/*****************************************************/

- (void)setTagsToDisplay:(NSArray *)tagsToDisplay{
    if(_tagsToDisplay != tagsToDisplay) {
        _tagsToDisplay = tagsToDisplay;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tagsToDisplay.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *tag = self.tagsToDisplay[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:
						   @"%@%@",
						   self.tagsToDisplayType==AVTagTextViewHashtags?@"#":@"@",
						   tag];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tagsDelegate && [self.tagsDelegate respondsToSelector:@selector(tagSelected:andType:)]){
        [self.tagsDelegate tagSelected:self.tagsToDisplay[indexPath.row] andType:self.tagsToDisplayType];
    }
}

@end
