import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:orders/orders.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({required this.status, super.key});

  final OrderStatus status;

  static const _stepLabels = ['Received', 'Packed', 'Shipped', 'Delivered'];

  int get _currentStep => switch (status) {
        OrderStatus.pending => 0,
        OrderStatus.inProgress => 2,
        OrderStatus.completed => _stepLabels.length,
        OrderStatus.cancelled => -1,
      };

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) return const _CancelledBanner();

    final current = _currentStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal stepper
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < _stepLabels.length; i++) ...[
              // Connector before each step except the first.
              // Yellow when current >= i (path to this step is complete).
              if (i > 0)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: Container(
                      height: 2,
                      color: current >= i ? SwColors.yellow : SwColors.border,
                    ),
                  ),
                ),
              _StepBubble(
                number: i + 1,
                label: _stepLabels[i],
                state: i < current
                    ? _NodeState.done
                    : i == current
                        ? _NodeState.current
                        : _NodeState.todo,
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        // Vertical step list with status dots
        for (int i = 0; i < _stepLabels.length; i++) ...[
          _StepRow(
            label: _stepLabels[i],
            state: i < current
                ? _NodeState.done
                : i == current
                    ? _NodeState.current
                    : _NodeState.todo,
          ),
          if (i < _stepLabels.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

enum _NodeState { done, current, todo }

class _StepBubble extends StatelessWidget {
  const _StepBubble({
    required this.number,
    required this.label,
    required this.state,
  });

  final int number;
  final String label;
  final _NodeState state;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color borderColor;
    final Color numColor;

    switch (state) {
      case _NodeState.done:
        bg = SwColors.yellow;
        borderColor = SwColors.yellow;
        numColor = SwColors.text;
      case _NodeState.current:
        bg = SwColors.text;
        borderColor = SwColors.text;
        numColor = SwColors.yellow;
      case _NodeState.todo:
        bg = SwColors.white;
        borderColor = SwColors.border;
        numColor = SwColors.text3;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: state == _NodeState.done
                ? const Icon(Icons.check, size: 14, color: SwColors.text)
                : Text(
                    '$number',
                    style: SwText.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: numColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: SwText.body(
              size: 11,
              weight: FontWeight.w600,
              color: state == _NodeState.todo ? SwColors.text3 : SwColors.text2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.state});

  final String label;
  final _NodeState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: state == _NodeState.todo ? SwColors.border : SwColors.yellow,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: SwText.body(
              size: 13,
              color: state == _NodeState.todo ? SwColors.text3 : SwColors.text,
              weight: state == _NodeState.current ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
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
          const Icon(Icons.cancel_outlined, size: 20, color: SwColors.text3),
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
