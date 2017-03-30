// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/clean/chrome/browser/ui/tab_strip/tab_strip_coordinator.h"

#import "ios/clean/chrome/browser/ui/tab_collection/tab_collection_mediator.h"
#import "ios/clean/chrome/browser/ui/tab_strip/tab_strip_view_controller.h"
#import "ios/shared/chrome/browser/coordinator_context/coordinator_context.h"
#import "ios/shared/chrome/browser/tabs/web_state_list.h"
#import "ios/shared/chrome/browser/ui/browser_list/browser.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

@interface TabStripCoordinator ()
@property(nonatomic, strong) TabStripViewController* viewController;
@property(nonatomic, strong) TabCollectionMediator* mediator;
@property(nonatomic, readonly) WebStateList& webStateList;
@end

@implementation TabStripCoordinator
@synthesize viewController = _viewController;
@synthesize mediator = _mediator;

#pragma mark - Properties

- (WebStateList&)webStateList {
  return self.browser->web_state_list();
}

#pragma mark - BrowserCoordinator

- (void)start {
  self.viewController = [[TabStripViewController alloc] init];
  self.mediator = [[TabCollectionMediator alloc] init];
  self.mediator.webStateList = &self.webStateList;
  self.mediator.consumer = self.viewController;
  self.viewController.dataSource = self.mediator;

  [self.context.baseViewController presentViewController:self.viewController
                                                animated:self.context.animated
                                              completion:nil];
  [super start];
}

@end