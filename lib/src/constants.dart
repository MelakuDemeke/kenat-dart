/// Constants for the Ethiopian calendar library
/// Contains month names, day names, holiday information, and other static data
library;

/// Month names in different languages
class MonthNames {
  static const List<String> english = [
    "Meskerem",
    "Tikimt",
    "Hidar",
    "Tahsas",
    "Tir",
    "Yekatit",
    "Megabit",
    "Miazia",
    "Ginbot",
    "Sene",
    "Hamle",
    "Nehase",
    "Pagume",
  ];

  static const List<String> amharic = [
    "መስከረም",
    "ጥቅምት",
    "ህዳር",
    "ታህሳስ",
    "ጥር",
    "የካቲት",
    "መጋቢት",
    "ሚያዝያ",
    "ግንቦት",
    "ሰኔ",
    "ሀምሌ",
    "ነሐሴ",
    "ጳጉሜ",
  ];

  static const List<String> gregorian = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
}

/// Days of the week in different languages
class DaysOfWeek {
  static const List<String> english = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  static const List<String> amharic = [
    "እሑድ",
    "ሰኞ",
    "ማክሰኞ",
    "ረቡዕ",
    "ሐሙስ",
    "ዓርብ",
    "ቅዳሜ",
  ];
}

/// Holiday tags for categorization
class HolidayTags {
  static const String public = "public";
  static const String religious = "religious";
  static const String christian = "christian";
  static const String orthodox = "orthodox";
  static const String muslim = "muslim";
  static const String state = "state";
  static const String cultural = "cultural";
  static const String other = "other";
}

/// Period labels for Ethiopian time system
class PeriodLabels {
  static const String day = "ጠዋት";
  static const String night = "ማታ";
}

/// Holiday information with names and descriptions in multiple languages
class HolidayInfo {
  final String key;
  final Map<String, String> name;
  final Map<String, String> description;

  const HolidayInfo({
    required this.key,
    required this.name,
    required this.description,
  });
}

/// Static holiday information
class Holidays {
  static const enkutatash = HolidayInfo(
    key: 'enkutatash',
    name: {'amharic': 'እንቁጣጣሽ', 'english': 'Ethiopian New Year (Enkutatash)'},
    description: {
      'amharic': 'የኢትዮጵያ አዲስ ዓመት መጀመሪያ፤ የዝናብ ወቅት ማብቃቱን እና ዳግም መታደስን ያመለክታል።',
      'english':
          'Marks the start of the Ethiopian year; symbolizes renewal and the end of the rainy season.',
    },
  );

  static const meskel = HolidayInfo(
    key: 'meskel',
    name: {'amharic': 'መስቀል', 'english': 'Finding of the True Cross (Meskel)'},
    description: {
      'amharic': 'በ4ኛው መቶ ክፍለ ዘመን በንግሥት እሌኒ አማካኝነት የጌታችን መስቀል መገኘቱን ያከብራል።',
      'english':
          'Commemorates the discovery of the True Cross by Empress Helena in the 4th century.',
    },
  );

  static const beherbehereseb = HolidayInfo(
    key: 'beherbehereseb',
    name: {
      'amharic': 'የብሔር ብሔረሰቦች ቀን',
      'english': "Nations, Nationalities, and Peoples' Day",
    },
    description: {
      'amharic':
          'የኢትዮጵያ ብሔር ብሔረሰቦችን ልዩነት የሚያከብር፣ እኩል መብታቸውን የሚያረጋግጥ እና በባህልና ቋንቋ አንድነትን የሚያጠናክር በዓል ነው።',
      'english':
          "Acknowledges and celebrates the diversity of Ethiopia's ethnic groups, affirming their equal rights and fostering unity.",
    },
  );

  static const gena = HolidayInfo(
    key: 'gena',
    name: {'amharic': 'ገና', 'english': 'Ethiopian Christmas (Genna)'},
    description: {
      'amharic': 'የኢየሱስ ክርስቶስን ልደት የሚያከብር የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተ ክርስቲያን በዓል።',
      'english':
          'Ethiopian Orthodox Christmas celebrating the birth of Jesus Christ.',
    },
  );

  static const timket = HolidayInfo(
    key: 'timket',
    name: {'amharic': 'ጥምቀት', 'english': 'Ethiopian Epiphany (Timket)'},
    description: {
      'amharic': 'የኢየሱስ ክርስቶስን በዮርዳኖስ ወንዝ መጠመቁን ያከብራል።',
      'english': 'Commemorates the baptism of Jesus in the Jordan River.',
    },
  );

  static const martyrsDay = HolidayInfo(
    key: 'martyrsDay',
    name: {'amharic': 'የሰማዕታት ቀን', 'english': "Martyrs' Day"},
    description: {
      'amharic': 'ለኢትዮጵያ ነፃነትና ክብር ሕይወታቸውን የሠዉ ሰማዕታትን ያስባል።',
      'english':
          "Honors those who sacrificed their lives for Ethiopia's freedom and independence.",
    },
  );

  static const adwa = HolidayInfo(
    key: 'adwa',
    name: {'amharic': 'የአድዋ ድል በዓል', 'english': 'Victory of Adwa'},
    description: {
      'amharic': 'በ1896 ዓ.ም. ኢትዮጵያ በጣሊያን ቅኝ ገዥዎች ላይ የተቀዳጀችውን ድል ያከብራል።',
      'english':
          "Celebrates Ethiopia's victory over Italian colonizers in 1896.",
    },
  );

  static const labour = HolidayInfo(
    key: 'labour',
    name: {'amharic': 'የሰራተኞች ቀን', 'english': 'International Labour Day'},
    description: {
      'amharic': 'ዓለም አቀፍ የሠራተኞችና የሥራ መብቶች ቀን ነው።',
      'english': 'A global celebration of workers and labor rights.',
    },
  );

  static const patriots = HolidayInfo(
    key: 'patriots',
    name: {'amharic': 'የአርበኞች ቀን', 'english': "Patriots' Victory Day"},
    description: {
      'amharic': 'የጣሊያን ወረራን የተቋቋሙ ኢትዮጵያውያን አርበኞችን ድል ያስባል።',
      'english':
          'Honors Ethiopian resistance fighters who defeated Italian occupation.',
    },
  );

  static const nineveh = HolidayInfo(
    key: 'nineveh',
    name: {'amharic': 'ጾመ ነነዌ', 'english': 'Fast of Nineveh'},
    description: {
      'amharic': 'የነነዌ ሰዎች ንስሐ መግባታቸውን የሚያስታውስ የሦስት ቀን ጾም ነው።',
      'english':
          'A three-day fast commemorating the repentance of the people of Nineveh.',
    },
  );

  static const abiyTsome = HolidayInfo(
    key: 'abiyTsome',
    name: {'amharic': 'ዐቢይ ጾም', 'english': 'Great Lent'},
    description: {
      'amharic': 'ከፋሲካ በፊት የሚጾም የ55 ቀናት የጾም ወቅት ነው።',
      'english': 'The Great Lent, a 55-day fasting period before Easter.',
    },
  );

  static const debreZeit = HolidayInfo(
    key: 'debreZeit',
    name: {'amharic': 'ደብረ ዘይት', 'english': 'Mid-Lent Sunday'},
    description: {
      'amharic': 'ኢየሱስ በደብረ ዘይት ተራራ ያስተማረውን ትምህርት የሚያስታውስ የዐቢይ ጾም አጋማሽ እሑድ።',
      'english':
          "Mid-Lent Sunday, commemorating Jesus's sermon on the Mount of Olives.",
    },
  );

  static const hosanna = HolidayInfo(
    key: 'hosanna',
    name: {'amharic': 'ሆሳዕና', 'english': 'Palm Sunday'},
    description: {
      'amharic': 'ኢየሱስ በክብር ወደ ኢየሩሳሌም መግባቱን የሚያስታውስ በዓል።',
      'english':
          "Palm Sunday, commemorating Jesus's triumphal entry into Jerusalem.",
    },
  );

  static const siklet = HolidayInfo(
    key: 'siklet',
    name: {'amharic': 'ስቅለት', 'english': 'Good Friday'},
    description: {
      'amharic': 'የኢየሱስ ክርስቶስን ስቅለት የሚያስታውስ ነው።',
      'english': 'Marks the crucifixion of Jesus Christ.',
    },
  );

  static const fasika = HolidayInfo(
    key: 'fasika',
    name: {'amharic': 'ፋሲካ', 'english': 'Ethiopian Easter'},
    description: {
      'amharic':
          'የኢየሱስ ክርስቶስን ከሙታን መነሣት ያከብራል። በኢትዮጵያ ውስጥ ካሉ ክርስቲያናዊ በዓላት አንዱና ዋነኛው ነው።',
      'english':
          'Celebrates the resurrection of Jesus Christ. One of the most important Christian holidays in Ethiopia.',
    },
  );

  static const rikbeKahnat = HolidayInfo(
    key: 'rikbeKahnat',
    name: {'amharic': 'ርክበ ካህናት', 'english': 'Meeting of the Priests'},
    description: {
      'amharic': 'ከፋሲካ 24 ቀናት በኋላ የሚከበር የካህናት መሰባሰብ በዓል ነው።',
      'english': 'The Meeting of the Priests, 24 days after Easter.',
    },
  );

  static const erget = HolidayInfo(
    key: 'erget',
    name: {'amharic': 'ዕርገት', 'english': 'Ascension'},
    description: {
      'amharic': 'ከፋሲካ 40 ቀናት በኋላ ኢየሱስ ወደ ሰማይ ማረጉን ያከብራል።',
      'english': 'The Ascension of Jesus into heaven, 40 days after Easter.',
    },
  );

  static const paraclete = HolidayInfo(
    key: 'paraclete',
    name: {'amharic': 'ጰራቅሊጦስ', 'english': 'Pentecost'},
    description: {
      'amharic': 'መንፈስ ቅዱስ በሐዋርያት ላይ መውረዱን የሚያከብር በዓል፣ ከፋሲካ 50 ቀናት በኋላ።',
      'english':
          'Pentecost, celebrating the descent of the Holy Spirit upon the Apostles, 50 days after Easter.',
    },
  );

  static const tsomeHawaryat = HolidayInfo(
    key: 'tsomeHawaryat',
    name: {'amharic': 'ጾመ ሐዋርያት', 'english': "Apostles' Fast"},
    description: {
      'amharic': 'ከጰራቅሊጦስ ማግስት የሚጀምር የሐዋርያት ጾም ነው።',
      'english':
          'The Fast of the Apostles, which begins the day after Pentecost.',
    },
  );

  static const tsomeDihnet = HolidayInfo(
    key: 'tsomeDihnet',
    name: {'amharic': 'ጾመ ድኅነት', 'english': 'Fast of Salvation'},
    description: {
      'amharic': 'በየሳምንቱ ረቡዕ እና ዓርብ የሚጾም የድኅነት ጾም ነው።',
      'english': 'The Fast of Salvation, observed on Wednesdays and Fridays.',
    },
  );

  static const eidFitr = HolidayInfo(
    key: 'eidFitr',
    name: {'amharic': 'ዒድ አል ፈጥር', 'english': 'Eid al-Fitr'},
    description: {
      'amharic': 'የረመዳን ጾም ወር መገባደድን የሚያመለክት በዓል።',
      'english': 'Marks the end of Ramadan, the month of fasting for Muslims.',
    },
  );

  static const eidAdha = HolidayInfo(
    key: 'eidAdha',
    name: {'amharic': 'ዒድ አል አድሐ', 'english': 'Eid al-Adha'},
    description: {
      'amharic': 'ኢድ አል-አድሃ (የአረፋ በዓል) ከታላቁ የሐጅ ጉዞ ማጠናቀቂያ በኋላ የሚከበርና ነቢዩ ኢብራሂም (አብርሃም) ልጃቸውን እስማኤልን ለመሰዋት ያሳዩትን ታማኝነት እና ተገዢነት የሚዘከርበት ትልቅ የእስልምና በዓል ነው።',
      'english':
          "Commemorates Abraham's willingness to sacrifice his son as an act of obedience to God.",
    },
  );

  static const moulid = HolidayInfo(
    key: 'moulid',
    name: {'amharic': 'መውሊድ', 'english': 'Birth of the Prophet'},
    description: {
      'amharic': 'የነቢዩ ሙሐመድን የልደት በዓል ያከብራል።',
      'english': 'Celebrates the birthday of the Prophet Mohammed.',
    },
  );

  static const jummah = HolidayInfo(
    key: 'jummah',
    name: {'amharic': 'ጁምዓ', 'english': 'Jummah'},
    description: {
      'amharic': 'ሳምንታዊ የሙስሊሞች የጋራ ስግደት።',
      'english': 'The weekly Muslim congregational prayer.',
    },
  );

  /// Get all holiday keys
  static List<String> get allKeys => [
    'enkutatash',
    'meskel',
    'beherbehereseb',
    'gena',
    'timket',
    'martyrsDay',
    'adwa',
    'labour',
    'patriots',
    'nineveh',
    'abiyTsome',
    'debreZeit',
    'hosanna',
    'siklet',
    'fasika',
    'rikbeKahnat',
    'erget',
    'paraclete',
    'tsomeHawaryat',
    'tsomeDihnet',
    'eidFitr',
    'eidAdha',
    'moulid',
    'jummah',
  ];

  /// Get holiday info by key
  static Map<String, dynamic>? getHolidayInfo(String key) {
    switch (key) {
      case 'enkutatash':
        return {'name': enkutatash.name, 'description': enkutatash.description};
      case 'meskel':
        return {'name': meskel.name, 'description': meskel.description};
      case 'beherbehereseb':
        return {
          'name': beherbehereseb.name,
          'description': beherbehereseb.description,
        };
      case 'gena':
        return {'name': gena.name, 'description': gena.description};
      case 'timket':
        return {'name': timket.name, 'description': timket.description};
      case 'martyrsDay':
        return {'name': martyrsDay.name, 'description': martyrsDay.description};
      case 'adwa':
        return {'name': adwa.name, 'description': adwa.description};
      case 'labour':
        return {'name': labour.name, 'description': labour.description};
      case 'patriots':
        return {'name': patriots.name, 'description': patriots.description};
      case 'nineveh':
        return {'name': nineveh.name, 'description': nineveh.description};
      case 'abiyTsome':
        return {'name': abiyTsome.name, 'description': abiyTsome.description};
      case 'debreZeit':
        return {'name': debreZeit.name, 'description': debreZeit.description};
      case 'hosanna':
        return {'name': hosanna.name, 'description': hosanna.description};
      case 'siklet':
        return {'name': siklet.name, 'description': siklet.description};
      case 'fasika':
        return {'name': fasika.name, 'description': fasika.description};
      case 'rikbeKahnat':
        return {
          'name': rikbeKahnat.name,
          'description': rikbeKahnat.description,
        };
      case 'erget':
        return {'name': erget.name, 'description': erget.description};
      case 'paraclete':
        return {'name': paraclete.name, 'description': paraclete.description};
      case 'tsomeHawaryat':
        return {
          'name': tsomeHawaryat.name,
          'description': tsomeHawaryat.description,
        };
      case 'tsomeDihnet':
        return {
          'name': tsomeDihnet.name,
          'description': tsomeDihnet.description,
        };
      case 'eidFitr':
        return {'name': eidFitr.name, 'description': eidFitr.description};
      case 'eidAdha':
        return {'name': eidAdha.name, 'description': eidAdha.description};
      case 'moulid':
        return {'name': moulid.name, 'description': moulid.description};
      case 'jummah':
        return {'name': jummah.name, 'description': jummah.description};
      default:
        return null;
    }
  }
}

/// Evangelist names for Bahire Hasab calculations
class EvangelistNames {
  static const Map<int, String> english = {
    1: "Matthew",
    2: "Mark",
    3: "Luke",
    0: "John",
  };

  static const Map<int, String> amharic = {
    1: "ማቴዎስ",
    2: "ማርቆስ",
    3: "ሉቃስ",
    0: "ዮሐንስ",
  };
}

/// Tewsak mapping for movable holidays
class TewsakMap {
  static const Map<String, int> english = {
    'Sunday': 7,
    'Monday': 6,
    'Tuesday': 5,
    'Wednesday': 4,
    'Thursday': 3,
    'Friday': 2,
    'Saturday': 8,
  };
}

/// Movable holiday tewsak values
class MovableHolidayTewsak {
  static const int nineveh = 0;
  static const int abiyTsome = 14;
  static const int debreZeit = 41;
  static const int hosanna = 62;
  static const int siklet = 67;
  static const int tinsaye = 69;
  static const int rikbeKahnat = 93;
  static const int erget = 108;
  static const int paraclete = 118;
  static const int tsomeHawaryat = 119;
  static const int tsomeDihenet = 121;
}

/// Movable holiday tags
class MovableHolidays {
  static const Map<String, List<String>> tags = {
    'nineveh': [HolidayTags.religious, HolidayTags.christian],
    'abiyTsome': [HolidayTags.religious, HolidayTags.christian],
    'debreZeit': [HolidayTags.religious, HolidayTags.christian],
    'hosanna': [HolidayTags.religious, HolidayTags.christian],
    'siklet': [
      HolidayTags.religious,
      HolidayTags.christian,
      HolidayTags.public,
    ],
    'fasika': [
      HolidayTags.public,
      HolidayTags.religious,
      HolidayTags.christian,
    ],
    'rikbeKahnat': [HolidayTags.religious, HolidayTags.christian],
    'erget': [HolidayTags.religious, HolidayTags.christian],
    'paraclete': [HolidayTags.religious, HolidayTags.christian],
    'tsomeHawaryat': [HolidayTags.religious, HolidayTags.christian],
    'tsomeDihenet': [HolidayTags.religious, HolidayTags.christian],
    'eidFitr': [HolidayTags.public, HolidayTags.religious, HolidayTags.muslim],
    'eidAdha': [HolidayTags.public, HolidayTags.religious, HolidayTags.muslim],
    'moulid': [HolidayTags.public, HolidayTags.religious, HolidayTags.muslim],
  };
}

/// Fasting keys for canonical fasting periods
class FastingKeys {
  static const String abiyTsome = 'ABIY_TSOME';
  static const String tsomeHawaryat = 'TSOME_HAWARYAT';
  static const String tsomeNebiyat = 'TSOME_NEBIYAT';
  static const String nineveh = 'NINEVEH';
  static const String filseta = 'FILSETA';
  static const String ramadan = 'RAMADAN';
  static const String tsomeDihenet = 'TSOME_DIHENET';
}

/// Fasting information with names and descriptions
class FastingInfo {
  final String key;
  final Map<String, String> name;
  final Map<String, String> description;
  final List<String> tags;

  const FastingInfo({
    required this.key,
    required this.name,
    required this.description,
    required this.tags,
  });
}

/// Static fasting information
class Fasting {
  static const abiyTsome = FastingInfo(
    key: 'ABIY_TSOME',
    name: {'amharic': 'ዐቢይ ጾም (ሁዳዴ)', 'english': 'Great Lent (Abiy Tsome)'},
    description: {
      'amharic': 'ከፋሲካ በፊት የሚጾም 55 ቀናት የጾም ወቅት ነው።',
      'english':
          'A 55-day fasting season observed before Easter in the Ethiopian Orthodox Church.',
    },
    tags: [HolidayTags.religious, HolidayTags.christian],
  );

  static const nineveh = FastingInfo(
    key: 'NINEVEH',
    name: {'amharic': 'ጾመ ነነዌ', 'english': 'Fast of Nineveh'},
    description: {
      'amharic':
          'የነነዌ ሰዎች ለሰሩት ሐጢያት የእግዚአብሔርን ምህረትና ይቅርታ ለመጠየቅ የፆሙትን ለማስታወስ ነው።',
      'english':
          'A three-day fast commemorating the repentance of the people of Nineveh.',
    },
    tags: [HolidayTags.religious, HolidayTags.christian],
  );

  static const tsomeHawaryat = FastingInfo(
    key: 'TSOME_HAWARYAT',
    name: {'amharic': 'ጾመ ሐዋርያት', 'english': "Apostles' Fast (Tsome Hawaryat)"},
    description: {
      'amharic':
          'ክርስቶስ ከሙታን ተለይቶ ከተነሳ በሃላ ቅዱሳን ሀዋርያት ሰማያዊ ተልእኮ ስለተሰማቸው ከ50ቀን በሃላ በበአለ ጰራቅሊጦስ ማግስት መፆም ጀመሩ።',
      'english':
          'Begins after Pentecost and lasts until Hamle 4 in the Ethiopian calendar.',
    },
    tags: [HolidayTags.religious, HolidayTags.christian],
  );

  static const tsomeNebiyat = FastingInfo(
    key: 'TSOME_NEBIYAT',
    name: {
      'amharic': 'የገና-ፆም (ጾመ ነቢያት)',
      'english': 'Fast of the Prophets (Tsome Nebiyat)',
    },
    description: {
      'amharic': 'ከህዳር 15 እስከ ታሕሳስ 28 ድረስ የሚጠብቅ የቋሚ ጾም ነው።',
      'english': 'A fixed fast observed from Hidar 15 to Tahsas 28.',
    },
    tags: [HolidayTags.religious, HolidayTags.christian],
  );

  static const filseta = FastingInfo(
    key: 'FILSETA',
    name: {'amharic': 'ፍልሰታ', 'english': 'Filseta'},
    description: {
      'amharic':
          'ፆመ ፍልሰታ /ከነሐሴ 1 እስከ ነሐሴ 14 ቀን/ የእመቤታችን ዕረፍት፣ ትንሣኤና ዕርገቷ የሚታሰብበት ወቅት ነው፡፡',
      'english':
          'A fixed 14-day fast (Nehase 1–14) commemorating the Dormition, Resurrection, and Assumption of the Virgin Mary; a season of prayer and intercession.',
    },
    tags: [HolidayTags.religious, HolidayTags.christian],
  );

  static const ramadan = FastingInfo(
    key: 'RAMADAN',
    name: {'amharic': 'ረመዳን', 'english': 'Ramadan'},
    description: {
      'amharic': 'ረመዳን በሂጅራ አቆጣጠር ዘጠነኛው ወር እና በሙስሊሞች ዘንድ የጾም፣ ጸሎት ወር ነው',
      'english':
          'The Islamic month of fasting from dawn to sunset; a time of prayer, reflection, and charity.',
    },
    tags: [HolidayTags.religious, HolidayTags.muslim],
  );

  static const tsomeDihenet = FastingInfo(
    key: 'TSOME_DIHENET',
    name: {'amharic': 'ጾመ ድኅነት', 'english': 'Fast of Salvation'},
    description: {
      'amharic': 'በየሳምንቱ ረቡዕ እና ዓርብ የሚጾም የድኅነት ጾም ነው።',
      'english': 'The Fast of Salvation, observed on Wednesdays and Fridays.',
    },
    tags: [HolidayTags.religious, HolidayTags.christian],
  );

  /// Get fasting info by key
  static Map<String, dynamic>? getFastingInfo(String key) {
    switch (key) {
      case 'ABIY_TSOME':
        return {
          'name': abiyTsome.name,
          'description': abiyTsome.description,
          'tags': abiyTsome.tags,
        };
      case 'NINEVEH':
        return {
          'name': nineveh.name,
          'description': nineveh.description,
          'tags': nineveh.tags,
        };
      case 'TSOME_HAWARYAT':
        return {
          'name': tsomeHawaryat.name,
          'description': tsomeHawaryat.description,
          'tags': tsomeHawaryat.tags,
        };
      case 'TSOME_NEBIYAT':
        return {
          'name': tsomeNebiyat.name,
          'description': tsomeNebiyat.description,
          'tags': tsomeNebiyat.tags,
        };
      case 'FILSETA':
        return {
          'name': filseta.name,
          'description': filseta.description,
          'tags': filseta.tags,
        };
      case 'RAMADAN':
        return {
          'name': ramadan.name,
          'description': ramadan.description,
          'tags': ramadan.tags,
        };
      case 'TSOME_DIHENET':
        return {
          'name': tsomeDihenet.name,
          'description': tsomeDihenet.description,
          'tags': tsomeDihenet.tags,
        };
      default:
        return null;
    }
  }
}
