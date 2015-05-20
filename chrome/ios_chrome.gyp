# Copyright 2014 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

{
  'variables': {
    'chromium_code': 1,
   },
  'targets': [
    {
      'target_name': 'ios_chrome_app',
      'type': 'static_library',
      'include_dirs': [
        '../..',
      ],
      'dependencies': [
        '../../base/base.gyp:base',
        'ios_chrome_browser',
      ],
      'link_settings': {
        'libraries': [
          '$(SDKROOT)/System/Library/Frameworks/Foundation.framework',
          '$(SDKROOT)/System/Library/Frameworks/UIKit.framework',
        ],
      },
      'sources': [
        'app/UIApplication+ExitsOnSuspend.h',
        'app/UIApplication+ExitsOnSuspend.mm',
        'app/deferred_initialization_runner.h',
        'app/deferred_initialization_runner.mm',
        'app/safe_mode_crashing_modules_config.h',
        'app/safe_mode_crashing_modules_config.mm',
        'app/safe_mode_util.cc',
        'app/safe_mode_util.h',
      ],
    },
    {
      'target_name': 'ios_chrome_browser',
      'type': 'static_library',
      'include_dirs': [
        '../..',
      ],
      'dependencies': [
        '../../base/base.gyp:base',
        '../../base/base.gyp:base_prefs',
        '../../breakpad/breakpad.gyp:breakpad_client',
        '../../components/components.gyp:autofill_core_browser',
        '../../components/components.gyp:autofill_ios_browser',
        '../../components/components.gyp:data_reduction_proxy_core_common',
        '../../components/components.gyp:dom_distiller_core',
        '../../components/components.gyp:dom_distiller_ios',
        '../../components/components.gyp:infobars_core',
        '../../components/components.gyp:keyed_service_core',
        '../../components/components.gyp:keyed_service_ios',
        '../../components/components.gyp:leveldb_proto',
        '../../components/components.gyp:pref_registry',
        '../../components/components.gyp:suggestions',
        '../../components/components.gyp:translate_core_browser',
        '../../components/components.gyp:translate_ios_browser',
        '../../components/components.gyp:sync_driver',
        '../../components/components.gyp:web_resource',
        '../../components/components.gyp:webp_transcode',
        '../../components/components_strings.gyp:components_strings',
        '../../google_apis/google_apis.gyp:google_apis',
        '../../net/net.gyp:net',
        '../../skia/skia.gyp:skia',
        '../../sync/sync.gyp:sync',
        '../../third_party/google_toolbox_for_mac/google_toolbox_for_mac.gyp:google_toolbox_for_mac',
        '../../ui/base/ui_base.gyp:ui_base',
        '../../ui/gfx/gfx.gyp:gfx',
        '../../url/url.gyp:url_lib',
        '../provider/ios_provider_chrome.gyp:ios_provider_chrome_browser',
        '../web/ios_web.gyp:ios_web',
        'injected_js',
        'ios_chrome_common',
        'ios_chrome_resources.gyp:ios_chrome_resources',
      ],
      'link_settings': {
        'libraries': [
          '$(SDKROOT)/System/Library/Frameworks/Accelerate.framework',
          '$(SDKROOT)/System/Library/Frameworks/CoreGraphics.framework',
          '$(SDKROOT)/System/Library/Frameworks/CoreLocation.framework',
          '$(SDKROOT)/System/Library/Frameworks/Foundation.framework',
          '$(SDKROOT)/System/Library/Frameworks/QuartzCore.framework',
          '$(SDKROOT)/System/Library/Frameworks/UIKit.framework',
        ],
      },
      'sources': [
        'browser/app_startup_parameters.h',
        'browser/app_startup_parameters.mm',
        'browser/application_context.cc',
        'browser/application_context.h',
        'browser/application_context_impl.cc',
        'browser/application_context_impl.h',
        'browser/arch_util.cc',
        'browser/arch_util.h',
        'browser/authentication/constants.h',
        'browser/authentication/constants.mm',
        'browser/autofill/autofill_agent_utils.h',
        'browser/autofill/autofill_agent_utils.mm',
        'browser/autofill/form_input_accessory_view.h',
        'browser/autofill/form_input_accessory_view.mm',
        'browser/autofill/form_input_accessory_view_controller.h',
        'browser/autofill/form_input_accessory_view_controller.mm',
        'browser/autofill/form_input_accessory_view_delegate.h',
        'browser/autofill/form_suggestion_controller.h',
        'browser/autofill/form_suggestion_controller.mm',
        'browser/autofill/form_suggestion_label.h',
        'browser/autofill/form_suggestion_label.mm',
        'browser/autofill/form_suggestion_provider.h',
        'browser/autofill/form_suggestion_view.h',
        'browser/autofill/form_suggestion_view.mm',
        'browser/autofill/form_suggestion_view_client.h',
        'browser/browser_state/browser_state_keyed_service_factories.h',
        'browser/browser_state/browser_state_keyed_service_factories.mm',
        'browser/browser_state/browser_state_otr_helper.cc',
        'browser/browser_state/browser_state_otr_helper.h',
        'browser/browsing_data_change_listening.h',
        'browser/chrome_paths.h',
        'browser/chrome_paths.mm',
        'browser/chrome_switches.cc',
        'browser/chrome_switches.h',
        'browser/chrome_url_constants.cc',
        'browser/chrome_url_constants.h',
        'browser/chrome_url_util.h',
        'browser/chrome_url_util.mm',
        'browser/crash_loop_detection_util.h',
        'browser/crash_loop_detection_util.mm',
        'browser/crash_report/crash_report_background_uploader.h',
        'browser/crash_report/crash_report_background_uploader.mm',
        'browser/dom_distiller/distiller_viewer.cc',
        'browser/dom_distiller/distiller_viewer.h',
        'browser/dom_distiller/dom_distiller_service_factory.cc',
        'browser/dom_distiller/dom_distiller_service_factory.h',
        'browser/experimental_flags.h',
        'browser/experimental_flags.mm',
        'browser/find_in_page/find_in_page_controller.h',
        'browser/find_in_page/find_in_page_controller.mm',
        'browser/find_in_page/find_in_page_model.h',
        'browser/find_in_page/find_in_page_model.mm',
        'browser/find_in_page/js_findinpage_manager.h',
        'browser/find_in_page/js_findinpage_manager.mm',
        'browser/first_run/first_run.h',
        'browser/first_run/first_run.mm',
        'browser/first_run/first_run_configuration.h',
        'browser/first_run/first_run_configuration.mm',
        'browser/first_run/first_run_metrics.h',
        'browser/geolocation/CLLocation+OmniboxGeolocation.h',
        'browser/geolocation/CLLocation+OmniboxGeolocation.mm',
        'browser/geolocation/CLLocation+XGeoHeader.h',
        'browser/geolocation/CLLocation+XGeoHeader.mm',
        'browser/geolocation/location_manager.h',
        'browser/geolocation/location_manager.mm',
        'browser/geolocation/omnibox_geolocation_config.h',
        'browser/geolocation/omnibox_geolocation_config.mm',
        'browser/infobars/confirm_infobar_controller.h',
        'browser/infobars/confirm_infobar_controller.mm',
        'browser/infobars/infobar.h',
        'browser/infobars/infobar.mm',
        'browser/infobars/infobar_container_ios.h',
        'browser/infobars/infobar_container_ios.mm',
        'browser/infobars/infobar_container_view.h',
        'browser/infobars/infobar_container_view.mm',
        'browser/infobars/infobar_controller.h',
        'browser/infobars/infobar_controller.mm',
        'browser/infobars/infobar_manager_impl.cc',
        'browser/infobars/infobar_manager_impl.h',
        'browser/infobars/infobar_utils.h',
        'browser/infobars/infobar_utils.mm',
        'browser/install_time_util.h',
        'browser/install_time_util.mm',
        'browser/installation_notifier.h',
        'browser/installation_notifier.mm',
        'browser/memory/memory_debugger.h',
        'browser/memory/memory_debugger.mm',
        'browser/memory/memory_debugger_manager.h',
        'browser/memory/memory_debugger_manager.mm',
        'browser/memory/memory_metrics.cc',
        'browser/memory/memory_metrics.h',
        'browser/memory/memory_wedge.cc',
        'browser/memory/memory_wedge.h',
        'browser/net/chrome_cookie_store_ios_client.h',
        'browser/net/chrome_cookie_store_ios_client.mm',
        'browser/net/image_fetcher.h',
        'browser/net/image_fetcher.mm',
        'browser/net/metrics_network_client.h',
        'browser/net/metrics_network_client.mm',
        'browser/net/metrics_network_client_manager.h',
        'browser/net/metrics_network_client_manager.mm',
        'browser/net/retryable_url_fetcher.h',
        'browser/net/retryable_url_fetcher.mm',
        'browser/passwords/password_generation_utils.h',
        'browser/passwords/password_generation_utils.mm',
        'browser/pref_names.cc',
        'browser/pref_names.h',
        'browser/prefs/pref_observer_bridge.h',
        'browser/prefs/pref_observer_bridge.mm',
        'browser/procedural_block_types.h',
        'browser/snapshots/snapshot_cache.h',
        'browser/snapshots/snapshot_cache.mm',
        'browser/snapshots/snapshot_manager.h',
        'browser/snapshots/snapshot_manager.mm',
        'browser/snapshots/snapshot_overlay.h',
        'browser/snapshots/snapshot_overlay.mm',
        'browser/snapshots/snapshots_util.h',
        'browser/snapshots/snapshots_util.mm',
        'browser/suggestions/image_fetcher_impl.h',
        'browser/suggestions/image_fetcher_impl.mm',
        'browser/suggestions/suggestions_service_factory.h',
        'browser/suggestions/suggestions_service_factory.mm',
        'browser/sync/sync_observer_bridge.h',
        'browser/sync/sync_observer_bridge.mm',
        'browser/sync/sync_setup_service.cc',
        'browser/sync/sync_setup_service.h',
        'browser/translate/after_translate_infobar_controller.h',
        'browser/translate/after_translate_infobar_controller.mm',
        'browser/translate/before_translate_infobar_controller.h',
        'browser/translate/before_translate_infobar_controller.mm',
        'browser/translate/chrome_ios_translate_client.h',
        'browser/translate/chrome_ios_translate_client.mm',
        'browser/translate/never_translate_infobar_controller.h',
        'browser/translate/never_translate_infobar_controller.mm',
        'browser/translate/translate_accept_languages_factory.cc',
        'browser/translate/translate_accept_languages_factory.h',
        'browser/translate/translate_infobar_tags.h',
        'browser/translate/translate_message_infobar_controller.h',
        'browser/translate/translate_message_infobar_controller.mm',
        'browser/translate/translate_service_ios.cc',
        'browser/translate/translate_service_ios.h',
        'browser/ui/animation_util.h',
        'browser/ui/animation_util.mm',
        'browser/ui/background_generator.h',
        'browser/ui/background_generator.mm',
        'browser/ui/commands/clear_browsing_data_command.h',
        'browser/ui/commands/clear_browsing_data_command.mm',
        'browser/ui/commands/generic_chrome_command.h',
        'browser/ui/commands/generic_chrome_command.mm',
        'browser/ui/commands/ios_command_ids.h',
        'browser/ui/commands/open_url_command.h',
        'browser/ui/commands/open_url_command.mm',
        'browser/ui/commands/set_up_for_testing_command.h',
        'browser/ui/commands/set_up_for_testing_command.mm',
        'browser/ui/commands/show_mail_composer_command.h',
        'browser/ui/commands/show_mail_composer_command.mm',
        'browser/ui/commands/show_signin_command.h',
        'browser/ui/commands/show_signin_command.mm',
        'browser/ui/commands/UIKit+ChromeExecuteCommand.h',
        'browser/ui/commands/UIKit+ChromeExecuteCommand.mm',
        'browser/ui/file_locations.h',
        'browser/ui/file_locations.mm',
        'browser/ui/image_util.h',
        'browser/ui/image_util.mm',
        'browser/ui/native_content_controller.h',
        'browser/ui/native_content_controller.mm',
        'browser/ui/orientation_limiting_navigation_controller.h',
        'browser/ui/orientation_limiting_navigation_controller.mm',
        'browser/ui/reversed_animation.h',
        'browser/ui/reversed_animation.mm',
        'browser/ui/show_mail_composer_util.h',
        'browser/ui/show_mail_composer_util.mm',
        'browser/ui/show_privacy_settings_util.h',
        'browser/ui/show_privacy_settings_util.mm',
        'browser/ui/side_swipe_gesture_recognizer.h',
        'browser/ui/side_swipe_gesture_recognizer.mm',
        'browser/ui/ui_util.h',
        'browser/ui/ui_util.mm',
        'browser/ui/uikit_ui_util.h',
        'browser/ui/uikit_ui_util.mm',
        'browser/ui/url_loader.h',
        'browser/updatable_config/updatable_array.h',
        'browser/updatable_config/updatable_array.mm',
        'browser/updatable_config/updatable_config_base.h',
        'browser/updatable_config/updatable_config_base.mm',
        'browser/updatable_config/updatable_dictionary.h',
        'browser/updatable_config/updatable_dictionary.mm',
        'browser/web/dom_altering_lock.h',
        'browser/web/dom_altering_lock.mm',
        'browser/web/web_view_type_util.h',
        'browser/web/web_view_type_util.mm',
        'browser/web_resource/ios_web_resource_service.cc',
        'browser/web_resource/ios_web_resource_service.h',
        'browser/xcallback_parameters.h',
        'browser/xcallback_parameters.mm',
      ],
    },
    {
      'target_name': 'ios_chrome_common',
      'type': 'static_library',
      'include_dirs': [
        '../..',
      ],
      'dependencies': [
        '../../base/base.gyp:base',
      ],
      'link_settings': {
        'libraries': [
          '$(SDKROOT)/System/Library/Frameworks/CoreGraphics.framework',
          '$(SDKROOT)/System/Library/Frameworks/Foundation.framework',
        ],
      },
      'sources': [
        'common/string_util.h',
        'common/string_util.mm',
      ]
    },
    {
      'target_name': 'injected_js',
      'type': 'none',
      'sources': [
        'browser/find_in_page/resources/find_in_page.js',
      ],
      'includes': [
        '../../ios/web/js_compile.gypi',
      ],
      'link_settings': {
        'mac_bundle_resources': [
          '<(SHARED_INTERMEDIATE_DIR)/find_in_page.js',
        ],
      },
    },
  ],
}
