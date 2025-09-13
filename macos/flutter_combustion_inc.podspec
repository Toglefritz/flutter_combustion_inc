#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_combustion_inc.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_combustion_inc'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for Combustion Inc. wireless temperature probes on macOS.'
  s.description      = <<-DESC
A Flutter plugin that enables communication between Flutter macOS applications and Combustion Inc. wireless temperature probes.
                       DESC
  s.homepage         = 'https://github.com/Toglefritz/flutter_combustion_inc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Toglefritz' => 'your.email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  
  s.dependency 'CombustionBLE'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end