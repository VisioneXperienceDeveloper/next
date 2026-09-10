#!/usr/bin/env ruby
# Development-only project generation. The checked-in xcodeproj opens without Ruby.
require 'xcodeproj'

root = File.expand_path('..', __dir__)
project = Xcodeproj::Project.new(File.join(root, 'Next.xcodeproj'))
app = project.new_target(:application, 'Next', :ios, '17.0')
unit = project.new_target(:unit_test_bundle, 'NextTests', :ios, '17.0')
ui = project.new_target(:ui_test_bundle, 'NextUITests', :ios, '17.0')
unit.add_dependency(app)
ui.add_dependency(app)

[[app, 'Next'], [unit, 'NextTests'], [ui, 'NextUITests']].each do |target, folder|
  group = project.main_group.new_group(folder, folder)
  Dir.glob(File.join(root, folder, '**', '*.swift')).sort.each do |path|
    ref = group.new_file(path.delete_prefix(File.join(root, folder) + '/'))
    target.source_build_phase.add_file_reference(ref)
  end
  target.build_configurations.each do |config|
    s = config.build_settings
    s['SWIFT_VERSION'] = '6.0'
    s['SWIFT_STRICT_CONCURRENCY'] = 'complete'
    s['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    s['TARGETED_DEVICE_FAMILY'] = '1'
    s['GENERATE_INFOPLIST_FILE'] = 'YES'
    s['PRODUCT_BUNDLE_IDENTIFIER'] = "com.visionexperiencedeveloper.next#{target == app ? '' : '.' + folder}"
    s['CODE_SIGN_STYLE'] = 'Automatic'
    s['DEVELOPMENT_TEAM'] = 'JS293ULS3A'
    s['MARKETING_VERSION'] = '1.0.0'
    s['CURRENT_PROJECT_VERSION'] = '3'
    s['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
    s['ENABLE_USER_SCRIPT_SANDBOXING'] = 'YES'
    s['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
    s['SUPPORTS_MACCATALYST'] = 'NO'
    s['SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD'] = 'NO'
  end
end
app.build_configurations.each do |config|
  s = config.build_settings
  s['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  s['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
  s['INFOPLIST_KEY_UISupportedInterfaceOrientations'] = 'UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
  s['INFOPLIST_KEY_CFBundleDisplayName'] = 'Next'
  s['INFOPLIST_KEY_ITSAppUsesNonExemptEncryption'] = 'NO'
  s['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'
  s['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  s['ENABLE_PREVIEWS'] = 'YES'
end
unit.build_configurations.each do |config|
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/Next.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Next'
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
end
ui.build_configurations.each { |config| config.build_settings['TEST_TARGET_NAME'] = 'Next' }
resources = project.main_group['Next']
%w[Resources/Assets.xcassets Resources/Localizable.xcstrings Resources/PrivacyInfo.xcprivacy].each do |file|
  next unless File.exist?(File.join(root, 'Next', file))
  app.resources_build_phase.add_file_reference(resources.new_file(file))
end
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.add_test_target(unit)
scheme.add_test_target(ui)
scheme.set_launch_target(app)
scheme.save_as(project.path, 'Next', true)
