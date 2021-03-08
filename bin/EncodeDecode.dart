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
  /*var bb = BytesBuilder();
  bb.addByte(45);
  bb.addByte(1);
  bb.addByte(2);
  bb.addByte(9);
  print(bb.toBytes());
  Uint8List DecodeMsg = msgPacket(bb.toBytes(), ePacketize.decode);
*/
  Uint8List DecodeMsg = msgPacket(EncodedMsg, ePacketize.decode);
  print('Decode: $DecodeMsg');
}

Uint8List msgPacket(Uint8List msg, ePacketize op) {
  if (op == ePacketize.encode) {
    var bb = BytesBuilder();
    //bb.addByte(79);
    //bb.addByte(59); //noise for test
    bb.addByte(1);
    bb.addByte(msg.length);
    bb.add(msg);
    var sum = 0;
    for (var i = 0; i < msg.length; i++) {
      sum += msg[i];
    }

    sum ^= 0xFF;
    sum += 1;

    bb.addByte(sum);
    // bb.addByte(99); //noise
    // bb.addByte(199);

    return bb.toBytes();
  } else {
    if (msg.contains(1)) {
      //Give the index of SOH
      var SOHindex = msg.indexOf(1);
      var decSum = 0;
      //print('Index of SOH: $SOHindex');
      //Remove the noise before SOH
      msg = msg.sublist(SOHindex, msg.length);
      print(msg);
//checking msg lenth is greater than  msg length which is encode --- 2 is the soh+length encode byte

      if (msg.length - 2 >= msg[1]) {
        var decodeMsgLen;
//decodeMsgLen give the encode msg length which is passed during encoding
        decodeMsgLen = msg[1];
//Summing all the message bit and CKSUM --msg[2+i] mean the message byte is starting from msg[2].. it will sum till the CKSUM
        for (var i = 0; i < decodeMsgLen + 1; i++) {
          decSum += msg[2 + i];
        }
//Adding 1 to the output of loop
        //   decSum += 1;
//trancate the value of decsum to uint8
        decSum &= 0xff;
//compare decSum value equal to CKSUM value
        if (decSum == 0) {
          //packet is good
//remove the SOH,Length -- till msg last byte

          return msg.sublist(2, decodeMsgLen + 2);
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
      return null;
    }
  }
}
