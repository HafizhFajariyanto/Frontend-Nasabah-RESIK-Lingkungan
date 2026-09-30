import 'package:flutter/material.dart';

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

// ---------------------------------------------------------------
// APP
// ---------------------------------------------------------------
class ResikApp extends StatelessWidget {
  const ResikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RESIK',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const TukarSaldoPage(),
      const PlaceholderPage(title: 'Setor'),
      const PlaceholderPage(title: 'Riwayat'),
      const PlaceholderPage(title: 'Profil'),
    ];

    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, 'Beranda'),
                _navItem(1, Icons.swap_horiz_rounded, 'Tukar'),
                GestureDetector(
                  onTap: () => setState(() => index = 2),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.recycling_rounded,
                        color: Colors.white),
                  ),
                ),
                _navItem(3, Icons.history_rounded, 'Riwayat'),
                _navItem(4, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final active = index == i;
    final color = active ? AppColors.orange : AppColors.muted;
    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
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
        child: Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      );
}

class Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool light;
  const Stat(
      {super.key,
      required this.label,
      required this.value,
      this.light = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: light ? Colors.white70 : AppColors.muted)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: light ? Colors.white : Colors.black87)),
      ],
    );
  }
}

class ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  const ActivityTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.amount});

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
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          Text(amount,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// LAYAR 1: BERANDA (RESIK)
// ---------------------------------------------------------------
const serifStyle = TextStyle(
  fontFamily: 'serif', // ganti dengan font desain (mis. lewat paket google_fonts)
  fontWeight: FontWeight.w800,
  color: AppColors.dark,
);

class CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool light;
  const CardHeader(
      {super.key,
      required this.icon,
      required this.title,
      this.trailing,
      this.light = false});

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
        Text(title,
            style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                color: color)),
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
    return LayoutBuilder(builder: (context, box) {
      final n = (box.maxWidth / 8).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
            n, (_) => Container(width: 4, height: 1.5, color: color)),
      );
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 18),
          const Text('Selamat pagi, dika',
              style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark)),
          const Text('Kamis, 17 September 2026',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 14),
          _saldoCard(),
          _targetCard(),
          _chartCard(),
          _priceCard(),
          _transaksiCard(),
          _mapCard(),
        ],
      ),
    );
  }

  // ---------- Header ----------
  Widget _header() {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.recycling, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        const Text('RESIK',
            style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.dark)),
        const Spacer(),
        Stack(
          children: [
            const Icon(Icons.notifications_none_rounded,
                color: AppColors.orange),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.orange, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.green,
            child: Icon(Icons.eco, size: 15, color: Colors.white)),
        const SizedBox(width: 8),
        const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.dark,
            child: Text('D',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13))),
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
              child: const Text('↗ +Rp78.092',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green)),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Rp',
                  style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      color: AppColors.dark)),
              SizedBox(width: 6),
              Text('171.770',
                  style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark)),
            ],
          ),
          const Divider(height: 24),
          const Row(
            children: [
              Expanded(child: Stat(label: 'SETORAN', value: '116,2 kg')),
              Expanded(child: Stat(label: 'EMISI', value: '169 kg')),
              Expanded(child: Stat(label: 'TRANSAKSI', value: '40')),
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
              light: true),
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
                        Text('100%',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text('Lunas',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('30,5 / 20 kg',
                        style: TextStyle(
                            fontFamily: 'serif',
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text(
                        'Target tercapai! Bonus Rp10.000 dari RW masuk akhir bulan.',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                      label: 'CO₂ TERREDUKSI', value: '169 kg', light: true)),
              Expanded(
                  child: Stat(
                      label: 'SETARA POHON', value: '≈ 8 pohon', light: true)),
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
            trailing: Text('kg / bulan',
                style: TextStyle(fontSize: 10, color: AppColors.muted)),
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
  Widget _priceCard() {
    return AppCard(
      child: Column(
        children: [
          const CardHeader(
            icon: Icons.sell_outlined,
            title: 'HARGA HARI INI',
            trailing: Text('17 Sep',
                style: TextStyle(fontSize: 11, color: AppColors.muted)),
          ),
          const SizedBox(height: 8),
          const _PriceRow(
              icon: Icons.eco_outlined,
              iconBg: Color(0xFFE3EDD9),
              name: 'Organik Dapur',
              sub: 'Eceng & sisa dapur',
              price: 'Rp1.000/kg',
              change: '+1,2%',
              up: true),
          const _PriceRow(
              icon: Icons.local_drink_outlined,
              iconBg: Color(0xFFFBEBC8),
              name: 'Plastik PET',
              sub: 'Botol bening & kemasan',
              price: 'Rp3.500/kg',
              change: '+6,2%',
              up: true),
          const _PriceRow(
              icon: Icons.inventory_2_outlined,
              iconBg: Color(0xFFFADBD0),
              name: 'Kertas & Kardus',
              sub: 'Koran, karton, buku',
              price: 'Rp2.200/kg',
              change: '−1,8%',
              up: false),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.orange,
                side: const BorderSide(color: AppColors.orange),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {},
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
            trailing: Text('Lihat Semua',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange)),
          ),
          SizedBox(height: 8),
          ActivityTile(
              icon: Icons.south_west_rounded,
              title: 'Kardus',
              subtitle: 'Hari ini · 10.20 · 3,2 kg',
              amount: '+Rp11.440'),
          ActivityTile(
              icon: Icons.south_west_rounded,
              title: 'Botol Plastik',
              subtitle: 'Kemarin · 09.15 · 4 kg',
              amount: '+Rp4.000'),
        ],
      ),
    );
  }

  // ---------- Titik setor terdekat ----------
  Widget _mapCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(
            icon: Icons.location_on_outlined,
            title: 'TITIK SETOR TERDEKAT',
            trailing: Text('Semua Titik',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange)),
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
                  child: Icon(Icons.location_on,
                      color: AppColors.orange, size: 38),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Koordinat: -6.3979, 106.8210',
                              style: TextStyle(fontSize: 10)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.dark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Lihat Lokasi',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 10)),
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
                child: Text('Pos Melati Indah',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              Text('Buka',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 2),
          const Row(
            children: [
              SizedBox(width: 17),
              Expanded(
                child: Text('Jl. Bigum-guza Barat No. 12 · 450 m',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ),
              Text('tutup 17.00',
                  style: TextStyle(fontSize: 10, color: AppColors.muted)),
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
        Text('${kg.toStringAsFixed(0)} kg',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: highlight ? AppColors.orange : AppColors.muted)),
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
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.muted)),
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
  const _PriceRow(
      {required this.icon,
      required this.iconBg,
      required this.name,
      required this.sub,
      required this.price,
      required this.change,
      required this.up});

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
                Text(name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800)),
              Text(change,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: up ? AppColors.green : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// LAYAR 2: TUKAR SALDO
// ---------------------------------------------------------------
class TukarSaldoPage extends StatefulWidget {
  const TukarSaldoPage({super.key});

  @override
  State<TukarSaldoPage> createState() => _TukarSaldoPageState();
}

class _TukarSaldoPageState extends State<TukarSaldoPage> {
  final controller = TextEditingController(text: '100000');
  int amount = 100000;
  int method = 0; // 0 = Tunai, 1 = E-Wallet
  final quickAmounts = [50000, 100000, 150000, 200000];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void setAmount(int v) {
    setState(() {
      amount = v;
      controller.text = v.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          const Row(
            children: [
              Text('Tukar Saldo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Spacer(),
              Icon(Icons.settings_outlined),
            ],
          ),
          const SizedBox(height: 14),

          // Saldo tersedia
          const AppCard(
            color: AppColors.dark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SALDO TERSEDIA',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 11, letterSpacing: 1)),
                SizedBox(height: 4),
                Text('Rp 212.450',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),

          // Metode penukaran
          const SectionTitle('Metode penukaran'),
          Row(
            children: [
              Expanded(child: _methodBox(0, Icons.payments_outlined, 'Tunai')),
              const SizedBox(width: 10),
              Expanded(
                  child: _methodBox(
                      1, Icons.account_balance_wallet_outlined, 'E-Wallet')),
            ],
          ),
          const SizedBox(height: 16),

          // Input nominal
          const SectionTitle('Nominal penukaran'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.orange, width: 1.5),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                border: InputBorder.none,
              ),
              onChanged: (v) => setState(() => amount = int.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(height: 10),

          // Pilihan cepat
          Wrap(
            spacing: 8,
            children: quickAmounts.map((v) {
              final selected = amount == v;
              return ChoiceChip(
                label: Text('${v ~/ 1000}rb'),
                selected: selected,
                selectedColor: AppColors.orange,
                labelStyle:
                    TextStyle(color: selected ? Colors.white : Colors.black87),
                onSelected: (_) => setAmount(v),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Ringkasan
          AppCard(
            child: Column(
              children: [
                _summaryRow('Biaya admin', 'Rp 0'),
                _summaryRow('Estimasi', 'Instan'),
                const Divider(),
                _summaryRow('Total diterima', rupiah(amount), bold: true),
              ],
            ),
          ),

          // Tombol
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Menukar ${rupiah(amount)}...')),
                );
              },
              child: const Text('Tukar Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 18),

          // Riwayat
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle('Riwayat penukaran'),
                ActivityTile(
                    icon: Icons.south_west_rounded,
                    title: 'Penukaran tunai',
                    subtitle: '22 Sep 2026',
                    amount: '-Rp 50.000'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodBox(int i, IconData icon, String label) {
    final selected = method == i;
    return GestureDetector(
      onTap: () => setState(() => method = i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.orange : Colors.transparent,
              width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.orange : AppColors.muted),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: bold ? Colors.black87 : AppColors.muted)),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 16 : 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}