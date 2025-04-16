import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:front/qr_code_scanner.dart';
import 'api.dart'; 


class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedCode;
  bool _dialogShown = false;
  UniqueKey _scannerKey = UniqueKey(); // força o rebuild do scanner
  final Api _api = Api(); // instância da classe api

  // função para exibir o diálogo com o QR Code ou mensagem de validação
  Future<void> _exibirDialogo(String code, {String? message}) async {
    await cameraController.stop();
    await Future.delayed(const Duration(milliseconds: 500));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code encontrado'),
        content: Text(message ?? code),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // fecha o dialog
            },
            child: const Text(
              'Fechar',
              style: TextStyle(fontFamily: "Roboto", color: Color.fromRGBO(26, 52, 141, 1)),
            ),
          ),
        ],
      ),
    );

    // reinicia o scanner após fechar o dialog
    setState(() {
      _dialogShown = false;
      scannedCode = null;
      _scannerKey = UniqueKey(); // força o rebuild do scanner
      cameraController.dispose();
      cameraController = MobileScannerController();
    });

    await cameraController.start();
  }

  // função chamada ao detectar um QR Code
  void _onCodeDetected(String code) async {
    if (_dialogShown || code == scannedCode) return;

    setState(() {
      scannedCode = code;
      _dialogShown = true;
    });

    // chama o método validaraluno da api
    try {
      var response = await _api.validarAluno(code, 'flutter_app');
      // exibe o resultado da API
      _exibirDialogo(code, message: "${response['mensagem']}");
    } catch (e) {
      // TODO: implementar verificação mais rigorosa se o aluno já foi cadastrado
      _exibirDialogo(code, message: "Erro ao cadastrar código");
    }
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
