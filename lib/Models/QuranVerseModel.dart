class QuranVerseModel {
  bool? success;
  String? service;
  Data? data;
  String? timestamp;
  ApiInfo? apiInfo;

  QuranVerseModel({
    this.success,
    this.service,
    this.data,
    this.timestamp,
    this.apiInfo,
  });

  QuranVerseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    service = json['service'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    timestamp = json['timestamp'];
    apiInfo = json['api_info'] != null
        ? new ApiInfo.fromJson(json['api_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['service'] = this.service;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['timestamp'] = this.timestamp;
    if (this.apiInfo != null) {
      data['api_info'] = this.apiInfo!.toJson();
    }
    return data;
  }
}

class Data {
  Surah? surah;
  Verse? verse;
  List<Audio>? audio;
  int? totalVersesInQuran;

  Data({this.surah, this.verse, this.audio, this.totalVersesInQuran});

  Data.fromJson(Map<String, dynamic> json) {
    surah = json['surah'] != null ? new Surah.fromJson(json['surah']) : null;
    verse = json['verse'] != null ? new Verse.fromJson(json['verse']) : null;
    if (json['audio'] != null) {
      audio = <Audio>[];
      json['audio'].forEach((v) {
        audio!.add(new Audio.fromJson(v));
      });
    }
    totalVersesInQuran = json['total_verses_in_quran'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.surah != null) {
      data['surah'] = this.surah!.toJson();
    }
    if (this.verse != null) {
      data['verse'] = this.verse!.toJson();
    }
    if (this.audio != null) {
      data['audio'] = this.audio!.map((v) => v.toJson()).toList();
    }
    data['total_verses_in_quran'] = this.totalVersesInQuran;
    return data;
  }
}

class Surah {
  int? number;
  String? nameArabic;
  String? nameEnglish;
  String? nameTranslation;

  Surah({this.number, this.nameArabic, this.nameEnglish, this.nameTranslation});

  Surah.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    nameArabic = json['name_arabic'];
    nameEnglish = json['name_english'];
    nameTranslation = json['name_translation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['number'] = this.number;
    data['name_arabic'] = this.nameArabic;
    data['name_english'] = this.nameEnglish;
    data['name_translation'] = this.nameTranslation;
    return data;
  }
}

class Verse {
  String? verseKey;
  int? ayah;
  String? arabic;
  String? transliteration;
  Translations? translations;

  Verse({
    this.verseKey,
    this.ayah,
    this.arabic,
    this.transliteration,
    this.translations,
  });

  Verse.fromJson(Map<String, dynamic> json) {
    verseKey = json['verse_key'];
    ayah = json['ayah'];
    arabic = json['arabic'];
    transliteration = json['transliteration'];
    translations = json['translations'] != null
        ? new Translations.fromJson(json['translations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['verse_key'] = this.verseKey;
    data['ayah'] = this.ayah;
    data['arabic'] = this.arabic;
    data['transliteration'] = this.transliteration;
    if (this.translations != null) {
      data['translations'] = this.translations!.toJson();
    }
    return data;
  }
}

class Translations {
  String? sahihInternational;
  String? pickthall;
  String? yusufAli;
  String? urdu;
  String? turkish;
  String? indonesian;
  String? french;
  String? german;
  String? bengali;
  String? spanish;
  String? malay;
  String? bosnian;

  Translations({
    this.sahihInternational,
    this.pickthall,
    this.yusufAli,
    this.urdu,
    this.turkish,
    this.indonesian,
    this.french,
    this.german,
    this.bengali,
    this.spanish,
    this.malay,
    this.bosnian,
  });

  Translations.fromJson(Map<String, dynamic> json) {
    sahihInternational = json['sahih_international'];
    pickthall = json['pickthall'];
    yusufAli = json['yusuf_ali'];
    urdu = json['urdu'];
    turkish = json['turkish'];
    indonesian = json['indonesian'];
    french = json['french'];
    german = json['german'];
    bengali = json['bengali'];
    spanish = json['spanish'];
    malay = json['malay'];
    bosnian = json['bosnian'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sahih_international'] = this.sahihInternational;
    data['pickthall'] = this.pickthall;
    data['yusuf_ali'] = this.yusufAli;
    data['urdu'] = this.urdu;
    data['turkish'] = this.turkish;
    data['indonesian'] = this.indonesian;
    data['french'] = this.french;
    data['german'] = this.german;
    data['bengali'] = this.bengali;
    data['spanish'] = this.spanish;
    data['malay'] = this.malay;
    data['bosnian'] = this.bosnian;
    return data;
  }
}

class Audio {
  int? reciterId;
  String? reciter;
  String? style;
  String? surahAudio;
  String? ayahAudio;

  Audio({
    this.reciterId,
    this.reciter,
    this.style,
    this.surahAudio,
    this.ayahAudio,
  });

  Audio.fromJson(Map<String, dynamic> json) {
    reciterId = json['reciter_id'];
    reciter = json['reciter'];
    style = json['style'];
    surahAudio = json['surah_audio'];
    ayahAudio = json['ayah_audio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reciter_id'] = this.reciterId;
    data['reciter'] = this.reciter;
    data['style'] = this.style;
    data['surah_audio'] = this.surahAudio;
    data['ayah_audio'] = this.ayahAudio;
    return data;
  }
}

class ApiInfo {
  String? sadaqahJariah;

  ApiInfo({this.sadaqahJariah});

  ApiInfo.fromJson(Map<String, dynamic> json) {
    sadaqahJariah = json['sadaqah_jariah'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sadaqah_jariah'] = this.sadaqahJariah;
    return data;
  }
}
