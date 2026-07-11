## 2.0.0

* Rewrote the Orthodox saints data model to match the upstream `nigs.json` schema exactly (day-keyed, flat entries), fixing MonthGrid so Christian-mode calendars correctly gate saints by `negs`/`showAllSaints` instead of always showing every saint.
* Fixed `MonthGrid`'s `weekStart` default (Sunday → Monday, matching the JS/TS reference) and made an invalid `weekdayLang` throw `InvalidGridConfigError` instead of silently defaulting.
* Fixed `KenatError.toJson()`'s `type` field, which previously always reported `'KenatError'` regardless of the actual error subclass.
* Fixed the broken `gregorianToHijri` stub, which previously returned nonsense values.
* Added the distance-to-date API: `distanceTo`, `distanceFromToday`, `Kenat.distanceToHoliday`, `Kenat.formatDistance`, `Kenat.generateDateRange`.
* Added Gregorian-calendar rendering: `calendar: 'gregorian'` support in `format`/`getDate`/`toISOString`, plus `formatGregorianStandard/WithWeekday/WithTime` and `toGregorianISODateString`.
* Added static `Kenat.getStaticMonthCalendar`/`Kenat.getYearCalendar`, and a console `printThisMonth()` (backed by a new render module).
* Added `getDate`, `isSameMonth`, `isSameYear`, `toJson`, `isHoliday`, and `startOf`/`endOf('year')`.
* Fixed `setTime` to always return a new instance instead of mutating in place, and corrected `startOf('day')`'s time value.
* Corrected the Ramadan fasting description text and removed an undocumented Islamic-holiday-date fallback that had no basis in the reference implementation.

## 1.0.1

* Added `example/` folder to improve pub.dev score.
* Shortened pubspec description to comply with pub.dev limits.

## 1.0.0

* Initial release of the Kenat Ethiopian calendar library for Dart.
* Full Ethiopian ↔ Gregorian date conversion support.
* Holiday calculations: fixed public/state holidays, movable Christian feasts, and Islamic holidays (Eid al-Fitr, Eid al-Adha, Moulid).
* Fasting period calculations: Abiy Tsome, Nineveh, Filseta, Tsome Hawaryat, Tsome Dihenet, Ramadan.
* Bahire Hasab system for computing movable feasts from Ethiopian ecclesiastical calendar.
* Ethiopian time system (12-hour day/night period) with conversions to/from Gregorian.
* Ge'ez (Ethiopic) numeral conversions in both directions.
* Date arithmetic: add/subtract days, months, and years; diff calculations.
* Calendar month grid generation with holiday and saint data overlay.
* Orthodox Saints (Hagiography) data for all months.
* Multiple date formatting options: standard, Geez, with weekday, with time, short, and ISO-like.
* Comprehensive error handling with descriptive error types.
* 12 test suites covering all core modules.
