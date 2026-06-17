import 'package:orders/orders.dart' as orders;
import 'package:profile/src/data/dtos/user_dto.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';

extension UserDtoMapper on UserDto {
  ProfileUser toProfileUser({
    int openOrdersCount = 0,
    double spentThisMonth = 0,
    String bay = '—',
  }) =>
      ProfileUser(
        id: id,
        name: name,
        email: email,
        role: _readableRole(role),
        bay: bay,
        openOrdersCount: openOrdersCount,
        spentThisMonth: spentThisMonth,
      );

  String _readableRole(String raw) {
    switch (raw.toUpperCase()) {
      case 'SUPERADMIN':
        return 'Super admin';
      case 'ADMIN_WAREHOUSE':
        return 'Admin depósito';
      case 'ADMIN_SALES':
        return 'Admin ventas';
      case 'ADMIN_SYSTEM':
        return 'Admin sistema';
      case 'OPERATOR':
        return 'Operador';
      default:
        return raw;
    }
  }
}

extension OrderToSummary on orders.Order {
  OrderSummary toSummary() {
    final itemsCount = items.fold<int>(0, (sum, i) => sum + i.quantity);
    final cents = items.fold<int>(0, (sum, i) => sum + (i.unitPrice.amount * i.quantity));
    return OrderSummary(
      id: 'WH-${id.substring(id.length > 5 ? id.length - 5 : 0).toUpperCase()}',
      dateLabel: _formatDate(createdAt),
      itemCount: itemsCount,
      status: _mapStatus(status),
      totalAmount: cents / 100.0,
    );
  }

  OrderStatus _mapStatus(dynamic raw) {
    // El status acá es OrderStatus de orders package (pending/inProgress/
    // completed/cancelled). Lo mapeo al enum de profile.
    final s = raw.toString().toLowerCase();
    if (s.contains('completed')) return OrderStatus.delivered;
    if (s.contains('inprogress')) return OrderStatus.shipped;
    if (s.contains('cancelled')) return OrderStatus.cancelled;
    return OrderStatus.processing;
  }

  String _formatDate(DateTime d) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}
