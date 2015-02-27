//
//  SearchViewController.h
//  BFC-iOS
//
//  Created by Matt Galloway on 10/7/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    BOOL goneToPictureView;
}
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSArray *orderedPhotoLocations;

@end
