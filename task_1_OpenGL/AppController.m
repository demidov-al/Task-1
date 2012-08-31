//
//  AppController.m
//  task_1_OpenGL
//
//  Created by Alexander Demidov on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

#define DEFAULT_MAX_X 1.0
#define DEFAULT_MAX_T 1.0
#define DEFAULT_X_NUM 10
#define DEFAULT_T_NUM 10
#define DEFAULT_EPS 0.01

double F(const double U)
{
    return log(1.0 + U*U);
}

double F_(const double U)
{
    return (2.0*U / (1.0 + U*U));
}

@interface AppController ()

- (NSArray *)getPointsWithEPS:(const double)eps XMax:(const double)maxX TMax:(const double)maxT XNum:(const int)numX TNum:(const int)numT;
- (void)plotGraphWithPoints:(NSArray *)points;

@end

@implementation AppController

@synthesize plotView = _plotView;
@synthesize maxXField = _maxXField;
@synthesize maxTField = _maxTField;
@synthesize xNumField = _xNumField;
@synthesize tNumField = _tNumField;
@synthesize epsField = _epsField;
@synthesize indicator = _indicator;
@synthesize plotButton = _plotButton;
@synthesize scaleXField = _scaleXField;
@synthesize scaleYField = _scaleYField;
@synthesize scaleZField = _scaleZField;
@synthesize points = _points;
@synthesize Xnum = _Xnum;

- (IBAction)plot:(NSButton *)sender
{
	[self.indicator startAnimation:self];
    self.Xnum = [self.xNumField.stringValue intValue];
    
    self.points = [self getPointsWithEPS:[self.epsField.stringValue doubleValue]
                                    XMax:[self.maxXField.stringValue doubleValue]
                                    TMax:[self.maxTField.stringValue doubleValue]
                                    XNum:[self.xNumField.stringValue intValue]
                                    TNum:[self.tNumField.stringValue intValue]];
    [self plotGraphWithPoints:self.points];
	[self.plotButton setEnabled:NO];
}

- (IBAction)defaultKeys:(NSButton *)sender
{
    [self.maxXField setStringValue:[NSString stringWithFormat:@"%.1lf", DEFAULT_MAX_X]];
    [self.maxTField setStringValue:[NSString stringWithFormat:@"%.1lf", DEFAULT_MAX_T]];
    [self.xNumField setStringValue:[NSString stringWithFormat:@"%d", DEFAULT_X_NUM]];
    [self.tNumField setStringValue:[NSString stringWithFormat:@"%d", DEFAULT_T_NUM]];
    [self.epsField setStringValue:[NSString stringWithFormat:@"%.2lf", DEFAULT_EPS]];
}

- (IBAction)setScale:(NSButton *)sender
{
	GLfloat X = [self.scaleXField.stringValue doubleValue];
	GLfloat Y = [self.scaleYField.stringValue doubleValue];
	GLfloat Z = [self.scaleZField.stringValue doubleValue];
	[self.plotView setScaleWithX:X Y:Y Z:Z];
}

- (NSArray *)getPointsWithEPS:(double)eps XMax:(double)maxX TMax:(double)maxT XNum:(int)numX TNum:(int)numT
{
    int i, j;
    const double dT = maxT / numT;
    const double dX = maxX / numX;
    
    double **GRID;
    GRID = (double **)malloc(numX*sizeof(double *));
    
    for (i = 0; i < numX; i++) {
        GRID[i] = (double *)malloc(numT*sizeof(double));
    }
    
    double currentX = 0.0;
    for (i = 0; i < numX; i++) {
        GRID[i][0] = cos(M_PI*currentX/2.0);
        currentX += dX;
    }
    
    double currentT = 0.0;
    for (j = 0; j < numT; j++) {
        GRID[0][j] = 1 + 0.5*atan(currentT);
        currentT += dT;
    }
    
    currentX = currentT = 0.0;
    
    double tempGRID = 0.0;
    for (j = 0; j < (numT-1); j++) {
        for (i = 0; i < (numX-1); i++) {
            GRID[i+1][j+1] = GRID[i][j+1];
            
            if (GRID[i][j+1] == 0.0) printf("%lf\n", GRID[i][j+1]);
            
            tempGRID = GRID[i+1][j+1] - (dX*(GRID[i][j+1] - GRID[i][j] + GRID[i+1][j+1] - GRID[i+1][j]) + dT*(F(GRID[i+1][j+1]) - F(GRID[i][j+1]) + F(GRID[i+1][j]) - F(GRID[i][j])))/(dX + dT*F_(GRID[i+1][j+1]));
            
            while (fabs(tempGRID - GRID[i+1][j+1]) > eps) {
                GRID[i+1][j+1] = tempGRID;
                tempGRID = GRID[i+1][j+1] - (dX*(GRID[i][j+1] - GRID[i][j] + GRID[i+1][j+1] - GRID[i+1][j]) + dT*(F(GRID[i+1][j+1]) - F(GRID[i][j+1]) + F(GRID[i+1][j]) - F(GRID[i][j])))/(dX + dT*F_(GRID[i+1][j+1]));
            }
            GRID[i+1][j+1] = tempGRID;
            tempGRID = 0.0;
        }
    }
    
    NSMutableArray *points = [NSMutableArray new];
    NSArray *pointInf;
    for(j = 0; j < numT; j++) {
        currentX = 0.0;
		for(i = 0; i < numX; i++) {
            pointInf = [NSArray arrayWithObjects:[NSNumber numberWithDouble:currentX],
                        [NSNumber numberWithDouble:currentT],
                        [NSNumber numberWithDouble:GRID[i][j]],
                        nil];
            [points addObject:pointInf];
            pointInf = nil;
            currentX += dX;
		}
        currentT += dT;
	}
    
    for (i = 0; i < numX; i++) {
        free(GRID[i]);
    }
    free(GRID);
    
	NSLog(@"Calculations done!");
    return points;
}

- (void)plotGraphWithPoints:(NSArray *)points
{
    self.plotView.plotPoints = points;
	self.plotView.delegate = self;
    [self.plotView setNeedsDisplay:YES];
	NSLog(@"Points has been sent to plot!");
}

- (void)plotViewDidFinishedPlot
{
	[self.indicator stopAnimation:self];
	[self.plotButton setEnabled:YES];
}
- (void)plotViewHasError
{
	[self.indicator stopAnimation:self];
	[self.plotButton setEnabled:YES];
}
@end
