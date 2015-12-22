//
//  AllFilmsViewController.h
//  MyCIFF
//
//  Created by Erin McGee on 2/21/15.
//  Copyright (c) 2015 Erin McGee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AllFilmsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *filmData;
}
@property (weak, nonatomic) IBOutlet UITableView *filmList;


@end
