# Kenat — Ethiopian Calendar for Dart 🗓️

[![pub package](https://img.shields.io/pub/v/kenat.svg)](https://pub.dev/packages/kenat)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-blue)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Kenat** (ቀናት — "days" in Amharic) is a comprehensive pure-Dart library for the Ethiopian calendar system. It provides everything you need to work with Ethiopian dates, times, and cultural/religious data in your Dart or Flutter application.

---

## ✨ Features

- 🔄 **Date Conversions** — Seamless Ethiopian ↔ Gregorian conversions
- 📅 **Date Arithmetic** — Add/subtract days, months, and years; compute differences
- 🕌🕍 **Holidays** — Fixed public holidays, movable Christian feasts, and Islamic holidays (Eid, Moulid)
- 🙏 **Fasting Periods** — Abiy Tsome, Nineveh, Filseta, Tsome Hawaryat, Tsome Dihenet, Ramadan
- 📖 **Bahire Hasab** — Full Ethiopian ecclesiastical computation system for movable feasts
- ⏰ **Ethiopian Time** — 12-hour day/night period system with Gregorian conversion
- 🔢 **Geez Numerals** — Convert Arabic ↔ Ethiopic (Geez) numerals
- 🗓️ **Calendar Grid** — Generate month grids with holiday and saint data overlays
- 🏛️ **Orthodox Saints** — Comprehensive hagiography data for all 13 months
- 🌐 **Multilingual** — Amharic and English support throughout the API
- ⚠️ **Error Handling** — Descriptive, typed error classes for all failure modes

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  kenat: ^1.0.0
```

Then run:

```bash
dart pub get
```

---

## 🚀 Quick Start

```dart
import 'package:kenat/kenat.dart';

void main() {
  // Today's Ethiopian date
  final today = Kenat.now();
  print(today.formatStandard());           // e.g. "ግንቦት 27 2016"
  print(today.formatStandard('english'));  // e.g. "Ginbot 27 2016"

  // Create from Ethiopian date
  final eth = Kenat.fromEthiopian(2016, 1, 1);
  print(eth.getGregorian());  // {year: 2023, month: 9, day: 11}

  // Create from Gregorian date
  final greg = Kenat.fromGregorian(2024, 5, 23);
  print(greg.getEthiopian()); // {year: 2016, month: 9, day: 15}
}
```

---

## 📖 API Reference

### `Kenat` — The Main Class

The primary class for all calendar operations. Can be constructed from a `DateTime`, an Ethiopian date map, or a date string.

#### Constructors & Factories

```dart
Kenat.now()                                      // Current date
Kenat.fromEthiopian(int year, int month, int day)
Kenat.fromGregorian(int year, int month, int day)
Kenat.fromString('2016/9/15')                    // "yyyy/mm/dd" or "yyyy-mm-dd"
```

#### Date Access

```dart
final d = Kenat.fromEthiopian(2016, 9, 15);

d.getEthiopian();  // {year: 2016, month: 9, day: 15}
d.getGregorian();  // {year: 2024, month: 5, day: 23}
d.getWeekday();    // 4  (0=Sunday … 6=Saturday)
d.getWeekdayName();         // "ሐሙስ" (Amharic)
d.getWeekdayName('english'); // "Thursday"
d.getDaysInMonth();  // 30
d.getDayOfYear();    // day number within the Ethiopian year
d.isLeapYear();      // false
d.isToday;           // bool
d.isWeekend;         // bool
```

#### Formatting

```dart
d.formatStandard();            // "ግንቦት 15 2016"
d.formatStandard('english');   // "Ginbot 15 2016"
d.formatInGeez();              // "ግንቦት ፲፭ ፳፻፲፮"
d.formatWithWeekday();         // "ሐሙስ, ግንቦት 15 2016"
d.formatWithWeekday('english', true); // with Geez numerals
d.formatShort();               // "2016/09/15"
d.toISODateString();           // "2016-09-15"
```

#### Date Arithmetic

```dart
d.addDays(10);      // new Kenat 10 days later
d.addMonths(2);     // 2 months later
d.addYears(1);      // 1 year later

d.add(5, 'days');      // generic add
d.subtract(3, 'months');

d.diffInDays(other);    // int
d.diffInMonths(other);  // int
d.diffInYears(other);   // int
d.diffBreakdown(other); // {years, months, days}
```

#### Date Comparison

```dart
d.isBefore(other);  // bool
d.isAfter(other);   // bool
d.isSameDay(other); // bool
d == other;         // equality by date
```

#### Navigation

```dart
d.startOf('month');   // first day of month
d.startOf('day');     // same day, time set to 1:00 day
d.endOf('month');     // last day of month
d.endOf('day');       // same day, time set to 12:00 night
d.startOfMonth();     // convenience alias
d.endOfMonth();       // convenience alias
```

---

### Holidays

```dart
// Get a specific holiday for a year
final meskel = getHoliday('meskel', 2016);
// {key: 'meskel', name: 'መስቀል', ethiopian: {year: 2016, month: 1, day: 17}, ...}

// All holidays in a month
final holidays = getHolidaysInMonth(2016, 1);
// Optional language option
final holidaysEn = getHolidaysInMonth(2016, 1, {'lang': 'english'});

// Filter by tag
final publicHolidays = getHolidaysInMonth(2016, 1, {'filter': 'public'});
final christianOnly = getHolidaysInMonth(2016, 1, {'filter': 'christian'});
final islamicOnly   = getHolidaysInMonth(2016, 1, {'filter': 'muslim'});

// All holidays for a year
final yearHolidays = getHolidaysForYear(2016);
```

**Holiday keys:** `enkutatash`, `meskel`, `gena`, `timket`, `adwa`, `labour`, `patriots`, `martyrsDay`, `beherbehereseb`, `nineveh`, `abiyTsome`, `debreZeit`, `hosanna`, `siklet`, `fasika`, `rikbeKahnat`, `erget`, `paraclete`, `tsomeHawaryat`, `tsomeDihnet`, `eidFitr`, `eidAdha`, `moulid`

**Holiday tags:** `public`, `state`, `religious`, `christian`, `orthodox`, `muslim`, `cultural`

---

### Bahire Hasab

The Bahire Hasab is the Ethiopian Orthodox system for computing movable feasts.

```dart
final bh = getBahireHasab(2016);

print(bh['ameteAlem']);     // Age of the world (e.g. 7516)
print(bh['evangelist']);    // {name: 'ዮሐንስ', remainder: 3}
print(bh['newYear']);       // {dayName: 'ቅዳሜ', tinteQemer: 5}
print(bh['medeb']);         // Metonic cycle position
print(bh['nineveh']);       // {year: 2016, month: 5, day: 17}
print(bh['movableFeasts']); // Map of all movable feasts

// Get a single movable holiday
final fasika = getMovableHoliday('fasika', 2016);
// {year: 2016, month: 8, day: 27}
```

**Movable feast keys:** `nineveh`, `abiyTsome`, `debreZeit`, `hosanna`, `siklet`, `fasika`, `rikbeKahnat`, `erget`, `paraclete`, `tsomeHawaryat`, `tsomeDihnet`

---

### Fasting Periods

```dart
import 'package:kenat/kenat.dart';

// Get start and end dates of a fasting period
final period = getFastingPeriod(FastingKeys.abiyTsome, 2016);
// {start: {year:2016, month:6, day:4}, end: {year:2016, month:8, day:26}}

// Get full fasting info with name and description
final info = getFastingInfo(FastingKeys.filseta, 2016, {'lang': 'english'});
// {key: 'filseta', name: 'Filseta', description: '...', tags: [...], period: {...}}

// Check if a date is an Orthodox weekly fast day (Wed/Fri, excluding post-Easter period)
final isfast = isTsomeDihnetFastDay({'year': 2016, 'month': 1, 'day': 5});
// true or false
```

**Fasting keys (via `FastingKeys` class):**

| Key | Description |
|---|---|
| `FastingKeys.abiyTsome` | Lent (Great Fast) |
| `FastingKeys.nineveh` | Fast of Nineveh |
| `FastingKeys.tsomeNebiyat` | Fast of the Prophets |
| `FastingKeys.filseta` | Fast of the Assumption (Nehase 1–14) |
| `FastingKeys.tsomeHawaryat` | Fast of the Apostles |
| `FastingKeys.tsomeDihenet` | Weekly fasting (Wed & Fri) |
| `FastingKeys.ramadan` | Islamic Ramadan |

---

### Ethiopian Time (`Time`)

The Ethiopian time system uses a 12-hour clock shifted by 6 hours from the Gregorian clock (6 AM = 12:00 "day", 6 PM = 12:00 "night").

```dart
// Create from Ethiopian hour/minute/period
final t = Time(6, 30, 'day');        // 6:30 AM Ethiopian = 12:30 PM Gregorian

// Create from Gregorian 24h time
final t2 = Time.fromGregorian(14, 0); // 2:00 PM = 8:00 "day" Ethiopian

// Create from string
final t3 = Time.fromString('6:30 night'); // or "፮:፴ ማታ"

// Convert back to Gregorian
print(t.toGregorian()); // {hour: 12, minute: 30}

// Format
print(t.format());                          // "፮:፴ ጠዋት"
print(t.format({'useGeez': false}));        // "06:30 day"
print(t.format({'lang': 'english'}));       // "06:30 day"

// Arithmetic
final later = t.add({'hours': 2, 'minutes': 30});
final earlier = t.subtract({'hours': 1});
final difference = t.diff(t2); // {hours: 1, minutes: 30}

// Kenat with time
final d = Kenat.fromEthiopian(2016, 9, 15);
final withTime = d.setTime(6, 30, 'day');
print(withTime.formatWithTime()); // "ግንቦት 15 2016 06:30 ጠዋት"
```

---

### Geez (Ethiopic) Numerals

```dart
toGeez(15);      // "፲፭"
toGeez(2016);    // "፳፻፲፮"
toGeez(10000);   // "፼"

toArabic('፲፭');   // 15
toArabic('፳፻፲፮'); // 2016
```

---

### Calendar Month Grid

Generate a structured calendar grid for UI rendering, with optional holidays, saints, and Geez numeral support.

```dart
final grid = createMonthGrid({
  'year': 2016,
  'month': 9,
  'useGeez': false,
  'weekdayLang': 'amharic', // or 'english'
  'weekStart': 0,           // 0=Sunday, 1=Monday, ...
  'mode': 'public',         // 'public' | 'christian' | 'orthodox' | 'muslim'
});

print(grid['monthName']); // "ግንቦት"
print(grid['year']);      // "2016"
print(grid['headers']);   // ["እሑድ","ሰኞ","ማክሰኞ",...]

// Each entry in grid['days'] is either null (padding) or:
// {
//   ethiopian: {year, month, day},
//   gregorian: {year, month, day},
//   weekday: 4,
//   weekdayName: "ሐሙስ",
//   isToday: false,
//   holidays: [ {key, name, description, tags, ...} ]
// }

// Navigate months
final nextMonth = grid['up']();
final prevMonth = grid['down']();
```

---

### Standalone Utility Functions

All major operations are also available as top-level functions for convenience:

```dart
// Conversions
toEC(2024, 5, 23);  // Ethiopian: {year: 2016, month: 9, day: 15}
toGC(2016, 9, 15);  // Gregorian: {year: 2024, month: 5, day: 23}

// Date arithmetic
addDays({'year': 2016, 'month': 1, 'day': 1}, 10);
addMonths({'year': 2016, 'month': 1, 'day': 1}, 2);
addYears({'year': 2016, 'month': 1, 'day': 1}, 1);
diffInDays(date1, date2);
diffInMonths(date1, date2);
diffInYears(date1, date2);

// Calendar grid
createMonthGrid({'year': 2016, 'month': 9});

// Format
formatStandard({'year': 2016, 'month': 9, 'day': 15});         // "ግንቦት 15 2016"
formatInGeezAmharic({'year': 2016, 'month': 9, 'day': 15});   // "ግንቦት ፲፭ ፳፻፲፮"
formatShort({'year': 2016, 'month': 9, 'day': 15});           // "2016/09/15"
formatWithWeekday({'year': 2016, 'month': 9, 'day': 15});
```

---

## 🗺️ Ethiopian Calendar Basics

| Feature | Details |
|---|---|
| **Months** | 13 months: 12 × 30 days + Pagume (5 or 6 days) |
| **Leap Year** | Every 4th year (year % 4 == 3), Pagume has 6 days |
| **Year Offset** | Ethiopian year is ~7–8 years behind Gregorian |
| **New Year** | Enkutatash — Meskerem 1 (≈ Sept 11/12) |
| **Time System** | Day starts at 6:00 AM (Ethiopian 12:00 day) |

**Ethiopian Month Names:**

| # | Amharic | English |
|---|---|---|
| 1 | መስከረም | Meskerem |
| 2 | ጥቅምት | Tikimt |
| 3 | ኅዳር | Hidar |
| 4 | ታኅሣሥ | Tahsas |
| 5 | ጥር | Tir |
| 6 | የካቲት | Yekatit |
| 7 | መጋቢት | Megabit |
| 8 | ሚያዚያ | Miyazia |
| 9 | ግንቦት | Ginbot |
| 10 | ሰኔ | Sene |
| 11 | ሐምሌ | Hamle |
| 12 | ነሐሴ | Nehase |
| 13 | ጳጉሜ | Pagume |

---

## 🧪 Testing

The library ships with 12 test suites covering all modules:

```bash
dart test
```

---

## 📄 License

[MIT License](LICENSE) © Melaku Demeke

---

## 🙋 Contributing

Pull requests and issues are welcome on [GitHub](https://github.com/MelakuDemeke/kenat-dart). Please open an issue before submitting large changes.