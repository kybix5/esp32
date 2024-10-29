import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import 'package:http/http.dart' as http;
import 'dart:convert'; // Импортируем библиотеку для работы с JSON
import 'buttonlist.dart';
import 'setings.dart';

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
          ButtonList(),
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
            icon: Icon(Icons.radio_button_checked),
            label: 'Кнопки',
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
      print('button status 1:' + pin1);

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

  // Рекурсивная функция, которая вызывает _yourFunction() с задержкой
  Future<void> _delayedCall() async {
    await Future.delayed(const Duration(seconds: 3));

    _delayedCall(); // Вызываем себя снова
  }

// Функция для инвертирования значения
  String invertValue(String pin) {
    return (pin == "0") ? "1" : "0"; // Инвертируем значение
  }

  // Функция для инверсии состояния пинов
  void _invertPinStates() {
    // Инвертируем значения
    pin1 = invertValue(pin1);
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

      print('button status 1' + pin1);
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
