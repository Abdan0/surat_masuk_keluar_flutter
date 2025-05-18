import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/disposisi_page.dart';

class MySuratCard extends StatelessWidget {
  final String nomorSurat;
  final String tanggalSurat;
  final String pengirimSurat;
  final String nomorAgenda;
  final String klasifikasiSurat;
  final String ringkasanSurat;
  final String keteranganSurat;
  final VoidCallback? onDisposisiTap;
  final VoidCallback? onPdfTap;

  const MySuratCard({
    super.key,
    required this.nomorSurat,
    required this.tanggalSurat,
    required this.pengirimSurat,
    this.nomorAgenda = "",
    this.klasifikasiSurat = "",
    this.ringkasanSurat = "",
    this.keteranganSurat = "",
    this.onDisposisiTap,
    this.onPdfTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
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
            padding: const EdgeInsets.all(12.0),
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
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
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
                                  fontSize: 10.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                '|',
                                style: TextStyle(
                                  color: AppPallete.textColor,
                                  fontSize: 10.0,
                                ),
                              ),
                              Text(
                                nomorAgenda,
                                style: const TextStyle(
                                  color: AppPallete.textColor,
                                  fontSize: 10.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                '|',
                                style: TextStyle(
                                  color: AppPallete.textColor,
                                  fontSize: 10.0,
                                ),
                              ),
                              Text(
                                klasifikasiSurat,
                                style: const TextStyle(
                                  color: AppPallete.textColor,
                                  fontSize: 10.0,
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
                              fontSize: 10.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            tanggalSurat,
                            style: const TextStyle(
                              color: AppPallete.textColor,
                              fontSize: 10.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),

                    // Tombol Disposisi dengan SizedBox
                    SizedBox(
                      height: 36,
                      width: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DisposisiPage(),
                            ),
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
                                  title: const Text('Detail'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Add edit action
                                  },
                                ),
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

                const SizedBox(height: 8),

                const Divider(
                  thickness: 1,
                  color: Colors.black54,
                ),

                //Bagian Bawah Card
                Row(
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
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            keteranganSurat,
                            style: const TextStyle(
                              color: AppPallete.textColor,
                              fontSize: 12.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}