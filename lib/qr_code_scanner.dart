import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScanner extends StatefulWidget {
  final Function(String code)
  onDetect; // função chamada quando o QR Code é detectado
  final MobileScannerController controller;

  const QRCodeScanner({
    Key? key,
    required this.onDetect,
    required this.controller,
  }) : super(key: key);

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _position;

  String? _lastQrcode;
  DateTime?
  _lastScan; // variável privada para armazenar o horário do último scaneamento

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _position = Tween<double>(begin: 0, end: 280).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        children: [
          // área ao redor do scanner
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(26, 52, 141, 1),
                width: 2,
              ),
            ),
            child: MobileScanner(
              controller: widget.controller,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final String? code = barcode.rawValue;

                if (code == null) return;

                final now = DateTime.now();

                // se o qrcode mudar, reinicia o timer
                if (code != _lastQrcode) {
                  _lastQrcode = code;
                  _lastScan = now;
                  return;
                }

                // se o qrcode não mudar durante 1 segundo, dispara o callback
                if (_lastScan != null &&
                    now.difference(_lastScan!).inMilliseconds >= 1000) {
                  widget.onDetect(code);

                  _lastQrcode = null;
                  _lastScan = null;
                }
              },
            ),
          ),

          // barra animada do scanner
          AnimatedBuilder(
            animation: _position,
            builder: (context, child) {
              return Positioned(
                top: _position.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: const Color.fromRGBO(255, 255, 255, 0.7),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
