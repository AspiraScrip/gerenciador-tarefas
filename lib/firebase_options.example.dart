// EXEMPLO. Rode "flutterfire configure" para gerar o lib/firebase_options.dart real.
// Este arquivo não é usado pelo app.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'SUA_API_KEY',
      appId: 'SEU_APP_ID',
      messagingSenderId: 'SEU_SENDER_ID',
      projectId: 'SEU_PROJECT_ID',
      databaseURL: 'https://SEU_PROJECT_ID-default-rtdb.firebaseio.com',
      storageBucket: 'SEU_PROJECT_ID.appspot.com',
    );
  }
}
