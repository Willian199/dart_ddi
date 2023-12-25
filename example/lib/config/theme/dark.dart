import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfumei/common/constants/injection_constants.dart';
import 'package:perfumei/common/model/layout.dart';
import 'package:perfumei/config/services/injection.dart';

class DarkTheme {
  static final ThemeData _default = FlexThemeData.dark(
    scheme: FlexScheme.blumineBlue,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 15,
    appBarElevation: 0,
    subThemesData: FlexSubThemesData(
      outlinedButtonOutlineSchemeColor: SchemeColor.onPrimaryContainer,
      appBarBackgroundSchemeColor: SchemeColor.secondaryContainer,
      appBarCenterTitle: !Platform.isIOS,
      buttonMinSize: const Size(100, 40),
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 20,
      inputDecoratorBorderWidth: 1,
      useTextTheme: true,
      thinBorderWidth: 2,
      appBarScrolledUnderElevation: 0,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
    tones: FlexTones.vividSurfaces(Brightness.dark),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    // To use the Playground font, add GoogleFonts package and uncomment
    fontFamily: GoogleFonts.montserrat().fontFamily,
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
  );

  static Color _getColorSegmentedButton(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return _default.colorScheme.secondary;
    }
    return _default.colorScheme.onPrimary;
  }

  static Color _getColorSegmentedButtonIcon(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return _default.colorScheme.onPrimary;
    }
    return _default.colorScheme.primary;
  }

  static void _registerLayout() {
    final baseTextStyle =
        TextStyle(fontFamily: GoogleFonts.montserrat().fontFamily);

    final itemsTextStyle = baseTextStyle.copyWith(
        color: _default.colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w400);

    final subTituloTextStyle = itemsTextStyle.copyWith(fontSize: 12);

    final tituloTextStyle = baseTextStyle.copyWith(
      color: _default.colorScheme.primary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    //ddi.destroy<Layout>();
    ddi.registerSingleton<Layout>(
      () => Layout(
        cardDegradeColors: [
          const Color(0xff00F6ff),
          const Color(0xFF436AB7),
          _default.colorScheme.primaryContainer
        ],
        baseTextStyle: baseTextStyle,
        itemsTextStyle: itemsTextStyle,
        subTituloTextStyle: subTituloTextStyle,
        tituloTextStyle: tituloTextStyle,
        cardBackgroundColor: _default.colorScheme.primaryContainer,
        onPrimary: _default.colorScheme.primary,
        segmentedButtonSelected: _default.colorScheme.onPrimary,
        segmentedButtonDeselected: _default.colorScheme.primary,
        notaDownColor: _default.colorScheme.tertiaryContainer.withOpacity(0.5),
        notaUpColor: _default.colorScheme.tertiary.withOpacity(0.5),
      ),
      registerIf: () =>
          ddi.get<bool>(qualifierName: InjectionConstants.darkMode),
    );
  }

  static ThemeData getTheme() {
    _registerLayout();

    return _default.copyWith(
      segmentedButtonTheme: _default.segmentedButtonTheme.copyWith(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.resolveWith(_getColorSegmentedButton),
          iconColor:
              MaterialStateProperty.resolveWith(_getColorSegmentedButtonIcon),
          animationDuration: const Duration(seconds: 2),
        ),
      ),
      splashColor: _default.colorScheme.onSecondary,
    );
  }
}
