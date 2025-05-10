# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### [0.3.8]
#### Added
- Added a settings page
- Added a fallback download server
- Added jump-drive related stats to the navigation stats
- Added reactive implant units

#### Changed
- Switched to a new download server to fix caching and SSL issues (this can be changed in the settings)
- Replaced the manup package with a custom implementation to remove Firebase dependencies

#### Fixed
- Fixed calculation issue with recursive drone attributes
- Fixed display issue with drone attributes
- Fixed issue with removed attributes that were hardcoded

### [0.3.7]
#### Added
- Added support for corp structures
- Added current shield selector for passive tanking
- Added implant instabuff modifiers

#### Changed
- Improve drone fitting tile (defensive resistance now have bars similar to the ship itself)

#### Fixed
- Fixed issues where it was not possible to rename characters if the total implant levels is set to 0
- Fixed attribute calculations for drones/fighters (again)
- Fixed missing missile range attribute

### [0.3.6]
#### Added
- Weapons will now display their raw damage

#### Fixed
- Fixed reordering of implants in the list page
- Fixed fitting to text export
- Fixed lightweight ship calculations
- Fixed issue where implants would not be applied after opening a fitting
- Fixed and added tests for implants/ai nanocores

### [0.3.5 (Beta)]
#### Added
- Added support for passive implants
- Added advanced units to implants
- Added option to fix SSL certificate issue, see discord
- Added option to enable file logging

#### Changed
- The app can now be launched without downloading the DB
- Changed the way attributes are displayed, now all attributes for all items should be displayed

#### Fixed
- Fixed UI crash for some implants
- Fixed localisation issue for some implants inside the list

### [0.3.4 (Beta)]

#### Added
- Added Implants
- Added Nanocore Library. However, the passive effects will probably be removed in the future and moved to a separate page.

#### Changed
- Updated to Android 34 as compile version
- Updated to Dart 3.5 and latest flutter. Additionally, most packages got updated to the latest version.
- Switched to declarative gradle plugins blocks

#### Fixed
- Fixed hangar rigs and added attributes to the UI Build Changes
- Fixed Golden Nanocores attributes

### [v0.3.3]

#### Added
- Added attributes for super weapons to the UI
- Added "clone fitted item"-button

#### Changed
- Updated market group ids to fix drones/fighter issues

#### Fixed
- Fixed DPS calculation issue for Doomsday Weapons
- Fixed capital integrated rigs (fitting was not updating correctly)

### [0.3.2]

#### Added
- Added player outposts and corresponding modules
- Added default skill level selector when creating new characters (all skills will be set to this level, for example "5/5/4")
- Added folders to fitting list

#### Fixed
- Fixed errors where higs anchor rigs could be used for integrated rigs

### [0.2.16 (Unreleased)]

#### Added
- Moved DB download to Github
- Added mining drones into mining calculations
- Ensure role bonuses have names

### [0.2.15]

#### Fixed
- Fix Cyno generators not fitting to relevant hulls

### [0.2.14]
#### Added
- Added special hold values in ship details

#### Fixed
- Ship bonuses rounding to nearest whole number (now shows 2 dp)
- Fix N-Space % not rendering correctly

### [0.2.12]
#### Added

#### Fixed
- Fixed Target Modules applying effects to local ship
- Fixed Weapon module bonuses not calculating correctly depending on slot
- Fixed some modifiers not being applied to race ships
- Corrects Carrier fighter counts for DPS calculation
- Clear all reliant skills on skill level change

### [0.2.11]
#### Added
- Add ability to edit pilot from fitting

#### Fixed
- Fix URLs not launching on some devices
- Fix wrapping issue for skill pips
- Fix Fighters fitting into drone bay 

### [0.2.10]
#### Added
- Calculate Group Reps in the tanking stats

#### Fixed
- Fix nanocore sub attributes are truncated to 4dp  

### [0.2.9]
#### Added
- Can trigger DB verification remotely (not always required and slows things down)

#### Fixed
- Tanking stats using inactive modules into calculations

### [0.2.8]
#### Added
- Add CRC check to ensure data downloads correctly
- Add Recharge rates with EHP toggle

#### Fixed
- Fix Light Theme text issues
- Fix Rig integrations not printing to text correctly

### [0.2.7]
#### Added
- Trainable attributes to Nanocores
- Nihilus space environment modifiers (Capacitor recharge time atm)
- Additional startup logging

### [0.2.6]
#### Fixed
- Db loader for Int Lists

### [0.2.5]
#### Added
- Add Local notifications for PI reminder
- Add UTC clock for reference of time
- Add EHP stat into Defences section

#### Fixed
- DB missing and would not re-download 
- Drones not reloading in active state
- Add back in Missile Range stat

### [0.2.4]
#### Added
- Ability to save QR codes to file (Still need to find a way to load on desktop)
- Add more stats to render in module tiles
- Add analytic for loading time

#### Fixed
- Rig Integrations not loading correctly
- Android 7.0 would not load attribute formulas

### [0.2.3]
#### Added
- Ability to add Rig Integrations, and export with text fittings
- Render Shield Bonus amount for boosters
- Retry logic if the app fails to start due to network issues
- Add white background for QR Codes

#### Fixed
- Adding drones would reset modifiers in a fitting
- Fittings slot layout would not reload correctly in some instances

### [0.2.2]
#### Added
- Additional logs and checks on Market API
- Added time calculation to fill Mining vessels
#### Fixed
- Fixed cloned characters and ships changing the source items

### [0.2.1]
#### Fixed
- Load issue on new install with no market API

### [0.2.0]
#### Added
- Updated to handle new naming scheme
- Fix issue - new characters could not set skills

#### Fixed

### [0.1.12]
#### Added
- Added update banner in drawer when updates are available
#### Fixed
- Fixed Blueprint description not showing item title and description
- Rolled back DB -> Now locked to ManUp file. This was for new naming scheme

### [0.1.10]
#### Fixed
- Fixed Export directory on mobiles not working correctly
### [0.1.9]
#### Added
- Added Nanocores into fitting simulation
- Added download progress when updating game data
- Show total SP for a character and SP for Skills in Character browser
- Added PI Countdown timer (local notifications on mobile incoming)
- Added Import/Export to CSV for character skills

#### Fixed
- Fixed rigs not printing bonuses

### [0.1.8]
#### Added

#### Fixed
- Fixed item name text not wrapping

### [0.1.7]
#### Added
- Added Market data for individual items and Fittings
- Print Align time as 3 decimal places
- Added logic for Command Modules

#### Fixed
- Fixed issue where wrong string shown for Missile Range
- Fixed issue where some attributes would not be shown
- Fixed issue where default pilot was not being applied on fresh boot

### [0.1.6]
#### Added
- Add Social links
- Change Fitting and Character lists to be reorderable (/u/DownvotesSloths)
- Add mining amount / minute (@RacingSOUL (Андрей)) 
- Add Scanner attributes and printing of stats
- Dropped Android min SDK to match Echoes (Android 5.1)

#### Fixed
- Fixed occasional issue where damage pattern may not have loaded

### [0.1.5]
#### Added
- Display side panel in wide screen mode
- Condense Skills entry widgets and replace with dots bar
- Enforce Skills Preskill entries
- Show Missile Range for missiles

#### Fixed
- Fix Windows not showing build number
- Fix Mining modules not showing mining amount in fitting screen
- Fix issue of incomplete fitting checks on modules (Strip Miners, etc)


### [0.1.4]
#### Added
- Add ability to clone Ships and Characters
- Add link between character and Pastebin CSV (for quick bulk updating)
- Add group reps into capacitor simulation (if flag is set)
- Prompt user to save dirty fitting before exiting screen
- Separate DB update from app cycle
- Create widget to select 'Default character'
- Add Empty pilot (No skills set) and show in Pilot selection list
- Replace Circular skill indicator with linear one
- Integrated ManUp for indicating updates of app and data
#### Fixed
- Fix search issue on Drones category

### [0.1.3]
#### Added
- Bottom drawer has context aware search bar
- Include Prototype rigs in listings 
- Ship hull shows on Fitting listing

#### Fixed
- Bug where modules and state would sometimes not save correctly

### [0.1.1]

#### Added
- Dark Mode
- Added drone check before fitting
