import 'package:flutter/material.dart';

class ListScrollAnchor {
  final ScrollController controller = ScrollController();
  final GlobalKey viewportKey = GlobalKey();
  final Map<int, GlobalKey> _itemKeys = {};

  Key? keyFor(int? id) =>
      id == null ? null : _itemKeys.putIfAbsent(id, GlobalKey.new);

  void preserveVisibleItem(Iterable<int> currentIds) {
    if (!controller.hasClients) return;
    final viewport = viewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !viewport.attached) return;
    final viewportTop = viewport.localToGlobal(Offset.zero).dy;
    final viewportBottom = viewportTop + viewport.size.height;
    final positions = <GlobalKey, double>{};
    for (final key in _itemKeys.values) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      if (top < viewportBottom && top + box.size.height > viewportTop) {
        positions[key] = top;
      }
    }
    final retainedIds = currentIds.toSet();
    _itemKeys.removeWhere((id, _) => !retainedIds.contains(id));
    if (positions.isEmpty) return;
    final orderedKeys = positions.keys.toList()
      ..sort((a, b) => positions[a]!.compareTo(positions[b]!));
    final oldOffset = controller.offset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      final position = controller.position;
      final expectedOffset =
          oldOffset.clamp(position.minScrollExtent, position.maxScrollExtent);
      if ((position.pixels - expectedOffset).abs() > 0.5) return;
      for (final key in orderedKeys) {
        final box = key.currentContext?.findRenderObject();
        if (box is! RenderBox || !box.attached || !box.hasSize) continue;
        final newTop = box.localToGlobal(Offset.zero).dy;
        final target = (position.pixels + newTop - positions[key]!)
            .clamp(position.minScrollExtent, position.maxScrollExtent);
        if ((target - position.pixels).abs() > 0.5) controller.jumpTo(target);
        break;
      }
    });
  }

  void dispose() => controller.dispose();
}
