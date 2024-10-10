import 'package:calm_lake_project/model/message.dart';
import 'package:calm_lake_project/vm/chating_controller.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Chatroom extends StatelessWidget {
  Chatroom({super.key});
  final ChatingController messageController = Get.put(ChatingController());
  final loginhandler = Get.put(LoginHandler());
  final TextEditingController sendController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chatRoom1'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                itemCount: messageController.messages.length,
                itemBuilder: (context, index) {
                  Message message = messageController.messages[index];
                  // print(message.userID);
                  return ListTile(
                    title: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              message.userID == loginhandler.box.read('userId')
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            BubbleSpecialThree(
                              text: message.contents,
                              color: message.userID ==
                                      loginhandler.box.read('userId')
                                  ? const Color(0xFF90CAF9)
                                  : const Color(0xFF2196F3),
                              tail: true,
                              textStyle:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            // Container(
                            //   padding: const EdgeInsets.symmetric(
                            //       vertical: 10, horizontal: 16),
                            //   margin: const EdgeInsets.symmetric(
                            //       vertical: 4, horizontal: 8),
                            //   decoration: BoxDecoration(
                            //     color: message.userID ==
                            //             loginhandler.box.read('userId')
                            //         ? Colors.blue[200]
                            //         : Colors.blue[500],
                            //     borderRadius: message.userID ==
                            //             loginhandler.box.read('userId')
                            //         ? const BorderRadius.only(
                            //             topLeft: Radius.circular(14),
                            //             topRight: Radius.circular(14),
                            //             bottomLeft: Radius.circular(14),
                            //           )
                            //         : const BorderRadius.only(
                            //             topLeft: Radius.circular(14),
                            //             topRight: Radius.circular(14),
                            //             bottomRight: Radius.circular(14),
                            //           ),
                            //   ),
                            //   child: Text(
                            //       message.contents,
                            //     style: const TextStyle(fontSize: 16),
                            //   ),
                            // ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              message.userID == loginhandler.box.read('userId')
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('h:mm a').format(message.timestamp),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color:  Color.fromARGB(18, 0, 0, 0), blurRadius: 10)
                ],
            // color:  내중에 테마따라서 ,
              ),
              child: Expanded(
                child: TextField(
                  maxLength: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  controller: sendController,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: const Icon(Icons.send),
                        color: Colors.blue,
                        iconSize: 25,
                      ),
                      hintText: "Type ypur message here",
                      hintMaxLines: 1,
                      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 8.0, vertical: 10),
                      hintStyle: const TextStyle(
                        fontSize: 16
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 0.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.black26,
                    width: 0.2,
                  ),
                ),
                ),),
                ),
            ),
          ),
        ]
      ),
    );
  }


  sendMessage() {
    messageController.addMessage(
        loginhandler.box.read('userId'), sendController.text);
    sendController.text = '';
  }
} // END
