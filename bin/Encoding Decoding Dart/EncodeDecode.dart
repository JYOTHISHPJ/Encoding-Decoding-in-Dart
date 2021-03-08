import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:core';

enum ePacketize { encode, decode }

void main(List<String> arguments) {
  List<int> data = [45, 87, 12];
  Uint8List bytes = Uint8List.fromList(data);

  print('Original: $bytes');
  Uint8List EncodedMsg = msgPacket(bytes, ePacketize.encode);

  print('Encode: $EncodedMsg');
  Uint8List DecodeMsg = msgPacket(EncodedMsg, ePacketize.decode);
  print('Decode: $DecodeMsg');
}

Uint8List msgPacket(Uint8List msg, ePacketize op) {
  if (op == ePacketize.encode) {
    var bb = BytesBuilder();
    bb.addByte(1);
    bb.addByte(msg.length);
    bb.add(msg);
    var sum = 0;
    for (var i = 0; i < msg.length; i++) {
      sum += msg[i];
    }
    sum += 1;

    bb.addByte(sum);
    return bb.toBytes();
  } else {
    if (msg.first == 1) {
      var decSum = 0;
      if (msg[1] == msg.length - 3) {
        var decodeMsgLen;

        decodeMsgLen = msg[1];

        for (var i = 0; i < decodeMsgLen; i++) {
          decSum += msg[2 + i];
        }
        decSum += 1;
        //trancate the value of decsum to uint8
        decSum &= 0xff;

        if (decSum == msg.last) {
          //packet is good
          return msg.sublist(2, msg.length - 1);
        } else {
          //packet is not good check sum does not match
          return null;
        }
      } else {
        //Length is not matching
        return null;
      }
    } else {
      //if SOH is not there
      print('SOH is not in $msg');
    }
  }
}
