// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/shared/chrome/browser/ui/browser_list/browser_web_state_list_delegate.h"

#include "base/logging.h"
#import "ios/chrome/browser/sessions/ios_chrome_session_tab_helper.h"
#import "ios/chrome/browser/ssl/ios_security_state_tab_helper.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

BrowserWebStateListDelegate::BrowserWebStateListDelegate(Browser* browser)
    : browser_(browser) {
  DCHECK(browser_);
}

BrowserWebStateListDelegate::~BrowserWebStateListDelegate() = default;

void BrowserWebStateListDelegate::WillAddWebState(web::WebState* web_state) {
  IOSChromeSessionTabHelper::CreateForWebState(web_state);
  IOSSecurityStateTabHelper::CreateForWebState(web_state);
}

void BrowserWebStateListDelegate::WebStateDetached(web::WebState* web_state) {}
