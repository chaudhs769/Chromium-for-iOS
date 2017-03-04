// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "ios/web/public/test/url_test_util.h"

#import "ios/web/navigation/navigation_item_impl.h"

namespace web {

base::string16 GetDisplayTitleForUrl(const GURL& url) {
  return NavigationItemImpl::GetDisplayTitleForURL(url);
}

}  // namespace web
