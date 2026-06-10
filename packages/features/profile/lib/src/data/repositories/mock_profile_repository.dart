import 'package:dartz/dartz.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  static const _user = ProfileUser(
    id: 'usr-001',
    name: 'Andrea Diaz',
    email: 'andrea.diaz@warehouse.co',
    role: 'Operador',
    bay: 'Bahía 14',
    openOrdersCount: 3,
    spentThisMonth: 522.00,
  );

  static const _orders = [
    OrderSummary(
      id: 'WH-49281',
      dateLabel: 'May 6',
      itemCount: 11,
      status: OrderStatus.shipped,
      totalAmount: 96.40,
    ),
    OrderSummary(
      id: 'WH-49108',
      dateLabel: 'May 2',
      itemCount: 4,
      status: OrderStatus.delivered,
      totalAmount: 41.20,
    ),
    OrderSummary(
      id: 'WH-48993',
      dateLabel: 'Apr 28',
      itemCount: 22,
      status: OrderStatus.delivered,
      totalAmount: 312.00,
    ),
    OrderSummary(
      id: 'WH-48870',
      dateLabel: 'Apr 24',
      itemCount: 6,
      status: OrderStatus.delivered,
      totalAmount: 73.10,
    ),
  ];

  @override
  Future<Either<ProfileFailure, ProfileUser>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Right(_user);
  }

  @override
  Future<Either<ProfileFailure, List<OrderSummary>>> getOrderHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Right(_orders);
  }
}
