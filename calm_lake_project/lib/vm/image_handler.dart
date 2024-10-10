import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageHandler extends GetxController {
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  String image = '';
  String filename = '';  

  getImageFromGallery(ImageSource imageSource) async{
    final XFile? pickedFile=await picker.pickImage(
      source: imageSource);
    imageFile=XFile(pickedFile!.path);
    update();
  }

  Future<void> editImage() async {
    if (imageFile == null) {
      print('No image selected');
      return ;
    }
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/login/upload'));
    var multipartFile =
        await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartFile);
    // 파일 이름 추출
    print(imageFile!.path);
    List<String> preFileName = imageFile!.path.split('/');
    image = preFileName.last;
    print('upload file name: $image');
    var response = await request.send();
    if (response.statusCode == 200) {
      print("Image uploaded successfully");
    } else {
      print('Image upload failed');
    }
  }

  deleteImage(String filename) async {
    final response = await http
        .delete(Uri.parse('http://127.0.0.1:8000/login/deleteFile/$filename'));
    if (response.statusCode == 200) {
      // print("Image deleted successfully");
    } else {
      // print("image deletion failed.");
    }
  }  

  Future<void> uploadImage() async {
    if (imageFile == null) {
      print('No image selected');
      return;
    }
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://10.0.2.2:8000/insert/upload'));
    var multipartFile =
        await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartFile);
    // 파일 이름 추출
    print(imageFile!.path);
    List<String> preFileName = imageFile!.path.split('/');
    image = preFileName.last;
    print('upload file name: $image');
    var response = await request.send();
    if (response.statusCode == 200) {
      print("Image uploaded successfully");
    } else {
      print('Image upload failed');
    }
  }
}
