/// Idiomas soportados por MovyPuebla.
enum AppLanguage {
  es, // Español
  nah, // Náhuatl
  totonaco, // Totonaco
  mazateco, // Mazateco
  popoloca, // Popoloca
  mixteco, // Mixteco
  otomi, // Otomí
  tepehua, // Tepehua
}

extension AppLanguageLabel on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.es:
        return 'Español';
      case AppLanguage.nah:
        return 'Náhuatl';
      case AppLanguage.totonaco:
        return 'Totonaco';
      case AppLanguage.mazateco:
        return 'Mazateco';
      case AppLanguage.popoloca:
        return 'Popoloca';
      case AppLanguage.mixteco:
        return 'Mixteco';
      case AppLanguage.otomi:
        return 'Otomí';
      case AppLanguage.tepehua:
        return 'Tepehua';
    }
  }
}

/// Traducciones de la app. Las lenguas indígenas usan traducciones
/// aproximadas/fonéticas — deben ser revisadas por hablantes nativos.
class AppStrings {
  static const Map<AppLanguage, Map<String, String>> _strings = {
    AppLanguage.es: _es,
    AppLanguage.nah: _nah,
    AppLanguage.totonaco: _totonaco,
    AppLanguage.mazateco: _mazateco,
    AppLanguage.popoloca: _popoloca,
    AppLanguage.mixteco: _mixteco,
    AppLanguage.otomi: _otomi,
    AppLanguage.tepehua: _tepehua,
  };

  static String get(AppLanguage lang, String key) {
    return _strings[lang]?[key] ?? _strings[AppLanguage.es]?[key] ?? key;
  }

  // ─── Español (base) ───
  static const _es = {
    'appName': 'MovyPuebla',
    'slogan': 'Por amor a Puebla',
    'login': 'Iniciar sesión',
    'register': 'Crear cuenta',
    'email': 'Correo',
    'password': 'Contraseña',
    'fullName': 'Nombre completo',
    'enter': 'Entrar',
    'registerMe': 'Registrarme',
    'alreadyHaveAccount': 'Ya tengo cuenta',
    'createAccount': 'Crear cuenta',
    'origin': 'Origen',
    'destination': 'Destino',
    'searchRoute': 'Buscar ruta',
    'noRoutes': 'Ingresa origen y destino, luego busca rutas.',
    'normalFare': 'Normal',
    'disability': 'Personas con discapacidad',
    'free': 'Gratis',
    'students': 'Estudiantes',
    'seniors': 'Adultos mayores',
    'nightFare': 'Feria (nocturno)',
    'mainStops': 'Paradas principales',
    'fares': 'Tarifas',
    'emergency': 'Emergencia',
    'call911': 'Llamar al 911',
    'municipalPolice': 'Policía Municipal Puebla',
    'emergencySms': 'SMS de emergencia',
    'selectHelp': 'Selecciona una opción de ayuda',
    'urban': 'Urbano',
    'howUseApp': '¿Cómo usarás MovyPuebla?',
    'citizen': 'Ciudadano',
    'driver': 'Transportista',
    'searchRoutes': 'Buscar rutas',
    'operateRoute': 'Operar ruta',
    'language': 'Idioma',
    'boardAt': 'Sube en',
    'alightAt': 'Baja en',
    'distance': 'Distancia',
    'time': 'Tiempo',
    'stops': 'paradas',
    'code': 'Código',
    'noCoordinates': 'Sin coordenadas',
    'requiredField': 'Campo obligatorio',
    'min6Chars': 'Mínimo 6 caracteres',
  };

  // ─── Náhuatl ───
  static const _nah = {
    'appName': 'MovyPuebla',
    'slogan': 'Ica tlazohtlaliztli Puebla',
    'login': 'Xicalaqui',
    'register': 'Xicchihua mocuenta',
    'email': 'Correo',
    'password': 'Tlaichtacatohtli',
    'fullName': 'Motocatzin',
    'enter': 'Xicalaqui',
    'registerMe': 'Niquinscribiroa',
    'alreadyHaveAccount': 'Ya nicpia nocuenta',
    'createAccount': 'Xicchihua mocuenta',
    'origin': 'Campa tipehua',
    'destination': 'Campa tiyas',
    'searchRoute': 'Xictemo ohtli',
    'noRoutes': 'Xictlali campa tipehua ihuan campa tiyas.',
    'normalFare': 'Tlaxtlahualli',
    'disability': 'Aquihque quipiya cocoxcayotl',
    'free': 'Ahtle',
    'students': 'Tlamachtiltin',
    'seniors': 'Huehuetque',
    'nightFare': 'Yohualli tlaxtlahualli',
    'mainStops': 'Hueyi tlanecuiloyan',
    'fares': 'Tlaxtlahualli',
    'emergency': 'Tepalehuiloni',
    'call911': 'Xitlahtlani 911',
    'selectHelp': 'Xicpehpena ce palehuiliztli',
    'urban': 'Altepetl',
    'citizen': 'Altepemaitl',
    'driver': 'Tepozmalacatiani',
    'searchRoutes': 'Xictemo ohtli',
    'language': 'Tlahtolli',
    'boardAt': 'Xitleco ipan',
    'alightAt': 'Xitemo ipan',
  };

  // ─── Totonaco ───
  static const _totonaco = {
    'appName': 'MovyPuebla',
    'slogan': 'Xapánat Puebla',
    'login': 'Katanu',
    'register': 'Kamakxtumit',
    'origin': 'Anta tachuna',
    'destination': 'Anta tapina',
    'searchRoute': 'Kasaksa tiji',
    'emergency': 'Kamalakpali',
    'citizen': 'Stakna',
    'driver': 'Tukuchunán',
    'language': 'Tachiwin',
  };

  // ─── Mazateco ───
  static const _mazateco = {
    'appName': 'MovyPuebla',
    'slogan': 'Xki tjín Puebla',
    'login': 'Kasén',
    'register': 'Kitsja nájin',
    'origin': 'Ñá kitsja',
    'destination': 'Ñá kjoa',
    'searchRoute': 'Nanguí ndi',
    'emergency': 'Kjoa chinga',
    'citizen': 'Xi̱ta̱',
    'driver': 'Xi̱ta̱ tsanga',
    'language': 'Én',
  };

  // ─── Popoloca ───
  static const _popoloca = {
    'appName': 'MovyPuebla',
    'slogan': 'Nda̱ kúni Puebla',
    'login': 'Kúhu',
    'register': 'Ndakani',
    'origin': 'Nuu kíxáa',
    'destination': 'Nuu kúhu',
    'searchRoute': 'Nanduku ichi',
    'emergency': 'Chiñu xéen',
    'citizen': 'Ñayivi',
    'driver': 'Ñayivi xíka',
    'language': 'Tu̱hun',
  };

  // ─── Mixteco ───
  static const _mixteco = {
    'appName': 'MovyPuebla',
    'slogan': 'Siki kúni Puebla',
    'login': 'Kívi',
    'register': 'Ndakani',
    'origin': 'Nuu kíxáa',
    'destination': 'Nuu kúhu',
    'searchRoute': 'Nanduku ichi',
    'emergency': 'Chiñu xéen',
    'citizen': 'Ñayivi',
    'driver': 'Ñayivi xíka',
    'language': 'Tu̱hun',
  };

  // ─── Otomí ───
  static const _otomi = {
    'appName': 'MovyPuebla',
    'slogan': 'Ko ar mhöte Puebla',
    'login': 'Cudi',
    'register': 'Hoki ar cuenta',
    'origin': 'Handi pefi',
    'destination': 'Handi ma',
    'searchRoute': 'Honi ar ñu',
    'emergency': 'Ar mfeni',
    'citizen': 'Ar jä\'i',
    'driver': 'Ar mefi',
    'language': 'Ar hñähñu',
  };

  // ─── Tepehua ───
  static const _tepehua = {
    'appName': 'MovyPuebla',
    'slogan': 'Lakgalhman Puebla',
    'login': 'Tamín',
    'register': 'Makgtay',
    'origin': 'Antá tamín',
    'destination': 'Antá an',
    'searchRoute': 'Putzay tiji',
    'emergency': 'Lakgapastakni',
    'citizen': 'Chixku',
    'driver': 'Chixku tukuchunán',
    'language': 'Tachiwin',
  };
}
