//
//  PlotView.h
//  task_1_OpenGL
//
//  Created by Alexander Demidov on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PlotViewDelegateAndDataSource;

@interface PlotView : NSOpenGLView {
	GLfloat LookAtRad, LookAtTetta, LookAtFi;
	BOOL isThereAnyPlot;
	GLfloat Xscale, Yscale, Zscale;
}

@property (strong) NSArray *plotPoints;
@property (weak) id <PlotViewDelegateAndDataSource> delegate;

- (void)setScaleWithX:(GLfloat)scaleX Y:(GLfloat)scaleY Z:(GLfloat)scaleZ;

@end

@protocol PlotViewDelegateAndDataSource <NSObject>

@property (nonatomic) int Xnum;

- (void)plotViewDidFinishedPlot;
- (void)plotViewHasError;

@end