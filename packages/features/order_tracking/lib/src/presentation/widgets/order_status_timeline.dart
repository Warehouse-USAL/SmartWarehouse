import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:orders/orders.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({required this.status, super.key});

  final OrderStatus status;

  static const _steps = [
    (value: OrderStatus.pending, label: 'Pending'),
    (value: OrderStatus.inProgress, label: 'In progress'),
    (value: OrderStatus.completed, label: 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return const _CancelledBanner();
    }
    final currentIndex = _indexFor(status);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            _TimelineNode(
              label: _steps[i].label,
              nodeState: i < currentIndex
                  ? _NodeState.done
                  : i == currentIndex
                      ? _NodeState.active
                      : _NodeState.upcoming,
            ),
            if (i < _steps.length - 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Container(
                    height: 2,
                    color: i < currentIndex ? SwColors.stockIn : SwColors.border,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  int _indexFor(OrderStatus s) => switch (s) {
        OrderStatus.pending => 0,
        OrderStatus.inProgress => 1,
        OrderStatus.completed || OrderStatus.cancelled => 2,
      };
}

enum _NodeState { done, active, upcoming }

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.label, required this.nodeState});

  final String label;
  final _NodeState nodeState;

  @override
  Widget build(BuildContext context) {
    final circleColor = switch (nodeState) {
      _NodeState.done => SwColors.stockIn,
      _NodeState.active => SwColors.yellow,
      _NodeState.upcoming => SwColors.border,
    };
    final textColor =
        nodeState == _NodeState.upcoming ? SwColors.text3 : SwColors.text;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: nodeState == _NodeState.done
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: SwText.body(size: 10, color: textColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SwColors.surface,
        borderRadius: BorderRadius.circular(SwRadii.card),
        border: Border.all(color: SwColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, size: 20, color: SwColors.text3),
          const SizedBox(width: 8),
          Text(
            'Order cancelled',
            style: SwText.body(size: 14, color: SwColors.text3),
          ),
        ],
      ),
    );
  }
}
