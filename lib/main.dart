import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const ResikApp());

// ---------------------------------------------------------------
// WARNA & HELPER
// ---------------------------------------------------------------
class AppColors {
  static const bg = Color(0xFFF3EEE3); // krem
  static const dark = Color(0xFF17472A); // hijau tua
  static const green = Color(0xFF3B7A2F); // hijau
  static const orange = Color(0xFFE8582B); // aksen
  static const muted = Color(0xFF7A7A6E); // teks abu
}

String rupiah(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

/// Font judul / angka besar (serif display seperti di desain).
/// Kalau di Figma fontnya beda, ganti GoogleFonts.fraunces di sini saja.
TextStyle display({
  double size = 14,
  FontWeight weight = FontWeight.w800,
  Color color = AppColors.dark,
}) => GoogleFonts.fraunces(fontSize: size, fontWeight: weight, color: color);

// ---------------------------------------------------------------
// APP
// ---------------------------------------------------------------
class ResikApp extends StatelessWidget {
  const ResikApp({super.key});

  // google_fonts v9 punya tipe TextTheme sendiri, jadi font dipasang
  // per-style ke TextTheme bawaan Flutter.
  TextTheme _spaceGrotesk(TextTheme t) {
    TextStyle? f(TextStyle? s) =>
        s == null ? null : GoogleFonts.spaceGrotesk(textStyle: s);
    return t.copyWith(
      displayLarge: f(t.displayLarge),
      displayMedium: f(t.displayMedium),
      displaySmall: f(t.displaySmall),
      headlineLarge: f(t.headlineLarge),
      headlineMedium: f(t.headlineMedium),
      headlineSmall: f(t.headlineSmall),
      titleLarge: f(t.titleLarge),
      titleMedium: f(t.titleMedium),
      titleSmall: f(t.titleSmall),
      bodyLarge: f(t.bodyLarge),
      bodyMedium: f(t.bodyMedium),
      bodySmall: f(t.bodySmall),
      labelLarge: f(t.labelLarge),
      labelMedium: f(t.labelMedium),
      labelSmall: f(t.labelSmall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
      useMaterial3: true,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RESIK',
      theme: base.copyWith(textTheme: _spaceGrotesk(base.textTheme)),
      home: const SplashPage(), // layar pertama: Splash -> Login
    );
  }
}

// ---------------------------------------------------------------
// SPLASH ANIMATION
// ---------------------------------------------------------------
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  late final Animation<double> _pop = CurvedAnimation(
      parent: _c, curve: const Interval(0.0, 0.25, curve: Curves.easeOutBack));
  late final Animation<double> _leaf = CurvedAnimation(
      parent: _c, curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic));
  late final Animation<double> _sway = CurvedAnimation(
      parent: _c, curve: const Interval(0.5, 0.72, curve: Curves.elasticOut));
  late final Animation<double> _text = CurvedAnimation(
      parent: _c, curve: const Interval(0.62, 0.88, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) _goLoginFromSplash();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _goLoginFromSplash() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Widget _mark(double leaf, double sway) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Transform.rotate(
          angle: (1 - sway) * -0.25,
          alignment: Alignment.bottomCenter,
          child: ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: leaf,
              child: const SizedBox(
                width: 15,
                height: 28,
                child: CustomPaint(painter: _LeafPainter()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final p = _pop.value;
            final t = _text.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'resik-logo',
                  child: Opacity(
                    opacity: p.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: p,
                      child: _mark(_leaf.value, _sway.value),
                    ),
                  ),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: t,
                    child: Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset((1 - t) * 16, 0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text('RESIK',
                              style: display(size: 32)
                                  .copyWith(letterSpacing: 1)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  const _LeafPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final leaf = Path()
      ..moveTo(w / 2, 0)
      ..quadraticBezierTo(w * 1.1, h * 0.45, w / 2, h)
      ..quadraticBezierTo(-w * 0.1, h * 0.45, w / 2, 0);
    canvas.drawPath(leaf, Paint()..color = Colors.white);
    canvas.drawLine(
      Offset(w / 2, h * 0.3),
      Offset(w / 2, h * 0.92),
      Paint()
        ..color = AppColors.orange
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------------------------------------------------------------
// SHELL: halaman + bottom navigation
// ---------------------------------------------------------------
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  bool showNotif = false; // true = tampilkan halaman Notifikasi
  bool showChat = false; // true = tampilkan chatbot

  /// Dipanggil oleh LeafChatButton (tombol daun) di semua halaman.
  void bukaChat() => setState(() {
    showChat = true;
    showNotif = false;
  });

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        onNotif: () => setState(() {
          showNotif = true;
          showChat = false;
        }),
        onProfil: () => setState(() {
          index = 4; // tab Profil
          showNotif = false;
          showChat = false;
        }),
      ),
      TukarSaldoPage(onBack: () => setState(() => index = 0)),
      SetorPage(onBack: () => setState(() => index = 0)),
      RiwayatPage(onBack: () => setState(() => index = 0)),
      ProfilPage(onBack: () => setState(() => index = 0)),
    ];

    return Scaffold(
      body: SafeArea(
        child: showChat
            ? ChatPage(onBack: () => setState(() => showChat = false))
            : showNotif
            ? NotifikasiPage(onBack: () => setState(() => showNotif = false))
            : pages[index],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 86, // ruang ekstra di atas bar untuk lingkaran yang menonjol
          child: Stack(
            children: [
              // bar putih dengan border & bayangan keras (gaya RESIK)
              Positioned(
                left: 14,
                right: 14,
                bottom: 10,
                height: 64,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.dark, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: AppColors.dark, offset: Offset(0, 4)),
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 14,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              // 5 menu di atas bar
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _navItem(0, Icons.home_rounded, 'Beranda'),
                      ),
                      Expanded(
                        child: _navItem(
                          1,
                          Icons.account_balance_wallet_rounded,
                          'Tukar',
                        ),
                      ),
                      Expanded(
                        child: _navItem(2, Icons.recycling_rounded, 'Setor'),
                      ),
                      Expanded(
                        child: _navItem(
                          3,
                          Icons.receipt_long_rounded,
                          'Riwayat',
                        ),
                      ),
                      Expanded(
                        child: _navItem(4, Icons.person_rounded, 'Profil'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Satu menu. Menu yang aktif "naik" menjadi lingkaran oranye yang
  /// menonjol keluar dari bar; menu lain berupa ikon polos.
  Widget _navItem(int i, IconData icon, String label) {
    final active = !showNotif && !showChat && index == i;
    const durasi = Duration(milliseconds: 300);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        index = i;
        showNotif = false;
        showChat = false;
      }),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ikon / lingkaran
          AnimatedPositioned(
            duration: durasi,
            curve: Curves.easeOutBack,
            left: 0,
            right: 0,
            top: active ? 0 : 22,
            child: Center(
              child: AnimatedContainer(
                duration: durasi,
                curve: Curves.easeOutCubic,
                width: active ? 54 : 28,
                height: active ? 54 : 28,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: active ? 1 : 0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.dark.withValues(alpha: active ? 1 : 0),
                    width: 1.5,
                  ),
                  boxShadow: active
                      ? const [
                          BoxShadow(color: AppColors.dark, offset: Offset(0, 3)),
                        ]
                      : const [],
                ),
                child: Icon(
                  icon,
                  size: active ? 26 : 24,
                  color: active ? Colors.white : AppColors.dark,
                ),
              ),
            ),
          ),
          // label
          Positioned(
            left: 0,
            right: 0,
            bottom: 17,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: durasi,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: active ? AppColors.orange : AppColors.muted,
                ),
                child: Text(label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Halaman $title (belum dibuat)'));
}

// ---------------------------------------------------------------
// LAYAR: SETOR SAMPAH
// ---------------------------------------------------------------

/// Data satu jenis sampah.
class _Jenis {
  final String nama;
  final IconData icon;
  final int hargaPerKg;
  const _Jenis(this.nama, this.icon, this.hargaPerKg);
}

const _daftarJenis = <_Jenis>[
  _Jenis('PLASTIK', Icons.local_drink_outlined, 5000),
  _Jenis('KARDUS', Icons.inventory_2_outlined, 4700),
  _Jenis('MINYAK\nJELANTAH', Icons.opacity_outlined, 5000),
];

class SetorPage extends StatefulWidget {
  final VoidCallback? onBack;
  const SetorPage({super.key, this.onBack});

  @override
  State<SetorPage> createState() => _SetorPageState();
}

class _SetorPageState extends State<SetorPage> {
  // index jenis yang sedang dipilih (urutan = urutan kartu)
  final List<int> selected = [0];

  // satu controller berat untuk tiap jenis
  late final List<TextEditingController> controllers = List.generate(
    _daftarJenis.length,
    (_) => TextEditingController(text: '2.5'),
  );

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- logika ----------
  double _kg(int i) =>
      double.tryParse(controllers[i].text.replaceAll(',', '.')) ?? 0;

  int _harga(int i) => (_kg(i) * _daftarJenis[i].hargaPerKg).round();

  double get totalKg => selected.fold(0.0, (s, i) => s + _kg(i));
  int get totalSaldo => selected.fold(0, (s, i) => s + _harga(i));

  String _fmtKg(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  void _toggle(int i) {
    setState(() {
      if (selected.contains(i)) {
        if (selected.length > 1) selected.remove(i); // minimal 1 jenis
      } else {
        selected.add(i);
      }
    });
  }

  void _tambahJenis() {
    final sisa = List.generate(
      _daftarJenis.length,
      (i) => i,
    ).where((i) => !selected.contains(i));
    if (sisa.isEmpty) {
      showAppPopup(
        context,
        type: PopupType.info,
        title: 'Semua Jenis Sudah Dipilih',
        message: 'Semua kategori sampah sudah ada di setoranmu.',
      );
      return;
    }
    setState(() => selected.add(sisa.first));
  }

  Future<void> _konfirmasi() async {
    if (totalKg <= 0) {
      showAppPopup(
        context,
        type: PopupType.error,
        title: 'Berat Belum Diisi',
        message: 'Isi estimasi berat sampah terlebih dahulu sebelum konfirmasi.',
      );
      return;
    }

    final ok = await showAppPopup(
      context,
      type: PopupType.konfirmasi,
      title: 'Konfirmasi Setoran?',
      message: 'Pastikan data setoran berikut sudah benar.',
      content: PopupRincian(
        rows: [
          for (final i in selected)
            MapEntry(
              _daftarJenis[i].nama.replaceAll('\n', ' '),
              '${_fmtKg(_kg(i))} kg',
            ),
          MapEntry('Total Berat', '${_fmtKg(totalKg)} kg'),
          MapEntry('Total Saldo', rupiah(totalSaldo)),
        ],
      ),
      confirmLabel: 'Ya, Setor',
      cancelLabel: 'Periksa Lagi',
    );
    if (ok != true || !mounted) return;

    await showAppPopup(
      context,
      type: PopupType.sukses,
      title: 'Setoran Berhasil',
      message: 'Saldo ${rupiah(totalSaldo)} masuk setelah petugas menimbang.',
      autoClose: const Duration(seconds: 2),
    );
  }

  // ---------- tampilan ----------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topBar(),
          const SizedBox(height: 14),
          _stepper(),
          const SizedBox(height: 18),
          Text(
            'Pilih Kategori Sampah',
            style: display(size: 15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _kategoriRow(),
          const SizedBox(height: 16),
          for (final i in selected) _beratCard(i),
          const SizedBox(height: 4),
          _ringkasan(),
          const SizedBox(height: 18),
          _konfirmasiButton(),
          const SizedBox(height: 18),
          _caraSetor(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dark, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.dark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('Setor Sampah', style: display(size: 22))),
        const LeafChatButton(),
      ],
    );
  }

  Widget _stepper() {
    Widget step(String no, String label, bool active) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppColors.dark : _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.dark : Colors.transparent,
              border: active ? null : Border.all(color: AppColors.muted),
            ),
            child: Text(
              no,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.dark : AppColors.muted,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          step('1', 'Pilih Kategori', true),
          const Expanded(child: Divider(color: _line, indent: 6, endIndent: 6)),
          step('2', 'Konfirmasi', false),
        ],
      ),
    );
  }

  Widget _kategoriRow() {
    return Row(
      children: [
        for (int i = 0; i < _daftarJenis.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == _daftarJenis.length - 1 ? 0 : 10,
              ),
              child: _kategoriTile(i),
            ),
          ),
      ],
    );
  }

  Widget _kategoriTile(int i) {
    final j = _daftarJenis[i];
    final on = selected.contains(i);
    return GestureDetector(
      onTap: () => _toggle(i),
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: on ? AppColors.orange : _line,
            width: on ? 1.8 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              j.icon,
              size: 24,
              color: on ? AppColors.orange : AppColors.muted,
            ),
            const SizedBox(height: 6),
            Text(
              j.nama,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
                color: on ? AppColors.orange : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _beratCard(int i) {
    final j = _daftarJenis[i];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16, right: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dark, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppColors.dark, offset: Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTIMASI BERAT (KG)',
            style: TextStyle(
              fontSize: 8.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEAE0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.dark, width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllers[i],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: display(size: 22),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Text(
                  'KG',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMASI PENDAPATAN',
                      style: TextStyle(
                        fontSize: 8.5,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(rupiah(_harga(i)), style: display(size: 20)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEAE0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'RP ${rupiah(j.hargaPerKg).substring(3)} / KG',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _tambahJenis,
            child: CustomPaint(
              foregroundPainter: const _DashedBorderPainter(
                color: AppColors.dark,
                radius: 10,
              ),
              child: Container(
                height: 42,
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_rounded,
                      size: 15,
                      color: AppColors.dark,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tambah Jenis Sampah',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ringkasan() {
    return Column(
      children: [
        Row(
          children: [
            Text('Ringkasan Setoran', style: display(size: 15)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${selected.length} JENIS',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Berat',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            Text(
              '${_fmtKg(totalKg)} Kg',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, color: _line),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Saldo Diterima',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            Text(
              rupiah(totalSaldo),
              style: display(size: 18, color: AppColors.orange),
            ),
          ],
        ),
      ],
    );
  }

  Widget _konfirmasiButton() {
    return GestureDetector(
      onTap: _konfirmasi,
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(0, 3)),
          ],
        ),
        child: const Text(
          'Konfirmasi Setoran',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _caraSetor() {
    Widget item(String no, String judul, String isi) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              no,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isi,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 15, color: AppColors.dark),
              const SizedBox(width: 6),
              Text('Cara Setor Sampah', style: display(size: 13)),
            ],
          ),
          const SizedBox(height: 12),
          item(
            '1',
            'Pilih & Kategorikan',
            'Pisahkan sampah sesuai terlebih dahulu hingga bersih.',
          ),
          item(
            '2',
            'Bawa ke Drop Point',
            'Sari titik penjemputan atau datang langsung ke titik terdekat.',
          ),
          item(
            '3',
            'Timbang & Cairkan',
            'Petugas akan menimbang sampahmu dan saldo akan langsung masuk.',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// WIDGET UMUM
// ---------------------------------------------------------------
class AppCard extends StatelessWidget {
  final Widget child;
  final Color color;
  const AppCard({super.key, required this.child, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6DFCF)),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );
}

class Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool light;
  const Stat({
    super.key,
    required this.label,
    required this.value,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: light ? Colors.white70 : AppColors.muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: light ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  const ActivityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.bg,
            child: Icon(icon, size: 18, color: AppColors.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// LAYAR: BERANDA (RESIK)
// ---------------------------------------------------------------
class CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool light;
  const CardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white70 : AppColors.muted;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: light ? Colors.white12 : AppColors.bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class DashedLine extends StatelessWidget {
  final Color color;
  const DashedLine({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final n = (box.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            n,
            (_) => Container(width: 4, height: 1.5, color: color),
          ),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback? onNotif;
  final VoidCallback? onProfil;
  const HomePage({super.key, this.onNotif, this.onProfil});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 18),
          Text('Selamat pagi, dika', style: display(size: 26)),
          const Text(
            'Kamis, 17 September 2026',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          _saldoCard(),
          _targetCard(),
          _chartCard(),
          _priceCard(context),
          _transaksiCard(),
          _mapCard(context),
        ],
      ),
    );
  }

  // ---------- Header ----------
  Widget _header() {
    return Row(
      children: [
        // Logo RESIK (assets/images/Overlay.png)
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/Overlay.png',
            width: 30,
            height: 30,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 30,
              height: 30,
              color: AppColors.orange,
              child: const Icon(Icons.eco, color: Colors.white, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('RESIK', style: display(size: 20)),
        const Spacer(),
        // Lonceng notifikasi: ketuk untuk membuka halaman Notifikasi
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onNotif,
          child: Stack(
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.orange,
              ),
              // titik oranye hanya muncul kalau ada yang belum dibaca
              ValueListenableBuilder<List<_Notif>>(
                valueListenable: notifikasi,
                builder: (context, list, _) {
                  if (!list.any((n) => !n.dibaca)) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const LeafChatButton(color: AppColors.green),
        const SizedBox(width: 8),
        // Avatar "D": ketuk untuk membuka halaman Profil
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onProfil,
          child: const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.dark,
            child: Text(
              'D',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Saldo tabungan ----------
  Widget _saldoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.account_balance_wallet_outlined,
            title: 'SALDO TABUNGAN',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EDD9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '↗ +Rp78.092',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Rp', style: display(size: 16, weight: FontWeight.w400)),
              const SizedBox(width: 6),
              Text('171.770', style: display(size: 44)),
            ],
          ),
          const Divider(height: 24),
          const Row(
            children: [
              Expanded(
                child: Stat(label: 'SETORAN', value: '116,2 kg'),
              ),
              Expanded(
                child: Stat(label: 'EMISI', value: '169 kg'),
              ),
              Expanded(
                child: Stat(label: 'TRANSAKSI', value: '40'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Target September (kartu hijau tua) ----------
  Widget _targetCard() {
    return AppCard(
      color: AppColors.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(
            icon: Icons.track_changes,
            title: 'TARGET SEPTEMBER',
            light: true,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      width: 84,
                      height: 84,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        color: AppColors.orange,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '100%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Lunas',
                          style: TextStyle(color: Colors.white70, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '30,5 / 20 kg',
                      style: display(size: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Target tercapai! Bonus Rp10.000 dari RW masuk akhir bulan.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26, color: Colors.white24),
          const Row(
            children: [
              Expanded(
                child: Stat(
                  label: 'CO₂ TERREDUKSI',
                  value: '169 kg',
                  light: true,
                ),
              ),
              Expanded(
                child: Stat(
                  label: 'SETARA POHON',
                  value: '≈ 8 pohon',
                  light: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Grafik setoran 6 bulan ----------
  Widget _chartCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(
            icon: Icons.bar_chart_rounded,
            title: 'SETORAN 6 BULAN',
            trailing: Text(
              'kg / bulan',
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: Stack(
              children: [
                // garis target 20 kg
                const Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: DashedLine(color: AppColors.orange),
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Bar(label: 'Apr', kg: 8),
                    _Bar(label: 'Mei', kg: 11),
                    _Bar(label: 'Jun', kg: 10),
                    _Bar(label: 'Jul', kg: 19),
                    _Bar(label: 'Agu', kg: 12),
                    _Bar(label: 'Sep', kg: 20, highlight: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Harga hari ini ----------
  void _semuaHarga(BuildContext context) {
    showAppPopup(
      context,
      type: PopupType.info,
      title: 'Harga Sampah Hari Ini',
      message: 'Harga dapat berubah setiap hari mengikuti pasar.',
      content: const PopupRincian(
        highlightLast: false,
        rows: [
          MapEntry('Organik Dapur', 'Rp1.000/kg'),
          MapEntry('Plastik PET', 'Rp3.500/kg'),
          MapEntry('Kertas & Kardus', 'Rp2.200/kg'),
        ],
      ),
      confirmLabel: 'Tutup',
    );
  }

  void _infoLokasi(BuildContext context) {
    showAppPopup(
      context,
      type: PopupType.info,
      title: 'Pos Melati Indah',
      message: 'Jl. Bigum-guza Barat No. 12, sekitar 450 m dari lokasimu.',
      content: const PopupRincian(
        highlightLast: false,
        rows: [
          MapEntry('Status', 'Buka'),
          MapEntry('Tutup', '17.00'),
          MapEntry('Koordinat', '-6.3979, 106.8210'),
        ],
      ),
      confirmLabel: 'Tutup',
    );
  }

  Widget _priceCard(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const CardHeader(
            icon: Icons.sell_outlined,
            title: 'HARGA HARI INI',
            trailing: Text(
              '17 Sep',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 8),
          const _PriceRow(
            icon: Icons.eco_outlined,
            iconBg: Color(0xFFE3EDD9),
            name: 'Organik Dapur',
            sub: 'Eceng & sisa dapur',
            price: 'Rp1.000/kg',
            change: '+1,2%',
            up: true,
          ),
          const _PriceRow(
            icon: Icons.local_drink_outlined,
            iconBg: Color(0xFFFBEBC8),
            name: 'Plastik PET',
            sub: 'Botol bening & kemasan',
            price: 'Rp3.500/kg',
            change: '+6,2%',
            up: true,
          ),
          const _PriceRow(
            icon: Icons.inventory_2_outlined,
            iconBg: Color(0xFFFADBD0),
            name: 'Kertas & Kardus',
            sub: 'Koran, karton, buku',
            price: 'Rp2.200/kg',
            change: '−1,8%',
            up: false,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.orange,
                side: const BorderSide(color: AppColors.orange),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _semuaHarga(context),
              child: const Text('Lihat Semua Harga  >'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Transaksi terakhir ----------
  Widget _transaksiCard() {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.receipt_long_outlined,
            title: 'TRANSAKSI TERAKHIR',
            trailing: Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.orange,
              ),
            ),
          ),
          SizedBox(height: 8),
          ActivityTile(
            icon: Icons.south_west_rounded,
            title: 'Kardus',
            subtitle: 'Hari ini · 10.20 · 3,2 kg',
            amount: '+Rp11.440',
          ),
          ActivityTile(
            icon: Icons.south_west_rounded,
            title: 'Botol Plastik',
            subtitle: 'Kemarin · 09.15 · 4 kg',
            amount: '+Rp4.000',
          ),
        ],
      ),
    );
  }

  // ---------- Titik setor terdekat ----------
  Widget _mapCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(
            icon: Icons.location_on_outlined,
            title: 'TITIK SETOR TERDEKAT',
            trailing: Text(
              'Semua Titik',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.orange,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Placeholder peta: ganti dengan flutter_map / gambar peta nanti
          Container(
            height: 140,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE6D0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.orange,
                    size: 38,
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Koordinat: -6.3979, 106.8210',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _infoLokasi(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.dark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Lihat Lokasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.circle, size: 9, color: AppColors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pos Melati Indah',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Buka',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Row(
            children: [
              SizedBox(width: 17),
              Expanded(
                child: Text(
                  'Jl. Bigum-guza Barat No. 12 · 450 m',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
              Text(
                'tutup 17.00',
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double kg;
  final bool highlight;
  const _Bar({required this.label, required this.kg, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${kg.toStringAsFixed(0)} kg',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.orange : AppColors.muted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 26,
          height: kg / 20 * 100, // 20 kg = tinggi 100
          decoration: BoxDecoration(
            color: highlight ? AppColors.orange : AppColors.green,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String name;
  final String sub;
  final String price;
  final String change;
  final bool up;
  const _PriceRow({
    required this.icon,
    required this.iconBg,
    required this.name,
    required this.sub,
    required this.price,
    required this.change,
    required this.up,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.dark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: up ? AppColors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// LAYAR: TUKAR SALDO (E-Wallet & Transfer Bank)
// ---------------------------------------------------------------

/// Format angka jadi 150.000 saat mengetik.
class RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final text = rupiah(int.parse(digits)).substring(3); // buang "Rp "
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Kotak dengan border putus-putus (kartu ringkasan & tombol tambah).
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

class TukarSaldoPage extends StatefulWidget {
  final VoidCallback? onBack;
  const TukarSaldoPage({super.key, this.onBack});

  @override
  State<TukarSaldoPage> createState() => _TukarSaldoPageState();
}

class _TukarSaldoPageState extends State<TukarSaldoPage> {
  static const int minimal = 50000;
  static const int biayaLayanan = 1000;

  int saldo = 212450;
  final controller = TextEditingController(text: '150.000');
  int amount = 150000;
  int method = 0; // 0 = E-Wallet, 1 = Transfer Bank
  int provider = 0; // index provider pada daftar metode yang aktif
  final quickAmounts = [50000, 100000, 150000, 200000];

  // daftar provider untuk tiap metode
  static const ewallets = ['Gopay', 'Dana', 'OVO', 'ShopeePay'];
  static const banks = ['Mandiri', 'BCA', 'BNI', 'BRI'];
  List<String> get providers => method == 0 ? ewallets : banks;

  // riwayat penarikan (terbaru di index 0)
  final List<Map<String, dynamic>> history = [
    {'name': 'Gopay - 0812***', 'date': '12 Sep 2026', 'amount': 150000},
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void setAmount(int v) {
    setState(() {
      amount = v;
      controller.text = rupiah(v).substring(3);
    });
  }

  Future<void> _submit() async {
    if (amount < minimal) {
      showAppPopup(
        context,
        type: PopupType.error,
        title: 'Penarikan Gagal',
        message: 'Minimal penarikan adalah ${rupiah(minimal)}.',
      );
      return;
    }
    if (amount > saldo) {
      showAppPopup(
        context,
        type: PopupType.error,
        title: 'Saldo Tidak Cukup',
        message:
            'Saldo tersedia ${rupiah(saldo)}, sedangkan nominal penarikan ${rupiah(amount)}.',
      );
      return;
    }

    final ok = await showAppPopup(
      context,
      type: PopupType.konfirmasi,
      title: 'Tukar Saldo Sekarang?',
      message: 'Periksa kembali rincian penarikan berikut.',
      content: PopupRincian(
        rows: [
          MapEntry('Tujuan', providers[provider]),
          MapEntry('Nominal', rupiah(amount)),
          MapEntry('Biaya Layanan', rupiah(biayaLayanan)),
          MapEntry('Total Diterima', rupiah(amount)),
        ],
      ),
      confirmLabel: 'Ya, Tukar',
      cancelLabel: 'Batal',
    );
    if (ok != true || !mounted) return;

    // catat ke riwayat & kurangi saldo
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final now = DateTime.now();
    final nomor = method == 0 ? '0812***' : '1234***';
    final tujuan = providers[provider];
    final nominal = amount;
    setState(() {
      saldo -= nominal;
      history.insert(0, {
        'name': '$tujuan - $nomor',
        'date': '${now.day} ${bulan[now.month - 1]} ${now.year}',
        'amount': nominal,
      });
    });

    await showAppPopup(
      context,
      type: PopupType.sukses,
      title: 'Penukaran Berhasil',
      message: '${rupiah(nominal)} sedang dikirim ke $tujuan.',
      autoClose: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topBar(),
          const SizedBox(height: 18),
          _saldoCard(),
          const SizedBox(height: 22),
          _label('METODE PENARIKAN'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _methodBox(0, Icons.smartphone_rounded, 'E-Wallet'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _methodBox(
                  1,
                  Icons.account_balance_rounded,
                  'Transfer Bank',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _providerRow(),
          const SizedBox(height: 14),
          _nominalBox(),
          const SizedBox(height: 8),
          Text(
            '*Minimal Penarikan ${rupiah(minimal)}',
            style: TextStyle(
              fontSize: 11,
              color: amount < minimal ? AppColors.orange : AppColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          _quickChips(),
          const SizedBox(height: 18),
          _summaryCard(),
          const SizedBox(height: 22),
          _submitButton(),
          const SizedBox(height: 26),
          Row(
            children: [
              _label('TARIK TERAKHIR'),
              const Spacer(),
              const Text(
                'LIHAT SEMUA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _historyTile(),
        ],
      ),
    );
  }

  // ---------- bagian-bagian layar ----------
  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dark, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.dark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('Tukar Saldo', style: display(size: 22)),
        const Spacer(),
        const LeafChatButton(),
      ],
    );
  }

  Widget _saldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: AppColors.orange, offset: Offset(5, 5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SALDO TERSEDIA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rupiah(saldo),
                  style: display(size: 32, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco, size: 11, color: Colors.white70),
                      SizedBox(width: 5),
                      Text(
                        'Eco-Warrior Level 2',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 40,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w600,
      color: AppColors.muted,
    ),
  );

  Widget _providerRow() {
    final list = providers;
    return Row(
      children: [
        for (int i = 0; i < list.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == list.length - 1 ? 0 : 8),
              child: GestureDetector(
                onTap: () => setState(() => provider = i),
                child: Container(
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: provider == i ? AppColors.dark : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.dark),
                  ),
                  child: Text(
                    list[i],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: provider == i ? Colors.white : AppColors.dark,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _methodBox(int i, IconData icon, String label) {
    final selected = method == i;
    return GestureDetector(
      onTap: () => setState(() {
        method = i;
        provider = 0;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.orange : const Color(0xFFE6DFCF),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFADBD0)
                    : const Color(0xFFEDE9DF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 19,
                color: selected ? AppColors.orange : AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? AppColors.dark : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nominalBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dark, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOMINAL PENARIKAN',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rp',
                style: display(
                  size: 26,
                  weight: FontWeight.w700,
                  color: const Color(0xFF9AA598),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                    RibuanFormatter(),
                  ],
                  style: display(size: 30),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => setState(
                    () => amount = int.tryParse(v.replaceAll('.', '')) ?? 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickChips() {
    return Row(
      children: [
        for (int i = 0; i < quickAmounts.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == quickAmounts.length - 1 ? 0 : 8,
              ),
              child: GestureDetector(
                onTap: () => setAmount(quickAmounts[i]),
                child: Container(
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: amount == quickAmounts[i]
                        ? AppColors.dark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.dark),
                  ),
                  child: Text(
                    '${quickAmounts[i] ~/ 1000}k',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: amount == quickAmounts[i]
                          ? Colors.white
                          : AppColors.dark,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _summaryCard() {
    return CustomPaint(
      foregroundPainter: const _DashedBorderPainter(
        color: Color(0xFFB9B3A2),
        radius: 16,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE8DA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _summaryRow('Biaya Layanan', rupiah(biayaLayanan)),
            _summaryRow('Estimasi Tiba', 'Instan ( < 10 Menit )'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: Color(0xFFD8D2C2)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Diterima',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  Text(
                    rupiah(amount),
                    style: display(size: 18, color: AppColors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: _submit,
      child: Container(
        height: 58,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: AppColors.orange, offset: Offset(5, 5)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Tukar Sekarang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyTile() {
    final last = history.first;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6DFCF)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E0CF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              size: 17,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  last['name'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  last['date'] as String,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            rupiah(last['amount'] as int),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// LAYAR: RIWAYAT
// ---------------------------------------------------------------

/// Data satu transaksi.
class _Trx {
  final String judul;
  final String jam;
  final String status; // 'Selesai' / 'Diproses'
  final int nominal;
  final bool masuk; // true = +, false = -
  final String sub; // teks kecil di bawah nominal
  final IconData icon;
  const _Trx({
    required this.judul,
    required this.jam,
    required this.status,
    required this.nominal,
    required this.masuk,
    required this.sub,
    required this.icon,
  });
}

/// Satu kelompok tanggal (HARI INI, KEMARIN, dst).
class _Grup {
  final String label;
  final List<_Trx> items;
  const _Grup(this.label, this.items);
}

const _riwayat = <_Grup>[
  _Grup('HARI INI', [
    _Trx(
      judul: 'Setor Plastik PET',
      jam: '14:20',
      status: 'Selesai',
      nominal: 12500,
      masuk: true,
      sub: '2.5 KG',
      icon: Icons.local_drink_outlined,
    ),
    _Trx(
      judul: 'Tarik Saldo\n(GoPay)',
      jam: '09:15',
      status: 'Diproses',
      nominal: 150000,
      masuk: false,
      sub: 'BIAYA ADMIN RP\n1.000',
      icon: Icons.payments_outlined,
    ),
  ]),
  _Grup('KEMARIN', [
    _Trx(
      judul: 'Setor Kardus',
      jam: '16:45',
      status: 'Selesai',
      nominal: 34200,
      masuk: true,
      sub: '11.4 KG',
      icon: Icons.inventory_2_outlined,
    ),
    _Trx(
      judul: 'Setor Kertas',
      jam: '19:50',
      status: 'Selesai',
      nominal: 39900,
      masuk: true,
      sub: '20.9 KG',
      icon: Icons.inventory_2_outlined,
    ),
  ]),
  _Grup('15 SEP 2023', [
    _Trx(
      judul: 'Setor Minyak\nJelantah',
      jam: '10:30',
      status: 'Selesai',
      nominal: 18000,
      masuk: true,
      sub: '1.2 KG',
      icon: Icons.eco_outlined,
    ),
  ]),
];

class RiwayatPage extends StatelessWidget {
  final VoidCallback? onBack;
  const RiwayatPage({super.key, this.onBack});

  // Ringkasan bulan ini (nanti ganti dengan hitungan dari data asli)
  static const String terkumpul = '42.5';
  static const String saldoMasuk = 'Rp 212k';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topBar(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ringkasCard(
                  icon: Icons.recycling_rounded,
                  label: 'TERKUMPUL',
                  value: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(terkumpul, style: display(size: 24)),
                      const SizedBox(width: 3),
                      Text(
                        'Kg',
                        style: display(size: 11, weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ringkasCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'SALDO MASUK',
                  value: Text(saldoMasuk, style: display(size: 22)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _bulanHeader('September 2026'),
          const SizedBox(height: 16),
          for (final g in _riwayat) ...[
            _grupHeader(g.label),
            const SizedBox(height: 12),
            for (final t in g.items) _trxTile(context, t),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  // ---------- bagian-bagian ----------
  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dark, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.dark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('Riwayat', style: display(size: 22))),
        const LeafChatButton(),
      ],
    );
  }

  Widget _ringkasCard({
    required IconData icon,
    required String label,
    required Widget value,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dark, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppColors.dark, offset: Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFADBD0),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(icon, size: 11, color: AppColors.orange),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    letterSpacing: .5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          value,
        ],
      ),
    );
  }

  Widget _bulanHeader(String text) {
    return Row(
      children: [
        Text(text, style: display(size: 14, weight: FontWeight.w700)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: _line, height: 1)),
        const SizedBox(width: 6),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.muted,
        ),
      ],
    );
  }

  Widget _grupHeader(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 9.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: _line, height: 1)),
      ],
    );
  }

  Widget _trxTile(BuildContext context, _Trx t) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => _detail(context, t),
    child: _trxTileBody(t),
  );

  void _detail(BuildContext context, _Trx t) {
    final selesai = t.status == 'Selesai';
    showAppPopup(
      context,
      type: selesai ? PopupType.sukses : PopupType.peringatan,
      title: t.judul.replaceAll('\n', ' '),
      message: selesai
          ? 'Transaksi ini sudah selesai diproses.'
          : 'Transaksi sedang diproses. Mohon tunggu sebentar.',
      content: PopupRincian(
        rows: [
          MapEntry('Waktu', t.jam),
          MapEntry('Status', t.status),
          MapEntry('Keterangan', t.sub.replaceAll('\n', ' ')),
          MapEntry(
            t.masuk ? 'Saldo Masuk' : 'Saldo Keluar',
            '${t.masuk ? '+' : '-'}${rupiah(t.nominal)}',
          ),
        ],
      ),
      confirmLabel: 'Tutup',
    );
  }

  Widget _trxTileBody(_Trx t) {
    final selesai = t.status == 'Selesai';
    final statusColor = selesai ? AppColors.green : AppColors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          // ikon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: t.masuk
                  ? const Color(0xFFFADBD0)
                  : const Color(0xFFE6E0CF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              t.icon,
              size: 22,
              color: t.masuk ? AppColors.orange : AppColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          // judul + jam + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.judul,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    text: '${t.jam} · ',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                    children: [
                      TextSpan(
                        text: t.status,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // nominal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${t.masuk ? '+' : '-'}${rupiah(t.nominal)}',
                style: display(size: 15, weight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                t.sub,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 8,
                  letterSpacing: .5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// LAYAR: PROFIL
// ---------------------------------------------------------------

/// Data satu rekening pencairan.
class _Rekening {
  String metode;
  String nomor;
  String pemilik;
  _Rekening(this.metode, this.nomor, this.pemilik);

  /// 081234567890 -> 0812 • • • • 7890
  String get masked {
    if (nomor.length <= 8) return nomor;
    return '${nomor.substring(0, 4)} • • • • ${nomor.substring(nomor.length - 4)}';
  }
}

const _daftarMetode = <String>[
  'E-Wallet (GoPay)',
  'E-Wallet (Dana)',
  'E-Wallet (OVO)',
  'E-Wallet (ShopeePay)',
  'BCA',
  'Mandiri',
  'BNI',
  'BRI',
];

const _tipePengguna = <String>[
  'Rumah Tangga',
  'Usaha / UMKM',
  'Sekolah',
  'Perkantoran',
];

/// Label kecil di atas input.
Widget _miniLabel(String text) => Text(
  text,
  style: const TextStyle(
    fontSize: 8,
    letterSpacing: .8,
    fontWeight: FontWeight.w700,
    color: AppColors.muted,
  ),
);

/// Dropdown dengan tampilan kotak (dipakai di Profil & form rekening).
class _BoxDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color border;
  final double borderWidth;
  final double radius;
  const _BoxDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.border = _line,
    this.borderWidth = 1,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium!;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: borderWidth),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.muted,
          ),
          hint: Text(
            hint,
            style: base.copyWith(
              fontSize: 11,
              color: AppColors.muted.withValues(alpha: .7),
            ),
          ),
          style: base.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
          items: [
            for (final e in items) DropdownMenuItem(value: e, child: Text(e)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Input teks berlabel untuk halaman profil.
class _ProfilField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? formatters;
  const _ProfilField({
    required this.label,
    required this.controller,
    this.keyboard,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _miniLabel(label),
        const SizedBox(height: 4),
        SizedBox(
          height: 42,
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            inputFormatters: formatters,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.dark, width: 1.3),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class ProfilPage extends StatefulWidget {
  final VoidCallback? onBack;
  const ProfilPage({super.key, this.onBack});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final namaC = TextEditingController(text: 'Andhika Ahmad');
  final hpC = TextEditingController(text: '+62 8123 456 789');
  final nikC = TextEditingController(text: '1234567891011213');
  final alamatC = TextEditingController(text: 'Jl. Sigura-gura Barat No.12, 450 m');
  final rtC = TextEditingController(text: '005');
  final rwC = TextEditingController(text: '012');
  final kelC = TextEditingController(
    text: 'Sigura-gura barat, Sigura-gura, Kota Malang',
  );

  String tipe = _tipePengguna.first;

  final List<_Rekening> rekening = [
    _Rekening('E-Wallet (GoPay)', '081234567890', 'Dhika Ahmad'),
  ];
  int utama = 0; // index rekening utama

  @override
  void dispose() {
    for (final c in [namaC, hpC, nikC, alamatC, rtC, rwC, kelC]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- logika rekening ----------
  Future<_Rekening?> _bukaForm({_Rekening? awal}) {
    return showModalBottomSheet<_Rekening>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _RekeningSheet(initial: awal),
    );
  }

  Future<void> _tambah() async {
    final r = await _bukaForm();
    if (r == null || !mounted) return;
    setState(() => rekening.add(r));
    await showAppPopup(
      context,
      type: PopupType.sukses,
      title: 'Rekening Ditambahkan',
      message: '${r.metode} berhasil ditambahkan sebagai metode pencairan.',
      autoClose: const Duration(milliseconds: 1800),
    );
  }

  Future<void> _ganti(int i) async {
    final r = await _bukaForm(awal: rekening[i]);
    if (r == null || !mounted) return;
    setState(() => rekening[i] = r);
    await showAppPopup(
      context,
      type: PopupType.sukses,
      title: 'Metode Diperbarui',
      message: 'Rekening pencairan berhasil diganti ke ${r.metode}.',
      autoClose: const Duration(milliseconds: 1800),
    );
  }

  Future<void> _jadikanUtama(int i) async {
    if (utama == i) return;
    final ok = await showAppPopup(
      context,
      type: PopupType.konfirmasi,
      title: 'Jadikan Metode Utama?',
      message:
          '${rekening[i].metode} akan dipakai sebagai rekening pencairan utama.',
      confirmLabel: 'Ya, Jadikan Utama',
      cancelLabel: 'Batal',
    );
    if (ok == true && mounted) setState(() => utama = i);
  }

  Future<void> _keluar() async {
    final ok = await showAppPopup(
      context,
      type: PopupType.konfirmasi,
      title: 'Keluar dari Akun?',
      message: 'Kamu perlu masuk lagi untuk memakai RESIK.',
      confirmLabel: 'Ya, Keluar',
      cancelLabel: 'Batal',
    );
    if (ok == true && mounted) _goLogin(context);
  }

  void _ubahLokasi() {
    showAppPopup(
      context,
      type: PopupType.info,
      title: 'Ubah Lokasi',
      message:
          'Pilih titik lewat peta akan tersedia di versi berikutnya. Koordinat saat ini: -6.3979, 106.8210.',
    );
  }

  // ---------- tampilan ----------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topBar(),
          const SizedBox(height: 16),
          _profilCard(),
          const SizedBox(height: 18),
          _sectionLabel('DATA PRIBADI'),
          const SizedBox(height: 10),
          _ProfilField(label: 'NAMA LENGKAP (SESUAI KTP)', controller: namaC),
          _ProfilField(
            label: 'NOMOR HP / WHATSAPP',
            controller: hpC,
            keyboard: TextInputType.phone,
          ),
          _ProfilField(
            label: 'NIK (KTP)',
            controller: nikC,
            keyboard: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
          ),
          _miniLabel('TIPE PENGGUNA'),
          const SizedBox(height: 4),
          _BoxDropdown(
            value: tipe,
            hint: 'Pilih tipe',
            items: _tipePengguna,
            onChanged: (v) => setState(() => tipe = v ?? tipe),
          ),
          const SizedBox(height: 18),
          _sectionLabel('ALAMAT'),
          const SizedBox(height: 10),
          _ProfilField(label: 'ALAMAT LENGKAP', controller: alamatC),
          Row(
            children: [
              Expanded(
                child: _ProfilField(
                  label: 'RT',
                  controller: rtC,
                  keyboard: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfilField(
                  label: 'RW',
                  controller: rwC,
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          _ProfilField(label: 'KELURAHAN / KEC. & KOTA', controller: kelC),
          _miniLabel('PINPOINT LOKASI'),
          const SizedBox(height: 4),
          _peta(),
          const SizedBox(height: 18),
          _sectionLabel('REKENING PENCAIRAN'),
          const SizedBox(height: 10),
          for (int i = 0; i < rekening.length; i++) _rekeningCard(i),
          _tambahButton(),
          const SizedBox(height: 14),
          _keluarButton(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dark, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.dark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('Profil', style: display(size: 22))),
        const LeafChatButton(),
      ],
    );
  }

  Widget _profilCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          // Foto profil (ganti Icon dengan Image.asset kalau sudah ada fotonya)
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EDD9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.orange, width: 2),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 34,
                    color: AppColors.dark,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      size: 9,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dhika Ahmad', style: display(size: 16)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBEBC8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Member Gold',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A5A00),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(width: 3, height: 11, color: AppColors.orange),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 9.5,
            letterSpacing: 1,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  Widget _peta() {
    // Placeholder peta: ganti dengan flutter_map / gambar peta nanti
    return Container(
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF7E8F5E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.location_on, color: AppColors.orange, size: 34),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Koordinat: -6.3979, 106.8210',
                      style: TextStyle(fontSize: 9, color: AppColors.muted),
                    ),
                  ),
                  GestureDetector(
                    onTap: _ubahLokasi,
                    child: const Text(
                      'Ubah Lokasi',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rekeningCard(int i) {
    final r = rekening[i];
    final isUtama = utama == i;
    const label = TextStyle(
      fontSize: 7.5,
      letterSpacing: 1,
      fontWeight: FontWeight.w600,
      color: Colors.white54,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isUtama ? 'METODE UTAMA' : 'METODE LAIN', style: label),
              const Spacer(),
              // ketuk lingkaran ini untuk menjadikan rekening utama
              GestureDetector(
                onTap: () => _jadikanUtama(i),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUtama ? AppColors.orange : Colors.transparent,
                    border: Border.all(
                      color: isUtama ? AppColors.orange : Colors.white38,
                      width: 1.5,
                    ),
                  ),
                  child: isUtama
                      ? const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(r.metode, style: display(size: 15, color: Colors.white)),
          const SizedBox(height: 14),
          const Text('NOMOR AKUN / NOMOR REKENING', style: label),
          const SizedBox(height: 3),
          Text(
            r.masked,
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NAMA PEMILIK', style: label),
                    const SizedBox(height: 3),
                    Text(
                      r.pemilik,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _ganti(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'GANTI METODE',
                    style: TextStyle(
                      fontSize: 8,
                      letterSpacing: .5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tambahButton() {
    return GestureDetector(
      onTap: _tambah,
      child: CustomPaint(
        foregroundPainter: const _DashedBorderPainter(
          color: Color(0xFFB9B3A2),
          radius: 12,
        ),
        child: Container(
          height: 44,
          width: double.infinity,
          alignment: Alignment.center,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_rounded, size: 14, color: AppColors.orange),
              SizedBox(width: 8),
              Text(
                'Tambah Metode Pencairan',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keluarButton() {
    return GestureDetector(
      onTap: _keluar,
      child: Container(
        height: 46,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout_rounded, size: 15, color: AppColors.orange),
            SizedBox(width: 8),
            Text(
              'Keluar dari Akun',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Form (bottom sheet) untuk tambah / ganti rekening pencairan.
class _RekeningSheet extends StatefulWidget {
  final _Rekening? initial; // null = tambah baru, isi = ganti metode
  const _RekeningSheet({this.initial});

  @override
  State<_RekeningSheet> createState() => _RekeningSheetState();
}

class _RekeningSheetState extends State<_RekeningSheet> {
  String? metode;
  late final TextEditingController pemilikC;
  late final TextEditingController nomorC;
  String? error;

  bool get edit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    metode = widget.initial?.metode;
    pemilikC = TextEditingController(text: widget.initial?.pemilik ?? '');
    nomorC = TextEditingController(text: widget.initial?.nomor ?? '');
  }

  @override
  void dispose() {
    pemilikC.dispose();
    nomorC.dispose();
    super.dispose();
  }

  void _simpan() {
    final nama = pemilikC.text.trim();
    final nomor = nomorC.text.trim();
    if (metode == null || nama.isEmpty || nomor.length < 6) {
      setState(() => error = 'Lengkapi semua data (nomor minimal 6 digit)');
      return;
    }
    Navigator.pop(context, _Rekening(metode!, nomor, nama));
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 11,
      color: AppColors.muted.withValues(alpha: .7),
    ),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.dark, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.dark, width: 1.5),
              boxShadow: const [
                BoxShadow(color: AppColors.dark, offset: Offset(0, 5)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    edit ? Icons.edit_rounded : Icons.add_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFADBD0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF2B9A3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.credit_card_rounded,
                        size: 16,
                        color: AppColors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        edit
                            ? 'Ganti Rekening Pencairan'
                            : 'Tambah Rekening Pencairan',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _BoxDropdown(
                  value: metode,
                  hint: 'Metode Pencairan',
                  items: _daftarMetode,
                  border: AppColors.dark,
                  borderWidth: 1.2,
                  onChanged: (v) => setState(() => metode = v),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pemilikC,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 12),
                  decoration: _dec('Nama Pemilik'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nomorC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(20),
                  ],
                  style: const TextStyle(fontSize: 12),
                  decoration: _dec('Nomor Akun / Nomor Rekening'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.orange,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                HardButton(label: edit ? 'Simpan' : 'Tambah', onTap: _simpan),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// LAYAR: NOTIFIKASI
// ---------------------------------------------------------------

/// Data satu notifikasi.
class _Notif {
  final String grup; // HARI INI / KEMARIN / tanggal
  final String judul;
  final String isi;
  final String waktu;
  final IconData icon;
  final Color bg;
  final Color fg;
  bool dibaca;
  _Notif({
    required this.grup,
    required this.judul,
    required this.isi,
    required this.waktu,
    required this.icon,
    required this.bg,
    required this.fg,
    this.dibaca = false,
  });
}

/// Daftar notifikasi dipakai bersama oleh Beranda (titik merah di lonceng)
/// dan halaman Notifikasi. Nanti ganti dengan data dari server.
final ValueNotifier<List<_Notif>> notifikasi = ValueNotifier<List<_Notif>>([
  _Notif(
    grup: 'HARI INI',
    judul: 'Saldo Masuk',
    isi: 'Saldo masuk Rp 15.000 dari Setoran #TX992',
    waktu: '10:46',
    icon: Icons.account_balance_wallet_outlined,
    bg: const Color(0xFFE3EDD9),
    fg: AppColors.green,
  ),
  _Notif(
    grup: 'HARI INI',
    judul: 'Penjemputan Sampah',
    isi: 'Armada sedang menuju lokasi Anda. Pastikan sampah sudah terpilah.',
    waktu: '08:20',
    icon: Icons.local_shipping_outlined,
    bg: const Color(0xFFFADBD0),
    fg: AppColors.orange,
  ),
  _Notif(
    grup: 'HARI INI',
    judul: 'Update Harga',
    isi: 'Kabar gembira! Harga Plastik PET naik hari ini menjadi Rp 4.500/kg.',
    waktu: '06:00',
    icon: Icons.trending_up_rounded,
    bg: const Color(0xFFDCE8FA),
    fg: const Color(0xFF3B6FD4),
    dibaca: true,
  ),
  _Notif(
    grup: 'KEMARIN',
    judul: 'Setoran Berhasil',
    isi: 'Setoran 05689 telah diverifikasi. Tabungan Anda bertambah Rp 8.200.',
    waktu: 'Kemarin',
    icon: Icons.check_circle_rounded,
    bg: const Color(0xFFE6E0CF),
    fg: AppColors.muted,
    dibaca: true,
  ),
  _Notif(
    grup: 'KEMARIN',
    judul: 'Tips Memilah',
    isi: 'Cara jitu membersihkan botol minyak agar diterima di bank sampah.',
    waktu: 'Kemarin',
    icon: Icons.lightbulb_outline_rounded,
    bg: const Color(0xFFE6E0CF),
    fg: AppColors.muted,
    dibaca: true,
  ),
  _Notif(
    grup: '23 SEPT 2026',
    judul: 'Setoran Berhasil',
    isi: 'Setoran 05689 telah diverifikasi. Tabungan Anda bertambah Rp 8.200.',
    waktu: '23 Sep',
    icon: Icons.check_circle_rounded,
    bg: const Color(0xFFE6E0CF),
    fg: AppColors.muted,
    dibaca: true,
  ),
  _Notif(
    grup: '23 SEPT 2026',
    judul: 'Tips Memilah',
    isi: 'Cara jitu membersihkan botol minyak agar diterima di bank sampah.',
    waktu: '23 Sep',
    icon: Icons.lightbulb_outline_rounded,
    bg: const Color(0xFFE6E0CF),
    fg: AppColors.muted,
    dibaca: true,
  ),
]);

void _tandaiDibaca(_Notif n) {
  n.dibaca = true;
  notifikasi.value = List.of(notifikasi.value); // beri tahu pendengar
}

void _tandaiSemuaDibaca() {
  for (final n in notifikasi.value) {
    n.dibaca = true;
  }
  notifikasi.value = List.of(notifikasi.value);
}

class NotifikasiPage extends StatelessWidget {
  final VoidCallback? onBack;
  const NotifikasiPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<_Notif>>(
      valueListenable: notifikasi,
      builder: (context, list, _) {
        // urutan grup mengikuti urutan data
        final grups = <String>[];
        for (final n in list) {
          if (!grups.contains(n.grup)) grups.add(n.grup);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context, list.any((n) => !n.dibaca)),
              const SizedBox(height: 18),
              for (final g in grups) ...[
                _grupHeader(g),
                const SizedBox(height: 12),
                for (final n in list.where((n) => n.grup == g)) _tile(n),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext context, bool adaBelumDibaca) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dark, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.dark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('Notifikasi', style: display(size: 22))),
        GestureDetector(
          onTap: adaBelumDibaca
              ? () {
                  _tandaiSemuaDibaca();
                  showAppPopup(
                    context,
                    type: PopupType.sukses,
                    title: 'Semua Sudah Dibaca',
                    message: 'Semua notifikasi ditandai sudah dibaca.',
                    autoClose: const Duration(milliseconds: 1400),
                  );
                }
              : null,
          child: Text(
            'TANDAI SEMUA DIBACA',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: .5,
              fontWeight: FontWeight.w800,
              color: adaBelumDibaca
                  ? AppColors.orange
                  : AppColors.muted.withValues(alpha: .6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _grupHeader(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 9.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: _line, height: 1)),
      ],
    );
  }

  Widget _tile(_Notif n) {
    final baru = !n.dibaca;
    return GestureDetector(
      onTap: baru ? () => _tandaiDibaca(n) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // belum dibaca = putih menonjol, sudah dibaca = pudar
          color: baru ? Colors.white : Colors.white.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: baru ? _line : Colors.transparent),
          boxShadow: baru
              ? const [BoxShadow(color: Colors.black12, blurRadius: 6)]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: n.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(n.icon, size: 19, color: n.fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.judul,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    n.isi,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.35,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  n.waktu,
                  style: const TextStyle(fontSize: 9, color: AppColors.muted),
                ),
                if (baru) ...[
                  const SizedBox(width: 5),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// LAYAR: CHATBOT (Asisten DaurUang)
// ---------------------------------------------------------------

/// Tombol daun bulat di pojok kanan atas. Ketuk untuk membuka chatbot.
/// Cukup pakai `const LeafChatButton()` di halaman mana pun di dalam MainShell.
class LeafChatButton extends StatelessWidget {
  final Color color;
  const LeafChatButton({super.key, this.color = AppColors.dark});

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => context.findAncestorStateOfType<_MainShellState>()?.bukaChat(),
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const Icon(Icons.eco, size: 15, color: Colors.white),
    ),
  );
}

/// Satu pesan di percakapan.
/// Di teks bot, tulisan di dalam [[...]] akan tampil tebal berwarna oranye.
class _Pesan {
  final bool bot;
  final String teks;
  final String jam;
  const _Pesan(this.bot, this.teks, this.jam);
}

List<_Pesan> _chatAwal() => [
  _Pesan(
    true,
    'Halo! Saya asisten virtual DaurUang. Anda bisa bertanya tentang jenis sampah, harga terkini, atau cara setor sampah di sini.',
    '09:15 AM',
  ),
  _Pesan(
    true,
    'Tahukah Anda? Memilah sampah plastik sesuai jenisnya (PET, HDPE, dll) bisa meningkatkan nilai jualnya hingga 20%!',
    '09:16 AM',
  ),
  _Pesan(false, 'Bagaimana cara membedakan plastik PET dan HDPE?', '09:17 AM'),
  _Pesan(
    true,
    'Perbedaannya cukup mudah:\n'
    '[[PET (Kode 1):]] Jernih/transparan, biasanya botol air mineral.\n'
    '[[HDPE (Kode 2):]] Lebih tebal, buram/tidak tembus cahaya, biasanya botol deterjen atau susu.',
    '09:18 AM',
  ),
];

/// Riwayat chat disimpan di sini supaya tidak hilang saat pindah tab.
final List<_Pesan> _chatLog = _chatAwal();

String _jamSekarang() {
  final n = DateTime.now();
  final h = n.hour % 12 == 0 ? 12 : n.hour % 12;
  final m = n.minute.toString().padLeft(2, '0');
  return '${h.toString().padLeft(2, '0')}:$m ${n.hour < 12 ? 'AM' : 'PM'}';
}

/// Jawaban bot sederhana berdasarkan kata kunci (belum memakai AI/server).
String _jawabBot(String q) {
  final t = q.toLowerCase();
  bool has(List<String> k) => k.any(t.contains);

  if (has(['harga'])) {
    return 'Harga sampah hari ini:\n'
        '[[Organik Dapur:]] Rp1.000/kg\n'
        '[[Plastik PET:]] Rp3.500/kg\n'
        '[[Kertas & Kardus:]] Rp2.200/kg\n'
        'Harga bisa berubah setiap hari ya.';
  }
  if (has(['pet', 'hdpe', 'bedakan', 'plastik'])) {
    return 'Perbedaannya cukup mudah:\n'
        '[[PET (Kode 1):]] Jernih/transparan, biasanya botol air mineral.\n'
        '[[HDPE (Kode 2):]] Lebih tebal, buram/tidak tembus cahaya, biasanya botol deterjen atau susu.';
  }
  if (has(['tarik', 'tukar', 'saldo', 'cair'])) {
    return 'Saldo bisa ditarik lewat menu [[Tukar]] ke E-Wallet atau Transfer Bank. '
        'Minimal penarikan Rp 50.000, biaya layanan Rp 1.000, dan estimasi tiba kurang dari 10 menit.';
  }
  if (has(['jadwal', 'jemput', 'ambil'])) {
    return 'Kamu akan mendapat notifikasi saat armada penjemputan menuju lokasimu. '
        'Pastikan sampah sudah [[terpilah dan bersih]] ya!';
  }
  if (has(['setor', 'cara'])) {
    return 'Caranya mudah:\n'
        '[[1. Pilih & kategorikan:]] pisahkan sampah dan bersihkan dulu.\n'
        '[[2. Bawa ke drop point:]] atau tunggu penjemputan.\n'
        '[[3. Timbang & cairkan:]] petugas menimbang dan saldo langsung masuk.';
  }
  if (has(['terima kasih', 'makasih', 'thanks'])) {
    return 'Sama-sama! Senang bisa membantu 🌱';
  }
  if (has(['halo', 'hai', 'hi ', 'pagi', 'siang', 'sore', 'malam'])) {
    return 'Halo! Ada yang bisa saya bantu seputar sampah, harga, atau penarikan saldo?';
  }
  return 'Maaf, saya belum paham pertanyaan itu. Coba tanyakan tentang '
      '[[harga sampah]], [[cara setor]], [[cara tarik saldo]], atau [[jenis plastik]].';
}

class ChatPage extends StatefulWidget {
  final VoidCallback? onBack;
  const ChatPage({super.key, this.onBack});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool mengetik = false;

  static const _saran = [
    'Harga sampah hari ini?',
    'Cara setor sampah?',
    'Jadwal penjemputan?',
    'Cara tarik saldo?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _kirim(String teks) async {
    final t = teks.trim();
    if (t.isEmpty || mengetik) return;
    _input.clear();
    setState(() {
      _chatLog.add(_Pesan(false, t, _jamSekarang()));
      mengetik = true;
    });
    _scrollBawah();

    await Future.delayed(const Duration(milliseconds: 900));
    _chatLog.add(_Pesan(true, _jawabBot(t), _jamSekarang()));
    if (!mounted) return;
    setState(() => mengetik = false);
    _scrollBawah();
  }

  Future<void> _hapusChat() async {
    final ok = await showAppPopup(
      context,
      type: PopupType.konfirmasi,
      title: 'Hapus Percakapan?',
      message: 'Semua pesan di chat ini akan dihapus dan tidak bisa dikembalikan.',
      confirmLabel: 'Ya, Hapus',
      cancelLabel: 'Batal',
    );
    if (ok != true || !mounted) return;
    setState(() {
      _chatLog
        ..clear()
        ..addAll(_chatAwal());
    });
    _scrollBawah();
  }

  // ---------- tampilan ----------
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: _topBar(),
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            children: [
              _tanggal('HARI INI'),
              const SizedBox(height: 14),
              for (final p in _chatLog) _bubble(p),
              if (mengetik) _mengetikBubble(),
            ],
          ),
        ),
        _saranRow(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _inputBar(),
        ),
      ],
    );
  }

  Widget _avatar(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: AppColors.dark,
      shape: BoxShape.circle,
    ),
    child: Icon(Icons.eco, size: size * .5, color: Colors.white),
  );

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dark, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: AppColors.dark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 38,
          height: 38,
          child: Stack(
            children: [
              _avatar(36),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bg, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asisten DaurUang', style: display(size: 14)),
              const Text(
                'Online • Siap membantu',
                style: TextStyle(fontSize: 9, color: AppColors.muted),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.dark),
          color: Colors.white,
          onSelected: (v) {
            if (v == 'hapus') _hapusChat();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'hapus',
              child: Text('Hapus percakapan', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tanggal(String text) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E0CF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
        ),
      ),
    ),
  );

  /// Ubah teks ber-[[tanda]] menjadi potongan teks oranye tebal.
  List<InlineSpan> _spans(String t) {
    final re = RegExp(r'\[\[(.*?)\]\]');
    final out = <InlineSpan>[];
    int i = 0;
    for (final m in re.allMatches(t)) {
      if (m.start > i) out.add(TextSpan(text: t.substring(i, m.start)));
      out.add(
        TextSpan(
          text: m.group(1),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.orange,
          ),
        ),
      );
      i = m.end;
    }
    if (i < t.length) out.add(TextSpan(text: t.substring(i)));
    return out;
  }

  Widget _bubble(_Pesan p) {
    final maxW = MediaQuery.of(context).size.width * .68;
    final jam = Text(
      p.jam,
      style: const TextStyle(fontSize: 7.5, color: AppColors.muted),
    );

    if (p.bot) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar(24),
            const SizedBox(width: 8),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        border: Border.all(color: _line),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: _spans(p.teks),
                          style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.45,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    jam,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // pesan pengguna (kanan)
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Text(
                  p.teks,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.45,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              jam,
            ],
          ),
        ),
      ),
    );
  }

  Widget _mengetikBubble() => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        _avatar(24),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _line),
          ),
          child: const Text(
            'Sedang mengetik...',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: AppColors.muted,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _saranRow() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _saran.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _kirim(_saran[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.dark.withValues(alpha: .35)),
            ),
            child: Text(
              _saran[i],
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => showAppPopup(
              context,
              type: PopupType.info,
              title: 'Lampiran Belum Tersedia',
              message: 'Fitur kirim foto sampah akan hadir di versi berikutnya.',
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFE3EDD9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 18,
                color: AppColors.dark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _input,
              textInputAction: TextInputAction.send,
              onSubmitted: _kirim,
              style: const TextStyle(fontSize: 11.5),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Tulis pesan...',
                hintStyle: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.muted.withValues(alpha: .7),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _kirim(_input.text),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// POPUP & BANNER (dipakai oleh semua tombol di aplikasi)
// ---------------------------------------------------------------
const _merah = Color(0xFFC62828);
const _merahMuda = Color(0xFFFDE8E6);

/// Jenis popup: menentukan warna & ikon.
enum PopupType { sukses, error, peringatan, info, konfirmasi }

class _PopupStyle {
  final Color warna;
  final Color latar;
  final IconData ikon;
  const _PopupStyle(this.warna, this.latar, this.ikon);
}

_PopupStyle _gaya(PopupType t) {
  switch (t) {
    case PopupType.sukses:
      return const _PopupStyle(
        AppColors.green,
        Color(0xFFE3EDD9),
        Icons.check_rounded,
      );
    case PopupType.error:
      return const _PopupStyle(_merah, _merahMuda, Icons.close_rounded);
    case PopupType.peringatan:
      return const _PopupStyle(
        Color(0xFFB77900),
        Color(0xFFFBEBC8),
        Icons.priority_high_rounded,
      );
    case PopupType.info:
      return const _PopupStyle(
        Color(0xFF3B6FD4),
        Color(0xFFDCE8FA),
        Icons.info_outline_rounded,
      );
    case PopupType.konfirmasi:
      return const _PopupStyle(
        AppColors.orange,
        Color(0xFFFADBD0),
        Icons.help_outline_rounded,
      );
  }
}

/// Tampilkan popup. Hasilnya:
///   true  = tombol utama ditekan (atau popup tertutup otomatis)
///   false = tombol batal ditekan
///   null  = popup ditutup dengan mengetuk area gelap
///
/// Contoh:
///   final ok = await showAppPopup(context,
///       type: PopupType.konfirmasi,
///       title: 'Keluar?', message: 'Yakin ingin keluar?',
///       confirmLabel: 'Ya', cancelLabel: 'Batal');
///   if (ok == true) { ... }
Future<bool?> showAppPopup(
  BuildContext context, {
  required PopupType type,
  required String title,
  required String message,
  Widget? content, // isi tambahan, mis. PopupRincian
  String? confirmLabel, // null + tanpa cancelLabel = tombol "Mengerti"
  String? cancelLabel,
  Duration? autoClose, // kalau diisi, popup menutup sendiri tanpa tombol
  bool dismissible = true,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Tutup',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => _PopupCard(
      type: type,
      title: title,
      message: message,
      content: content,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      autoClose: autoClose,
    ),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
    ),
  );
}

class _PopupCard extends StatefulWidget {
  final PopupType type;
  final String title;
  final String message;
  final Widget? content;
  final String? confirmLabel;
  final String? cancelLabel;
  final Duration? autoClose;
  const _PopupCard({
    required this.type,
    required this.title,
    required this.message,
    this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.autoClose,
  });

  @override
  State<_PopupCard> createState() => _PopupCardState();
}

class _PopupCardState extends State<_PopupCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final d = widget.autoClose;
    if (d != null) {
      _timer = Timer(d, () {
        if (mounted) Navigator.of(context).pop(true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _ikon(_PopupStyle g) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 650),
    curve: Curves.elasticOut,
    builder: (_, v, child) => Transform.scale(scale: v, child: child),
    child: Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: g.latar, shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(color: g.warna, shape: BoxShape.circle),
          child: Icon(g.ikon, size: 30, color: Colors.white),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final g = _gaya(widget.type);
    final adaTombol = widget.autoClose == null;
    final utama = widget.confirmLabel ?? 'Mengerti';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dark, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: AppColors.dark, offset: Offset(0, 6)),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ikon(g),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: display(size: 19),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.5,
                        color: AppColors.muted,
                      ),
                    ),
                    if (widget.content != null) widget.content!,
                    if (adaTombol) ...[
                      const SizedBox(height: 20),
                      HardButton(
                        label: utama,
                        onTap: () => Navigator.of(context).pop(true),
                      ),
                      if (widget.cancelLabel != null) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: Container(
                            height: 46,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.dark,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              widget.cancelLabel!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kotak rincian di dalam popup (label kiri, nilai kanan).
/// Baris terakhir ditonjolkan kalau highlightLast = true.
class PopupRincian extends StatelessWidget {
  final List<MapEntry<String, String>> rows;
  final bool highlightLast;
  const PopupRincian({
    super.key,
    required this.rows,
    this.highlightLast = true,
  });

  List<Widget> _baris(int i) {
    final last = highlightLast && i == rows.length - 1;
    return [
      if (last && i > 0)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(height: 1, color: Color(0xFFD8D2C2)),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              rows[i].key,
              style: TextStyle(
                fontSize: last ? 12 : 11,
                fontWeight: last ? FontWeight.bold : FontWeight.normal,
                color: last ? AppColors.dark : AppColors.muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                rows[i].value,
                textAlign: TextAlign.right,
                style: last
                    ? display(size: 16, color: AppColors.orange)
                    : const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEDE8DA),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _line),
    ),
    child: Column(
      children: [for (int i = 0; i < rows.length; i++) ..._baris(i)],
    ),
  );
}

/// Banner pesan di dalam halaman (mis. error login).
class AlertBanner extends StatelessWidget {
  final String message;
  final PopupType type;
  const AlertBanner(this.message, {super.key, this.type = PopupType.error});

  @override
  Widget build(BuildContext context) {
    final g = _gaya(type);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: g.latar,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: g.warna.withValues(alpha: .35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 15, color: g.warna),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: g.warna,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// AUTH: LOGIN, REGISTRASI STEP 1 & 2, SUKSES
// ===============================================================

const _line = Color(0xFFE6DFCF); // border krem, sama dengan AppCard
const _card = Color(0xFFFDFBF5);

void _goHome(BuildContext context) => Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const MainShell()),
  (r) => false,
);

void _goLogin(BuildContext context) => Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const LoginScreen()),
  (r) => false,
);

// ---------------------------------------------------------------
// WIDGET BERSAMA
// ---------------------------------------------------------------
class AuthLogo extends StatelessWidget {
  final double size;
  const AuthLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .3),
    child: Image.asset(
      'assets/images/Overlay.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: AppColors.orange,
        child: Icon(Icons.eco_rounded, color: Colors.white, size: size * .5),
      ),
    ),
  );
}

class HardButton extends StatelessWidget {
  final String label;
  final IconData? trailing;
  final VoidCallback onTap;
  const HardButton({
    super.key,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 52,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: AppColors.dark, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(trailing, color: Colors.white, size: 16),
          ],
        ],
      ),
    ),
  );
}

class GoogleButton extends StatelessWidget {
  final Color background;
  final VoidCallback onTap;
  const GoogleButton({
    super.key,
    required this.onTap,
    this.background = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 48,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dark, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'G',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4285F4),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Lanjut dengan Google',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    ),
  );
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: Divider(color: _line)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'ATAU',
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1,
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(child: Divider(color: _line)),
    ],
  );
}

class LabeledField extends StatelessWidget {
  final String label, hint;
  final bool obscure;
  final bool hasError;
  final Widget? trailingLabel;
  final TextInputType? keyboard;
  final TextEditingController? controller;
  const LabeledField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.hasError = false,
    this.trailingLabel,
    this.keyboard,
    this.controller,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: hasError ? _merah : AppColors.dark,
              ),
            ),
            if (trailingLabel != null) trailingLabel!,
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.muted.withValues(alpha: .6),
            ),
            filled: true,
            fillColor: hasError ? _merahMuda : Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hasError ? _merah : _line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? _merah : AppColors.dark,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class BottomLink extends StatelessWidget {
  final String text, action;
  final Color actionColor;
  final VoidCallback onTap;
  const BottomLink({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
    this.actionColor = AppColors.dark,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Text.rich(
      TextSpan(
        text: '$text ',
        style: const TextStyle(fontSize: 12, color: AppColors.muted),
        children: [
          TextSpan(
            text: action,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: actionColor,
            ),
          ),
        ],
      ),
    ),
  );
}

class AuthTopBar extends StatelessWidget {
  final int step; // 1 atau 2
  const AuthTopBar({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    Widget seg(Color c) => Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
    final off = Colors.white.withValues(alpha: .8);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AuthLogo(size: 36),
            const Text(
              'Daftar Akun',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            seg(step == 1 ? AppColors.orange : AppColors.dark),
            const SizedBox(width: 4),
            seg(step == 2 ? AppColors.orange : off),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DATA DIRI',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
                color: step == 1 ? AppColors.orange : AppColors.muted,
              ),
            ),
            Text(
              'BUAT PASSWORD',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
                color: step == 2 ? AppColors.orange : AppColors.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------
// 1. LOGIN
// ---------------------------------------------------------------

/// Tombol "Lanjut dengan Google" (dipakai di Login & Registrasi).
Future<void> _loginGoogle(BuildContext context) async {
  final ok = await showAppPopup(
    context,
    type: PopupType.konfirmasi,
    title: 'Lanjut dengan Google?',
    message: 'Kamu akan masuk memakai akun Google di perangkat ini.',
    confirmLabel: 'Lanjutkan',
    cancelLabel: 'Batal',
  );
  if (ok == true && context.mounted) _goHome(context);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userC = TextEditingController();
  final passC = TextEditingController();
  bool remember = false, hide = true;
  String? error; // pesan banner merah
  bool errUser = false, errPass = false;
  int gagal = 0; // jumlah percobaan gagal

  @override
  void dispose() {
    userC.dispose();
    passC.dispose();
    super.dispose();
  }

  InputDecoration _dec(
    String hint,
    IconData icon, {
    Widget? suffix,
    bool err = false,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 12,
      color: AppColors.muted.withValues(alpha: .6),
    ),
    prefixIcon: Icon(icon, size: 16, color: err ? _merah : AppColors.muted),
    suffixIcon: suffix,
    filled: true,
    fillColor: err ? _merahMuda : _card,
    contentPadding: const EdgeInsets.symmetric(vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: err ? _merah : AppColors.dark, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: err ? _merah : AppColors.orange,
        width: 1.5,
      ),
    ),
  );

  void _bersih(String _) {
    if (error != null) {
      setState(() {
        error = null;
        errUser = false;
        errPass = false;
      });
    }
  }

  Future<void> _masuk() async {
    final u = userC.text.trim();
    final p = passC.text;

    if (u.isEmpty || p.isEmpty) {
      setState(() {
        errUser = u.isEmpty;
        errPass = p.isEmpty;
        error = 'Lengkapi WhatsApp/email dan password terlebih dahulu.';
      });
      return;
    }

    // DEMO: password < 6 karakter dianggap salah.
    // Ganti bagian ini dengan pemanggilan API login.
    if (p.length < 6) {
      gagal++;
      if (gagal >= 3) {
        gagal = 0;
        setState(() {
          error = null;
          errUser = false;
          errPass = false;
        });
        final reset = await showAppPopup(
          context,
          type: PopupType.peringatan,
          title: 'Terlalu Banyak Percobaan',
          message:
              'Demi keamanan akunmu, coba lagi beberapa menit lagi atau reset password.',
          confirmLabel: 'Reset Password',
          cancelLabel: 'Tutup',
        );
        if (reset == true && mounted) _lupaPassword();
        return;
      }
      setState(() {
        errUser = true;
        errPass = true;
        error = 'Email atau password salah. Periksa kembali dan coba lagi.';
      });
      return;
    }

    setState(() {
      error = null;
      errUser = false;
      errPass = false;
      gagal = 0;
    });
    await showAppPopup(
      context,
      type: PopupType.sukses,
      title: 'Berhasil Masuk',
      message: 'Selamat datang kembali di RESIK!',
      autoClose: const Duration(milliseconds: 1400),
    );
    if (!mounted) return;
    _goHome(context);
  }

  Future<void> _lupaPassword() async {
    final ok = await showAppPopup(
      context,
      type: PopupType.info,
      title: 'Reset Password',
      message:
          'Kami akan mengirim tautan reset password ke WhatsApp atau email yang terdaftar.',
      confirmLabel: 'Kirim Tautan',
      cancelLabel: 'Batal',
    );
    if (ok != true || !mounted) return;
    await showAppPopup(
      context,
      type: PopupType.sukses,
      title: 'Tautan Terkirim',
      message: 'Silakan cek WhatsApp atau emailmu untuk mengatur ulang password.',
      autoClose: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Hero(tag: 'resik-logo', child: AuthLogo()),
              const SizedBox(height: 22),
              Text(
                'Selamat Datang',
                style: display(size: 28, weight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk untuk lanjut setor sampah dan\nkumpulkan saldomu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dark, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: AppColors.dark, offset: Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    if (error != null) ...[
                      AlertBanner(error!),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: userC,
                      onChanged: _bersih,
                      style: const TextStyle(fontSize: 13),
                      decoration: _dec(
                        'WhatsApp atau Email',
                        Icons.phone_outlined,
                        err: errUser,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passC,
                      onChanged: _bersih,
                      obscureText: hide,
                      style: const TextStyle(fontSize: 13),
                      decoration: _dec(
                        'Password',
                        Icons.lock_outline,
                        err: errPass,
                        suffix: IconButton(
                          icon: Icon(
                            hide
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.dark,
                          ),
                          onPressed: () => setState(() => hide = !hide),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: remember,
                            side: const BorderSide(color: AppColors.dark),
                            onChanged: (v) => setState(() => remember = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ingat saya',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.dark,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _lupaPassword,
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    HardButton(
                      label: 'Masuk',
                      trailing: Icons.arrow_forward,
                      onTap: _masuk,
                    ),
                    const SizedBox(height: 14),
                    const OrDivider(),
                    const SizedBox(height: 14),
                    GoogleButton(onTap: () => _loginGoogle(context)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BottomLink(
                text: 'Belum punya akun?',
                action: 'Daftar',
                actionColor: AppColors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterStep1()),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '© 2026 RESIK ECOSYSTEM',
                style: TextStyle(fontSize: 9, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------
// 2. REGISTRASI STEP 1 - DATA DIRI
// ---------------------------------------------------------------
class RegisterStep1 extends StatefulWidget {
  const RegisterStep1({super.key});

  @override
  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  final namaC = TextEditingController();
  final hpC = TextEditingController();
  final emailC = TextEditingController();
  final alamatC = TextEditingController();
  bool errNama = false, errHp = false, errEmail = false;

  @override
  void dispose() {
    for (final c in [namaC, hpC, emailC, alamatC]) {
      c.dispose();
    }
    super.dispose();
  }

  void _lanjut() {
    final nama = namaC.text.trim();
    final hp = hpC.text.replaceAll(RegExp(r'[^0-9]'), '');
    final email = emailC.text.trim();
    final emailOk =
        email.isEmpty || RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    setState(() {
      errNama = nama.isEmpty;
      errHp = hp.length < 9;
      errEmail = !emailOk;
    });

    if (errNama || errHp || errEmail) {
      showAppPopup(
        context,
        type: PopupType.error,
        title: 'Data Belum Lengkap',
        message: errNama
            ? 'Nama lengkap wajib diisi.'
            : errHp
            ? 'Nomor WhatsApp belum valid (minimal 9 digit).'
            : 'Format email belum benar.',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterStep2(nama: nama)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            const AuthTopBar(step: 1),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.recycling_rounded,
                        color: AppColors.green,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Yuk, mulai setor\nsampah!',
                      textAlign: TextAlign.center,
                      style: display(size: 22),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Daftar dulu untuk mulai kumpulkan saldo\ndari sampahmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: 'Nama Lengkap',
                    hint: 'Contoh: Andi Wijaya',
                    controller: namaC,
                    hasError: errNama,
                  ),
                  LabeledField(
                    label: 'Nomor WhatsApp',
                    hint: '0812xxxx',
                    keyboard: TextInputType.phone,
                    controller: hpC,
                    hasError: errHp,
                  ),
                  LabeledField(
                    label: 'Email',
                    hint: 'nama@email.com',
                    keyboard: TextInputType.emailAddress,
                    controller: emailC,
                    hasError: errEmail,
                  ),
                  LabeledField(
                    label: 'Alamat / Kelurahan',
                    hint: 'Cari kelurahan Anda',
                    controller: alamatC,
                    trailingLabel: GestureDetector(
                      onTap: () => showAppPopup(
                        context,
                        type: PopupType.info,
                        title: 'Pakai Lokasi Saya',
                        message:
                            'Deteksi lokasi otomatis akan tersedia di versi berikutnya. Untuk sekarang, ketik kelurahanmu secara manual.',
                      ),
                      child: const Text(
                        'Pakai lokasi saya',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            HardButton(label: 'Lanjut', onTap: _lanjut),
            const SizedBox(height: 14),
            const OrDivider(),
            const SizedBox(height: 14),
            GoogleButton(background: _card, onTap: () => _loginGoogle(context)),
            const SizedBox(height: 16),
            BottomLink(
              text: 'Sudah punya akun?',
              action: 'Masuk',
              onTap: () => _goLogin(context),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------
// 3. REGISTRASI STEP 2 - BUAT PASSWORD
// ---------------------------------------------------------------
class RegisterStep2 extends StatefulWidget {
  final String nama;
  const RegisterStep2({super.key, this.nama = ''});

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  final passC = TextEditingController();
  final konfC = TextEditingController();
  bool agree = false;
  bool errPass = false, errKonf = false;

  @override
  void dispose() {
    passC.dispose();
    konfC.dispose();
    super.dispose();
  }

  TextSpan _link(String t) => TextSpan(
    text: t,
    style: const TextStyle(
      fontWeight: FontWeight.w800,
      color: AppColors.dark,
      decoration: TextDecoration.underline,
    ),
  );

  Future<void> _submit() async {
    final p = passC.text;
    final k = konfC.text;

    if (p.length < 6) {
      setState(() {
        errPass = true;
        errKonf = false;
      });
      showAppPopup(
        context,
        type: PopupType.error,
        title: 'Password Terlalu Pendek',
        message: 'Gunakan minimal 6 karakter agar akunmu aman.',
      );
      return;
    }
    if (p != k) {
      setState(() {
        errPass = false;
        errKonf = true;
      });
      showAppPopup(
        context,
        type: PopupType.error,
        title: 'Password Tidak Sama',
        message: 'Konfirmasi password harus sama dengan password.',
      );
      return;
    }
    setState(() {
      errPass = false;
      errKonf = false;
    });
    if (!agree) {
      showAppPopup(
        context,
        type: PopupType.peringatan,
        title: 'Syarat & Ketentuan',
        message:
            'Setujui Syarat & Ketentuan dan Kebijakan Privasi terlebih dahulu.',
      );
      return;
    }

    await showAppPopup(
      context,
      type: PopupType.sukses,
      title: 'Pendaftaran Berhasil',
      message: 'Akunmu sedang disiapkan...',
      autoClose: const Duration(milliseconds: 1500),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SuccessScreen(name: widget.nama.isEmpty ? 'Sobat RESIK' : widget.nama),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            const AuthTopBar(step: 2),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  Center(
                    child: Text('Satu langkah lagi!', style: display(size: 22)),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Buat password yang kuat untuk\nkeamanan akunmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LabeledField(
                    label: 'Password',
                    hint: '••••••••',
                    obscure: true,
                    controller: passC,
                    hasError: errPass,
                  ),
                  LabeledField(
                    label: 'Konfirmasi Password',
                    hint: '••••••••',
                    obscure: true,
                    controller: konfC,
                    hasError: errKonf,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: agree,
                          side: const BorderSide(
                            color: AppColors.dark,
                            width: 1.5,
                          ),
                          onChanged: (v) => setState(() => agree = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Saya setuju dengan ',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.muted,
                            ),
                            children: [
                              _link('Syarat & Ketentuan'),
                              const TextSpan(text: ' dan '),
                              _link('Kebijakan Privasi'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            const SizedBox(height: 36),
            HardButton(label: 'Daftar Sekarang', onTap: _submit),
            const SizedBox(height: 14),
            BottomLink(
              text: 'Sudah punya akun?',
              action: 'Masuk',
              onTap: () => _goLogin(context),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------
// 4. REGISTRASI BERHASIL
// ---------------------------------------------------------------
class SuccessScreen extends StatelessWidget {
  final String name;
  const SuccessScreen({super.key, this.name = 'Budi Santoso'});

  Widget _dot() => Container(
    width: 6,
    height: 6,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.muted,
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        // dekorasi daun
        Positioned(
          top: -10,
          right: 10,
          child: Transform.rotate(
            angle: .5,
            child: Container(
              width: 130,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: .15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(90),
                  bottomRight: Radius.circular(90),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.bg,
                                  border: Border.all(color: _line),
                                ),
                              ),
                              Container(
                                width: 84,
                                height: 84,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.dark,
                                ),
                              ),
                              const Positioned(
                                right: 6,
                                top: 4,
                                child: AuthLogo(size: 24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Akun Berhasil\nDibuat!',
                          textAlign: TextAlign.center,
                          style: display(size: 26),
                        ),
                        const SizedBox(height: 14),
                        Text.rich(
                          TextSpan(
                            text: 'Selamat datang di ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text: 'RESIK',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark,
                                ),
                              ),
                              const TextSpan(text: ', '),
                              TextSpan(
                                text: name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark,
                                ),
                              ),
                              const TextSpan(
                                text: '. Kamu sekarang bisa mulai menyetor sampah dan mengumpulkan saldo.',
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 26),
                        HardButton(
                          label: 'Mulai Sekarang',
                          onTap: () => _goHome(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dot(),
                      const SizedBox(width: 6),
                      Container(
                        width: 26,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _dot(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}