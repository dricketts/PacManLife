//
//  PacManLifeViewController.h
//  PacManLife
//
//  Created by Daniel on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PacManLifeViewController : UIViewController <MKMapViewDelegate> {
    
    MKMapView *mapView;
    NSMutableDictionary *dotAnnotationDict;
    BOOL hasLocatedUser;
    
}
                                                        
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (IBAction)startNewGame:(id)sender;

// Generates the dots (pellets).
- (void) generateDotsFromCurrentLocation:(CLLocation *) currentLocation
                        withNumberOfDots:(NSUInteger) numDots;

// Removes the dots from the locations, this handles all updating
// of data structures and removal of annotations.
- (void) removeDotFromLocations:(NSSet *) locations;

// Centers the view on the dots (pellets).
- (void) centerViewOnDots;

// Centers the view on the user at a default zoom level.
- (void) centerViewOnUser;

@end
