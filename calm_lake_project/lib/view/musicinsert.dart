import 'package:calm_lake_project/vm/music_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MusicInsert extends StatelessWidget {
  MusicInsert({super.key});
  // musicHandler 생성
  final musicHandler = Get.put(MusicHandler());
  // 텍스트 필드 생성
  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Music insert'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            // 음악 이름 입력
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: '타이틀을 입력하세요', border: OutlineInputBorder()),
              ),
            ),
            // 부제목(가수)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: subtitleController,
                decoration: const InputDecoration(
                    labelText: '부제목을 입력하세요', border: OutlineInputBorder()),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // 음악 추가, firebase에 데이터 추가 버튼
                      ElevatedButton(
                          onPressed: () async {
                            // firestore에 mp3파일 업로드
                            await musicHandler.uploadMp3File();
                            // 업로드한 mp3파일 주소 가져와서 firebase에 넣기
                            flieAllInsert();
                            // 음악 리스트 갯수 업데이트
                            musicHandler.getLastDocumentId();
                            Get.back();
                            // 지금 사용X
                            // musicHandler.changemp3State();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffD8EFCA),
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(2))),
                          child: const Text('File Insert')),
                      // 지금은 사용할 수 없음
                      // Text(musicHandler.mp3UploadOk)
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Column(
                //     children: [
                //       ElevatedButton(
                //           onPressed: () {
                //             musicHandler.galleryImage();
                //             print(musicHandler.imgFile);
                //             musicHandler.changeimageState();
                //             musicHandler.reload();
                //           },
                //           style: ElevatedButton.styleFrom(
                //               backgroundColor: const Color(0xffF9D3CC),
                //               shape: BeveledRectangleBorder(
                //                   borderRadius: BorderRadius.circular(2))),
                //           child: const Text('Image insert')),
                //       Text(musicHandler.imageUploadOk)
                //     ],
                //   ),
                // ),
              ],
            ),
            //   Container(
            //   width: MediaQuery.of(context).size.width,
            //   height: 200,
            //   color: Colors.grey,
            //   child: Center(
            //     child: musicHandler.showImage()
            //   ),
            // ),

            // 안드로이드가 외부로 나가면 초기화면으로 돌아가서 이미지는 고정하고 파일만 넣는 형태로 바꿈
            // ElevatedButton(
            //     onPressed: () {
            //       flieAllInsert();
            //       musicHandler.changelastState();
            //       Get.back();
            //     },
            //     style: ElevatedButton.styleFrom(
            //         backgroundColor: const Color(0xffD8EFCA),
            //         shape: BeveledRectangleBorder(
            //             borderRadius: BorderRadius.circular(2))),
            //     child: const Text('File insert')),
          ],
        ),
      ),
    );
  }

  // IOS에서 mp3파일을 직접 넣기가 어려워서 Android Emulator로 파일을 넣어야 함
  flieAllInsert() async {
    // String image = await musicHandler.preparingImage();
    // print('00000000000000000 ${musicHandler.downloadUrl} 000000000000000000000000');

    FirebaseFirestore.instance
        .collection('music')
        .doc(musicHandler.lastDocId.toString())
        .set({
      'name': titleController.text.trim(),
      'mp3': musicHandler.downloadUrl,
      'singer': subtitleController.text.trim(),
      'image':
          'https://firebasestorage.googleapis.com/v0/b/calmlake-f513a.appspot.com/o/image%2Fvivaldi_base.jpg?alt=media&token=54a1b36b-5f7d-402d-a794-1639db7edcb2'
    });
  }
}
