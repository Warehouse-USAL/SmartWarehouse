import 'package:commons/commons.dart';
import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:design_system/widgets/spaces/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.trailing,
    this.secondaryLeadingWidget,
    this.autoImplyLeading = true,
    this.backgroundColor,
    this.showExitModal = false,
    this.onBackPressed,
    this.height = 40,
    this.topPadding = 12,
  });

  final bool autoImplyLeading;
  final Widget? title, trailing, secondaryLeadingWidget;
  final Color? backgroundColor;
  final bool showExitModal;
  final VoidCallback? onBackPressed;
  final double height, topPadding;

  @override
  Widget build(BuildContext context) {
    final navigationHelper = _navigationHelper;
    final canGoBack = onBackPressed != null || navigationHelper.canPop(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: PreferredSize(
            preferredSize: preferredSize,
            child: Container(
              color: backgroundColor ?? Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: CustomSpace.x6.value),
              child: Row(
                children: [
                  if (autoImplyLeading && canGoBack)
                    Expanded(
                      child: Row(
                        children: [
                          PressableWidget(
                            backgroundColor: Colors.transparent,
                            onPressed: onBackPressed ?? () => navigationHelper.popToPreviousRoute(context),
                            child: const CustomIcon(data: CustomIconData.leftSquareArrow, size: Size(28, 28)),
                          ),
                          if (secondaryLeadingWidget != null) ...{
                            const CustomSpacer(width: CustomSpace.x2),
                            secondaryLeadingWidget!,
                          },
                        ],
                      ),
                    )
                  else
                    const Spacer(),
                  Center(child: title),
                  if (trailing != null)
                    Expanded(child: Align(alignment: Alignment.centerRight, child: trailing))
                  else
                    const Expanded(child: CustomSpacer()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  NavigationHelper get _navigationHelper => Injector.i.resolve<NavigationHelper>();

  @override
  Size get preferredSize => Size.fromHeight(height);
}
