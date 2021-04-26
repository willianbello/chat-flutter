import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  ChatMessage(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !mine ?
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data['senderPhotoUrl'])
              )
            )
          : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: !mine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                data['imgUrl'] != null ?
                  Image.network(data['imgUrl'], width: 230)
                    :
                  Text(data['texto'],
                    textAlign: mine ? TextAlign.end : TextAlign.start,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      fontSize: 18,
                    )
                  ),
                Text('${data["senderName"]} ${data['dateTime']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green
                  )
                )
              ],
            )
          ),
          mine ?
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: CircleAvatar(
                backgroundImage: NetworkImage(data['senderPhotoUrl'])
            )
          ) : Container(),
        ],
      ),
    );
  }
}
