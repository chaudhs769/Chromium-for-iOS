// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/ui/collection_view/cells/collection_view_footer_item.h"

#import "ios/chrome/browser/ui/colors/MDCPalette+CrAdditions.h"
#import "ios/chrome/browser/ui/util/label_link_controller.h"
#import "ios/chrome/common/string_util.h"
#import "ios/third_party/material_components_ios/src/components/Palettes/src/MaterialPalettes.h"
#import "ios/third_party/material_roboto_font_loader_ios/src/src/MaterialRobotoFontLoader.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

namespace {
// Padding used on the leading and trailing edges of the cell.
const CGFloat kDefaultHorizontalPadding = 24;

// Padding used on the leading edge for the text when the cell has an image.
const CGFloat kImageRightMargin = 10;

// Padding used on the top and bottom edges of the cell.
const CGFloat kVerticalPadding = 16;
}  // namespace

@interface CollectionViewFooterCell ()

// Delegate to notify when the link in |textLabel| is tapped.
@property(nonatomic, weak) id<CollectionViewFooterLinkDelegate> linkDelegate;

// Sets the URL to load when the link in |textLabel| is tapped.
- (void)setLabelLinkURL:(const GURL&)URL;

@end

@implementation CollectionViewFooterItem

@synthesize text = _text;
@synthesize linkURL = _linkURL;
@synthesize linkDelegate = _linkDelegate;
@synthesize image = _image;

- (instancetype)initWithType:(NSInteger)type {
  self = [super initWithType:type];
  if (self) {
    self.cellClass = [CollectionViewFooterCell class];
  }
  return self;
}

#pragma mark CollectionViewItem

- (void)configureCell:(CollectionViewFooterCell*)cell {
  [super configureCell:cell];
  cell.textLabel.text = _text;
  [cell setLabelLinkURL:_linkURL];
  cell.linkDelegate = _linkDelegate;
  cell.imageView.image = _image;
}

@end

@interface CollectionViewFooterCell () {
  LabelLinkController* _linkController;
  NSLayoutConstraint* _textLeadingAnchorConstraint;
  NSLayoutConstraint* _imageLeadingAnchorConstraint;
}
@end

@implementation CollectionViewFooterCell

@synthesize textLabel = _textLabel;
@synthesize imageView = _imageView;
@synthesize linkDelegate = _linkDelegate;
@synthesize horizontalPadding = _horizontalPadding;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.isAccessibilityElement = YES;

    _textLabel = [[UILabel alloc] init];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_textLabel];

    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_imageView];

    _textLabel.font =
        [[MDFRobotoFontLoader sharedInstance] mediumFontOfSize:14];
    _textLabel.textColor = [[MDCPalette greyPalette] tint900];
    _textLabel.shadowOffset = CGSizeMake(1.f, 0.f);
    _textLabel.shadowColor = [UIColor whiteColor];
    _textLabel.numberOfLines = 0;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    _horizontalPadding = kDefaultHorizontalPadding;
    _textLeadingAnchorConstraint = [_textLabel.leadingAnchor
        constraintEqualToAnchor:_imageView.trailingAnchor];
    _imageLeadingAnchorConstraint = [_imageView.leadingAnchor
        constraintEqualToAnchor:self.contentView.leadingAnchor
                       constant:_horizontalPadding];
    [NSLayoutConstraint activateConstraints:@[
      [_textLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor
                                           constant:kVerticalPadding],
      [_textLabel.bottomAnchor
          constraintEqualToAnchor:self.contentView.bottomAnchor
                         constant:-kVerticalPadding],
      [_imageView.centerYAnchor
          constraintEqualToAnchor:self.contentView.centerYAnchor],
      _textLeadingAnchorConstraint,
      _imageLeadingAnchorConstraint,
    ]];
  }
  return self;
}

- (void)setLabelLinkURL:(const GURL&)URL {
  _linkController = nil;
  if (!URL.is_valid()) {
    return;
  }

  NSRange range;
  NSString* text = _textLabel.text;
  _textLabel.text = ParseStringWithLink(text, &range);
  if (range.location != NSNotFound && range.length != 0) {
    __weak CollectionViewFooterCell* weakSelf = self;
    _linkController = [[LabelLinkController alloc]
        initWithLabel:_textLabel
               action:^(const GURL& URL) {
                 [weakSelf.linkDelegate cell:weakSelf didTapLinkURL:URL];
               }];
    [_linkController setLinkColor:[[MDCPalette cr_bluePalette] tint500]];
    [_linkController addLinkWithRange:range url:URL];
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];

  _imageLeadingAnchorConstraint.constant = _horizontalPadding;

  // Adjust the text label preferredMaxLayoutWidth when the parent's width
  // changes, for instance on screen rotation.
  CGFloat parentWidth = self.contentView.frame.size.width;
  if (_imageView.image) {
    _textLabel.preferredMaxLayoutWidth =
        parentWidth - 2.f * _imageLeadingAnchorConstraint.constant -
        kImageRightMargin - _imageView.image.size.width;
    _textLeadingAnchorConstraint.constant = kImageRightMargin;
  } else {
    _textLabel.preferredMaxLayoutWidth =
        parentWidth - 2.f * _imageLeadingAnchorConstraint.constant;
    _textLeadingAnchorConstraint.constant = 0;
  }

  // Re-layout with the new preferred width to allow the label to adjust its
  // height.
  [super layoutSubviews];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.textLabel.text = nil;
  self.imageView.image = nil;
  [self setLabelLinkURL:GURL()];
  self.horizontalPadding = kDefaultHorizontalPadding;
  _linkController = nil;
  _linkDelegate = nil;
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
  return NO;  // Accessibility for this element is handled in
              // LabelLinkController's TransparentLinkButton objects.
}

@end
