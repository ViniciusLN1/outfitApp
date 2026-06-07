import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_controller.g.dart';

@Riverpod(keepAlive: true)
class CurrentTabIndex extends _$CurrentTabIndex {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}
