import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_combustion_inc/flutter_combustion_inc.dart';
import 'package:flutter_combustion_inc/flutter_combustion_inc_platform_interface.dart';
import 'package:flutter_combustion_inc/flutter_combustion_inc_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterCombustionIncPlatform
    with MockPlatformInterfaceMixin
    implements FlutterCombustionIncPlatform {
}

void main() {
  final FlutterCombustionIncPlatform initialPlatform = FlutterCombustionIncPlatform.instance;

  test('$MethodChannelFlutterCombustionInc is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterCombustionInc>());
  });

  test('getPlatformVersion', () async {
    FlutterCombustionInc flutterCombustionIncPlugin = FlutterCombustionInc();
    MockFlutterCombustionIncPlatform fakePlatform = MockFlutterCombustionIncPlatform();
    FlutterCombustionIncPlatform.instance = fakePlatform;
  });
}
