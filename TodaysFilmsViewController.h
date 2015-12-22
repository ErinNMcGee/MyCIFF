//
//  TodaysFilmsViewController.h
//  MyCIFF
//
//  Created by Erin McGee on 2/21/15.
//  Copyright (c) 2015 Erin McGee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TodaysCalendarViewController.h"
#import "EditFilmsViewController.h"

@interface TodaysFilmsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *todaysFilmData;
}
@property (weak, nonatomic) IBOutlet UITableView *todaysFilmsList;
@end
