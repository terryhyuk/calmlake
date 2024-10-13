import 'dart:io';

import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MusicInsert extends StatelessWidget {
  MusicInsert({super.key});
  final VmHandler vmHandler = VmHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music insert'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                vmHandler.uploadFile();
              }, 
              child: const Text('Mp3 insert')
              ),
            ElevatedButton(
              onPressed: () {
                vmHandler.galleryImage();
                vmHandler.reload();
              }, 
              child: const Text('Image insert')
              ),
                Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color: Colors.grey,
                child: Center(
                  child: vmHandler.showImage()
                ),
              ),
            ElevatedButton(
              onPressed: () {
                flieAllInsert();
                Get.back();
              }, 
              child: const Text('File insert')
              ),
          ],
        ),
      ),
    );
  }
  flieAllInsert() async{
    String image = await vmHandler.preparingImage();

    FirebaseFirestore.instance
    .collection('music')
    .add(
      {
        'name' : 'vivaldi2',
        'mp3' : vmHandler.downloadMp3URL,
        'singer' : 'vivaldi',
        'image' : image
      }
    );
  }
}