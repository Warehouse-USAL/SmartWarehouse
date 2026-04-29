import 'package:commons/commons.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:design_system/navigation_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login/src/presentation/bloc/authenticate_email/authenticate_email_cubit.dart';
import 'package:login/src/presentation/bloc/email_form/email_form_cubit.dart';
import 'package:login/src/presentation/components/email_section_component.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginView extends StatelessWidget {
  const LoginView({
    required this.emailFormCubit,
    required this.onSubmitMailSuccess,
    required this.onSignUpPressed,
    required this.onContinueWithGooglePressed,
    required this.authenticateEmailCubit,
    super.key,
  });

  final EmailFormCubit emailFormCubit;
  final Function(BuildContext context, String email) onSubmitMailSuccess;
  final Function(BuildContext context) onSignUpPressed, onContinueWithGooglePressed;
  final AuthenticateEmailCubit authenticateEmailCubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F7),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocConsumer<AuthenticateEmailCubit, AuthenticateEmailState>(
          listener: _onAuthenticateEmailStateChange,
          bloc: authenticateEmailCubit,
          builder: (context, state) {
            final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
            return Column(
              children: [
                EmailSectionComponent(
                  formCubit: emailFormCubit,
                  isPrimaryButtonLoading: isLoading,
                  onSignUpPressed: () => onSignUpPressed(context),
                  onContinuePressed: (email) => _onSubmitPressed(context, email),
                  onContinueWithGooglePressed: () => onContinueWithGooglePressed(context),
                ),
                VersionComponent(environmentConfig: Injector.i.resolve<EnvironmentConfig>()),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onAuthenticateEmailStateChange(BuildContext context, AuthenticateEmailState state) {
    state.whenOrNull(
      fail: (failure) async => authenticateEmailCubit.reset(),
      success: () async {
        final email = emailFormCubit.state.text;
        if (email != null) onSubmitMailSuccess(context, email);
      },
    );
  }

  void _onSubmitPressed(BuildContext context, String email) {
    if (emailFormCubit.state.isValid) authenticateEmailCubit.submit(email);
  }
}

class VersionComponent extends StatefulWidget {
  const VersionComponent({required this.environmentConfig, super.key, this.customStyle});

  final EnvironmentConfig environmentConfig;
  final TextStyle? customStyle;

  @override
  State<VersionComponent> createState() => _VersionComponentState();
}

class _VersionComponentState extends State<VersionComponent> {
  late Future<String> _versionFuture;

  @override
  void initState() {
    _versionFuture = _appEnvironmentVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final environment = Injector.i.resolve<EnvironmentConfig>().environment.when(
          dev: () => 'DEV',
          prod: () => '',
          qa: () => 'QA',
        );

    return FutureBuilder<String>(
      future: _versionFuture,
      builder: (_, snapshot) {
        return CustomText(
          '$environment - ${snapshot.data ?? 'none'}',
          styleBuilder: (s) => s.f10W500,
        );
      },
    );
  }

  Future<String> _appEnvironmentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version.split(' ').first;
    return version;
  }
}
