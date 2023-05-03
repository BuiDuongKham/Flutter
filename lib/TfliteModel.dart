import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({Key? key}) : super(key: key);

  @override
  _TfliteModelState createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  late List _results;
  late File _image;
  bool imageSelect=false;
  static final Map<String,String> _labels={
    "Đậu":"Trong 100g đậu chứa khoảng 33 calo, 1,93 g protein, 0,19 g chất béo, 7,45 g carbohydrate, 3,2 g chất xơ, 1,48 g đường",
    "Khổ Qua": "Trong 124g khổ qua chứa khoảng 24 calo, 1 g protein, 0,2 g chất béo, 5,4 g carbohydrate, 2,5 g chất xơ, 2,4 g đường",
    "Bầu" : "Trong 100g quả bầu chứa: 95% nước, 21% calcium, 25% phosphor, 2.9% glucid, 1% cellulose, 0.2 mg sắt, 0.5% protid; cùng các loại vitamin như: 0.03 mg B2, 0.02 mg caroten, 12 mg C, 0.40 mg PP và 0.02 mg B1",
    "Cà Tím": " Trong 100g cà tím chứa khoảng 25 calo, 1 g protein, 0,2 g chất béo, 6 g carbohydrate, 3 g chất xơ",
    "Cải Xanh": "Trong 100g cải xanh chứa khoảng 33 calo, 2.8 g protein, 0.4 g chất béo, 7 g carbohydrate, 2,5 g chất xơ",
    "Cải Bắp" : " Trong 100g cải bắp chứa khoảng 24 calo, 1,3 g protein, 0,1 g chất béo, 6 g carbohydrate, 2,5 g chất xơ",
    "Ớt Chuông" :" Trong 100g ớt chuông chứa khoảng 39 calo, 2 g protein, 0.2 g chất béo, 9 g carbohydrate, 1,5 g chất xơ",
    "Cà Rốt": "Trong 100g cà rốt chứa khoảng 41 calo, 0,9 g protein, 0,2 g chất béo, 10 g carbohydrate, 2,8 g chất xơ",
    "Bông Cải Trắng":"Trong 100g bông cải trắng chứa khoảng 24 calo, 1,9 g protein, 0,3 g chất béo, 5 g carbohydrate, 2 g chất xơ",
    "Dưa Chuột": "Trong 100g dưa chuột chứa khoảng 16 calo, 0,65 g protein, 0,11 g chất béo, 3.63 g carbohydrate, 0,5 g chất xơ",
    "Đu Đủ": "Trong 100g đu đủ xanh chứa khoảng 43 calo, 0,47 g protein, 0,26 g chất béo, 10.82 g carbohydrate, 1,7 g chất xơ",
    "Khoai Tây" :"Trong 100g khoai tây chứa khoảng 77 calo, 1,8 g protein, 0,1 g chất béo, 17,8 g carbohydrate, 1,7 g chất xơ",
    "Bí Ngô":"Trong 100g bí ngô chứa khoảng 33 calo, 1,9 g protein, 0,2 g chất béo, 7,5 g carbohydrate, 2,5 g chất xơ",
    "Củ Cải":"Trong 100g củ cải chứa khoảng 24 calo, 1,3 g protein, 0,1 g chất béo, 6 g carbohydrate, 2,5 g chất xơ",
    "Cà Chua":"Trong 100g cà chua chứa khoảng 18 calo, 0,9 g protein, 0,1 g chất béo, 4 g carbohydrate, 1,5 g chất xơ",
  };

  @override
  void initState()
  {
    super.initState();
    loadModel();
  }
  Future loadModel()
  async {
    Tflite.close();
    String res;
    res=(await Tflite.loadModel(model: "assets/model.tflite",labels: "assets/labels.txt"))!;
    print("Models loading status: $res");
  }
  Future imageClassification(File image)
  async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1, // Thử điều chính những thuộc tính này để tăng độ chính xác
      threshold: 0.05,
      imageMean: 0,
      imageStd: 1,
      asynch: true
    );
    setState(() {
      _results=recognitions!;
      _image=image;
      imageSelect=true;

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Classification"),
      ),
      body: ListView(
        children: [
          (imageSelect)?Container(
        margin: const EdgeInsets.all(10),
        child: Image.file(_image),
      ):Container(
        margin: const EdgeInsets.all(10),
            child: const Opacity(
              opacity: 0.8,
              child: Center(
                child: Text("No image selected"),
              ),
            ),
      ),
          SingleChildScrollView(
            child: Column(
              children: (imageSelect)?_results.map((result) {
                return Card(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      "${result['label']} \n ${_labels[result['label']]}\n Theo: USDA Nutrient Database",
                      style: const TextStyle(color: Colors.red,
                      fontSize: 20),
                    ),
                  ),
                );
              }).toList():[],

            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: "Pick Image",
        child: const Icon(Icons.image),
      ),
    );
  }
  Future pickImage()
  async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 224,
      maxWidth: 224
    );
    File image=File(pickedFile!.path);
    imageClassification(image);
  }
}
