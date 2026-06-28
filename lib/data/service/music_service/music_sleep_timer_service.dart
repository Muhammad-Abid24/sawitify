part of 'music_service.dart';

extension MusicSleepTimerService on MusicService {
  // ======================================================
  // START SLEEP TIMER
  // ======================================================

  Future<void> startSleepTimer(Duration duration) async {
    await cancelSleepTimer();

    _sleepDuration = duration;
    _sleepEndTime = DateTime.now().add(duration);

    _sleepTimer = Timer(duration, () async {
      try {
        if (player.playing) {
          await pause();
        }
      } catch (_) {}

      await cancelSleepTimer();
    });

    _startSleepTicker();

    notifyListeners();
  }

  // ======================================================
  // CANCEL
  // ======================================================

  Future<void> cancelSleepTimer() async {
    _sleepTimer?.cancel();
    _sleepTimer = null;

    _sleepTickerSub?.cancel();
    _sleepTickerSub = null;

    _sleepEndTime = null;
    _sleepDuration = null;

    notifyListeners();
  }

  // ======================================================
  // TICKER
  // ======================================================

  void _startSleepTicker() {
    _sleepTickerSub?.cancel();

    _sleepTickerSub = Stream.periodic(const Duration(seconds: 1), (x) => x)
        .listen((_) {
          if (_sleepEndTime == null) {
            return;
          }

          if (_sleepEndTime!.isBefore(DateTime.now())) {
            return;
          }

          notifyListeners();
        });
  }

  // ======================================================
  // FORMAT
  // ======================================================

  String get remainingSleepTimeLabel {
    final remain = remainingSleepTime;

    if (remain == Duration.zero) {
      return "00:00";
    }

    final hours = remain.inHours;
    final minutes = remain.inMinutes.remainder(60);
    final seconds = remain.inSeconds.remainder(60);

    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:"
          "${minutes.toString().padLeft(2, '0')}:"
          "${seconds.toString().padLeft(2, '0')}";
    }

    return "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }
}
