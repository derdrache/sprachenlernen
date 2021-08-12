import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audioplayer_background.dart';

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class MyAudioplayer extends StatefulWidget {
  final String audioName;
  final String audioPath;

  const MyAudioplayer(this.audioName, this.audioPath);
  MyAudioplayerState createState() => MyAudioplayerState();
}

class MyAudioplayerState extends State<MyAudioplayer> {
  double _volume = 1;
  Duration _duration = Duration(minutes: 3);
  Duration _audioPosition = Duration();
  bool _playing = false;
  double _speed = 1.0;


  void initState() {
    super.initState();

    setDuration();

    audioplayerStartSetup();

    setAudioPosition();

  }

  void setDuration(){
    var audioPlayer = AudioPlayer();
    audioPlayer.setUrl(widget.audioPath, isLocal: true);
    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });
  }

  void audioplayerStartSetup(){
    AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
        params: {
          "audioPath": widget.audioPath,
          "audioName": widget.audioName,
        },
        androidStopForegroundOnPause: true
    );
  }

  void setAudioPosition(){
    AudioService.positionStream.listen((Duration position) {
      setState((){
        if (position >= _duration) {
          while (position >= _duration) {
            position = position - _duration;
          }
        }

        _audioPosition = position;
      });
    });
  }


  Widget build(BuildContext context) {
    double buttonSize = 30;
    var titleBackgroundColor = Theme.of(context).accentColor;
    var playerBackgroundColor = Theme.of(context).accentColor;

    Widget audioplayerTitleWidget() {
      return Text(
          widget.audioName.length > 30
              ? widget.audioName.substring(0, 30) +
                  "... ." +
                  widget.audioName.split(".")[1]
              : widget.audioName,
          style: TextStyle(fontSize: 18));
    }

    IconButton playButton() {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 32.0,
        padding: EdgeInsets.zero,
        onPressed: AudioService.play,
      );
    }

    IconButton pauseButton() {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 32.0,
        padding: EdgeInsets.zero,
        onPressed: AudioService.pause,
      );
    }

    Widget audioSlider() {
      return Slider(
            value: _audioPosition.inSeconds.toDouble(),
            min: 0,
            max: _duration.inSeconds.toDouble(),
            activeColor: Colors.black,
            inactiveColor: Colors.grey,
            onChanged: (newPosition){
              AudioService.seekTo(Duration(seconds: newPosition.toInt()));
            },
          );
    }

    void playbackSpeedFunction()  {
      var changeSpeed;
      _speed = double.parse((_speed).toStringAsFixed(1));

      if (_speed == 1.0) {
        changeSpeed = 0.5;
      } else if (_speed == 0.5) {
        changeSpeed = 0.7;
      } else if (_speed == 0.7) {
        changeSpeed = 0.9;
      } else if (_speed == 0.9) {
        changeSpeed = 1.0;
      }

      AudioService.setSpeed(changeSpeed);

    }

    Widget playbackSpeedButton() {
      return Container(
          width: buttonSize,
          color: playerBackgroundColor,
          child: MaterialButton(
              minWidth: 0,
              padding: EdgeInsets.all(0),
              child: Text(double.parse((_speed).toStringAsFixed(1)).toString() + "x"),
              onPressed: playbackSpeedFunction
          )
      );
    }

    Widget volumenPopupMenu() {
      return PopupMenuButton(
        offset: Offset(0, -200),
        child: MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.all(0),
            child: Icon(Icons.volume_up),
            onPressed: null
        ),
        itemBuilder: (context) {
          return [
            PopupMenuItem(child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                label: (_volume * 100).toString(),
                onChanged: (double value) {
                  setState(() {
                    _volume = value;
                  });
                  //audioPlayer.setVolume(_volume);
                  AudioService.customAction("setVolume", _volume);
                },
              );
            }))
          ];
        },
      );
    }

    Widget volumenButton() {
      return Container(
          width: buttonSize + 5,
          decoration: new BoxDecoration(
              color: playerBackgroundColor,
              borderRadius: new BorderRadius.only(
                topRight: const Radius.circular(5.0),
                bottomRight: const Radius.circular(5.0),
              )),
          child: volumenPopupMenu()
      );
    }

    Widget audioControllContainer() {
      return Container(
          height: 30,
          child: Row(children: [
            _playing==true? pauseButton() : playButton(),
            Expanded(child: audioSlider()),
            playbackSpeedButton(), //Geschwindigkeit einstellen - dropdown mit 0,5 bis 1?
            volumenButton(), //Lautstärke regeln
          ])
      );
    }


    return Container(
        decoration: BoxDecoration(
            color: titleBackgroundColor,
            border: Border(
              top: BorderSide(
                width: 1,
                color: Colors.black
              ),
                bottom: BorderSide(
                    width: 1,
                    color: Colors.black
                )
            )
        ),
        child: StreamBuilder<PlaybackState>(
          stream: AudioService.playbackStateStream,
          builder: (context, snapshot) {
            _playing = snapshot.data?.playing ?? false;
            _speed = snapshot.data?.speed ?? 0;
            return Column(children: [
              audioplayerTitleWidget(),
              SizedBox(height: 10),
              audioControllContainer(),
            ]);
        })
    );
  }
}




