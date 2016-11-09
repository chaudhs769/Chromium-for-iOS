// Copyright 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/web/navigation/crw_session_controller.h"

#import <Foundation/Foundation.h>

#include <utility>

#include "base/logging.h"
#import "base/mac/scoped_nsobject.h"
#include "base/strings/sys_string_conversions.h"
#import "ios/web/navigation/crw_session_controller+private_constructors.h"
#include "ios/web/navigation/crw_session_entry.h"
#include "ios/web/navigation/navigation_item_impl.h"
#include "ios/web/public/referrer.h"
#include "ios/web/public/test/test_browser_state.h"
#include "ios/web/public/test/test_web_thread_bundle.h"
#import "net/base/mac/url_conversions.h"
#include "testing/gtest/include/gtest/gtest.h"
#include "testing/gtest_mac.h"
#include "testing/platform_test.h"

@interface CRWSessionController (Testing)
- (const GURL&)URLForSessionAtIndex:(NSUInteger)index;
- (const GURL&)currentURL;
@end

@implementation CRWSessionController (Testing)
- (const GURL&)URLForSessionAtIndex:(NSUInteger)index {
  CRWSessionEntry* entry =
      static_cast<CRWSessionEntry*>([self.entries objectAtIndex:index]);
  return entry.navigationItem->GetURL();
}

- (const GURL&)currentURL {
  DCHECK([self currentEntry]);
  return [self currentEntry].navigationItem->GetURL();
}
@end

namespace {

class CRWSessionControllerTest : public PlatformTest {
 protected:
  void SetUp() override {
    session_controller_.reset(
        [[CRWSessionController alloc] initWithWindowName:@"test window"
                                                openerId:@"opener"
                                             openedByDOM:NO
                                   openerNavigationIndex:0
                                            browserState:&browser_state_]);
  }

  web::Referrer MakeReferrer(const std::string& url) {
    return web::Referrer(GURL(url), web::ReferrerPolicyDefault);
  }

  web::TestWebThreadBundle thread_bundle_;
  web::TestBrowserState browser_state_;
  base::scoped_nsobject<CRWSessionController> session_controller_;
};

TEST_F(CRWSessionControllerTest, InitWithWindowName) {
  EXPECT_NSEQ(@"test window", [session_controller_ windowName]);
  EXPECT_NSEQ(@"opener", [session_controller_ openerId]);
  EXPECT_FALSE([session_controller_ isOpenedByDOM]);
  EXPECT_EQ(0U, [[session_controller_ entries] count]);
  EXPECT_EQ(nil, [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, AddPendingEntry) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];

  EXPECT_EQ(0U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ currentURL]);
}

TEST_F(CRWSessionControllerTest, AddPendingEntryWithCommittedEntries) {
  [session_controller_
        addPendingEntry:GURL("http://www.committed.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.committed.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ currentURL]);
}

TEST_F(CRWSessionControllerTest, AddPendingEntryOverriding) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_
        addPendingEntry:GURL("http://www.another.url.com")
               referrer:MakeReferrer("http://www.another.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];

  EXPECT_EQ(0U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.another.url.com/"),
      [session_controller_ currentURL]);
}

TEST_F(CRWSessionControllerTest, AddPendingEntryAndCommit) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, AddPendingEntryOverridingAndCommit) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_
        addPendingEntry:GURL("http://www.another.url.com")
               referrer:MakeReferrer("http://www.another.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.another.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, AddPendingEntryAndCommitMultiple) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_
        addPendingEntry:GURL("http://www.another.url.com")
               referrer:MakeReferrer("http://www.another.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(2U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      GURL("http://www.another.url.com/"),
      [session_controller_ URLForSessionAtIndex:1U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:1U],
      [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, AddPendingEntryAndDiscard) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ discardNonCommittedEntries];

  EXPECT_EQ(0U, [[session_controller_ entries] count]);
  EXPECT_EQ(nil, [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, AddPendingEntryAndDiscardAndAddAndCommit) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ discardNonCommittedEntries];

  [session_controller_
        addPendingEntry:GURL("http://www.another.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.another.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, AddPendingEntryAndCommitAndAddAndDiscard) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_
        addPendingEntry:GURL("http://www.another.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ discardNonCommittedEntries];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest,
       CommitPendingEntryWithoutPendingOrCommittedEntry) {
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(0U, [[session_controller_ entries] count]);
  EXPECT_EQ(nil, [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest,
       CommitPendingEntryWithoutPendingEntryWithCommittedEntry) {
  // Setup committed entry
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  // Commit pending entry when there is no such one
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
}

// Tests that forward entries are discarded after navigation entry is committed.
TEST_F(CRWSessionControllerTest, CommitPendingEntryWithExistingForwardEntries) {
  // Make 3 entries.
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                              referrer:MakeReferrer("http://www.example.com/a")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:YES];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/1")
                              referrer:MakeReferrer("http://www.example.com/b")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:YES];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/2")
                              referrer:MakeReferrer("http://www.example.com/c")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:YES];
  [session_controller_ commitPendingEntry];

  // Go back to the first entry.
  [session_controller_ goToEntry:[[session_controller_ entries] firstObject]];

  // Create and commit a new pending entry.
  [session_controller_ addPendingEntry:GURL("http://www.example.com/2")
                              referrer:MakeReferrer("http://www.example.com/c")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:YES];
  [session_controller_ commitPendingEntry];

  // All forward entries should go away.
  EXPECT_EQ(2U, [[session_controller_ entries] count]);
  EXPECT_EQ(0U, [[session_controller_ forwardEntries] count]);
  ASSERT_EQ(1, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(0, [session_controller_ previousNavigationIndex]);
}

TEST_F(CRWSessionControllerTest,
       DiscardPendingEntryWithoutPendingOrCommittedEntry) {
  [session_controller_ discardNonCommittedEntries];

  EXPECT_EQ(0U, [[session_controller_ entries] count]);
  EXPECT_EQ(nil, [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest,
       DiscardPendingEntryWithoutPendingEntryWithCommittedEntry) {
  // Setup committed entry
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  // Discard noncommitted entries when there is no such one
  [session_controller_ discardNonCommittedEntries];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, UpdatePendingEntryWithoutPendingEntry) {
  [session_controller_
       updatePendingEntry:GURL("http://www.another.url.com")];
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(0U, [[session_controller_ entries] count]);
  EXPECT_EQ(nil, [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, UpdatePendingEntryWithPendingEntry) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_
       updatePendingEntry:GURL("http://www.another.url.com")];

  EXPECT_EQ(
      GURL("http://www.another.url.com/"),
      [session_controller_ currentURL]);
}

TEST_F(CRWSessionControllerTest,
       UpdatePendingEntryWithPendingEntryAlreadyCommited) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
       updatePendingEntry:GURL("http://www.another.url.com")];
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, GoBackWithoutCommitedEntry) {
  [session_controller_ goBack];

  EXPECT_EQ(0U, [[session_controller_ entries] count]);
  EXPECT_EQ(nil, [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, GoBackWithSingleCommitedEntry) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_ goBack];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
}

// Tests going back from the second and last entry to the first one.
TEST_F(CRWSessionControllerTest, GoBackFromTheEnd) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url2.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_ goBack];

  ASSERT_EQ(2U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      GURL("http://www.url2.com/"),
      [session_controller_ URLForSessionAtIndex:1U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
  EXPECT_EQ([[session_controller_ entries] objectAtIndex:1U],
            [session_controller_ previousEntry]);
}

// Tests going back twice from the second and last entry to the first one.
TEST_F(CRWSessionControllerTest, GoBackFromTheBeginning) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url2.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_ goBack];
  [session_controller_ goBack];

  EXPECT_EQ(2U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      GURL("http://www.url2.com/"),
      [session_controller_ URLForSessionAtIndex:1U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
  EXPECT_EQ([[session_controller_ entries] objectAtIndex:1U],
            [session_controller_ previousEntry]);
}

TEST_F(CRWSessionControllerTest, GoBackFromTheMiddle) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url2.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url3.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url4.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_ goBack];
  [session_controller_ goBack];

  EXPECT_EQ(4U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      GURL("http://www.url2.com/"),
      [session_controller_ URLForSessionAtIndex:1U]);
  EXPECT_EQ(
      GURL("http://www.url3.com/"),
      [session_controller_ URLForSessionAtIndex:2U]);
  EXPECT_EQ(
      GURL("http://www.url4.com/"),
      [session_controller_ URLForSessionAtIndex:3U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:1U],
      [session_controller_ currentEntry]);
  EXPECT_EQ([[session_controller_ entries] objectAtIndex:2U],
            [session_controller_ previousEntry]);
}

TEST_F(CRWSessionControllerTest, GoBackAndRemove) {
  [session_controller_
   addPendingEntry:GURL("http://www.url.com")
   referrer:MakeReferrer("http://www.referer.com")
   transition:ui::PAGE_TRANSITION_TYPED
   rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
   addPendingEntry:GURL("http://www.url2.com")
   referrer:MakeReferrer("http://www.referer.com")
   transition:ui::PAGE_TRANSITION_TYPED
   rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_ goBack];
  [session_controller_ removeEntryAtIndex:1];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
            GURL("http://www.url.com/"),
            [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
            [[session_controller_ entries] objectAtIndex:0U],
            [session_controller_ currentEntry]);
  EXPECT_EQ([session_controller_ currentEntry],
            [session_controller_ previousEntry]);
}

TEST_F(CRWSessionControllerTest, GoForwardWithoutCommitedEntry) {
  [session_controller_ goForward];

  EXPECT_EQ(0U, [[session_controller_ entries] count]);
  EXPECT_EQ(nil, [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, GoForwardWithSingleCommitedEntry) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_ goForward];

  EXPECT_EQ(1U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:0U],
      [session_controller_ currentEntry]);
  EXPECT_EQ([[session_controller_ entries] objectAtIndex:0U],
            [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, GoForewardFromTheEnd) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url2.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_ goForward];

  EXPECT_EQ(2U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      GURL("http://www.url2.com/"),
      [session_controller_ URLForSessionAtIndex:1U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:1U],
      [session_controller_ currentEntry]);
  EXPECT_EQ([[session_controller_ entries] objectAtIndex:1U],
            [session_controller_ currentEntry]);
}

TEST_F(CRWSessionControllerTest, GoForewardFromTheBeginning) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url2.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_ goBack];
  [session_controller_ goForward];

  EXPECT_EQ(2U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      GURL("http://www.url2.com/"),
      [session_controller_ URLForSessionAtIndex:1U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:1U],
      [session_controller_ currentEntry]);
  EXPECT_EQ([[session_controller_ entries] objectAtIndex:0U],
            [session_controller_ previousEntry]);
}

TEST_F(CRWSessionControllerTest, GoForwardFromTheMiddle) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url2.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url3.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url4.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  [session_controller_ goBack];
  [session_controller_ goBack];
  [session_controller_ goForward];

  EXPECT_EQ(4U, [[session_controller_ entries] count]);
  EXPECT_EQ(
      GURL("http://www.url.com/"),
      [session_controller_ URLForSessionAtIndex:0U]);
  EXPECT_EQ(
      GURL("http://www.url2.com/"),
      [session_controller_ URLForSessionAtIndex:1U]);
  EXPECT_EQ(
      GURL("http://www.url3.com/"),
      [session_controller_ URLForSessionAtIndex:2U]);
  EXPECT_EQ(
      GURL("http://www.url4.com/"),
      [session_controller_ URLForSessionAtIndex:3U]);
  EXPECT_EQ(
      [[session_controller_ entries] objectAtIndex:2U],
      [session_controller_ currentEntry]);
  EXPECT_EQ([[session_controller_ entries] objectAtIndex:1U],
            [session_controller_ previousEntry]);
}

// Tests going delta, including out of range cases.
TEST_F(CRWSessionControllerTest, GoDelta) {
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                              referrer:MakeReferrer("http://www.example.com/a")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/redirect")
                              referrer:MakeReferrer("http://www.example.com/r")
                            transition:ui::PAGE_TRANSITION_IS_REDIRECT_MASK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/1")
                              referrer:MakeReferrer("http://www.example.com/b")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/2")
                              referrer:MakeReferrer("http://www.example.com/c")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/redirect")
                              referrer:MakeReferrer("http://www.example.com/r")
                            transition:ui::PAGE_TRANSITION_IS_REDIRECT_MASK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  ASSERT_EQ(4, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(3, [session_controller_ previousNavigationIndex]);
  NSArray* entries = [session_controller_ entries];
  ASSERT_EQ(5U, entries.count);

  // Try going forward, which should not be possible.
  EXPECT_FALSE([session_controller_ canGoDelta:1]);
  [session_controller_ goDelta:1];
  ASSERT_EQ(4, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(3, [session_controller_ previousNavigationIndex]);

  // Try going back 3 entries, which should not be possible as there are only 2
  // non-redirect entries.
  EXPECT_FALSE([session_controller_ canGoDelta:-3]);
  [session_controller_ goDelta:-3];
  ASSERT_EQ(4, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(3, [session_controller_ previousNavigationIndex]);
  [session_controller_ goToEntry:entries[4]];

  // Go back 2 entries.
  EXPECT_TRUE([session_controller_ canGoDelta:-2]);
  [session_controller_ goDelta:-2];
  ASSERT_EQ(1, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(4, [session_controller_ previousNavigationIndex]);

  // Try going back 1 entry which should not be possible, because back entry had
  // redirect response.
  EXPECT_FALSE([session_controller_ canGoDelta:-1]);
  [session_controller_ goDelta:-1];
  ASSERT_EQ(1, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(4, [session_controller_ previousNavigationIndex]);

  // Try going forward 3 entries which should not be possible, because there are
  // only 2 non-redirect entries in forward entries.
  EXPECT_FALSE([session_controller_ canGoDelta:3]);
  [session_controller_ goDelta:3];
  ASSERT_EQ(1, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(4, [session_controller_ previousNavigationIndex]);
  [session_controller_ goToEntry:entries[1]];

  // Go forward 2 entries.
  EXPECT_TRUE([session_controller_ canGoDelta:2]);
  [session_controller_ goDelta:2];
  ASSERT_EQ(4, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(1, [session_controller_ previousNavigationIndex]);

  // Now add a transient entry and go back 2 entries.
  [session_controller_ addTransientEntryWithURL:GURL("http://www.example.com")];
  EXPECT_TRUE([session_controller_ canGoDelta:-2]);
  [session_controller_ goDelta:-2];
  ASSERT_EQ(2, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(4, [session_controller_ previousNavigationIndex]);

  // Try going back 2 entries which should not be possible, because there is
  // only one non-redirect back entry.
  EXPECT_FALSE([session_controller_ canGoDelta:-2]);
  [session_controller_ goDelta:-2];
  ASSERT_EQ(2, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(4, [session_controller_ previousNavigationIndex]);
  [session_controller_ goToEntry:entries[2]];

  // Go back 1 entry.
  EXPECT_TRUE([session_controller_ canGoDelta:-1]);
  [session_controller_ goDelta:-1];
  ASSERT_EQ(1, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(2, [session_controller_ previousNavigationIndex]);

  // Go forward 1 entry.
  EXPECT_TRUE([session_controller_ canGoDelta:1]);
  [session_controller_ goDelta:1];
  ASSERT_EQ(2, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(1, [session_controller_ previousNavigationIndex]);
}

TEST_F(CRWSessionControllerTest, CanGoBackWithoutCommitedEntry) {
  EXPECT_FALSE([session_controller_ canGoBack]);
  EXPECT_FALSE([session_controller_ canGoDelta:-1]);
}

// Tests that |canGoBack| returns NO if there is a transient entry, but no
// committed entries.
TEST_F(CRWSessionControllerTest, CanGoBackWithTransientEntry) {
  [session_controller_ addTransientEntryWithURL:GURL("http://www.url.com")];

  EXPECT_FALSE([session_controller_ canGoBack]);
}

// Tests that |canGoBack| returns YES if there is a transient entry and at least
// one committed entry.
TEST_F(CRWSessionControllerTest, CanGoBackWithTransientEntryAndCommittedEntry) {
  [session_controller_ addPendingEntry:GURL("http://www.url.com")
                              referrer:MakeReferrer("http://www.referer.com")
                            transition:ui::PAGE_TRANSITION_TYPED
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addTransientEntryWithURL:GURL("http://www.url.com")];

  EXPECT_TRUE([session_controller_ canGoBack]);
}

TEST_F(CRWSessionControllerTest, CanGoBackWithSingleCommitedEntry) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_FALSE([session_controller_ canGoBack]);
  EXPECT_FALSE([session_controller_ canGoDelta:-1]);
}

TEST_F(CRWSessionControllerTest, CanGoBackWithMultipleCommitedEntries) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url1.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url2.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_TRUE([session_controller_ canGoBack]);
  EXPECT_TRUE([session_controller_ canGoDelta:-1]);

  [session_controller_ goBack];
  EXPECT_TRUE([session_controller_ canGoBack]);
  EXPECT_TRUE([session_controller_ canGoDelta:-1]);

  [session_controller_ goBack];
  EXPECT_FALSE([session_controller_ canGoBack]);
  EXPECT_FALSE([session_controller_ canGoDelta:-1]);

  [session_controller_ goBack];
  EXPECT_FALSE([session_controller_ canGoBack]);
  EXPECT_FALSE([session_controller_ canGoDelta:-1]);

  [session_controller_ goForward];
  EXPECT_TRUE([session_controller_ canGoBack]);
  EXPECT_TRUE([session_controller_ canGoDelta:-1]);
}

// Tests that going forward is not possible if there is a pending entry.
TEST_F(CRWSessionControllerTest, CanGoForwardWithPendingEntry) {
  [session_controller_ addPendingEntry:GURL("http://www.url.com")
                              referrer:MakeReferrer("http://www.referer.com")
                            transition:ui::PAGE_TRANSITION_TYPED
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.url1.com")
                              referrer:MakeReferrer("http://www.referer.com")
                            transition:ui::PAGE_TRANSITION_TYPED
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ goBack];
  [session_controller_ addPendingEntry:GURL("http://www.url2.com")
                              referrer:MakeReferrer("http://www.referer.com")
                            transition:ui::PAGE_TRANSITION_TYPED
                     rendererInitiated:NO];

  // Pending entry should not allow going forward.
  EXPECT_FALSE([session_controller_ canGoForward]);
  EXPECT_FALSE([session_controller_ canGoDelta:1]);
}

TEST_F(CRWSessionControllerTest, CanGoForwardWithoutCommitedEntry) {
  EXPECT_FALSE([session_controller_ canGoForward]);
  EXPECT_FALSE([session_controller_ canGoDelta:1]);
}

TEST_F(CRWSessionControllerTest, CanGoForwardWithSingleCommitedEntry) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_FALSE([session_controller_ canGoForward]);
  EXPECT_FALSE([session_controller_ canGoDelta:1]);
}

TEST_F(CRWSessionControllerTest, CanGoForwardWithMultipleCommitedEntries) {
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url1.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_
        addPendingEntry:GURL("http://www.url2.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_FALSE([session_controller_ canGoForward]);
  EXPECT_FALSE([session_controller_ canGoDelta:1]);

  [session_controller_ goBack];
  EXPECT_TRUE([session_controller_ canGoForward]);
  EXPECT_TRUE([session_controller_ canGoDelta:1]);

  [session_controller_ goBack];
  EXPECT_TRUE([session_controller_ canGoForward]);
  EXPECT_TRUE([session_controller_ canGoDelta:1]);

  [session_controller_ goForward];
  EXPECT_TRUE([session_controller_ canGoForward]);
  EXPECT_TRUE([session_controller_ canGoDelta:1]);

  [session_controller_ goForward];
  EXPECT_FALSE([session_controller_ canGoForward]);
  EXPECT_FALSE([session_controller_ canGoDelta:1]);
}

// Helper to create a NavigationItem. Caller is responsible for freeing
// the memory.
web::NavigationItem* CreateNavigationItem(const std::string& url,
                                          const std::string& referrer,
                                          NSString* title) {
  web::Referrer referrer_object(GURL(referrer),
                                web::ReferrerPolicyDefault);
  web::NavigationItemImpl* navigation_item = new web::NavigationItemImpl();
  navigation_item->SetURL(GURL(url));
  navigation_item->SetReferrer(referrer_object);
  navigation_item->SetTitle(base::SysNSStringToUTF16(title));
  navigation_item->SetTransitionType(ui::PAGE_TRANSITION_TYPED);

  return navigation_item;
}

TEST_F(CRWSessionControllerTest, CreateWithEmptyNavigations) {
  ScopedVector<web::NavigationItem> items;
  base::scoped_nsobject<CRWSessionController> controller(
      [[CRWSessionController alloc] initWithNavigationItems:std::move(items)
                                               currentIndex:0
                                               browserState:&browser_state_]);
  EXPECT_EQ(controller.get().entries.count, 0U);
  EXPECT_EQ(controller.get().currentNavigationIndex, -1);
  EXPECT_EQ(controller.get().previousNavigationIndex, -1);
  EXPECT_FALSE(controller.get().currentEntry);
}

TEST_F(CRWSessionControllerTest, CreateWithNavList) {
  ScopedVector<web::NavigationItem> items;
  items.push_back(CreateNavigationItem("http://www.google.com",
                                       "http://www.referrer.com", @"Google"));
  items.push_back(CreateNavigationItem("http://www.yahoo.com",
                                       "http://www.google.com", @"Yahoo"));
  items.push_back(CreateNavigationItem("http://www.espn.com",
                                       "http://www.nothing.com", @"ESPN"));
  base::scoped_nsobject<CRWSessionController> controller(
      [[CRWSessionController alloc] initWithNavigationItems:std::move(items)
                                               currentIndex:1
                                               browserState:&browser_state_]);

  EXPECT_EQ(controller.get().entries.count, 3U);
  EXPECT_EQ(controller.get().currentNavigationIndex, 1);
  EXPECT_EQ(controller.get().previousNavigationIndex, -1);
  // Sanity check the current entry, the CRWSessionEntry unit test will ensure
  // the entire object is created properly.
  CRWSessionEntry* current_entry = controller.get().currentEntry;
  EXPECT_EQ(current_entry.navigationItem->GetURL(),
            GURL("http://www.yahoo.com"));
  EXPECT_EQ([[controller openerId] length], 0UL);
}

// Tests index of previous navigation entry.
TEST_F(CRWSessionControllerTest, PreviousNavigationEntry) {
  EXPECT_EQ(session_controller_.get().previousNavigationIndex, -1);
  [session_controller_
        addPendingEntry:GURL("http://www.url.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  EXPECT_EQ(session_controller_.get().previousNavigationIndex, -1);
  [session_controller_
        addPendingEntry:GURL("http://www.url1.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  EXPECT_EQ(session_controller_.get().previousNavigationIndex, 0);
  [session_controller_
        addPendingEntry:GURL("http://www.url2.com")
               referrer:MakeReferrer("http://www.referer.com")
             transition:ui::PAGE_TRANSITION_TYPED
      rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(session_controller_.get().previousNavigationIndex, 1);

  [session_controller_ goBack];
  EXPECT_EQ(session_controller_.get().previousNavigationIndex, 2);

  [session_controller_ goBack];
  EXPECT_EQ(session_controller_.get().previousNavigationIndex, 1);

  [session_controller_ goForward];
  EXPECT_EQ(session_controller_.get().previousNavigationIndex, 0);

  [session_controller_ goForward];
  EXPECT_EQ(session_controller_.get().previousNavigationIndex, 1);
}

TEST_F(CRWSessionControllerTest, PushNewEntry) {
  ScopedVector<web::NavigationItem> items;
  items.push_back(CreateNavigationItem("http://www.firstpage.com",
                                       "http://www.starturl.com", @"First"));
  items.push_back(CreateNavigationItem("http://www.secondpage.com",
                                       "http://www.firstpage.com", @"Second"));
  items.push_back(CreateNavigationItem("http://www.thirdpage.com",
                                       "http://www.secondpage.com", @"Third"));
  base::scoped_nsobject<CRWSessionController> controller(
      [[CRWSessionController alloc] initWithNavigationItems:std::move(items)
                                               currentIndex:0
                                               browserState:&browser_state_]);

  GURL pushPageGurl1("http://www.firstpage.com/#push1");
  NSString* stateObject1 = @"{'foo': 1}";
  [controller pushNewEntryWithURL:pushPageGurl1
                      stateObject:stateObject1
                       transition:ui::PAGE_TRANSITION_LINK];
  CRWSessionEntry* pushedEntry = [controller currentEntry];
  web::NavigationItemImpl* pushedItem = pushedEntry.navigationItemImpl;
  NSUInteger expectedCount = 2;
  EXPECT_EQ(expectedCount, controller.get().entries.count);
  EXPECT_EQ(pushPageGurl1, pushedEntry.navigationItem->GetURL());
  EXPECT_TRUE(pushedItem->IsCreatedFromPushState());
  EXPECT_NSEQ(stateObject1, pushedItem->GetSerializedStateObject());
  EXPECT_EQ(GURL("http://www.firstpage.com/"),
            pushedEntry.navigationItem->GetReferrer().url);

  // Add another new entry and check size and fields again.
  GURL pushPageGurl2("http://www.firstpage.com/push2");
  [controller pushNewEntryWithURL:pushPageGurl2
                      stateObject:nil
                       transition:ui::PAGE_TRANSITION_LINK];
  pushedEntry = [controller currentEntry];
  pushedItem = pushedEntry.navigationItemImpl;
  expectedCount = 3;
  EXPECT_EQ(expectedCount, controller.get().entries.count);
  EXPECT_EQ(pushPageGurl2, pushedEntry.navigationItem->GetURL());
  EXPECT_TRUE(pushedItem->IsCreatedFromPushState());
  EXPECT_EQ(nil, pushedItem->GetSerializedStateObject());
  EXPECT_EQ(pushPageGurl1, pushedEntry.navigationItem->GetReferrer().url);
}

TEST_F(CRWSessionControllerTest, IsSameDocumentNavigation) {
  ScopedVector<web::NavigationItem> items;
  items.push_back(
      CreateNavigationItem("http://foo.com", "http://google.com", @"First"));
  // Push state navigation.
  items.push_back(
      CreateNavigationItem("http://foo.com#bar", "http://foo.com", @"Second"));
  items.push_back(CreateNavigationItem("http://google.com",
                                       "http://foo.com#bar", @"Third"));
  items.push_back(
      CreateNavigationItem("http://foo.com", "http://google.com", @"Fourth"));
  // Push state navigation.
  items.push_back(
      CreateNavigationItem("http://foo.com/bar", "http://foo.com", @"Fifth"));
  // Push state navigation.
  items.push_back(CreateNavigationItem("http://foo.com/bar#bar",
                                       "http://foo.com/bar", @"Sixth"));
  base::scoped_nsobject<CRWSessionController> controller(
      [[CRWSessionController alloc] initWithNavigationItems:std::move(items)
                                               currentIndex:0
                                               browserState:&browser_state_]);
  CRWSessionEntry* entry0 = [controller.get().entries objectAtIndex:0];
  CRWSessionEntry* entry1 = [controller.get().entries objectAtIndex:1];
  CRWSessionEntry* entry2 = [controller.get().entries objectAtIndex:2];
  CRWSessionEntry* entry3 = [controller.get().entries objectAtIndex:3];
  CRWSessionEntry* entry4 = [controller.get().entries objectAtIndex:4];
  CRWSessionEntry* entry5 = [controller.get().entries objectAtIndex:5];
  entry1.navigationItemImpl->SetIsCreatedFromPushState(true);
  entry4.navigationItemImpl->SetIsCreatedFromHashChange(true);
  entry5.navigationItemImpl->SetIsCreatedFromPushState(true);

  EXPECT_FALSE(
      [controller isSameDocumentNavigationBetweenEntry:entry0 andEntry:entry0]);
  EXPECT_TRUE(
      [controller isSameDocumentNavigationBetweenEntry:entry0 andEntry:entry1]);
  EXPECT_TRUE(
      [controller isSameDocumentNavigationBetweenEntry:entry5 andEntry:entry3]);
  EXPECT_TRUE(
      [controller isSameDocumentNavigationBetweenEntry:entry4 andEntry:entry3]);
  EXPECT_FALSE(
      [controller isSameDocumentNavigationBetweenEntry:entry1 andEntry:entry2]);
  EXPECT_FALSE(
      [controller isSameDocumentNavigationBetweenEntry:entry0 andEntry:entry5]);
  EXPECT_FALSE(
      [controller isSameDocumentNavigationBetweenEntry:entry2 andEntry:entry4]);
}

TEST_F(CRWSessionControllerTest, UpdateCurrentEntry) {
  ScopedVector<web::NavigationItem> items;
  items.push_back(CreateNavigationItem("http://www.firstpage.com",
                                       "http://www.starturl.com", @"First"));
  items.push_back(CreateNavigationItem("http://www.secondpage.com",
                                       "http://www.firstpage.com", @"Second"));
  items.push_back(CreateNavigationItem("http://www.thirdpage.com",
                                       "http://www.secondpage.com", @"Third"));
  base::scoped_nsobject<CRWSessionController> controller(
      [[CRWSessionController alloc] initWithNavigationItems:std::move(items)
                                               currentIndex:0
                                               browserState:&browser_state_]);

  GURL replacePageGurl1("http://www.firstpage.com/#replace1");
  NSString* stateObject1 = @"{'foo': 1}";

  // Replace current entry and check the size of history and fields of the
  // modified entry.
  [controller updateCurrentEntryWithURL:replacePageGurl1
                            stateObject:stateObject1];
  CRWSessionEntry* replacedEntry = [controller currentEntry];
  web::NavigationItemImpl* replacedItem = replacedEntry.navigationItemImpl;
  NSUInteger expectedCount = 3;
  EXPECT_EQ(expectedCount, controller.get().entries.count);
  EXPECT_EQ(replacePageGurl1, replacedEntry.navigationItem->GetURL());
  EXPECT_FALSE(replacedItem->IsCreatedFromPushState());
  EXPECT_NSEQ(stateObject1, replacedItem->GetSerializedStateObject());
  EXPECT_EQ(GURL("http://www.starturl.com/"),
            replacedEntry.navigationItem->GetReferrer().url);

  // Replace current entry and check size and fields again.
  GURL replacePageGurl2("http://www.firstpage.com/#replace2");
  [controller.get() updateCurrentEntryWithURL:replacePageGurl2 stateObject:nil];
  replacedEntry = [controller currentEntry];
  replacedItem = replacedEntry.navigationItemImpl;
  EXPECT_EQ(expectedCount, controller.get().entries.count);
  EXPECT_EQ(replacePageGurl2, replacedEntry.navigationItem->GetURL());
  EXPECT_FALSE(replacedItem->IsCreatedFromPushState());
  EXPECT_NSEQ(nil, replacedItem->GetSerializedStateObject());
  EXPECT_EQ(GURL("http://www.starturl.com/"),
            replacedEntry.navigationItem->GetReferrer().url);
}

TEST_F(CRWSessionControllerTest, TestBackwardForwardEntries) {
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                             referrer:MakeReferrer("http://www.example.com/a")
                           transition:ui::PAGE_TRANSITION_LINK
                    rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/1")
                             referrer:MakeReferrer("http://www.example.com/b")
                           transition:ui::PAGE_TRANSITION_LINK
                    rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/redirect")
                             referrer:MakeReferrer("http://www.example.com/r")
                           transition:ui::PAGE_TRANSITION_IS_REDIRECT_MASK
                    rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/2")
                             referrer:MakeReferrer("http://www.example.com/c")
                           transition:ui::PAGE_TRANSITION_LINK
                    rendererInitiated:NO];
  [session_controller_ commitPendingEntry];

  EXPECT_EQ(3, session_controller_.get().currentNavigationIndex);
  NSArray* backEntries = [session_controller_ backwardEntries];
  EXPECT_EQ(2U, [backEntries count]);
  EXPECT_EQ(0U, [[session_controller_ forwardEntries] count]);
  EXPECT_EQ("http://www.example.com/1",
            [[backEntries objectAtIndex:0] navigationItem]->GetURL().spec());

  [session_controller_ goBack];
  EXPECT_EQ(1U, [[session_controller_ backwardEntries] count]);
  EXPECT_EQ(1U, [[session_controller_ forwardEntries] count]);

  [session_controller_ goBack];
  NSArray* forwardEntries = [session_controller_ forwardEntries];
  EXPECT_EQ(0U, [[session_controller_ backwardEntries] count]);
  EXPECT_EQ(2U, [forwardEntries count]);
  EXPECT_EQ("http://www.example.com/2",
            [[forwardEntries objectAtIndex:1] navigationItem]->GetURL().spec());
}

TEST_F(CRWSessionControllerTest, GoToEntry) {
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                             referrer:MakeReferrer("http://www.example.com/a")
                           transition:ui::PAGE_TRANSITION_LINK
                    rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/1")
                             referrer:MakeReferrer("http://www.example.com/b")
                           transition:ui::PAGE_TRANSITION_LINK
                    rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/redirect")
                             referrer:MakeReferrer("http://www.example.com/r")
                           transition:ui::PAGE_TRANSITION_IS_REDIRECT_MASK
                    rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/2")
                             referrer:MakeReferrer("http://www.example.com/c")
                           transition:ui::PAGE_TRANSITION_LINK
                    rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  EXPECT_EQ(3, session_controller_.get().currentNavigationIndex);

  CRWSessionEntry* entry1 = [session_controller_.get().entries objectAtIndex:1];
  [session_controller_ goToEntry:entry1];
  EXPECT_EQ(1, session_controller_.get().currentNavigationIndex);

  // Remove an entry and attempt to go it. Ensure it outlives the removal.
  base::scoped_nsobject<CRWSessionEntry> entry3(
      [[session_controller_.get().entries objectAtIndex:3] retain]);
  [session_controller_ removeEntryAtIndex:3];
  [session_controller_ goToEntry:entry3];
  EXPECT_EQ(1, session_controller_.get().currentNavigationIndex);
}

// Tests -[CRWSessionController indexOfEntryForDelta:] API for positive,
// negative and zero delta. Tested session controller will have redirect entries
// to make sure they are appropriately skipped.
TEST_F(CRWSessionControllerTest, IndexOfEntryForDelta) {
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                              referrer:MakeReferrer("http://www.example.com/a")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/redirect")
                              referrer:MakeReferrer("http://www.example.com/r")
                            transition:ui::PAGE_TRANSITION_IS_REDIRECT_MASK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/1")
                              referrer:MakeReferrer("http://www.example.com/b")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/2")
                              referrer:MakeReferrer("http://www.example.com/c")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/redirect")
                              referrer:MakeReferrer("http://www.example.com/r")
                            transition:ui::PAGE_TRANSITION_IS_REDIRECT_MASK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  ASSERT_EQ(4, [session_controller_ currentNavigationIndex]);
  ASSERT_EQ(5U, [[session_controller_ entries] count]);

  // Go to entry at index 1 and test API from that state.
  NSArray* entries = [session_controller_ entries];
  [session_controller_ goToEntry:entries[1]];
  ASSERT_EQ(1, [session_controller_ currentNavigationIndex]);
  EXPECT_EQ(-1, [session_controller_ indexOfEntryForDelta:-1]);
  EXPECT_EQ(-2, [session_controller_ indexOfEntryForDelta:-2]);
  EXPECT_EQ(2, [session_controller_ indexOfEntryForDelta:1]);
  EXPECT_EQ(4, [session_controller_ indexOfEntryForDelta:2]);
  EXPECT_EQ(5, [session_controller_ indexOfEntryForDelta:3]);

  // Go to entry at index 2 and test API from that state.
  [session_controller_ goToEntry:entries[2]];
  ASSERT_EQ(2, [session_controller_ currentNavigationIndex]);
  EXPECT_EQ(1, [session_controller_ indexOfEntryForDelta:-1]);
  EXPECT_EQ(-1, [session_controller_ indexOfEntryForDelta:-2]);
  EXPECT_EQ(4, [session_controller_ indexOfEntryForDelta:1]);
  EXPECT_EQ(5, [session_controller_ indexOfEntryForDelta:2]);

  // Go to entry at index 4 and test API from that state.
  [session_controller_ goToEntry:entries[4]];
  ASSERT_EQ(4, [session_controller_ currentNavigationIndex]);
  EXPECT_EQ(2, [session_controller_ indexOfEntryForDelta:-1]);
  EXPECT_EQ(1, [session_controller_ indexOfEntryForDelta:-2]);
  EXPECT_EQ(5, [session_controller_ indexOfEntryForDelta:1]);
  EXPECT_EQ(6, [session_controller_ indexOfEntryForDelta:2]);

  // Now try with existing transient entry.
  [session_controller_ addTransientEntryWithURL:GURL("http://www.example.com")];
  ASSERT_EQ(5U, [[session_controller_ entries] count]);
  ASSERT_EQ(4, [session_controller_ currentNavigationIndex]);
  EXPECT_EQ(4, [session_controller_ indexOfEntryForDelta:-1]);
  EXPECT_EQ(2, [session_controller_ indexOfEntryForDelta:-2]);
  EXPECT_EQ(1, [session_controller_ indexOfEntryForDelta:-3]);
  EXPECT_EQ(5, [session_controller_ indexOfEntryForDelta:1]);
  EXPECT_EQ(6, [session_controller_ indexOfEntryForDelta:2]);
}

// Tests that visible URL is the same as transient URL if there are no committed
// entries.
TEST_F(CRWSessionControllerTest, VisibleEntryWithSingleTransientEntry) {
  [session_controller_ addTransientEntryWithURL:GURL("http://www.example.com")];
  web::NavigationItem* visible_item =
      [[session_controller_ visibleEntry] navigationItem];
  ASSERT_TRUE(visible_item);
  EXPECT_EQ("http://www.example.com/", visible_item->GetURL().spec());
}

// Tests that visible URL is the same as transient URL if there is a committed
// entry.
TEST_F(CRWSessionControllerTest, VisibleEntryWithCommittedAndTransientEntries) {
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                              referrer:MakeReferrer("http://www.example.com/a")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addTransientEntryWithURL:GURL("http://www.example.com")];
  web::NavigationItem* visible_item =
      [[session_controller_ visibleEntry] navigationItem];
  ASSERT_TRUE(visible_item);
  EXPECT_EQ("http://www.example.com/", visible_item->GetURL().spec());
}

// Tests that visible URL is the same as pending URL if it was user-initiated.
TEST_F(CRWSessionControllerTest,
       VisibleEntryWithSingleUserInitiatedPendingEntry) {
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                              referrer:MakeReferrer("http://www.example.com/a")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  web::NavigationItem* visible_item =
      [[session_controller_ visibleEntry] navigationItem];
  ASSERT_TRUE(visible_item);
  EXPECT_EQ("http://www.example.com/0", visible_item->GetURL().spec());
}

// Tests that visible URL is the same as pending URL if it was user-initiated
// and there is a committed entry.
TEST_F(CRWSessionControllerTest,
       VisibleEntryWithCommittedAndUserInitiatedPendingEntry) {
  [session_controller_ addPendingEntry:GURL("http://www.example.com")
                              referrer:MakeReferrer("http://www.example.com/a")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                              referrer:MakeReferrer("http://www.example.com/b")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:NO];
  web::NavigationItem* visible_item =
      [[session_controller_ visibleEntry] navigationItem];
  ASSERT_TRUE(visible_item);
  EXPECT_EQ("http://www.example.com/0", visible_item->GetURL().spec());
}

// Tests that visible URL is not the same as pending URL if it was
// renderer-initiated.
TEST_F(CRWSessionControllerTest,
       VisibleEntryWithSingleRendererInitiatedPendingEntry) {
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                              referrer:MakeReferrer("http://www.example.com/a")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:YES];
  web::NavigationItem* visible_item =
      [[session_controller_ visibleEntry] navigationItem];
  ASSERT_FALSE(visible_item);
}

// Tests that visible URL is not the same as pending URL if it was
// renderer-initiated and there is a committed entry.
TEST_F(CRWSessionControllerTest,
       VisibleEntryWithCommittedAndRendererInitiatedPendingEntry) {
  [session_controller_ addPendingEntry:GURL("http://www.example.com")
                              referrer:MakeReferrer("http://www.example.com/a")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:YES];
  [session_controller_ commitPendingEntry];
  [session_controller_ addPendingEntry:GURL("http://www.example.com/0")
                              referrer:MakeReferrer("http://www.example.com/b")
                            transition:ui::PAGE_TRANSITION_LINK
                     rendererInitiated:YES];
  web::NavigationItem* visible_item =
      [[session_controller_ visibleEntry] navigationItem];
  ASSERT_TRUE(visible_item);
  EXPECT_EQ("http://www.example.com/", visible_item->GetURL().spec());
}

}  // anonymous namespace
