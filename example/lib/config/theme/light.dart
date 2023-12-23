import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfumei/common/constants/injection_constants.dart';
import 'package:perfumei/common/model/layout.dart';
import 'package:perfumei/config/services/injection.dart';

class LigthTheme {
  static final ThemeData _default = FlexThemeData.light(
    scheme: FlexScheme.blumineBlue,
    surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
    blendLevel: 9,
    appBarElevation: 0,
    applyElevationOverlayColor: false,
    appBarOpacity: 1,
    tabBarStyle: FlexTabBarStyle.forBackground,
    bottomAppBarElevation: 0,
    //Para testar layout. Em produção não usar
    //platform: TargetPlatform.windows,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    subThemesData: FlexSubThemesData(
        outlinedButtonOutlineSchemeColor: SchemeColor.onPrimaryContainer,
        appBarBackgroundSchemeColor: SchemeColor.secondaryContainer,
        appBarCenterTitle: !Platform.isIOS,
        buttonMinSize: const Size(100, 40),
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 20,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderWidth: 1,
        inputDecoratorFillColor: Colors.white70,
        useTextTheme: true,
        thinBorderWidth: 2,
        appBarScrolledUnderElevation: 0),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
    tones: FlexTones.vividSurfaces(Brightness.light),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.montserrat().fontFamily,
  );

  static Color _getColorSegmentedButton(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{MaterialState.selected};
    if (states.any(interactiveStates.contains)) {
      return _default.colorScheme.secondary;
    }
    return _default.colorScheme.onPrimary;
  }

  static Color _getColorSegmentedButtonIcon(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{MaterialState.selected};
    if (states.any(interactiveStates.contains)) {
      return _default.colorScheme.onPrimary;
    }
    return _default.colorScheme.primary;
  }

  static void _registerLayout() {
    final baseTextStyle = TextStyle(fontFamily: GoogleFonts.montserrat().fontFamily);

    final itemsTextStyle = baseTextStyle.copyWith(color: _default.colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w400);

    final subTituloTextStyle = itemsTextStyle.copyWith(fontSize: 12);

    final tituloTextStyle = baseTextStyle.copyWith(
      color: _default.colorScheme.onPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    ddi.registerSingleton<Layout>(
      () => Layout(
        cardDegradeColors: [const Color(0xff00F6ff), const Color(0xFF436AB7), _default.colorScheme.primary],
        baseTextStyle: baseTextStyle,
        itemsTextStyle: itemsTextStyle,
        subTituloTextStyle: subTituloTextStyle,
        tituloTextStyle: tituloTextStyle,
        cardBackgroundColor: _default.colorScheme.primary,
        onPrimary: _default.colorScheme.onPrimary,
        segmentedButtonSelected: _default.colorScheme.onPrimary,
        segmentedButtonDeselected: _default.colorScheme.primary,
        notaDownColor: _default.colorScheme.onPrimaryContainer,
        notaUpColor: _default.colorScheme.primaryContainer,
      ),
      registerIf: () => !ddi.get<bool>(qualifierName: InjectionConstants.darkMode),
    );
  }

  static ThemeData getTheme() {
    _registerLayout();

    return _default.copyWith(
      segmentedButtonTheme: _default.segmentedButtonTheme.copyWith(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(_getColorSegmentedButton),
          iconColor: MaterialStateProperty.resolveWith(_getColorSegmentedButtonIcon),
          animationDuration: const Duration(seconds: 2),
        ),
      ),
      splashColor: _default.colorScheme.secondary,
    );
  }
}
