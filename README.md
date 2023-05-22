# SWEET - Silkys Wonderful Eve Echoes Tool

[![Tests](https://github.com/SilkyPantsDan/sweet/actions/workflows/run_tests.yml/badge.svg)](https://github.com/SilkyPantsDan/sweet/actions/workflows/run_tests.yml)

Unsure exactly what this will be yet, but it's starting off as a simple fitting tool, as well as other 'Quality of Life' things that crop up along the way.

To Do list:

- [x] Market Browser
    - [x] Integration with Eve Echoes Market
- [x] Item Browser
    - [ ] Compare items
- [x] Character builder 
    - [x] CRUD characters
    - [x] Set skill levels
    - Import/Export via 
        - [ ] Share sheet
        - [x] QR codes
        - [x] Pastebin CSV
- [x] Fitting tool, with:
    - [x] Cap simulator
    - [x] EHP/DPS
    - [x] Hot/Cold readings
    - [x] Ship Modes

----

## Build notes
Currently targeting on the `beta` channel - ensure you have also enabled Desktop
```
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter pub get
```

Should the models change, you may need to update the generated files.
```
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Update app icons

```
flutter pub get
flutter pub run flutter_launcher_icons:main
```

### Attributions!!

Eve Echoes thanks to CCP and NetEase

Sweet Icon made by [Icongeek26 from www.flaticon.com](https://www.flaticon.com/packs/cafe-59)


