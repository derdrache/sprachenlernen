import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_close',
  label: 'Stop',
  action: MediaAction.stop,
);


class AudioPlayerTask extends BackgroundAudioTask{
  var _audioPlayer = new AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {

    AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.connecting,
    );

    await _audioPlayer.setFilePath(params!["audioPath"]);
    _audioPlayer.setLoopMode(LoopMode.one);

    return super.onStart(params);
  }

  @override
  Future<void> onPlay() async{
    AudioServiceBackground.setState(
        controls: [MediaControl.pause, MediaControl.stop],
        playing: true,
        processingState: AudioProcessingState.ready);

    await _audioPlayer.play();
  }

  @override
  Future<void> onStop() async{
    AudioServiceBackground.setState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.stopped
    );

    _audioPlayer.stop();

    await super.onStop();
  }

  @override
  Future<void> onPause() async {
    AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.ready
    );
    await _audioPlayer.pause();
  }

  @override
  Future<void> onSetSpeed(double speed) async {
    AudioServiceBackground.setState(
      speed: speed,
    );

    await _audioPlayer.setSpeed(speed);
  }

  @override
  Future<void> onSeekTo(Duration position) async{
    AudioServiceBackground.setState(position: position);

    await _audioPlayer.seek(position);
  }

  @override
  Future onCustomAction(String name, arguments) {
    switch (name) {
      case 'setVolume':
        _audioPlayer.setVolume(arguments);
        break;
    }
    return _audioPlayer.setVolume(arguments);
  }
}

