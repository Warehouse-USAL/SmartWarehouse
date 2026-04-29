import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_theme.dart';
import 'package:design_system/theme/themes/smartwarehouse/smart_warehouse_colors.dart';
import 'package:design_system/theme/themes/smartwarehouse/smart_warehouse_text_styles.dart';

class SmartWarehouseTheme implements CustomTheme {
  @override
  CustomThemeExtension get themeExtension => CustomThemeExtension(
        textStyles: SmartWarehouseTextStyles(),
        darkGray: SmartWarehouseColors.darkGray,
        gray: SmartWarehouseColors.gray,
        lightGray: SmartWarehouseColors.lightGray,
        primaryWhite: SmartWarehouseColors.primaryWhite,
        primaryBlack: SmartWarehouseColors.primaryBlack,
        black50: SmartWarehouseColors.black50,
        gray300: SmartWarehouseColors.gray300,
        white300: SmartWarehouseColors.white300,
        black70: SmartWarehouseColors.black70,
        white80: SmartWarehouseColors.white80,
        white90: SmartWarehouseColors.white90,
        black10: SmartWarehouseColors.black10,
        negative300: SmartWarehouseColors.negative300,
        tertiary200: SmartWarehouseColors.tertiary200,
        gray500: SmartWarehouseColors.gray500,
        white800: SmartWarehouseColors.white800,
        gray200: SmartWarehouseColors.gray200,
        white10: SmartWarehouseColors.white10,
        black20: SmartWarehouseColors.black20,
      );
}
