import 'dart:io';

import 'package:community_analysis/widget/answer_container.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

enum ModelEnum {
  emotion,
  gender,
  age;

  String modelPath() => "assets/models/${name}_model.tflite";

  String labelPath() => "assets/labels/${name}_labels.txt";
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<HomeView> {
  String? _outputEmotion;
  String? _outputGender;
  String? _outputAge;

  File? _image;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Analysis App'),
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null
                      ? const Text(
                          "Resim Yükleyin Lütfen",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.file(
                              _image!,
                              width: 300,
                              fit: BoxFit.fill,
                            ),
                          )),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const WhiteContainerWidget(text: "Cinsiyet:"),
                      WhiteContainerWidget(text: _outputGender?.substring(1) ?? "-"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const WhiteContainerWidget(text: "Duygu:"),
                      WhiteContainerWidget(text: _outputEmotion?.substring(1) ?? "-"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const WhiteContainerWidget(text: "Yaş:"),
                      WhiteContainerWidget(text: _outputAge?.substring(1) ?? "-"),
                    ],
                  )
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        backgroundColor: Colors.red,
        child: const Icon(Icons.image),
      ),
    );
  }

  pickImage() async {
    await loadModel(ModelEnum.emotion);

    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    await classifyImage(_image!, ModelEnum.emotion);

    await loadModel(ModelEnum.gender);
    await classifyImage(_image!, ModelEnum.gender);

    await loadModel(ModelEnum.age);
    await classifyImage(_image!, ModelEnum.age);
  }

  Future<void> classifyImage(File image, ModelEnum modelEnum) async {
    try {
      var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        _loading = false;
        print(output?.map((e) => e.toString()).toList());
        if (modelEnum == ModelEnum.emotion) {
          _outputEmotion = "${output?[0]["label"]}";
        } else if (modelEnum == ModelEnum.gender) {
          _outputGender = "${output?[0]["label"]}";
        } else {
          _outputAge = "${output?[0]["label"]}";
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> loadModel(ModelEnum modelEnum) async {
    await Tflite.loadModel(model: modelEnum.modelPath(), labels: modelEnum.labelPath());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Tflite.close();
    });
    super.dispose();
  }
}
