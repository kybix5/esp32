import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Импортируем библиотеку для работы с JSON

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _formKey = GlobalKey<FormState>();
  String cameraUrl = 'https://media.w3.org/2010/05/sintel/trailer.mp4'; // Заменить на ваш URL
  String id_esp = "ssid";
  String ssid = "ssid";
  String password = "password";

  final TextEditingController urlController = TextEditingController(text: 'https://media.w3.org/2010/05/sintel/trailer.mp4');
  final TextEditingController idespController = TextEditingController(text: 'esp32_device_id');
  final TextEditingController ssidController = TextEditingController(text: 'ssidController');
  final TextEditingController passwordController = TextEditingController(text: 'passwordController');

  Future<void> _sendCameraSettings(String cameraUrl, String id_esp, String ssid, String password) async {
    final url = Uri.parse('https://e-rec.ru/esp32/camera.php'); // Замените на ваш URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'url': cameraUrl,
        'id_esp': id_esp,
        'ssid': ssid,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Успешно отправлено
      print('Данные успешно отправлены');
      // Закрываем форму
      try {
        final responseJson = jsonDecode(response.body);
        if (responseJson['answer'] == 'ok') {
          print('данные переданны: ${responseJson}');
          _showErrorDialog(responseJson['answer']);
        } else {
          print('Ошибка при отправке данных: ${responseJson}');
          _showErrorDialog(responseJson['answer']);
        }
      } catch (e) {
        print('Ошибка декодирования JSON: $e');
        _showErrorDialog('Ошибка декодирования JSON: $e');
      }
    } else {
      // Ошибка при отправке
      print('Ошибка при отправке данных: ${response.statusCode}');
      // Показываем сообщение об ошибке
      _showErrorDialog('Ошибка при отправке данных: ${response.statusCode}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ответ сервера'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Закрыть диалог
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: urlController,
                decoration: InputDecoration(labelText: 'URL камеры'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: idespController,
                decoration: InputDecoration(labelText: 'id_esp'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: ssidController,
                decoration: InputDecoration(labelText: 'ssid'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'password'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Проверка на заполненность полей
                  if (urlController.text.isEmpty) {
                    // Здесь можно показать сообщение об ошибке
                    _showErrorDialog('Пожалуйста, введите url');
                    return;
                  }
                  if (idespController.text.isEmpty) {
                    // Здесь можно показать сообщение об ошибке
                    _showErrorDialog('Пожалуйста, введите id_esp');
                    return;
                  }
                  if (ssidController.text.isEmpty) {
                    // Здесь можно показать сообщение об ошибке
                    _showErrorDialog('Пожалуйста, введите ssid');
                    return;
                  }
                  // Проверка на заполненность полей
                  if (passwordController.text.isEmpty) {
                    // Здесь можно показать сообщение об ошибке
                    _showErrorDialog('Пожалуйста, введите password');
                    return;
                  }
                  _sendCameraSettings(urlController.text, idespController.text, ssidController.text, passwordController.text);
                },
                child: Text('Сохранить настройки'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
