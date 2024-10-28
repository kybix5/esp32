import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import 'package:http/http.dart' as http;
import 'dart:convert'; // Импортируем библиотеку для работы с JSON

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Индекс выбранного экрана

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Автоматика')),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          VideoScreen(),
          CameraScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Ворота',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройка',
          ),
        ],
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VlcPlayerController _videoPlayerController; // Объявляем контроллер
  String _currentVideoUrl = '';
  String _videoUrl = 'http://media.w3.org/2010/05/bunny/movie.mp41';
  String pin1 = "0";
  String pin2 = "0";
  String pin3 = "0";
  String pin4 = "0";
  Color _buttonColor = Colors.green; // Инициализируем цвет

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VlcPlayerController.network('http://media.w3.org/2010/05/bunny/movie.mp41'); // Инициализируем пустым URL
    _loadInitialData(); // Загружаем данные при инициализации виджета
  }

  Future<void> _loadInitialData() async {
    final url = 'https://e-rec.ru/esp32/geturl.php'; // Замените на ваш URL API

    final Map<String, dynamic> requestBody = {
      'id': 'esp32_device_id',
      'url': 'get',
      // Добавьте необходимые поля
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      pin1 = data['pin1'];
      pin2 = data['pin2'];
      pin3 = data['pin3'];
      pin4 = data['pin4'];
      print('button status 1:' + pin1 + ' 2:' + pin2);

      final String newVideoUrl = data['url']; // Замените ключ на правильный

      setState(() {
        _currentVideoUrl = newVideoUrl;
        print('button status url: ' + newVideoUrl);
        _videoPlayerController.setMediaFromNetwork(_currentVideoUrl);
        _updateButtonColor();
      });
    } else {
      throw Exception('Failed to load video URL');
    }
  }

//получаем url видео , домофона и.т.д
  Future<String> _fetchVideoUrl() async {
    final url = 'https://e-rec.ru/esp32/geturl.php'; // Замените на ваш URL API

    final Map<String, dynamic> requestBody = {
      'id': 'esp32_device_id',
      'url': 'get',
      // Добавьте необходимые поля
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      pin1 = data['pin1'];
      pin2 = data['pin2'];
      pin3 = data['pin3'];
      pin4 = data['pin4'];
      //_updateButtonColor();
      return data['url']; // Предположим, что URL находится в поле 'url'
    } else {
      throw Exception('Failed to load video URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: VlcPlayer(
                controller: _videoPlayerController,
                aspectRatio: 16 / 9,
                placeholder: Center(child: CircularProgressIndicator()),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('button down');
                _invertPinStates(); // изменяем значение портов на противоположное
                _sendPostRequest(); // отправка команды на сервер
                _updateButtonColor(); // Обновляем цвет кнопки после получения ответа
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor, // Устанавливаем цвет кнопки
              ),
              child: Text('Открыть Ворота'),
            ),
          ],
        ),
      ),
    );
  }

// Функция для инвертирования значения
  String invertValue(String pin) {
    return (pin == "0") ? "1" : "0"; // Инвертируем значение
  }

  // Функция для инверсии состояния пинов
  void _invertPinStates() {
    // Инвертируем значения
    // Инвертируем значения
    pin1 = invertValue(pin1);
    pin2 = invertValue(pin2);
    pin3 = invertValue(pin3);
    pin4 = invertValue(pin4);
    print('button invertPinStates');
    print('button :' + pin1);
  }

  Future<void> _sendPostRequest() async {
    // Заменить URL-адрес на свой
    final url = Uri.parse('https://e-rec.ru/esp32/open.php');

    // Создаем JSON-объект
    final Map<String, dynamic> data = {
      'id': 'esp32_device_id',
      'pin1': pin1,
      'pin2': pin2,
      'pin3': pin3,
      'pin4': pin4,
    };

    // Отправляем POST-запрос с заголовком Content-Type
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // Указываем, что отправляем JSON
      },
      body: jsonEncode(data), // Преобразуем Map в JSON-строку
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      pin1 = data['pin1'];
      pin2 = data['pin2'];
      pin3 = data['pin3'];
      pin4 = data['pin4'];
      print('button status 1' + pin1 + ' 2' + pin2);
      //_updateButtonColor(); // Обновляем цвет кнопки после получения ответа
    } else {
      print('Failed to load pin status');
      throw Exception('Failed to load pin status');
    }
  }

  void _updateButtonColor() {
    setState(() {
      _buttonColor = _getButtonColor(); // Обновляем цвет кнопки
    });
  }

  Color _getButtonColor() {
    if (pin1 == '1') {
      return Colors.red; // Цвет для pin1 < 5
    } else if (pin1 == '0') {
      return Colors.green; // Цвет для pin1 >= 5 и < 10
    } else {
      return Colors.yellow; // Цвет для pin1 >= 10
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }
}

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
