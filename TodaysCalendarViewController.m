//
//  TodaysCalendarViewController.m
//  MyCIFF
//
//  Created by Erin McGee on 12/21/15.
//  Copyright © 2015 Erin McGee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TodaysCalendarViewController.h"

// Uncomment the following line to use the built in calendar as a source for events:
//#define USE_EVENTKIT_DATA_SOURCE 1

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface TodaysCalendarViewController()
@property (strong, nonatomic) NSArray *todaysFilmData;
@end

@implementation TodaysCalendarViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidLoad {
    [self loadData];
}


-(void) loadData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Film"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.todaysFilmData=objects;
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
