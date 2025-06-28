import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_service/audio_service.dart';


import '../constants/constants.dart';
import '../models/qari.dart';
import '../models/surah.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({
    Key? key,
    required this.qari,
    required this.index,
    required this.list,
  }) : super(key: key);

  final Qari qari;
  final int index;
  final List<Surah>? list;

  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final _player = AudioPlayer();
  bool isLoopingCurrentItem = false;
  Duration defaultDuration = const Duration(milliseconds: 1);
  int currentIndex = 0;

  @override
  void initState() {
    currentIndex = max(0, widget.index - 1); // prevents -1 index
    _loadSurah(currentIndex);
    super.initState();

    _player.playbackEventStream.listen((event) {
      print("Player state: ${event.processingState}, playing: ${_player.playing}");
    }, onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }


  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
              (position, buffered, duration) =>
              PositionData(position, buffered, duration ?? Duration.zero));

  void _loadSurah(int index) async {
    if (widget.qari.path == null || widget.qari.path!.isEmpty) {
      print("Qari path is null or empty");
      return;
    }

    if (widget.list == null || index < 0 || index >= widget.list!.length) {
      print("Invalid Surah index or list is null");
      return;
    }

    var basePath = widget.qari.path!;
    if (!basePath.endsWith('/')) basePath += '/';
    final surahNumber = (index + 1).toString().padLeft(3, '0');
    final url = '$basePath$surahNumber.mp3';

    print(" Loading audio from: $url");

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            album: 'Quran Recitation',
            title: widget.list![index].name!,
            artist: widget.qari.name ?? 'Unknown',
          ),
        ),
      );

      await _player.setVolume(1.0); // Ensure not muted
      await _player.play();         //  Start playing the correct audio
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // Surah info
              _buildSurahInfo(),
              const SizedBox(height: 30),

              // SeekBar
              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return SeekBar(
                    duration: positionData?.duration ?? defaultDuration,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition:
                    positionData?.bufferedPosition ?? Duration.zero,
                    onChanged: _player.seek,
                  );
                },
              ),
              const SizedBox(height: 10),

              // Player controls
              _buildPlayerControls(),

              const SizedBox(height: 10),

              // Upcoming Surah preview
              _buildUpcomingPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahInfo() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.2,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Constants.kPrimary,
        boxShadow: const [
          BoxShadow(blurRadius: 1, offset: Offset(0, 2), color: Colors.black12)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.list![currentIndex].name!,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Total Aya : ${widget.list![currentIndex].numberOfAyahs}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous
        IconButton(
          onPressed: () {
            if (currentIndex > 0) {
              setState(() => currentIndex--);
              _loadSurah(currentIndex);
            }
          },
          icon: Icon(
            FontAwesomeIcons.stepBackward,
            color: Colors.black,
            size: MediaQuery.of(context).size.width * 0.05,
          ),
        ),

        // Play/Pause
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            final isPlaying = state?.playing ?? false;
            final isBuffering = state?.processingState ==
                ProcessingState.loading ||
                state?.processingState == ProcessingState.buffering;

            if (isBuffering) {
              return const SpinKitRipple(
                color: Colors.black,
                duration: Duration(milliseconds: 800),
              );
            } else if (!isPlaying) {
              return _buildControlButton(
                icon: FontAwesomeIcons.play,
                onTap: _player.play,
              );
            } else {
              return _buildControlButton(
                icon: FontAwesomeIcons.pause,
                onTap: _player.pause,
              );
            }
          },
        ),

        // Next
        IconButton(
          onPressed: () {
            if (currentIndex < 113) {
              setState(() => currentIndex++);
              _loadSurah(currentIndex);
            }
          },
          icon: Icon(
            FontAwesomeIcons.stepForward,
            color: Colors.black,
            size: MediaQuery.of(context).size.width * 0.05,
          ),
        ),

        // Volume
        IconButton(
          icon: Icon(
            Icons.volume_up,
            size: MediaQuery.of(context).size.width * 0.1,
          ),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.1,
              max: 1.0,
              value: _player.volume,
              stream: _player.volumeStream,
              onChanged: _player.setVolume,
            );
          },
        ),

        // Speed
        StreamBuilder<double>(
          stream: _player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text(
              "${snapshot.data?.toStringAsFixed(1) ?? _player.speed.toStringAsFixed(1)}x",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: _player.speed,
                stream: _player.speedStream,
                onChanged: _player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Constants.kPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon,
            color: Colors.black,
            size: MediaQuery.of(context).size.width * 0.05),
      ),
    );
  }

  Widget _buildUpcomingPreview() {
    return currentIndex >= 113
        ? Container()
        : Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                spreadRadius: 0.01,
                offset: Offset(0.0, 1)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('UPCOMING SURAH',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (currentIndex + 1 < widget.list!.length)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.play_circle_fill,
                        color: Constants.kPrimary),
                    Text(
                      widget.list![currentIndex + 1].name!,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 20),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              if (currentIndex + 2 < widget.list!.length)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.play_circle_fill,
                        color: Constants.kPrimary),
                    Text(
                      widget.list![currentIndex + 2].name!,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 20),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// === Position Data Model ===
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

// === SeekBar Widget ===
class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;

  const SeekBar({
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Constants.kPrimary,
            inactiveTrackColor: Colors.grey,
            trackHeight: 5.0,
            thumbColor: Constants.kPrimary,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayColor: Colors.purple.withAlpha(32),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() => _dragValue = value);
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(widget.position),
                  style: TextStyle(color: Colors.black, fontSize: width * 0.05)),
              Text(_formatDuration(widget.duration),
                  style: TextStyle(color: Colors.black, fontSize: width * 0.05)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// === Slider Dialog ===
void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}








