//
//  AppController.h
//  task_1_OpenGL
//
//  Created by Alexander Demidov on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlotView.h"

@interface AppController : NSObject <PlotViewDelegateAndDataSource>

@property (weak) IBOutlet PlotView *plotView;
@property (weak) IBOutlet NSTextField *maxXField;
@property (weak) IBOutlet NSTextField *maxTField;
@property (weak) IBOutlet NSTextField *xNumField;
@property (weak) IBOutlet NSTextField *tNumField;
@property (weak) IBOutlet NSTextField *epsField;
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSButton *plotButton;
@property (weak) IBOutlet NSTextField *scaleXField;
@property (weak) IBOutlet NSTextField *scaleYField;
@property (weak) IBOutlet NSTextField *scaleZField;

@property (strong) NSArray *points; //первый объект - значение X, второй - значение T, третий - значение функции
@property (nonatomic) int Xnum;


- (IBAction)plot:(NSButton *)sender;
- (IBAction)defaultKeys:(NSButton *)sender;
- (IBAction)setScale:(NSButton *)sender;
- (void)plotViewDidFinishedPlot;
- (void)plotViewHasError;

@end
