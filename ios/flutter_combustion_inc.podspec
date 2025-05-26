#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_combustion_inc.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_combustion_inc'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin that enables communication between Flutter mobile applications and Combustion Inc. wireless temperature probes.'
  s.description      = <<-DESC
A Flutter plugin that enables communication between Flutter mobile applications and Combustion Inc. wireless temperature probes.
                       DESC
  s.homepage         = 'https://github.com/Toglefritz/flutter_combustion_inc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Splendid Endeavors' => 'hello@splendidendeavors.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.source_files = 'Classes/**/*.{h,m,swift}', 'CombustionBLE/Sources/**/*.swift'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_combustion_inc_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
