import 'package:dio/dio.dart';

class PlayerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',

      'Accept-Encoding': 'gzip',

      'Accept-Language': 'en-US,en;q=0.5',

      'Content-Type': 'application/json',

      'Origin': 'https://www.youtube.com',

      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.18 Safari/537.36',

      'X-Goog-Visitor-Id':
          'CgtqUThRTURlYnhwVSiEqsPRBjIKCgJJRBIEGgAgLWLfAgrcAjE5LllUPW1ia1RZX3lqNUpVLXZSTzdqSHJ4aVZYaFlscDJCaUtVbVIwSDJHZVBwQnVFOGMza1lCd3hrNG41Y0hDVUhPd2xsYmk5NFhqWGZQZkJtRFBpeWNZelBrX3ljMzB6UFN6MFRfeFQyZkFsSnV5NF95Mkg3MW1KVy0wYV9zXzVzRzNzLVBBcURhcDVLcVU2M0JlaE5RQ3lvbWdMVFFLUmNzdjBFVjV2REJPaF9wVkZtSndRRFVKYkd0MkJlSlNnYXVNNVF6UkQwZWduY2Z0NUFRX190N3FrWmpNb0hSYjVuYl82bXNLQkYyYUpOMWJCdWdZMTBUU0VSQ3NodUo1dkg0WUNtMmowbm5XTlgtRzdzRUJOdE80UDBwd1poTHJrWnJ0TmRXRmJjTk96YXMzam51OGJ1UjNVZWstNGg2RWgtVndLTU12dFBlZ1RtLWtnd2dNTE9FZ09lQQ%3D%3D',

      'X-Youtube-Client-Name': 'ANDROID_VR',

      'X-Youtube-Client-Version': '1.56.21',

      'Cookie':
          '__Secure-YNID=19.YT=mbkTY_yj5JU-vRO7jHrxiVXhYlp2BiKUmR0H2GePpBuE8c3kYBwxk4n5cHCUHOwllbi94XjXfPfBmDPiycYzPk_yc30zPSz0T_xT2fAlJuy4_y2H71mJW-0a_s_5sG3s-PAqDap5KqU63BehNQCyomgLTQKRcsv0EV5vDBOh_pVFmJwQDUJbGt2BeJSgauM5QzRD0egncft5AQ__t7qkZjMoHRb5nb_6msKBF2aJN1bBugY10TSERCshuJ5vH4YCm2j0nnWNX-G7sEBNtO4P0pwZhLrkZrtNdWFbcNOzas3jnu8buR3Uek-4h6Eh-VwKMMvtPegTm-kgwgMLOEgOeA; YSC=WaQXe8fD0c8; __Secure-ROLLOUT_TOKEN=CLLi7NO06pLVUxCLpo3z-YqVAxiLpo3z-YqVAw%3D%3D; __Secure-YEC=; VISITOR_INFO1_LIVE=jQ8QMDebxpU; VISITOR_PRIVACY_METADATA=CgJJRBIEGgAgLQ%3D%3D; PREF=hl=en; SOCS=CAI; GPS=1',
    });

    super.onRequest(options, handler);
  }
}
