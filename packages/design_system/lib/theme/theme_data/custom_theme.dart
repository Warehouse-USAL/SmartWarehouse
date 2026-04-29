import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/themes/smartwarehouse/smart_warehouse_theme.dart';

abstract class CustomTheme {
  factory CustomTheme.smartWarehouse() => SmartWarehouseTheme();

  CustomThemeExtension get themeExtension;
}
