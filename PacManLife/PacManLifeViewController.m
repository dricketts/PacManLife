//
//  PacManLifeViewController.m
//  PacManLife
//
//  Created by Daniel on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PacManLifeViewController.h"

@implementation PacManLifeViewController
@synthesize mapView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int initialCapacity = 20;
    dotAnnotationDict = [NSMutableDictionary dictionaryWithCapacity:initialCapacity];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Non-Lifecycle methods


// Called to start a new game.
- (IBAction)startNewGame:(id)sender {
    
    [self generateDotsFromCurrentLocation:mapView.userLocation.location withNumberOfDots:20];
    [self centerViewOnDots];
}

// Generates the dots (pellets).
- (void) generateDotsFromCurrentLocation:(CLLocation *) currentLocation
    withNumberOfDots:(NSUInteger) numDots
{
    // Remove any old dots
    [dotAnnotationDict removeAllObjects];
    for (id <MKAnnotation> annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
    
    for (int i = 1; i <= numDots; i++) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude+.001*i longitude:currentLocation.coordinate.longitude+.001*i];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = location.coordinate;
        [dotAnnotationDict setObject:annotation forKey:location];
        [mapView addAnnotation:annotation];
    }
}

// Called by some map view magic to create the view for an annotation.
- (MKAnnotationView *)mapView:(MKMapView *) theMapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, return a picture of pac man.
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
//        // Try to dequeue an existing pac man view first.
//        MKAnnotationView*    pacManView = (MKAnnotationView*)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"PacManAnnotationView"];
//    
//        if (!pacManView)
//        {
//            // Create a new pac man view if none was found.
//            pacManView = [[MKAnnotationView alloc] initWithAnnotation:annotation
//                                                   reuseIdentifier:@"PacManAnnotationView"];
//            pacManView.image = [UIImage imageNamed:@"pacman.png"];
//            pacManView.annotation = annotation;
//        }
//        else
//            pacManView.annotation = annotation;
//    
//        return pacManView;
    }
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing dot view first.
        MKAnnotationView*    dotView = (MKAnnotationView*)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"DotAnnotationView"];
        
        if (!dotView)
        {
            // Create a new dot view if none was found.
            dotView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                    reuseIdentifier:@"DotAnnotationView"];
            dotView.image = [UIImage imageNamed:@"Dot.png"];
            dotView.annotation = annotation;
        }
        else
            dotView.annotation = annotation;
        
        return dotView;
    }
    
    return nil;
}

// Called by some map view magic when the user location changes.
- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    if (!hasLocatedUser) {
        [self centerViewOnUser];
        hasLocatedUser = YES;
    }
    // Collect the locations to delete in a set while iterating through the elements.
    // This is necessary because collections cannot be changed while iterating through them.
    NSMutableSet *locationsToDelete = [NSMutableSet setWithCapacity:5];
    
    for (CLLocation *location in dotAnnotationDict) {
        if ([location distanceFromLocation:userLocation.location] < 150) {
            // The user collected the dot (pellet).
            // TODO: Update score
            
            // Remove dot and annotation.
            [locationsToDelete addObject:location];
        }
    }
    
    [self removeDotFromLocations:locationsToDelete];
}

// Removes the dots from the locations, this handles all updating
// of data structures and removal of annotations.
- (void) removeDotFromLocations:(NSSet *) locations
{
    for (CLLocation *location in locations)
    {
        id<MKAnnotation> annotation = [dotAnnotationDict objectForKey:location];
        [mapView removeAnnotation:annotation];
        [dotAnnotationDict removeObjectForKey:location];
    }
}

// Centers the view so that it includes all the dots
// at the appropriate zoom level.
- (void) centerViewOnDots
{
    MKMapRect zoomRect = MKMapRectNull;
    for (CLLocation *location in dotAnnotationDict)
    {
        id<MKAnnotation> annotation = [dotAnnotationDict objectForKey:location];
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    [mapView setVisibleMapRect:zoomRect animated:YES];
}

- (void) centerViewOnUser
{
    // Center the view.
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    
    // Set to default zoom level.
    MKCoordinateRegion theRegion = mapView.region;
    
    theRegion.span.longitudeDelta = 0.1;
    theRegion.span.latitudeDelta = 0.1;
    [mapView setRegion:theRegion animated:YES];
}

@end
