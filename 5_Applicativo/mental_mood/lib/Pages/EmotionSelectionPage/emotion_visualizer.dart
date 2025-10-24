import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';

class EmotionVisualizerWidget extends StatefulWidget {
  final EmozioneData? emozione;
  const EmotionVisualizerWidget({super.key, required this.emozione});

  @override
  State<EmotionVisualizerWidget> createState() => _EmotionVisualizerWidgetState();
}

class _EmotionVisualizerWidgetState extends State<EmotionVisualizerWidget> {
  @override
  Widget build(BuildContext context) {
    if(!(widget.emozione == null)){
      return Image.asset(widget.emozione!.imgPath);
    }else{
      return Image.asset("assets/images/unknown.png");
    }
  }
}
