// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/ui/settings/material_cell_catalog_view_controller.h"

#import <UIKit/UIKit.h>

#import "base/mac/foundation_util.h"
#include "components/grit/components_scaled_resources.h"
#import "ios/chrome/browser/ui/autofill/cells/cvc_item.h"
#import "ios/chrome/browser/ui/autofill/cells/status_item.h"
#import "ios/chrome/browser/ui/autofill/cells/storage_switch_item.h"
#import "ios/chrome/browser/ui/collection_view/cells/MDCCollectionViewCell+Chrome.h"
#import "ios/chrome/browser/ui/collection_view/cells/collection_view_account_item.h"
#import "ios/chrome/browser/ui/collection_view/cells/collection_view_detail_item.h"
#import "ios/chrome/browser/ui/collection_view/cells/collection_view_footer_item.h"
#import "ios/chrome/browser/ui/collection_view/cells/collection_view_switch_item.h"
#import "ios/chrome/browser/ui/collection_view/cells/collection_view_text_item.h"
#import "ios/chrome/browser/ui/collection_view/collection_view_model.h"
#import "ios/chrome/browser/ui/icons/chrome_icon.h"
#import "ios/chrome/browser/ui/settings/cells/account_control_item.h"
#import "ios/chrome/browser/ui/settings/cells/account_signin_item.h"
#import "ios/chrome/browser/ui/settings/cells/autofill_data_item.h"
#import "ios/chrome/browser/ui/settings/cells/native_app_item.h"
#import "ios/chrome/browser/ui/settings/cells/sync_switch_item.h"
#import "ios/chrome/browser/ui/settings/cells/text_and_error_item.h"
#import "ios/chrome/browser/ui/uikit_ui_util.h"
#import "ios/public/provider/chrome/browser/chrome_browser_provider.h"
#import "ios/public/provider/chrome/browser/signin/signin_resources_provider.h"
#import "ios/third_party/material_components_ios/src/components/CollectionCells/src/MaterialCollectionCells.h"
#import "ios/third_party/material_components_ios/src/components/Palettes/src/MaterialPalettes.h"
#import "ios/third_party/material_roboto_font_loader_ios/src/src/MaterialRobotoFontLoader.h"

namespace {

typedef NS_ENUM(NSInteger, SectionIdentifier) {
  SectionIdentifierTextCell = kSectionIdentifierEnumZero,
  SectionIdentifierDetailCell,
  SectionIdentifierSwitchCell,
  SectionIdentifierNativeAppCell,
  SectionIdentifierAutofill,
  SectionIdentifierAccountCell,
  SectionIdentifierAccountControlCell,
  SectionIdentifierFooters,
};

typedef NS_ENUM(NSInteger, ItemType) {
  ItemTypeTextCheckmark = kItemTypeEnumZero,
  ItemTypeTextDetail,
  ItemTypeTextError,
  ItemTypeDetailBasic,
  ItemTypeDetailLeftMedium,
  ItemTypeDetailRightMedium,
  ItemTypeDetailLeftLong,
  ItemTypeDetailRightLong,
  ItemTypeDetailBothLong,
  ItemTypeSwitchBasic,
  ItemTypeSwitchDynamicHeight,
  ItemTypeSwitchSync,
  ItemTypeHeader,
  ItemTypeAccountDetail,
  ItemTypeAccountCheckMark,
  ItemTypeAccountSignIn,
  ItemTypeApp,
  ItemTypeAutofillDynamicHeight,
  ItemTypeAutofillCVC,
  ItemTypeAutofillStatus,
  ItemTypeAutofillStorageSwitch,
  ItemTypeAccountControlDynamicHeight,
  ItemTypeFooter,
};

// Image fixed horizontal size.
const CGFloat kHorizontalImageFixedSize = 40;

}  // namespace

@implementation MaterialCellCatalogViewController

- (instancetype)init {
  self = [super initWithStyle:CollectionViewControllerStyleAppBar];
  if (self) {
    [self loadModel];
  }
  return self;
}

- (void)loadModel {
  [super loadModel];
  CollectionViewModel* model = self.collectionViewModel;

  // Text cells.
  [model addSectionWithIdentifier:SectionIdentifierTextCell];

  CollectionViewTextItem* textHeader = [
      [[CollectionViewTextItem alloc] initWithType:ItemTypeHeader] autorelease];
  textHeader.text = @"MDCCollectionViewTextCell";
  [model setHeader:textHeader
      forSectionWithIdentifier:SectionIdentifierTextCell];

  CollectionViewTextItem* textCell = [[[CollectionViewTextItem alloc]
      initWithType:ItemTypeTextCheckmark] autorelease];
  textCell.text = @"Text cell 1";
  textCell.accessoryType = MDCCollectionViewCellAccessoryCheckmark;
  [model addItem:textCell toSectionWithIdentifier:SectionIdentifierTextCell];
  CollectionViewTextItem* textCell2 = [[[CollectionViewTextItem alloc]
      initWithType:ItemTypeTextDetail] autorelease];
  textCell2.text =
      @"Text cell with text that is so long it must truncate at some point";
  textCell2.accessoryType = MDCCollectionViewCellAccessoryDetailButton;
  [model addItem:textCell2 toSectionWithIdentifier:SectionIdentifierTextCell];

  // Text and Error cell.
  TextAndErrorItem* textAndErrorItem =
      [[[TextAndErrorItem alloc] initWithType:ItemTypeTextError] autorelease];
  textAndErrorItem.text = @"Text and Error cell";
  textAndErrorItem.shouldDisplayError = YES;
  textAndErrorItem.accessoryType =
      MDCCollectionViewCellAccessoryDisclosureIndicator;
  [model addItem:textAndErrorItem
      toSectionWithIdentifier:SectionIdentifierTextCell];

  // Detail cells.
  [model addSectionWithIdentifier:SectionIdentifierDetailCell];
  CollectionViewDetailItem* detailBasic = [[[CollectionViewDetailItem alloc]
      initWithType:ItemTypeDetailBasic] autorelease];
  detailBasic.text = @"Preload Webpages";
  detailBasic.detailText = @"Only on Wi-Fi";
  detailBasic.accessoryType = MDCCollectionViewCellAccessoryDisclosureIndicator;
  [model addItem:detailBasic
      toSectionWithIdentifier:SectionIdentifierDetailCell];
  CollectionViewDetailItem* detailMediumLeft =
      [[[CollectionViewDetailItem alloc] initWithType:ItemTypeDetailLeftMedium]
          autorelease];
  detailMediumLeft.text = @"A long string but it should fit";
  detailMediumLeft.detailText = @"Detail";
  [model addItem:detailMediumLeft
      toSectionWithIdentifier:SectionIdentifierDetailCell];
  CollectionViewDetailItem* detailMediumRight =
      [[[CollectionViewDetailItem alloc] initWithType:ItemTypeDetailRightMedium]
          autorelease];
  detailMediumRight.text = @"Main";
  detailMediumRight.detailText = @"A long string but it should fit";
  [model addItem:detailMediumRight
      toSectionWithIdentifier:SectionIdentifierDetailCell];
  CollectionViewDetailItem* detailLongLeft = [[[CollectionViewDetailItem alloc]
      initWithType:ItemTypeDetailLeftLong] autorelease];
  detailLongLeft.text =
      @"This is a very long main text that is intended to overflow";
  detailLongLeft.detailText = @"Detail Text";
  [model addItem:detailLongLeft
      toSectionWithIdentifier:SectionIdentifierDetailCell];
  CollectionViewDetailItem* detailLongRight = [[[CollectionViewDetailItem alloc]
      initWithType:ItemTypeDetailRightLong] autorelease];
  detailLongRight.text = @"Main Text";
  detailLongRight.detailText =
      @"This is a very long detail text that is intended to overflow";
  [model addItem:detailLongRight
      toSectionWithIdentifier:SectionIdentifierDetailCell];
  CollectionViewDetailItem* detailLongBoth = [[[CollectionViewDetailItem alloc]
      initWithType:ItemTypeDetailBothLong] autorelease];
  detailLongBoth.text =
      @"This is a very long main text that is intended to overflow";
  detailLongBoth.detailText =
      @"This is a very long detail text that is intended to overflow";
  [model addItem:detailLongBoth
      toSectionWithIdentifier:SectionIdentifierDetailCell];

  // Switch cells.
  [model addSectionWithIdentifier:SectionIdentifierSwitchCell];
  [model addItem:[self basicSwitchItem]
      toSectionWithIdentifier:SectionIdentifierSwitchCell];
  [model addItem:[self longTextSwitchItem]
      toSectionWithIdentifier:SectionIdentifierSwitchCell];
  [model addItem:[self syncSwitchItem]
      toSectionWithIdentifier:SectionIdentifierSwitchCell];

  // Native app cells.
  [model addSectionWithIdentifier:SectionIdentifierNativeAppCell];
  NativeAppItem* fooApp =
      [[[NativeAppItem alloc] initWithType:ItemTypeApp] autorelease];
  fooApp.name = @"App Foo";
  fooApp.state = NativeAppItemSwitchOff;
  [model addItem:fooApp toSectionWithIdentifier:SectionIdentifierNativeAppCell];
  NativeAppItem* barApp =
      [[[NativeAppItem alloc] initWithType:ItemTypeApp] autorelease];
  barApp.name = @"App Bar";
  barApp.state = NativeAppItemSwitchOn;
  [model addItem:barApp toSectionWithIdentifier:SectionIdentifierNativeAppCell];
  NativeAppItem* bazApp =
      [[[NativeAppItem alloc] initWithType:ItemTypeApp] autorelease];
  bazApp.name = @"App Baz Qux Bla Bug Lorem ipsum dolor sit amet";
  bazApp.state = NativeAppItemInstall;
  [model addItem:bazApp toSectionWithIdentifier:SectionIdentifierNativeAppCell];

  // Autofill cells.
  [model addSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self autofillItemWithMainAndTrailingText]
      toSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self autofillItemWithLeadingTextOnly]
      toSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self autofillItemWithAllText]
      toSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self cvcItem]
      toSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self cvcItemWithDate]
      toSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self cvcItemWithError]
      toSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self statusItemVerifying]
      toSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self statusItemVerified]
      toSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self statusItemError]
      toSectionWithIdentifier:SectionIdentifierAutofill];
  [model addItem:[self storageSwitchItem]
      toSectionWithIdentifier:SectionIdentifierAutofill];

  // Account cells.
  [model addSectionWithIdentifier:SectionIdentifierAccountCell];
  [model addItem:[self accountItemDetailWithError]
      toSectionWithIdentifier:SectionIdentifierAccountCell];
  [model addItem:[self accountItemCheckMark]
      toSectionWithIdentifier:SectionIdentifierAccountCell];
  [model addItem:[self accountSignInItem]
      toSectionWithIdentifier:SectionIdentifierAccountCell];

  // Account control cells.
  [model addSectionWithIdentifier:SectionIdentifierAccountControlCell];
  [model addItem:[self accountControlItem]
      toSectionWithIdentifier:SectionIdentifierAccountControlCell];
  [model addItem:[self accountControlItemWithExtraLongText]
      toSectionWithIdentifier:SectionIdentifierAccountControlCell];

  // Footers.
  [model addSectionWithIdentifier:SectionIdentifierFooters];
  [model addItem:[self shortFooterItem]
      toSectionWithIdentifier:SectionIdentifierFooters];
  [model addItem:[self longFooterItem]
      toSectionWithIdentifier:SectionIdentifierFooters];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Cell Catalog";

  // Customize collection view settings.
  self.styler.cellStyle = MDCCollectionViewCellStyleCard;
}

#pragma mark UICollectionViewDataSource

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView
          viewForSupplementaryElementOfKind:(NSString*)kind
                                atIndexPath:(NSIndexPath*)indexPath {
  UICollectionReusableView* cell = [super collectionView:collectionView
                       viewForSupplementaryElementOfKind:kind
                                             atIndexPath:indexPath];
  MDCCollectionViewTextCell* textCell =
      base::mac::ObjCCast<MDCCollectionViewTextCell>(cell);
  if (textCell) {
    textCell.textLabel.font =
        [[MDFRobotoFontLoader sharedInstance] mediumFontOfSize:14];
    textCell.textLabel.textColor = [[MDCPalette greyPalette] tint500];
  }

  return cell;
};

#pragma mark MDCCollectionViewStylingDelegate

- (CGFloat)collectionView:(nonnull UICollectionView*)collectionView
    cellHeightAtIndexPath:(nonnull NSIndexPath*)indexPath {
  CollectionViewItem* item =
      [self.collectionViewModel itemAtIndexPath:indexPath];
  switch (item.type) {
    case ItemTypeFooter:
    case ItemTypeSwitchDynamicHeight:
    case ItemTypeSwitchSync:
    case ItemTypeAccountControlDynamicHeight:
    case ItemTypeTextError:
    case ItemTypeAutofillCVC:
    case ItemTypeAutofillStatus:
    case ItemTypeAutofillStorageSwitch:
    case ItemTypeAutofillDynamicHeight:
      return [MDCCollectionViewCell
          cr_preferredHeightForWidth:CGRectGetWidth(collectionView.bounds)
                             forItem:item];
    case ItemTypeApp:
      return MDCCellDefaultOneLineWithAvatarHeight;
    case ItemTypeAccountDetail:
      return MDCCellDefaultTwoLineHeight;
    case ItemTypeAccountCheckMark:
      return MDCCellDefaultTwoLineHeight;
    case ItemTypeAccountSignIn:
      return MDCCellDefaultThreeLineHeight;
    default:
      return MDCCellDefaultOneLineHeight;
  }
}

- (MDCCollectionViewCellStyle)collectionView:(UICollectionView*)collectionView
                         cellStyleForSection:(NSInteger)section {
  NSInteger sectionIdentifier =
      [self.collectionViewModel sectionIdentifierForSection:section];
  switch (sectionIdentifier) {
    case SectionIdentifierFooters:
      // Display the Learn More footer in the default style with no "card" UI
      // and no section padding.
      return MDCCollectionViewCellStyleDefault;
    default:
      return self.styler.cellStyle;
  }
}

- (BOOL)collectionView:(UICollectionView*)collectionView
    shouldHideItemBackgroundAtIndexPath:(NSIndexPath*)indexPath {
  NSInteger sectionIdentifier =
      [self.collectionViewModel sectionIdentifierForSection:indexPath.section];
  switch (sectionIdentifier) {
    case SectionIdentifierFooters:
      // Display the Learn More footer without any background image or
      // shadowing.
      return YES;
    default:
      return NO;
  }
}

- (BOOL)collectionView:(nonnull UICollectionView*)collectionView
    hidesInkViewAtIndexPath:(nonnull NSIndexPath*)indexPath {
  NSInteger sectionIdentifier =
      [self.collectionViewModel sectionIdentifierForSection:indexPath.section];
  switch (sectionIdentifier) {
    case SectionIdentifierFooters:
    case ItemTypeSwitchBasic:
    case ItemTypeSwitchDynamicHeight:
    case ItemTypeApp:
    case ItemTypeAutofillStorageSwitch:
    case ItemTypeSwitchSync:
      return YES;
    default:
      return NO;
  }
}

#pragma mark Item models

- (CollectionViewItem*)accountItemDetailWithError {
  CollectionViewAccountItem* accountItemDetail =
      [[[CollectionViewAccountItem alloc] initWithType:ItemTypeAccountDetail]
          autorelease];
  accountItemDetail.image = [UIImage imageNamed:@"default_avatar"];
  accountItemDetail.text = @"Account User Name";
  accountItemDetail.detailText =
      @"Syncing to AccountUserNameAccount@example.com";
  accountItemDetail.accessoryType =
      MDCCollectionViewCellAccessoryDisclosureIndicator;
  accountItemDetail.shouldDisplayError = YES;
  return accountItemDetail;
}

- (CollectionViewItem*)accountItemCheckMark {
  CollectionViewAccountItem* accountItemCheckMark =
      [[[CollectionViewAccountItem alloc] initWithType:ItemTypeAccountCheckMark]
          autorelease];
  accountItemCheckMark.image = [UIImage imageNamed:@"default_avatar"];
  accountItemCheckMark.text = @"Lorem ipsum dolor sit amet, consectetur "
                              @"adipiscing elit, sed do eiusmod tempor "
                              @"incididunt ut labore et dolore magna aliqua.";
  accountItemCheckMark.detailText =
      @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do "
      @"eiusmod tempor incididunt ut labore et dolore magna aliqua.";
  accountItemCheckMark.accessoryType = MDCCollectionViewCellAccessoryCheckmark;
  return accountItemCheckMark;
}

- (CollectionViewItem*)accountSignInItem {
  AccountSignInItem* accountSignInItem = [[[AccountSignInItem alloc]
      initWithType:ItemTypeAccountSignIn] autorelease];
  accountSignInItem.image =
      CircularImageFromImage(ios::GetChromeBrowserProvider()
                                 ->GetSigninResourcesProvider()
                                 ->GetDefaultAvatar(),
                             kHorizontalImageFixedSize);
  return accountSignInItem;
}

- (CollectionViewItem*)accountControlItem {
  AccountControlItem* item = [[[AccountControlItem alloc]
      initWithType:ItemTypeAccountControlDynamicHeight] autorelease];
  item.image = [UIImage imageNamed:@"settings_sync"];
  item.text = @"Account Sync Settings";
  item.detailText = @"Detail text";
  item.accessoryType = MDCCollectionViewCellAccessoryDisclosureIndicator;
  return item;
}

- (CollectionViewItem*)accountControlItemWithExtraLongText {
  AccountControlItem* item = [[[AccountControlItem alloc]
      initWithType:ItemTypeAccountControlDynamicHeight] autorelease];
  item.image = [ChromeIcon infoIcon];
  item.text = @"Account Control Settings";
  item.detailText =
      @"Detail text detail text detail text detail text detail text.";
  item.accessoryType = MDCCollectionViewCellAccessoryDisclosureIndicator;
  return item;
}

#pragma mark Private

- (CollectionViewItem*)basicSwitchItem {
  CollectionViewSwitchItem* item = [[[CollectionViewSwitchItem alloc]
      initWithType:ItemTypeSwitchBasic] autorelease];
  item.text = @"Enable awesomeness.";
  item.on = YES;
  return item;
}

- (CollectionViewItem*)longTextSwitchItem {
  CollectionViewSwitchItem* item = [[[CollectionViewSwitchItem alloc]
      initWithType:ItemTypeSwitchDynamicHeight] autorelease];
  item.text = @"Enable awesomeness. This is a very long text that is intended "
              @"to overflow.";
  item.on = YES;
  return item;
}

- (CollectionViewItem*)syncSwitchItem {
  SyncSwitchItem* item =
      [[[SyncSwitchItem alloc] initWithType:ItemTypeSwitchSync] autorelease];
  item.text = @"Cell used in Sync Settings";
  item.detailText =
      @"This is a very long text that is intended to overflow to two lines.";
  item.on = NO;
  return item;
}

- (CollectionViewItem*)autofillItemWithMainAndTrailingText {
  AutofillDataItem* item = [[[AutofillDataItem alloc]
      initWithType:ItemTypeAutofillDynamicHeight] autorelease];
  item.text = @"Main Text";
  item.trailingDetailText = @"Trailing Detail Text";
  item.accessoryType = MDCCollectionViewCellAccessoryNone;
  return item;
}

- (CollectionViewItem*)autofillItemWithLeadingTextOnly {
  AutofillDataItem* item = [[[AutofillDataItem alloc]
      initWithType:ItemTypeAutofillDynamicHeight] autorelease];
  item.text = @"Main Text";
  item.leadingDetailText = @"Leading Detail Text";
  item.accessoryType = MDCCollectionViewCellAccessoryDisclosureIndicator;
  return item;
}

- (CollectionViewItem*)autofillItemWithAllText {
  AutofillDataItem* item = [[[AutofillDataItem alloc]
      initWithType:ItemTypeAutofillDynamicHeight] autorelease];
  item.text = @"Main Text";
  item.leadingDetailText = @"Leading Detail Text";
  item.trailingDetailText = @"Trailing Detail Text";
  item.accessoryType = MDCCollectionViewCellAccessoryDisclosureIndicator;
  return item;
}

- (CollectionViewItem*)cvcItem {
  CVCItem* item =
      [[[CVCItem alloc] initWithType:ItemTypeAutofillCVC] autorelease];
  item.instructionsText =
      @"This is a long text explaining to enter card details and what "
      @"will happen afterwards.";
  item.CVCImageResourceID = IDR_CREDIT_CARD_CVC_HINT;
  return item;
}

- (CollectionViewItem*)cvcItemWithDate {
  CVCItem* item =
      [[[CVCItem alloc] initWithType:ItemTypeAutofillCVC] autorelease];
  item.instructionsText =
      @"This is a long text explaining to enter card details and what "
      @"will happen afterwards.";
  item.CVCImageResourceID = IDR_CREDIT_CARD_CVC_HINT;
  item.showDateInput = YES;
  return item;
}

- (CollectionViewItem*)cvcItemWithError {
  CVCItem* item =
      [[[CVCItem alloc] initWithType:ItemTypeAutofillCVC] autorelease];
  item.instructionsText =
      @"This is a long text explaining to enter card details and what "
      @"will happen afterwards. Is this long enough to span 3 lines?";
  item.errorMessage = @"Some error";
  item.CVCImageResourceID = IDR_CREDIT_CARD_CVC_HINT_AMEX;
  item.showNewCardButton = YES;
  item.showCVCInputError = YES;
  return item;
}

- (CollectionViewItem*)statusItemVerifying {
  StatusItem* item =
      [[[StatusItem alloc] initWithType:ItemTypeAutofillStatus] autorelease];
  item.text = @"Verifying…";
  return item;
}

- (CollectionViewItem*)statusItemVerified {
  StatusItem* item =
      [[[StatusItem alloc] initWithType:ItemTypeAutofillStatus] autorelease];
  item.state = StatusItemState::VERIFIED;
  item.text = @"Verified!";
  return item;
}

- (CollectionViewItem*)statusItemError {
  StatusItem* item =
      [[[StatusItem alloc] initWithType:ItemTypeAutofillStatus] autorelease];
  item.state = StatusItemState::ERROR;
  item.text = @"There was a really long error. We can't tell you more, but we "
              @"will still display this long string.";
  return item;
}

- (CollectionViewItem*)storageSwitchItem {
  StorageSwitchItem* item = [[[StorageSwitchItem alloc]
      initWithType:ItemTypeAutofillStorageSwitch] autorelease];
  item.on = YES;
  return item;
}

- (CollectionViewFooterItem*)shortFooterItem {
  CollectionViewFooterItem* footerItem = [[[CollectionViewFooterItem alloc]
      initWithType:ItemTypeFooter] autorelease];
  footerItem.text = @"Hello";
  return footerItem;
}

- (CollectionViewFooterItem*)longFooterItem {
  CollectionViewFooterItem* footerItem = [[[CollectionViewFooterItem alloc]
      initWithType:ItemTypeFooter] autorelease];
  footerItem.text = @"Hello Hello Hello Hello Hello Hello Hello Hello Hello "
                    @"Hello Hello Hello Hello Hello Hello Hello Hello Hello "
                    @"Hello Hello Hello Hello Hello Hello Hello Hello Hello ";
  footerItem.image = [UIImage imageNamed:@"app_icon_placeholder"];
  return footerItem;
}

@end
