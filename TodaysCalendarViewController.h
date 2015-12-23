//
//  TodaysCalendarViewController.h
//  MyCIFF
//
//  Created by Erin McGee on 12/21/15.
//  Copyright © 2015 Erin McGee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MGCDayPlannerEKViewController.h"

@interface TodaysCalendarViewController : MGCDayPlannerEKViewController

@property (nonatomic) UIPopoverController *calendarPopover;

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) EKEventStore *eventStore;

@end
