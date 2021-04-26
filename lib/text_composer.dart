import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  final Function({String text, File imgFile }) sendMessage;

  TextComposer(this.sendMessage);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _messageController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: showCameraOrGallery
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration.collapsed(
                hintText: 'Envia uma Mensagem'
              ),
              onChanged: (text){
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text){
                widget.sendMessage(text: text);
                reset();
              },
            )
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing ? (){
              widget.sendMessage(text: _messageController.text);
              reset();
            } : null
          )
        ],
      ),
    );
  }

  void reset() {
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  void showCameraOrGallery() {
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text('Obter Imagem'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final PickedFile imgFile = await picker.getImage(source: ImageSource.camera);

                if(imgFile?.path == null) return;

                final image = File(imgFile.path);
                widget.sendMessage(imgFile: image);
              },
              child: Text('Camera'),
            ),
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final PickedFile imgFile = await picker.getImage(source: ImageSource.gallery);
                  if(imgFile?.path == null) return;

                  final image = File(imgFile.path);
                  widget.sendMessage(imgFile: image);
                },
                child: Text('Galeria'),
            ),
          ],
        );
      }
    );
  }
}
