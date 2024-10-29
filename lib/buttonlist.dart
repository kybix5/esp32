import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ButtonList extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ButtonList> {
  // Переменные для хранения состояния кнопок
  List<bool> _buttonStates = List.filled(8, false); // Изначально все кнопки выключены
  Color _connectionColor = Colors.red; // Изначально красный, т.е. нет связи

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Загружаем начальные данные при инициализации
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi),
                SizedBox(width: 8.0),
                Text(
                  'Состояние связи',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(width: 8.0),
                Container(
                  width: 16.0,
                  height: 16.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _connectionColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 8 кнопок
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(8, (index) {
                return ElevatedButton(
                  onPressed: () {
                    _sendPostRequest(index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonStates[index] ? Colors.green : Colors.grey,
                  ),
                  child: Text('Кнопка ${index + 1}'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Функция для загрузки начальных данных (состояние кнопок, цвет индикатора)
  Future<void> _loadInitialData() async {
    final url = Uri.parse('https://e-rec.ru/esp32/get_data'); // Замените URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Обновляем состояние кнопок
      _buttonStates = List.generate(8, (index) => data['button_states'][index]);
      // Обновляем цвет индикатора
      _connectionColor = data['connection_status'] == 'connected' ? Colors.green : Colors.red;

      setState(() {}); // Перерисовываем виджет
    } else {
      // Обработка ошибки
    }
  }

  // Функция для отправки POST-запроса при нажатии кнопки
  Future<void> _sendPostRequest(int buttonIndex) async {
    final url = 'https://e-rec.ru/esp32/get_data/edit_bt.php';

    final Map<String, dynamic> requestBody = {
      'id': 'esp32_device_id',
      'button_index': buttonIndex,
      // Добавьте необходимые поля
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Обновляем состояние кнопок
      _buttonStates = List.generate(8, (index) => data['button_states'][index]);

      // Обновляем цвет индикатора
      _connectionColor = data['connection_status'] == 'connected' ? Colors.green : Colors.red;

      // Обновляем состояние кнопки
      //_buttonStates[buttonIndex] = data['new_button_state'];

      setState(() {}); // Перерисовываем виджет
    } else {
      print('button : post error' + response.body);
    }
  }
}