import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const NetGuardApp());
}

const bg = Color(0xFF081321);
const panel = Color(0xFF122238);
const blue = Color(0xFF38BDF8);
const green = Color(0xFF22C55E);
const red = Color(0xFFEF4444);
const orange = Color(0xFFF59E0B);

class ScanResult {
  final String ssid;
  final String security;
  final int score;
  final String level;
  final List<String> findings;
  final DateTime time;

  ScanResult({
    required this.ssid,
    required this.security,
    required this.score,
    required this.level,
    required this.findings,
    required this.time,
  });
}

class NetGuardApp extends StatelessWidget {
  const NetGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NetGuard',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selected = 0;
  final List<ScanResult> history = [];

  void addResult(ScanResult result) {
    setState(() {
      history.insert(0, result);
      selected = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        history: history,
        onScan: () => setState(() => selected = 1),
      ),
      AnalyzerPage(onAnalyzed: addResult),
      HistoryPage(history: history),
      const GuidePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield, color: blue, size: 27),
            SizedBox(width: 10),
            Text('NetGuard', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.security, color: green),
          ),
        ],
      ),
      body: IndexedStack(index: selected, children: pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: panel,
        selectedIndex: selected,
        onDestinationSelected: (i) => setState(() => selected = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.wifi_find), label: 'Analyze'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Guide'),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

Widget sectionTitle(String title, {String? subtitle}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
      ],
    ),
  );
}

Widget panelCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white10),
    ),
    child: child,
  );
}

class DashboardPage extends StatelessWidget {
  final List<ScanResult> history;
  final VoidCallback onScan;

  const DashboardPage({super.key, required this.history, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final latest = history.isEmpty ? null : history.first;
    final scoreColor = latest == null
        ? blue
        : latest.score >= 60
        ? red
        : latest.score >= 30
        ? orange
        : green;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        panelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NETWORK SECURITY MONITOR',
                style: TextStyle(color: blue, fontSize: 11, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                latest == null ? 'Protect your Wi-Fi connection' : latest.ssid,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                latest == null
                    ? 'Analyze network security and identify common Wi-Fi risks.'
                    : 'Last analysis: ${latest.level} risk',
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.shield, size: 46, color: scoreColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latest == null
                              ? 'No analysis yet'
                              : '${latest.score}/100 risk score',
                          style: TextStyle(
                            color: scoreColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          latest == null
                              ? 'Start your first analysis'
                              : latest.level,
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onScan,
                  icon: const Icon(Icons.wifi_find),
                  label: const Text('Analyze Wi-Fi Network'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        sectionTitle('Security Features'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: const [
            FeatureTile(
              icon: Icons.wifi,
              title: 'Wi-Fi Analysis',
              detail: 'Network security',
            ),
            FeatureTile(
              icon: Icons.warning_amber,
              title: 'Threat Detection',
              detail: 'Identify weaknesses',
            ),
            FeatureTile(
              icon: Icons.shield,
              title: 'Risk Assessment',
              detail: 'Risk score',
            ),
            FeatureTile(
              icon: Icons.lightbulb_outline,
              title: 'Recommendations',
              detail: 'Safety tips',
            ),
          ],
        ),
        const SizedBox(height: 20),
        sectionTitle('Latest Analysis'),
        if (latest == null)
          panelCard(
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No scan history. Analyze a network to see results here.',
                  ),
                ),
              ],
            ),
          )
        else
          ResultCard(result: latest),
        const SizedBox(height: 20),
        const Text(
          'NetGuard provides an educational security assessment. A low risk score does not guarantee that a network is safe.',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return panelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: blue, size: 27),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            detail,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class WifiNetwork {
  final String ssid;
  final int rssi;
  final int frequency;
  final String capabilities;

  WifiNetwork({
    required this.ssid,
    required this.rssi,
    required this.frequency,
    required this.capabilities,
  });

  factory WifiNetwork.fromMap(Map<String, dynamic> map) {
    return WifiNetwork(
      ssid: map['ssid']?.toString() ?? 'Unknown',
      rssi: (map['rssi'] as num?)?.toInt() ?? -100,
      frequency: (map['frequency'] as num?)?.toInt() ?? 0,
      capabilities: map['capabilities']?.toString() ?? '',
    );
  }

  String get security {
    final c = capabilities.toUpperCase();
    if (c.contains('WPA3') || c.contains('SAE')) return 'WPA3';
    if (c.contains('WPA2')) return 'WPA2';
    if (c.contains('WEP')) return 'WEP';
    if (c.contains('WPA')) return 'WPA';
    return 'Open / Unknown';
  }

  String get status {
    if (security == 'WPA3' || security == 'WPA2') return 'GOOD';
    if (security == 'WPA') return 'WARNING';
    return 'DANGER';
  }

  Color get statusColor {
    if (status == 'GOOD') return green;
    if (status == 'WARNING') return orange;
    return red;
  }

  double get signal => ((rssi + 100) / 60).clamp(0.0, 1.0).toDouble();
}

class NearbyWifiRadar extends StatefulWidget {
  const NearbyWifiRadar({super.key});

  @override
  State<NearbyWifiRadar> createState() => _NearbyWifiRadarState();
}

class _NearbyWifiRadarState extends State<NearbyWifiRadar> {
  static const channel = MethodChannel('netguard/wifi');

  List<WifiNetwork> networks = [];
  bool scanning = false;
  String message = 'Tap Scan Nearby Wi-Fi to begin';

  Future<void> scanNetworks() async {
    if (scanning) return;

    setState(() {
      scanning = true;
      message = 'Scanning nearby networks...';
      networks = [];
    });

    try {
      final result = await channel.invokeMethod<List<dynamic>>('scanWifi');

      final found = (result ?? [])
          .map((e) => WifiNetwork.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (!mounted) return;

      setState(() {
        networks = found;
        message = found.isEmpty
            ? 'No networks found. Check Wi-Fi and Location settings.'
            : '${found.length} nearby networks detected';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        message = e.message ?? 'Unable to scan Wi-Fi networks';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        message = 'Scan error: $e';
      });
    } finally {
      if (mounted) setState(() => scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final good = networks.where((n) => n.status == 'GOOD').length;
    final warning = networks.where((n) => n.status == 'WARNING').length;
    final danger = networks.where((n) => n.status == 'DANGER').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          'Nearby Wi-Fi Radar',
          subtitle:
              'Discover nearby wireless networks and assess their advertised security',
        ),
        panelCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    scanning ? Icons.radar : Icons.wifi_tethering,
                    color: blue,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    scanning ? 'RADAR SCANNING...' : 'RADAR SCANNER',
                    style: const TextStyle(
                      color: blue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 270,
                width: double.infinity,
                child: CustomPaint(
                  painter: WifiRadarPainter(networks: networks),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: scanning ? null : scanNetworks,
                  icon: Icon(scanning ? Icons.hourglass_top : Icons.radar),
                  label: Text(scanning ? 'Scanning...' : 'Scan Nearby Wi-Fi'),
                ),
              ),
            ],
          ),
        ),
        if (networks.isNotEmpty) ...[
          const SizedBox(height: 14),
          panelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SECURITY SUMMARY',
                  style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem('GOOD', good, green),
                    _summaryItem('WARNING', warning, orange),
                    _summaryItem('DANGER', danger, red),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          sectionTitle('Detected Networks'),
          ...networks.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: panelCard(
                child: Row(
                  children: [
                    Icon(Icons.wifi, color: n.statusColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.ssid,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${n.security}  •  ${n.rssi} dBm  •  ${n.frequency} MHz',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          n.status,
                          style: TextStyle(
                            color: n.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const Text(
                          'Assessment',
                          style: TextStyle(color: Colors.white38, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        const Text(
          'Security labels are preliminary assessments based on advertised Wi-Fi capabilities. They do not prove that a network is trustworthy or detect all attacks.',
          style: TextStyle(color: Colors.white38, fontSize: 10),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _summaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class WifiRadarPainter extends CustomPainter {
  final List<WifiNetwork> networks;

  WifiRadarPainter({required this.networks});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.43;

    final ringPaint = Paint()
      ..color = blue.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fillPaint = Paint()
      ..color = blue.withValues(alpha: 0.035)
      ..style = PaintingStyle.fill;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, fillPaint);
      canvas.drawCircle(center, radius * i / 4, ringPaint);
    }

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      ringPaint,
    );

    final centerPaint = Paint()..color = blue;
    canvas.drawCircle(center, 5, centerPaint);

    for (int i = 0; i < networks.length; i++) {
      final network = networks[i];
      final angle = (i * 2.399) - math.pi / 2;
      final distance = radius * (0.35 + (1 - network.signal) * 0.55);

      final point = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      final dotPaint = Paint()..color = network.statusColor;
      canvas.drawCircle(point, 8, dotPaint);
      canvas.drawCircle(
        point,
        13,
        Paint()
          ..color = network.statusColor.withValues(alpha: 0.22)
          ..style = PaintingStyle.fill,
      );

      final label = TextPainter(
        text: TextSpan(
          text: network.ssid.length > 13
              ? '${network.ssid.substring(0, 13)}...'
              : network.ssid,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 105);

      final dx = point.dx > center.dx
          ? point.dx + 10
          : point.dx - label.width - 10;

      final dy = (point.dy - label.height / 2)
          .clamp(0.0, size.height - label.height)
          .toDouble();

      label.paint(canvas, Offset(dx.clamp(0.0, size.width - label.width), dy));
    }
  }

  @override
  bool shouldRepaint(covariant WifiRadarPainter oldDelegate) => true;
}

class AnalyzerPage extends StatefulWidget {
  final ValueChanged<ScanResult> onAnalyzed;

  const AnalyzerPage({super.key, required this.onAnalyzed});

  @override
  State<AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> {
  final ssidController = TextEditingController();
  String security = 'WPA2';
  bool isPublic = false;
  bool passwordProtected = true;
  ScanResult? result;

  @override
  void dispose() {
    ssidController.dispose();
    super.dispose();
  }

  void analyze() {
    final ssid = ssidController.text.trim();
    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the Wi-Fi network name (SSID).'),
        ),
      );
      return;
    }

    int score = 0;
    final findings = <String>[];

    if (security == 'Open') {
      score += 50;
      findings.add('Open network: wireless traffic may be exposed.');
    } else if (security == 'WEP') {
      score += 45;
      findings.add('WEP encryption is outdated and weak.');
    } else if (security == 'WPA') {
      score += 25;
      findings.add('WPA is an older security protocol.');
    } else if (security == 'WPA2') {
      score += 10;
      findings.add(
        'WPA2 is widely used; use a strong password and updated router.',
      );
    } else {
      findings.add('WPA3 is a modern Wi-Fi security protocol.');
    }

    if (isPublic) {
      score += 20;
      findings.add('Public hotspot: verify the network name with the venue.');
    }

    if (!passwordProtected && security != 'Open') {
      score += 20;
      findings.add('Password protection is reported as disabled.');
    }

    if (findings.isEmpty) {
      findings.add(
        'No basic configuration weakness was identified from the entered details.',
      );
    }

    if (score > 100) score = 100;

    final level = score >= 60
        ? 'High'
        : score >= 30
        ? 'Medium'
        : 'Low';

    final scan = ScanResult(
      ssid: ssid,
      security: security,
      score: score,
      level: level,
      findings: findings,
      time: DateTime.now(),
    );

    setState(() => result = scan);
    widget.onAnalyzed(scan);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const NearbyWifiRadar(),
        const SizedBox(height: 12),
        sectionTitle(
          'Wi-Fi Security Analyzer',
          subtitle: 'Enter network details to assess common security risks.',
        ),
        panelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Network name (SSID)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ssidController,
                decoration: const InputDecoration(
                  hintText: 'Example: Campus_WiFi',
                  prefixIcon: Icon(Icons.wifi),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Encryption / Security type',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: security,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                    value: 'Open',
                    child: Text('Open (No encryption)'),
                  ),
                  DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                  DropdownMenuItem(value: 'WPA', child: Text('WPA')),
                  DropdownMenuItem(value: 'WPA2', child: Text('WPA2')),
                  DropdownMenuItem(value: 'WPA3', child: Text('WPA3')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => security = v);
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('This is a public hotspot'),
                subtitle: const Text(
                  'For example: cafe, airport or railway station',
                ),
                value: isPublic,
                onChanged: (v) => setState(() => isPublic = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Password protected'),
                value: passwordProtected,
                onChanged: (v) => setState(() => passwordProtected = v),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: analyze,
                  icon: const Icon(Icons.security),
                  label: const Text('Analyze Network'),
                ),
              ),
            ],
          ),
        ),
        if (result != null) ...[
          const SizedBox(height: 20),
          sectionTitle('Analysis Result'),
          ResultCard(result: result!),
        ],
        const SizedBox(height: 20),
        const Text(
          'Note: This version analyzes the details you enter. It does not automatically scan nearby Wi-Fi networks or verify router security.',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

class ResultCard extends StatelessWidget {
  final ScanResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.score >= 60
        ? red
        : result.score >= 30
        ? orange
        : green;

    return panelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.ssid,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Security: ${result.security}',
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Risk score'),
              Text(
                '${result.score}/100',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: result.score / 100,
              minHeight: 10,
              backgroundColor: Colors.white12,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${result.level} Risk',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 28),
          const Text('Findings', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...result.findings.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(f, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          const Text(
            'Recommendations',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'â€¢ Prefer WPA3 or WPA2-AES encryption.\nâ€¢ Avoid sensitive transactions on untrusted public Wi-Fi.\nâ€¢ Verify the official hotspot name.\nâ€¢ Keep your device and router updated.',
            style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<ScanResult> history;

  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle(
          'Scan History',
          subtitle: 'Analysis records from this app session',
        ),
        if (history.isEmpty)
          panelCard(
            child: const Column(
              children: [
                Icon(Icons.history, size: 45, color: blue),
                SizedBox(height: 12),
                Text('No scan records yet'),
                Text(
                  'Your analysis results will appear here.',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          )
        else
          ...history.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ResultCard(result: item),
            ),
          ),
      ],
    );
  }
}

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  Widget guideItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: panelCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: blue, size: 27),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white60, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle(
          'Wi-Fi Security Guide',
          subtitle: 'Learn how to stay safe on wireless networks',
        ),
        guideItem(
          Icons.lock,
          'Use WPA2 or WPA3',
          'Prefer WPA3 when available. WPA2 with AES is generally preferable to older WEP or WPA configurations.',
        ),
        guideItem(
          Icons.public,
          'Be careful with public Wi-Fi',
          'Public hotspots may be monitored or impersonated. Confirm the network name with the venue.',
        ),
        guideItem(
          Icons.vpn_key,
          'Use strong passwords',
          'Use a unique, long Wi-Fi password. Avoid common or easily guessed passwords.',
        ),
        guideItem(
          Icons.system_update,
          'Keep devices updated',
          'Install operating system and security updates. Router firmware should also be updated.',
        ),
        guideItem(
          Icons.https,
          'Use HTTPS',
          'Check that websites use HTTPS. Avoid entering sensitive information on suspicious pages.',
        ),
        guideItem(
          Icons.share,
          'Disable unnecessary sharing',
          'Turn off file sharing and avoid exposing device services when connected to public networks.',
        ),
        guideItem(
          Icons.warning,
          'Avoid unknown hotspots',
          'Attackers can create fake hotspots with names similar to trusted networks.',
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle('Settings & About'),
        panelCard(
          child: const Column(
            children: [
              Icon(Icons.shield, size: 65, color: blue),
              SizedBox(height: 12),
              Text(
                'NetGuard',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              Text(
                'Intelligent Public Wi-Fi Security Analysis',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
              SizedBox(height: 12),
              Text('Version 1.0.0', style: TextStyle(color: blue)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        panelCard(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Platform: Android'),
              Text('Framework: Flutter'),
              Text('Purpose: Wi-Fi security awareness and risk assessment'),
              SizedBox(height: 15),
              Text(
                'Disclaimer',
                style: TextStyle(fontWeight: FontWeight.bold, color: orange),
              ),
              SizedBox(height: 6),
              Text(
                'NetGuard is an educational prototype. Its risk score is based on user-entered network details. It is not a penetration-testing tool and cannot guarantee that a network is safe.',
                style: TextStyle(color: Colors.white60, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
