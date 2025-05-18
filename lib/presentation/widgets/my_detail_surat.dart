import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/disposisi_page.dart';

class MyDetailSurat extends StatelessWidget {
  final String nomorSurat;
  final String tanggalSurat;
  final String pengirimSurat;
  final String nomorAgenda;
  final String klasifikasiSurat;
  final String ringkasanSurat;
  final String keteranganSurat;
  final String createByController;
  final String createOnController;
  final String updateOnController;
  final VoidCallback? onDisposisiTap;
  final VoidCallback? onPdfTap;

  const MyDetailSurat(
      {super.key,
      required this.nomorSurat,
      required this.tanggalSurat,
      required this.pengirimSurat,
      required this.nomorAgenda,
      required this.klasifikasiSurat,
      required this.ringkasanSurat,
      required this.keteranganSurat,
      required this.createByController,
      required this.createOnController,
      required this.updateOnController,
      this.onDisposisiTap,
      this.onPdfTap});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> detailItems = {
      'Tanggal Surat': tanggalSurat,
      'Nomor Surat': nomorSurat,
      'Nomor Agenda': nomorAgenda,
      'Klasifikasi Surat': klasifikasiSurat,
      'Pengirim Surat': pengirimSurat,
      'Dibuat Oleh': createByController,
      'Dibuat Pada': createOnController,
      'Diperbarui Pada': updateOnController,
    };
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppPallete.borderColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Bagian Atas Card
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Atribut Surat - Gunakan Expanded untuk mencegah overflow
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nomorSurat,
                            style: const TextStyle(
                              color: AppPallete.textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8.0),
                          Wrap(
                            spacing: 5.0, // jarak horizontal antar items
                            children: [
                              Text(
                                pengirimSurat,
                                style: const TextStyle(
                                  color: AppPallete.textColor,
                                  fontSize: 12.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                '|',
                                style: TextStyle(
                                  color: AppPallete.textColor,
                                  fontSize: 12.0,
                                ),
                              ),
                              Text(
                                nomorAgenda,
                                style: const TextStyle(
                                  color: AppPallete.textColor,
                                  fontSize: 12.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                '|',
                                style: TextStyle(
                                  color: AppPallete.textColor,
                                  fontSize: 12.0,
                                ),
                              ),
                              Text(
                                klasifikasiSurat,
                                style: const TextStyle(
                                  color: AppPallete.textColor,
                                  fontSize: 12.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    // Tanggal Surat
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal Surat',
                            style: TextStyle(
                              color: AppPallete.textColor, 
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            tanggalSurat,
                            style: const TextStyle(
                              color: AppPallete.textColor, 
                              fontSize: 12.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),

                    // Button Disposisi
                    SizedBox(
                      height: 36,
                      width: 80,
                      child: ElevatedButton(
                        onPressed: onDisposisiTap ?? () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => const DisposisiPage()
                            )
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Disposisi',
                            style: TextStyle(
                              color: AppPallete.whiteColor,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    // Menu options
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        // Show options menu
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Edit'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Add edit action
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Hapus'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Add delete action
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Divider(
                  thickness: 1,
                  color: Colors.black45,
                ),

                //Bagian Bawah Card
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Detail surat - menggunakan Expanded untuk mencegah overflow
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ringkasanSurat,
                              style: const TextStyle(
                                color: AppPallete.textColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              keteranganSurat,
                              style: const TextStyle(
                                color: AppPallete.textColor,
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // PDF icon
                      IconButton(
                        onPressed: onPdfTap ?? () {
                          // Default action if onPdfTap is null
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Membuka dokumen PDF')),
                          );
                        },
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 30,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                ),

                const Divider(
                  thickness: 1,
                  color: Colors.black45,
                ),

                // Detail section dengan tampilan yang lebih baik
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          "Detail Informasi Surat",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor,
                          ),
                        ),
                      ),
                      ...detailItems.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label
                              Expanded(
                                flex: 5,
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF29314F),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // Separator
                              const Text(
                                " : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF29314F),
                                  fontSize: 14,
                                ),
                              ),
                              // Value dengan wrapping text untuk menghindari overflow
                              Expanded(
                                flex: 6,
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 14, 
                                    color: Color(0xFF29314F),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                
                // Button bar untuk navigasi tambahan
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // Implementasi cetak dokumen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mencetak dokumen')),
                          );
                        },
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('Cetak', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Implementasi share dokumen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Berbagi dokumen')),
                          );
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Bagikan', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}