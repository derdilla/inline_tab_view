import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inline_tab_view/src/inline_tab_view_parent_data.dart';

void main() {
  test('empty parent data smoke test', () {
    final data = InlineTabViewParentData();
    expect(data, isA<ContainerBoxParentData<RenderBox>>());
  });
}