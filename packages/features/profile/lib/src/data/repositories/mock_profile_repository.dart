import 'package:catalog/catalog.dart';
import 'package:dartz/dartz.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';
import 'package:profile/src/domain/entities/user_address.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  static const _user = ProfileUser(
    id: 'usr-001',
    name: 'Andrea Diaz',
    email: 'andrea.diaz@warehouse.co',
    role: 'Operador',
    openOrdersCount: 3,
    spentThisMonth: Money(amount: 52200, currency: 'ARS'),
    address: UserAddress(
      street: 'Av. Corrientes 1234',
      postalCode: 'C1043',
      department: '4A',
      floor: '4',
    ),
  );

  static const _orders = [
    OrderSummary(
      id: 'WH-49281',
      dateLabel: 'May 6',
      itemCount: 11,
      status: OrderStatus.shipped,
      total: Money(amount: 9640, currency: 'ARS'),
    ),
    OrderSummary(
      id: 'WH-49108',
      dateLabel: 'May 2',
      itemCount: 4,
      status: OrderStatus.delivered,
      total: Money(amount: 4120, currency: 'ARS'),
    ),
    OrderSummary(
      id: 'WH-48993',
      dateLabel: 'Apr 28',
      itemCount: 22,
      status: OrderStatus.delivered,
      total: Money(amount: 31200, currency: 'ARS'),
    ),
    OrderSummary(
      id: 'WH-48870',
      dateLabel: 'Apr 24',
      itemCount: 6,
      status: OrderStatus.delivered,
      total: Money(amount: 7310, currency: 'ARS'),
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

  @override
  Future<Either<ProfileFailure, ProfileUser>> updateProfile({
    String? name,
    UserAddress? address,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Right(_user.copyWith(name: name, address: address));
  }
}
