import 'package:flutter/material.dart';

import '../models/pesanan_model.dart';
import '../utils/format.dart';
import '../utils/theme.dart';
import 'status_badge.dart';

/// Tabel pesanan untuk layar lebar (versi web).
///
/// Pada rancangan web Figma, daftar kartu diganti tabel dengan kolom
/// Nama Pelanggan, Menu / Paket, Porsi, Tgl Pengiriman, Total,
/// Status Pesanan, dan Status Pembayaran. Klik baris membuka
/// Detail Pesanan lewat [onPesananTap].
class PesananTable extends StatelessWidget {
  /// Pesanan yang ditampilkan, urutan dipertahankan.
  final List<Pesanan> daftar;

  /// Callback ketika sebuah baris diklik.
  final void Function(Pesanan pesanan)? onPesananTap;

  const PesananTable({
    super.key,
    required this.daftar,
    this.onPesananTap,
  });

  static const TextStyle _gayaKepala = TextStyle(
    fontSize: AppTheme.keterangan,
    fontWeight: FontWeight.w600,
    color: AppTheme.textSecondary,
  );

  static const TextStyle _gayaSel = TextStyle(
    fontSize: AppTheme.keterangan,
    color: AppTheme.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: const WidgetStatePropertyAll(
                AppTheme.permukaan,
              ),
              headingRowHeight: 48,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              horizontalMargin: AppTheme.spacing8,
              columnSpacing: AppTheme.spacing16,
              dividerThickness: 1,
              columns: const [
                DataColumn(label: Text('Nama Pelanggan', style: _gayaKepala)),
                DataColumn(label: Text('Menu / Paket', style: _gayaKepala)),
                DataColumn(
                  label: Text('Porsi', style: _gayaKepala),
                  numeric: true,
                ),
                DataColumn(label: Text('Tgl Pengiriman', style: _gayaKepala)),
                DataColumn(label: Text('Total', style: _gayaKepala)),
                DataColumn(label: Text('Status Pesanan', style: _gayaKepala)),
                DataColumn(
                  label: Text('Status Pembayaran', style: _gayaKepala),
                ),
              ],
              rows: [
                for (final pesanan in daftar)
                  DataRow(
                    onSelectChanged: onPesananTap == null
                        ? null
                        : (_) => onPesananTap!(pesanan),
                    cells: [
                      DataCell(
                        Text(
                          pesanan.namaPelanggan,
                          style: _gayaSel.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(Text(pesanan.menu, style: _gayaSel)),
                      DataCell(
                        Text('${pesanan.jumlahPorsi}', style: _gayaSel),
                      ),
                      DataCell(
                        Text(
                          Format.tanggal(pesanan.tanggalKirim),
                          style: _gayaSel,
                        ),
                      ),
                      DataCell(
                        Text(
                          pesanan.totalHarga > 0
                              ? Format.rupiah(pesanan.totalHarga)
                              : '-',
                          style: _gayaSel,
                        ),
                      ),
                      DataCell(StatusBadge.pesanan(pesanan.statusPesanan)),
                      DataCell(
                        StatusBadge.pembayaran(pesanan.statusPembayaran),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
