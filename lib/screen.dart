import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:front/qr_code_scanner.dart';
import 'api.dart'; 

// comunicação com a API
class QRCodeValidator {
  final Api _api = Api();

  // método para validar o QR Code com a API
  Future<Map<String, dynamic>> validateQRCode(String code) async {
    return await _api.validateStudent(code, 'flutter_app');
  }
}

// classe para exibir o dialog
class DialogService {
  static Future<void> displayDialog(
    BuildContext context,
    String code,
    {String? message, 
    required Function onPressed}
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'QR Code Encontrado',
          style: TextStyle(fontSize: 24.0), 
        ),
        content: Text(
          message ?? code, 
          style: TextStyle(fontSize: 18.0), 
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // fecha o dialog
              onPressed(); // executa a função de callback ao fechar
            },
            child: const Text(
              'Fechar',
              style: TextStyle(fontFamily: "Roboto", color: Color.fromRGBO(26, 52, 141, 1), fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedCode;
  bool _dialogShown = false;
  UniqueKey _scannerKey = UniqueKey(); // força o rebuild do scanner
  
  // instância da classe de validação
  final QRCodeValidator _validator = QRCodeValidator();

  // função chamada ao detectar um QR Code
  void _onCodeDetected(String code) async {
    if (_dialogShown || code == scannedCode) return;

    setState(() {
      scannedCode = code;
      _dialogShown = true;
    });

    await cameraController.stop();
    await Future.delayed(const Duration(milliseconds: 500));

    // chama o método validateQRCode da API através do validador
    try {
      var response = await _validator.validateQRCode(code);
      await DialogService.displayDialog(
        context, 
        code, 
        message: "${response['mensagem']}",
        onPressed: _restartScanner,
      );
    } catch (e) {
      // TODO: Implementar verificação mais rigorosa se o aluno já foi cadastrado
      await DialogService.displayDialog(
        context, 
        code, 
        message: "Erro ao registrar aluno",
        onPressed: _restartScanner,
      );
    }
  }

  // função para reiniciar o scanner após fechar o dialog
  void _restartScanner() {
    setState(() {
      _dialogShown = false;
      scannedCode = null;
      _scannerKey = UniqueKey(); // força o rebuild do scanner
      cameraController.dispose();
      cameraController = MobileScannerController();
    });

    cameraController.start();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(26, 52, 141, 1),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/logo.png', height: 40),
                const SizedBox(width: 8),
                const Text(
                  'Fatec Log',
                  style: TextStyle(fontSize: 18, fontFamily: "Roboto", color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.cameraswitch),
                  tooltip: 'Trocar câmera',
                  onPressed: () {
                    cameraController.switchCamera();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.flash_on),
                  tooltip: 'Ligar/desligar flash',
                  onPressed: () {
                    cameraController.toggleTorch();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aponte a câmera para o QR Code!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (!_dialogShown)
              QRCodeScanner(
                key: _scannerKey,
                onDetect: _onCodeDetected, // passa a função para lidar com a detecção
                controller: cameraController,
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
