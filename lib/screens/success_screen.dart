import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/ais_theme.dart';
import '../widgets/ais_navbar.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AISNavBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AISColors.successGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              'สมัครสำเร็จแล้ว! 🎉',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AISColors.textDark),
            ),
            const SizedBox(height: 12),
            const Text(
              'ขอบคุณที่เลือกใช้บริการ AIS\nแพ็กเกจของคุณจะเริ่มใช้งานได้ทันที',
              style: TextStyle(
                  fontSize: 16,
                  color: AISColors.textMedium,
                  height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AISColors.ldBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AISColors.ldBlue.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.science,
                          size: 16, color: AISColors.ldBlue),
                      SizedBox(width: 6),
                      Text(
                        'LaunchDarkly Experiment Event Tracked',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AISColors.ldBlue),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '"checkout-completed" metric ถูก track ไปยัง LD Experiments แล้ว\nใช้ข้อมูลนี้เพื่อวัด Conversion Rate ของแต่ละ Flag Variant',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AISColors.textMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('กลับหน้าหลัก'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/ld-demo'),
                  icon: const Icon(Icons.toggle_on),
                  label: const Text('ดู LD Demo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
