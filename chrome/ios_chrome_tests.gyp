# Copyright 2014 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
{
  'variables': {
    'chromium_code': 1,
  },
  'targets': [
    {
      'target_name': 'ios_chrome_unittests',
      'type': '<(gtest_target_type)',
      'dependencies': [
        '../../base/base.gyp:base',
        '../../base/base.gyp:base_prefs_test_support',
        '../../base/base.gyp:test_support_base',
        '../../components/components.gyp:bookmarks_test_support',
        '../../components/components.gyp:enhanced_bookmarks_test_support',
        '../../components/components.gyp:favicon_base',
        '../../components/components.gyp:metrics',
        '../../components/components.gyp:metrics_test_support',
        '../../components/components.gyp:update_client',
        '../../components/components.gyp:version_info',
        '../../net/net.gyp:net_test_support',
        '../../skia/skia.gyp:skia',
        '../../testing/gmock.gyp:gmock',
        '../../testing/gtest.gyp:gtest',
        '../../third_party/ocmock/ocmock.gyp:ocmock',
        '../../ui/gfx/gfx.gyp:gfx',
        '../../ui/gfx/gfx.gyp:gfx_test_support',
        '../ios_tests.gyp:test_support_ios',
        '../web/ios_web.gyp:ios_web',
        '../web/ios_web.gyp:ios_web_test_support',
        'ios_chrome.gyp:ios_chrome_app',
        'ios_chrome.gyp:ios_chrome_browser',
        'ios_chrome.gyp:ios_chrome_common',
        'ios_chrome_test_support',
      ],
      'mac_bundle_resources': [
        'browser/ui/native_content_controller_test.xib'
      ],
      'sources': [
        'app/safe_mode_util_unittest.cc',
        'browser/chrome_url_util_unittest.mm',
        'browser/crash_loop_detection_util_unittest.mm',
        'browser/favicon/large_icon_cache_unittest.cc',
        'browser/geolocation/CLLocation+XGeoHeaderTest.mm',
        'browser/geolocation/location_manager_unittest.mm',
        'browser/geolocation/omnibox_geolocation_local_state_unittest.mm',
        'browser/install_time_util_unittest.mm',
        'browser/installation_notifier_unittest.mm',
        'browser/metrics/ios_chrome_metrics_service_accessor_unittest.cc',
        'browser/metrics/ios_chrome_stability_metrics_provider_unittest.cc',
        'browser/metrics/ios_stability_metrics_provider_unittest.mm',
        'browser/metrics/previous_session_info_unittest.mm',
        'browser/net/cookie_util_unittest.mm',
        'browser/net/image_fetcher_unittest.mm',
        'browser/net/metrics_network_client_unittest.mm',
        'browser/net/retryable_url_fetcher_unittest.mm',
        'browser/signin/chrome_identity_service_observer_bridge_unittest.mm',
        'browser/signin/gaia_auth_fetcher_ios_unittest.mm',
        'browser/snapshots/lru_cache_unittest.mm',
        'browser/snapshots/snapshot_cache_unittest.mm',
        'browser/snapshots/snapshots_util_unittest.mm',
        'browser/translate/translate_service_ios_unittest.cc',
        'browser/ui/commands/set_up_for_testing_command_unittest.mm',
        'browser/ui/keyboard/UIKeyCommand+ChromeTest.mm',
        'browser/ui/keyboard/hardware_keyboard_watcher_unittest.mm',
        'browser/ui/native_content_controller_unittest.mm',
        'browser/ui/ui_util_unittest.mm',
        'browser/ui/uikit_ui_util_unittest.mm',
        'browser/update_client/ios_chrome_update_query_params_delegate_unittest.cc',
        'browser/web_resource/web_resource_util_unittest.cc',
        'common/string_util_unittest.mm',
      ],
      'actions': [
        {
          'action_name': 'copy_ios_chrome_test_data',
          'variables': {
            'test_data_files': [
              'test/data/webdata/bookmarkimages',
            ],
            'test_data_prefix': 'ios/chrome',
          },
          'includes': [ '../../build/copy_test_data_ios.gypi' ]
        },
      ],
      'includes': ['ios_chrome_resources_bundle.gypi'],
    },
    {
      'target_name': 'ios_chrome_test_support',
      'type': 'static_library',
      'dependencies': [
        '../../base/base.gyp:base',
        '../../components/components.gyp:password_manager_core_browser_test_support',
        '../../components/components.gyp:signin_ios_browser_test_support',
        '../../testing/gmock.gyp:gmock',
        '../../testing/gtest.gyp:gtest',
        '../../ui/base/ui_base.gyp:ui_base',
        '../../url/url.gyp:url_lib',
        '../provider/ios_provider_chrome.gyp:ios_provider_chrome_browser',
        'ios_chrome.gyp:ios_chrome_browser',
      ],
      'sources': [
        'browser/geolocation/location_manager+Testing.h',
        'browser/geolocation/test_location_manager.h',
        'browser/geolocation/test_location_manager.mm',
        'browser/net/mock_image_fetcher.h',
        'browser/net/mock_image_fetcher.mm',
        'browser/signin/fake_oauth2_token_service_builder.cc',
        'browser/signin/fake_oauth2_token_service_builder.h',
        'browser/signin/fake_signin_manager_builder.cc',
        'browser/signin/fake_signin_manager_builder.h',
        'browser/sync/sync_setup_service_mock.cc',
        'browser/sync/sync_setup_service_mock.h',
        'test/block_cleanup_test.h',
        'test/block_cleanup_test.mm',
        'test/ios_chrome_unit_test_suite.cc',
        'test/ios_chrome_unit_test_suite.h',
        'test/run_all_unittests.cc',
        'test/testing_application_context.cc',
        'test/testing_application_context.h',
      ],
    },
  ],
}
