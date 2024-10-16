import 'package:calm_lake_project/vm/NavigationController.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PostImageHandler extends NavigationController {
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  String image = '';
  int firstDisp = 0;

  getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = XFile(pickedFile.path);
      //print(imageFile!.path);
      update();
    } else {
      //print('이미지 선택이 취소되었습니다.');
    }
  }

  changeImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = XFile(pickedFile.path);
      //print(imageFile!.path);
      firstDisp = 1;
      update();
    } else {
      //print('이미지 선택이 취소되었습니다.');
    }
  }

  Future<void> uploadImage() async {
    if (imageFile == null) {
      //print('No image selected');
      return;
    }
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/insert/upload'));
    var multipartFile =
        await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartFile);
    // 파일 이름 추출
    //print(imageFile!.path);
    List<String> preFileName = imageFile!.path.split('/');
    image = preFileName.last;
    //print('upload file name: $image');
    var response = await request.send();
    if (response.statusCode == 200) {
      //print("Image uploaded successfully");
    } else {
      //print('Image upload failed');
    }
  }

  deletePostImage(String filename) async {
    final response = await http
        .delete(Uri.parse('http://127.0.0.1:8000/query/deleteimage/$filename'));
    if (response.statusCode == 200) {
      //print("Image deleted successfully");
    } else {
      //print("image deletion failed.");
    }
  }
}
