import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter VLC Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter VLC Camera'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  String? _cameraUrl;
  String? _cameraName;
  String? _cameraDescription;

  // Список настроек камеры
  List<CameraSettings> _cameraSettings = [];

  // VLC плеер
  VlcPlayerController? _vlcPlayerController;

  // API URL
  final String _apiBaseUrl = 'https://e-rec.ru/esp32';

  // Функция получения данных камеры с сервера
  Future<void> _fetchCameraData() async {
    final response = await http.get(Uri.parse('$_apiBaseUrl/cameras'));
    if (response.statusCode == 200) {
      // Обработка полученных данных
      final data = json.decode(response.body);
      // Обновление состояния
      setState(() {
        _cameraUrl = data['url'];
        _cameraName = data['name'];
        _cameraDescription = data['description'];
        // Получение настроек камеры
        _cameraSettings = data['settings'].map<CameraSettings>((item) => CameraSettings.fromJson(item)).toList();
      });
    } else {
      // Ошибка получения данных
      print('Error fetching camera data: ${response.statusCode}');
    }
  }

  // Функция отправки настроек камеры на сервер
  Future<void> _saveCameraSettings() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.post(Uri.parse('$_apiBaseUrl/cameras'),
          body: jsonEncode({
            'name': _cameraName,
            'description': _cameraDescription,
            'settings': _cameraSettings.map((e) => e.toJson()).toList(),
          }));
      if (response.statusCode == 200) {
        // Успешная отправка
        print('Camera settings saved successfully!');
      } else {
        // Ошибка отправки
        print('Error saving camera settings: ${response.statusCode}');
      }
    }
  }

  // Функция инициализации VLC плеера
  void _initVlcPlayer() {
    _vlcPlayerController = VlcPlayerController.network(_cameraUrl ?? "");
    _vlcPlayerController!.addListener(() {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    // Загрузка данных камеры с сервера
    _fetchCameraData();
  }

  @override
  void dispose() {
    _vlcPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraUrl != null
                ? VlcPlayer(
                    controller: _vlcPlayerController!,
                    aspectRatio: 16 / 9,
                    placeholder: Center(child: CircularProgressIndicator()),
                  )
                : Center(child: Text('Loading Camera...')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _cameraUrl != null ? _initVlcPlayer : null,
              child: Text('Start Camera'),
            ),
          ),
          // Виджет настроек камеры
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Camera Name'),
                        initialValue: _cameraName,
                        onSaved: (value) {
                          _cameraName = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        initialValue: _cameraDescription,
                        onSaved: (value) {
                          _cameraDescription = value;
                        },
                      ),
                      // Список настроек камеры
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _cameraSettings.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_cameraSettings[index].name),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _cameraSettings.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: _saveCameraSettings,
                        child: Text('Save Camera Settings'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Обработка перехода по навигации
          switch (index) {
            case 0:
              // Переход к экрану камеры
              setState(() {});
              break;
            case 1:
              // Переход к экрану настроек
              setState(() {});
              break;
          }
        },
      ),
    );
  }
}

// Класс для представления настроек камеры
class CameraSettings {
  String name;
  String value;

  CameraSettings({required this.name, required this.value});

  // Метод для создания объекта из JSON
  factory CameraSettings.fromJson(Map<String, dynamic> json) {
    return CameraSettings(
      name: json['name'],
      value: json['value'],
    );
  }

  // Метод для преобразования объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
