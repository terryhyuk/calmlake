import 'package:calm_lake_project/vm/music_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/music.dart';
import 'musicinsert.dart';

class Musiclist extends StatelessWidget {
  Musiclist({super.key});
  final musicHandler = Get.put((MusicHandler()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Music'),
          actions: [
            // 음악 추가 버튼(음악 추가 페이지로 이동)
            IconButton(
                onPressed: () {
                  Get.to(() => MusicInsert());
                },
                icon: const Icon(Icons.add_outlined))
          ],
        ),
        // 음악 리스트를 출력
        body: StreamBuilder<QuerySnapshot>(
          // firebase에 있는 데이터중 music collection의 문서 전체 출력
          stream: FirebaseFirestore.instance.collection('music').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final documents = snapshot.data!.docs;
            // print(documents.toList());
            return ListView(
              // map형식으로 되어있는 데이터를 list로 변환
              children: documents.map((e) => buildItemWidgets(e)).toList(),
            );
          },
        ));
  }

  Widget buildItemWidgets(DocumentSnapshot doc) {
    // model에 있는 music모델을 이용하여 map형식으로 되어있던 데이터를 model(music)형식으로 변환
    final music = Music(
        image: doc['image'],
        mp3: doc['mp3'],
        name: doc['name'],
        singer: doc['singer']);
    return GestureDetector(
      // list의 노래를 선택하면 선택한 노래로 변경
      onTap: () {
        musicHandler.firebaseMusicFunction(music.mp3, music.image, music.name, doc.id);
        // print(doc.id);
        Get.back();
      },
      // Card형태로 리스트를 만드는 구성
      child: Card(
        color: Colors.white,
        child: ListTile(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(music.image),
                radius: 30,
              ),
              Column(
                children: [
                  Text(
                    '    ${music.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Row(
                    children: [
                      Text(
                        music.singer,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
