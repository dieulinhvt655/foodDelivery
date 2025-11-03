// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
//
// class QRCodeDialog extends StatefulWidget {
//   final double orderTotal;
//   final String orderId;
//   final VoidCallback? onPaymentSuccess;
//
//   const QRCodeDialog({
//     super.key,
//     required this.orderTotal,
//     required this.orderId,
//     this.onPaymentSuccess,
//   });
//
//   @override
//   State<QRCodeDialog> createState() => _QRCodeDialogState();
// }
//
// class _QRCodeDialogState extends State<QRCodeDialog> {
//   int _remainingSeconds = 300; // 5 minutes = 300 seconds
//   Timer? _timer;
//   bool _isExpired = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }
//
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           if (_remainingSeconds > 0) {
//             _remainingSeconds--;
//
//             // Auto close at 4 minutes 45 seconds (285 seconds remaining = 15 seconds elapsed)
//             if (_remainingSeconds == 285) {
//               _timer?.cancel();
//               // Close dialog and show success message
//               if (mounted) {
//                 Navigator.of(context).pop();
//                 // Show payment success notification
//                 if (widget.onPaymentSuccess != null) {
//                   Future.delayed(const Duration(milliseconds: 300), () {
//                     if (mounted) {
//                       widget.onPaymentSuccess!();
//                     }
//                   });
//                 } else {
//                   // Default success message
//                   Future.delayed(const Duration(milliseconds: 300), () {
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Thanh toán thành công'),
//                           backgroundColor: Color(0xFFFF6B35),
//                           duration: Duration(seconds: 3),
//                         ),
//                       );
//                     }
//                   });
//                 }
//               }
//             }
//           } else {
//             _isExpired = true;
//             _timer?.cancel();
//           }
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   String _formatTime(int seconds) {
//     final minutes = seconds ~/ 60;
//     final secs = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
//   }
//
//   String _generateQRData() {
//     // Generate QR code data with order ID and total
//     return 'PAYMENT:${widget.orderId}:${widget.orderTotal.toStringAsFixed(2)}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 350),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Close button
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'QR Code Payment',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Color(0xFF2D2D2D)),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             // QR Code
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: _isExpired
//                       ? Colors.red
//                       : const Color(0xFFFFE0B3),
//                   width: 2,
//                 ),
//               ),
//               child: _isExpired
//                   ? Column(
//                       children: [
//                         const Icon(
//                           Icons.error_outline,
//                           color: Colors.red,
//                           size: 64,
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'QR Code Expired',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.red,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'Please select another payment method',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF6F6F6F),
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     )
//                   : QrImageView(
//                       data: _generateQRData(),
//                       version: QrVersions.auto,
//                       size: 200,
//                       backgroundColor: Colors.white,
//                       errorCorrectionLevel: QrErrorCorrectLevel.M,
//                     ),
//             ),
//             const SizedBox(height: 24),
//             // Timer
//             if (!_isExpired)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF4E3),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.timer_outlined,
//                       color: Color(0xFFFF6B35),
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Valid for: ${_formatTime(_remainingSeconds)}',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFFFF6B35),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 20),
//             // Order Total
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFF4E3),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Order Total',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   Text(
//                     '\$${widget.orderTotal.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFFFF6B35),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Close button
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFFFF6B35),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
