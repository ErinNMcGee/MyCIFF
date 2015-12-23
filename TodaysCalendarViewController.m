//
//  TodaysCalendarViewController.m
//  MyCIFF
//
//  Created by Erin McGee on 12/21/15.
//  Copyright © 2015 Erin McGee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TodaysCalendarViewController.h"
#import "TodaysFilmsViewController.h"
#import "MGCDateRange.h"
#import "NSCalendar+MGCAdditions.h"

@interface TodaysCalendarViewController()
@property (strong, nonatomic) NSArray *todaysFilmData;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation TodaysCalendarViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.eventStore = [[EKEventStore alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *calID = [[NSUserDefaults standardUserDefaults]stringForKey:@"calendarIdentifier"];
    self.calendar = [NSCalendar mgc_calendarFromPreferenceString:calID];
    
    NSUInteger firstWeekday = [[NSUserDefaults standardUserDefaults]integerForKey:@"firstDay"];
    if (firstWeekday != 0) {
        self.calendar.firstWeekday = firstWeekday;
    } else {
        [[NSUserDefaults standardUserDefaults]registerDefaults:@{ @"firstDay" : @(self.calendar.firstWeekday) }];
    }
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.calendar = self.calendar;
    self.dayPlannerView.backgroundColor = [UIColor clearColor];
    self.dayPlannerView.backgroundView = [UIView new];
    self.dayPlannerView.backgroundView.backgroundColor = [UIColor whiteColor];
    self.dayPlannerView.dateFormat = @"eeeee\nd MMM";
    self.dayPlannerView.dayHeaderHeight = 50;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self action:@selector(handleExit) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setFrame:CGRectMake(0, 20, 100, 32)];
    [cancelButton setTitle:@"<" forState:UIControlStateNormal];
    
    [self.dayPlannerView addSubview:cancelButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSDate *date = [self.calendar mgc_startOfWeekForDate:[NSDate date]];
    [self moveToDate:date animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CalendarControllerNavigation

- (void)moveToDate:(NSDate*)date animated:(BOOL)animated
{
    if (!self.dayPlannerView.dateRange || [self.dayPlannerView.dateRange containsDate:date]) {
        [self.dayPlannerView scrollToDate:date options:MGCDayPlannerScrollDateTime animated:animated];
    }
}

- (void) handleExit
{
    TodaysFilmsViewController *todayView = [[TodaysFilmsViewController alloc] initWithNibName:@"TodaysFilmsViewController" bundle:nil];
    [self presentViewController:todayView animated:NO completion:nil];
}

- (NSDate*)centerDate
{
    NSDate *date = [self.dayPlannerView dateAtPoint:self.dayPlannerView.center rounded:NO];
    return date;
}

@end
