import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {

  final String baseUrl = dotenv.env['API_URL'] ?? '';
  final String apiToken = dotenv.env['API_TOKEN'] ?? '';

  // enviar dados como json
  Future<Map<String, dynamic>> validarAluno(String ra, String nome) async {
    var url = Uri.parse('$baseUrl/validar');

    // body da requisição
    var body = json.encode({'RA': ra, 'Nome': nome});

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // informa que o body é JSON
        'Authorization': 'Bearer $apiToken',
      },
      body: body,
    );

    // verifica o status da resposta
    if (response.statusCode == 200) {
      print("Resposta: ${response.body}");
      return json.decode(response.body); 
    } else {
      print("Erro: ${response.statusCode} - ${response.body}");
      throw Exception('Erro ao validar aluno: ${response.body}'); 
    }
  }

  // método para listar alunos validados
  Future<List<dynamic>> listarValidados() async {
    var url = Uri.parse('$baseUrl/validados'); 
    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );

    if (response.statusCode == 200) {
      print("Resposta: ${response.body}");
      return json.decode(response.body); 
    } else {
      print("Erro: ${response.statusCode} - ${response.body}");
      throw Exception('Erro ao listar validados: ${response.body}');
    }
  }
}
