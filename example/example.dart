import 'package:kenat/kenat.dart';

void main() {
  // 1. Get the current Ethiopian date
  final today = Kenat.now();
  print('Today in standard format: ${today.formatStandard()}');
  print('Today in Geez numerals: ${today.formatInGeez()}');

  // 2. Date Conversions
  final ethDate = Kenat.fromEthiopian(2016, 9, 15);
  print('Ethiopian 2016/09/15 is Gregorian: ${ethDate.getGregorian()}');

  final gregDate = Kenat.fromGregorian(2024, 5, 23);
  print('Gregorian 2024-05-23 is Ethiopian: ${gregDate.formatStandard('english')}');

  // 3. Holidays
  // Check public holidays in Meskerem (Month 1) for the year 2016
  final holidaysInMeskerem = getHolidaysInMonth(2016, 1);
  print('\nHolidays in Meskerem 2016:');
  for (var holiday in holidaysInMeskerem) {
    print('- ${holiday['name']} on Meskerem ${holiday['ethiopian']['day']}');
  }

  // 4. Fasting Periods
  // Get information about Abiy Tsome (Great Lent) for 2016
  final abiyTsome = getFastingInfo(FastingKeys.abiyTsome, 2016);
  if (abiyTsome != null) {
    final start = abiyTsome['period']['start'];
    final end = abiyTsome['period']['end'];
    print('\nAbiy Tsome in 2016 starts on Month ${start['month']}, Day ${start['day']} and ends on Month ${end['month']}, Day ${end['day']}');
  }

  // 5. Ethiopian Time System
  // 6:30 AM in Ethiopian time is 12:30 PM in Gregorian
  final time = Time(6, 30, 'day');
  print('\nEthiopian Time ${time.format()} corresponds to Gregorian ${time.toGregorian()['hour']}:${time.toGregorian()['minute']}');
}
