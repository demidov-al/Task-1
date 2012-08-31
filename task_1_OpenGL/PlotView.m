//
//  PlotView.m
//  task_1_OpenGL
//
//  Created by Alexander Demidov on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlotView.h"
#import "AppController.h"
#import <GLUT/glut.h>

#define A 0.5 //длина засечки на оси
#define DEFAULT_LOOK_AT_RADIUS 7.0	//расстояние от камеры до центра СК
#define DEFAULT_LOOK_AT_TETTA M_PI/4.0
#define DEFAULT_LOOK_AT_FI M_PI/4.0
#define DEFAULT_SCALE 1.0
#define ANGLE_STEP 0.05

GLfloat frontColor[] = {1.0, 0.0, 0.0, 1.0};
GLfloat backColor[] = {0.0, 1.0, 0.0, 1.0};

void normalizeVector(double *v) {
    double x = v[0];
    double y = v[1];
    double z = v[2];
    double length = sqrt(x*x + y*y + z*z);
    
    v[0] = v[0] / length;
    v[1] = v[1] / length;
    v[2] = v[2] / length;
}

@interface PlotView ()

- (void)prepare;
- (void)drawAxis;
- (void)drawPlotFromCurrentPoints;

@end

@implementation PlotView

@synthesize plotPoints = _plotPoints;
@synthesize delegate = _delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepare];
		LookAtRad = DEFAULT_LOOK_AT_RADIUS;
		LookAtFi = DEFAULT_LOOK_AT_FI;
		LookAtTetta = DEFAULT_LOOK_AT_TETTA;
		isThereAnyPlot = NO;
		Xscale = Yscale = Zscale = DEFAULT_SCALE;
    }
    return self;
}

- (void)setScaleWithX:(GLfloat)scaleX Y:(GLfloat)scaleY Z:(GLfloat)scaleZ
{
	Xscale = scaleX;
	Yscale = scaleY;
	Zscale = scaleZ;
	[self setNeedsDisplay:YES];
}

- (void)prepare
{
    NSLog(@"prepare...");
    
    NSOpenGLContext *glcontext = [self openGLContext];
    [glcontext makeCurrentContext];
    
	glClearColor(0.0, 0.0, 0.0, 0.0);
    
    glShadeModel(GL_SMOOTH);
    
    GLfloat mat_specular[] = {1.0, 1.0, 1.0, 1.0};
    glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
    glMaterialf(GL_FRONT, GL_SHININESS, 128.0);
    
    GLfloat position[] = {0.0, 0.0, 3.0, 1.0};
    glLightfv(GL_LIGHT0, GL_POSITION, position);
    glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE);
    
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
}

- (void)reshape
{
    glViewport(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);

    glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(90.0, 1.33, 0.1, 30.0);
	
	glMatrixMode(GL_MODELVIEW);
}

- (void)drawRect:(NSRect)dirtyRect
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	if (!self.plotPoints) {
		NSLog(@"You should draw some text on the plot view");
//вывод текста в OpenGL
		[self.delegate plotViewHasError];
	}
	else {
		glLoadIdentity();
		gluLookAt(LookAtRad*sin(LookAtTetta)*cos(LookAtFi),
				  LookAtRad*sin(LookAtTetta)*sin(LookAtFi),
				  LookAtRad*cos(LookAtTetta), 0.0, 0.0, 0.0, 0.0, 0.0, 1.0);
		[self drawAxis];
		glScalef(Xscale, Yscale, Zscale);
		[self drawPlotFromCurrentPoints];
		[self.delegate plotViewDidFinishedPlot];
		isThereAnyPlot = YES;
	}
	glFlush();
}

- (void)drawAxis
{
	//нарисовать стрелочки на осях!
    glDisable(GL_LIGHTING);
    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_LINES);
	//ось Z
    glVertex3d(0.0, 0.0, 10.0);
    glVertex3d(0.0, 0.0, -10.0);
	//ось Y
    glVertex3d(0.0, 10.0, 0.0);
    glVertex3d(0.0, -10.0, 0.0);
	//ось X
    glVertex3d(10.0, 0.0, 0.0);
    glVertex3d(-10.0, 0.0, 0.0);
	//засечки на осях
	GLint i;
	for (i = 0; i < 10; i++) {
		glVertex3d((GLdouble)i, 0.0 - A, 0.0);
		glVertex3d((GLdouble)i, 0.0 + A, 0.0);
		glVertex3d(0.0 - A, (GLdouble)i, 0.0);
		glVertex3d(0.0 + A, (GLdouble)i, 0.0);
		glVertex3d(0.0, 0.0 - A, (GLdouble)i);
		glVertex3d(0.0, 0.0 + A, (GLdouble)i);
		glVertex3d(-(GLdouble)i, 0.0 - A, 0.0);
		glVertex3d(-(GLdouble)i, 0.0 + A, 0.0);
		glVertex3d(0.0 - A, -(GLdouble)i, 0.0);
		glVertex3d(0.0 + A, -(GLdouble)i, 0.0);
		glVertex3d(0.0, 0.0 - A, -(GLdouble)i);
		glVertex3d(0.0, 0.0 + A, -(GLdouble)i);
	}
    glEnd();
}

- (void)drawPlotFromCurrentPoints
{
//	glColor3f(1.0, 0.0, 0.0);
    glEnable(GL_LIGHTING);
    
    glMaterialfv(GL_FRONT, GL_DIFFUSE, frontColor);
    glMaterialfv(GL_BACK, GL_DIFFUSE, backColor);
    
	GLint i;
    GLint Xnum = self.delegate.Xnum;
    
	for (i = 0; i < [self.plotPoints count] - Xnum; i++) {
        if ((i % Xnum) == (Xnum - 1)) continue;
        
        double leftBottomPoint[] = {[[[self.plotPoints objectAtIndex:i] objectAtIndex:0] doubleValue],
                                    [[[self.plotPoints objectAtIndex:i] objectAtIndex:1] doubleValue],
                                    [[[self.plotPoints objectAtIndex:i] objectAtIndex:2] doubleValue]};
        
        double rightBottomPoint[] = {[[[self.plotPoints objectAtIndex:(i + 1)] objectAtIndex:0] doubleValue],
                                     [[[self.plotPoints objectAtIndex:(i + 1)] objectAtIndex:1] doubleValue],
                                     [[[self.plotPoints objectAtIndex:(i + 1)] objectAtIndex:2] doubleValue]};
        
        double leftTopPoint[] = {[[[self.plotPoints objectAtIndex:(i + Xnum)] objectAtIndex:0] doubleValue],
                                 [[[self.plotPoints objectAtIndex:(i + Xnum)] objectAtIndex:1] doubleValue],
                                 [[[self.plotPoints objectAtIndex:(i + Xnum)] objectAtIndex:2] doubleValue]};
        
        double rightTopPoint[] = {[[[self.plotPoints objectAtIndex:(i + Xnum + 1)] objectAtIndex:0] doubleValue],
                                  [[[self.plotPoints objectAtIndex:(i + Xnum + 1)] objectAtIndex:1] doubleValue],
                                  [[[self.plotPoints objectAtIndex:(i + Xnum + 1)] objectAtIndex:2] doubleValue]};
        
        double n[] = {(rightBottomPoint[1] - leftBottomPoint[1])*(rightTopPoint[2] - leftBottomPoint[2]) - (rightBottomPoint[2] - leftBottomPoint[2])*(rightTopPoint[1] - leftBottomPoint[1]),
                      (rightBottomPoint[2] - leftBottomPoint[2])*(rightTopPoint[0] - leftBottomPoint[0]) - (rightBottomPoint[0] - leftBottomPoint[0])*(rightTopPoint[2] - leftBottomPoint[2]),
                      (rightBottomPoint[0] - leftBottomPoint[0])*(rightTopPoint[1] - leftBottomPoint[1]) - (rightBottomPoint[1] - leftBottomPoint[1])*(rightTopPoint[0] - leftBottomPoint[0])};
        normalizeVector(n);
        
        glBegin(GL_QUAD_STRIP);
        
        glNormal3dv(n);
        
		glVertex3dv(leftBottomPoint);
        glVertex3dv(rightBottomPoint);
        glVertex3dv(leftTopPoint);
        glVertex3dv(rightTopPoint);
        
        glEnd();
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if (!isThereAnyPlot) return;
	
	GLfloat dX = theEvent.deltaX;
	GLfloat dY = theEvent.deltaY;
//	NSLog(@"dX = %f dY = %f", dX, dY);
//	
//	GLfloat x = LookAtRad*sin(LookAtTetta)*cos(LookAtFi);
//	GLfloat y = LookAtRad*sin(LookAtTetta)*sin(LookAtFi);
//	GLfloat z = LookAtRad*cos(LookAtTetta);
//	
//	x = x - 0.1*dX;
//	z = z - 0.1*dY;
//	
//	LookAtTetta = atanf(z/sqrtf(x*x + y*y));
//	LookAtFi = atanf(x/y);
	
	GLfloat newTetta = LookAtTetta;
	GLfloat newFi = LookAtFi;
	if (dY > 0.0) newTetta -= ANGLE_STEP;
	else if (dY < 0.0) newTetta += ANGLE_STEP;
	if (dX > 0.0) newFi -= ANGLE_STEP;
	else if (dX < 0.0) newFi += ANGLE_STEP;
	
	if (newTetta < 0.0 || newTetta > M_PI) return;
	
	LookAtTetta = newTetta;
	LookAtFi = newFi;
	//посмотреть граничные условия
//	NSLog(@"tetta = %f fi = %f", LookAtTetta, LookAtFi);
	[self setNeedsDisplay:YES];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	if (!isThereAnyPlot) return;
	GLfloat newLookAtRad = LookAtRad - (GLfloat)theEvent.deltaY;
	if ((GLint)LookAtRad <= (GLint)theEvent.deltaY || (GLint)newLookAtRad > 18) return;
	LookAtRad = newLookAtRad;
	[self setNeedsDisplay:YES];
}

@end
