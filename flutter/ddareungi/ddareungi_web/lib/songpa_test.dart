// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SongpaTest extends StatelessWidget {
  const SongpaTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  test();
                },
                child: const Text('Test'))
          ],
        ),
      ),
    );
  }

  //FFFFf
  test() async {
    var url = Uri.parse('http://127.0.0.1:8000/test/predict');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      var result = dataConvertedJSON['result'];
      print('예측대여 ${result['rent']}');
      print('예측반납 ${result['restore']}');
    } else {
      print('ERROR');
    }
  }
}
