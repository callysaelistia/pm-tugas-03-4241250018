import 'dart:io';

typedef MataKuliah = ({String nama, int sks, String nilai});

void main() {
  final List<MataKuliah> daftarMk = [];
  print('Masukkan data mata kuliah. Kosongkan nama untuk selesai.\n');

  while (true) {
    final nama = _bacaInput('Nama MK : ');
    if (nama.isEmpty) {
      break;
    }

    try {
      final sksInput = _bacaInput('SKS     : ');
      final sks = validasiSks(sksInput);

      final nilaiInput = _bacaInput('Nilai   : ').toUpperCase();
      validasiNilai(nilaiInput);

      daftarMk.add((nama: nama, sks: sks, nilai: nilaiInput));
    } on FormatException catch (e) {
      print('Data diabaikan: ${e.message}');
    }
    print('');
  }

  if (daftarMk.isEmpty) {
    print('Tidak ada data mata kuliah yang dimasukkan.');
    return;
  }

  cetakKhs(daftarMk, urutkan: true);
}

String _bacaInput(String prompt) {
  stdout.write(prompt);
  return (stdin.readLineSync() ?? '').trim();
}

int validasiSks(String input) {
  final sks = int.tryParse(input);
  if (sks == null || sks < 1 || sks > 6) {
    throw FormatException('SKS harus berupa angka 1-6, bukan "$input".');
  }
  return sks;
}

void validasiNilai(String huruf) {
  const nilaiValid = ['A', 'B', 'C', 'D', 'E'];
  if (!nilaiValid.contains(huruf)) {
    throw FormatException(
      'Nilai huruf "$huruf" tidak valid (gunakan A, B, C, D, atau E).',
    );
  }
}

double bobot(String huruf) => switch (huruf.toUpperCase()) {
  'A' => 4.0,
  'B' => 3.0,
  'C' => 2.0,
  'D' => 1.0,
  'E' => 0.0,
  _ => 0.0,
};

double hitungIp(List<MataKuliah> data) {
  final totalSks = data.fold<int>(0, (acc, mk) => acc + mk.sks);
  if (totalSks == 0) {
    return 0.0;
  }

  final totalMutu = data.fold<double>(
    0.0,
    (acc, mk) => acc + (mk.sks * bobot(mk.nilai)),
  );
  return totalMutu / totalSks;
}

String predikat(double ip) => switch (ip) {
  >= 3.51 => 'Dengan Pujian (Cum Laude)',
  >= 3.00 => 'Memuaskan',
  >= 2.50 => 'Cukup',
  _ => 'Kurang',
};

void cetakKhs(List<MataKuliah> data, {bool urutkan = false}) {
  final daftarTampil = List<MataKuliah>.from(data);

  if (urutkan) {
    daftarTampil.sort((a, b) => bobot(b.nilai).compareTo(bobot(a.nilai)));
  }

  print('Mata Kuliah                  SKS  Nilai');
  print('---------------------------------------');
  for (final mk in daftarTampil) {
    final namaPad = mk.nama.padRight(28);
    final sksPad = mk.sks.toString().padLeft(3);
    print('$namaPad $sksPad  ${mk.nilai}');
  }
  print('---------------------------------------');

  final totalSks = daftarTampil.fold<int>(0, (acc, mk) => acc + mk.sks);
  final ip = hitungIp(daftarTampil);

  print('Total SKS : $totalSks');
  print('IP        : ${ip.toStringAsFixed(2)} (${predikat(ip)})');

  final perluPerbaikan = daftarTampil
      .where((mk) => bobot(mk.nilai) < 2.0)
      .map((mk) => mk.nama)
      .toList();

  if (perluPerbaikan.isNotEmpty) {
    print('Perlu diperbaiki: ${perluPerbaikan.join(', ')}');
  }
}
