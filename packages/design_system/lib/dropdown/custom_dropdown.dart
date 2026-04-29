import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/widgets/text/custom_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    required this.items,
    required this.onChanged,
    this.selectedItem,
    super.key,
    this.label,
    this.borderColor,
    this.errorText,
    this.hintText,
  });

  final List<CustomDropdownItem> items;
  final CustomDropdownItem? selectedItem;
  final Color? borderColor;
  final Function(CustomDropdownItem? item) onChanged;
  final String? errorText, hintText, label;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    final selectedColor = theme.gray;
    final textStyles = CustomTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              buttonStyleData: ButtonStyleData(overlayColor: WidgetStateProperty.all(theme.white80)),
              customButton: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor ?? theme.black50),
                  color: theme.white80,
                ),
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      selectedItem?.text ?? label ?? '',
                      style: textStyles.f18W500.value.copyWith(fontWeight: FontWeight.w400),
                    ),
                    const CustomIcon(data: CustomIconData.chevronDownOutline, size: Size(24, 24)),
                  ],
                ),
              ),
              isExpanded: true,
              items: items
                  .map(
                    (item) => DropdownMenuItem<CustomDropdownItem>(
                      value: item,
                      child: Text(
                        item.text,
                        style: textStyles.f16W600.value.copyWith(color: selectedColor),
                      ),
                    ),
                  )
                  .toList(),
              value: selectedItem,
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomText(errorText!, style: textStyles.f16W600.value.copyWith(color: Colors.red)),
          ),
      ],
    );
  }
}

class CustomDropdownItem {
  CustomDropdownItem(this.text, this.id);

  final String text, id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CustomDropdownItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
