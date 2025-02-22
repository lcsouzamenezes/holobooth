import 'package:flutter/material.dart';
import 'package:holobooth/assets/assets.dart';
import 'package:holobooth_ui/holobooth_ui.dart';

enum Character {
  dash,
  sparky;

  Image toImage() {
    switch (this) {
      case Character.dash:
        return Assets.characters.dash.image();
      case Character.sparky:
        return Assets.characters.sparky.image();
    }
  }

  Color toBackgroundColor() {
    switch (this) {
      case Character.dash:
        return HoloBoothColors.blue;
      case Character.sparky:
        return HoloBoothColors.sparkyColor;
    }
  }
}
