# Dokumen Kebutuhan Data Toko Kosmetik GlowUp Beauty

## 1. Latar Belakang dan Aktivitas Organisasi
Toko Kosmetik GlowUp Beauty mengelola penjualan ritel produk perawatan kulit (skincare), tata rias (makeup), dan perawatan tubuh. Aktivitas utama meliputi pengelolaan keanggotaan (member), transaksi penjualan kasir, pemantauan masa kadaluarsa (expired date) dan stok barang, pemesanan ke distributor resmi, serta penyusunan laporan penjualan harian/bulanan.

## 2. Aktor dan Proses Bisnis

| Kode | Proses Bisnis | Aktor | Pemicu |
|---|---|---|---|
| PB-01 | Mendaftarkan Member Baru | Kasir | Pelanggan mengajukan pembuatan akun member |
| PB-02 | Mencatat Transaksi Penjualan | Kasir | Pelanggan melakukan pembayaran produk di kasir |
| PB-03 | Pengadaan Stok ke Distributor | Staf Gudang | `stok_produk` ≤ `stok_minimum` |
| PB-04 | Penerimaan Produk & Cek Kadaluarsa | Staf Gudang | Produk tiba dari distributor |
| PB-05 | Penyusunan Laporan Penjualan & Stok | Manajer Toko | Penutupan kasir harian / awal bulan |
| PB-06 | Kelola Data Distributor Kosmetik | Staf Gudang | Adanya kerjasama distributor baru / perubahan kontak |

## 3. Dokumen Sumber yang Dianalisis
- **Formulir Registrasi Member:** Nama, No HP, Email, Tanggal Lahir.
- **Struk Penjualan:** No Nota, Tanggal, Jam, Nama Kasir, Id Member, Nama Produk, Qty, Harga Satuan, Diskon, Total Bayar.
- **Faktur Penerimaan Barang:** No Faktur, Distributor, Tanggal Terkumpul, Kode Barcode, Lot Number, Tanggal Kadaluarsa, Qty Beli, Harga Beli.

## 4. Entitas Kandidat dan Elemen Data
- **Pelanggan:** id_pelanggan, no_member, nama_pelanggan, no_hp_pelanggan, tgl_lahir, poin_member, tgl_daftar.
- **Pegawai:** id_pegawai, kode_pegawai, nama_pegawai, peran_pegawai.
- **Produk:** id_produk, kode_barcode, nama_produk, merek_produk, kategori_produk, harga_jual, stok_produk, stok_minimum.
- **Detail_Batch:** id_batch, id_produk, no_lot, tgl_kadaluarsa, stok_batch.
- **Penjualan:** id_penjualan, no_nota, tgl_penjualan, id_pegawai, id_pelanggan, total_bayar, jenis_pembayaran.
- **Detail_Penjualan:** id_penjualan, id_produk, qty_jual, harga_satuan, diskon_item.
- **Distributor:** id_distributor, nama_distributor, telepon_distributor, alamat_distributor.
- **Pembelian:** id_pembelian, no_faktur, tgl_pembelian, id_distributor, status_pembelian.
- **Detail_Pembelian:** id_pembelian, id_produk, qty_beli, harga_beli_satuan.

## 5. Aturan Bisnis
- **AB-01:** Setiap nota penjualan memiliki nomor unik dan minimal berisi 1 kaleng/botol/pcs produk.
- **AB-02:** Penjualan dapat dilakukan kepada pelanggan umum maupun member. Member aktif berhak mendapatkan promo poin dan potongan diskon member.
- **AB-03:** Stok produk berkurang otomatis saat terjadi transaksi kasir dan bertambah saat penerimaan faktur pengadaan.
- **AB-04:** Kasir dilarang memproses penjualan untuk produk yang telah melewati `tgl_kadaluarsa`.
- **AB-05:** Atribut `kode_barcode` dan `no_member` bernilai unik.
- **AB-06:** Peringatan pemesanan ulang (*reorder point*) dipicu saat `stok_produk` mencapai atau di bawah `stok_minimum`.

## 6. Kebutuhan Informasi

| Kode | Kebutuhan Informasi | Data yang Diperlukan |
|---|---|---|
| KI-01 | Laporan total penjualan harian dan bulanan berdasarkan kategori produk | Penjualan, Detail_Penjualan, Produk |
| KI-02 | Daftar produk kosmetik yang mendekati masa kadaluarsa (< 90 hari) | Produk, Detail_Batch |
| KI-03 | Laporan 5 merek kosmetik paling laris (*top selling brands*) per bulan | Detail_Penjualan, Produk |
| KI-04 | Rekapitulasi transaksi dan sisa poin loyalitas member | Penjualan, Pelanggan |

## 7. Matriks CRUD

| Proses | Pelanggan | Pegawai | Produk | Penjualan | Detail_Penjualan | Distributor | Pembelian | Detail_Pembelian |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| PB-01 | C | R | - | - | - | - | - | - |
| PB-02 | R, U | R | R, U | C | C | - | - | - |
| PB-03 | - | R | R | - | - | R | C | C |
| PB-04 | - | R | U | - | - | R | U | R |
| PB-05 | R | R | R | R | R | R | R | R |
| PB-06 | - | R | - | - | - | C, U | - | - |

## 8. Kamus Data Awal (Cuplikan)

| Elemen Data | Arti / Deskripsi | Contoh Nilai | Aturan Integritas | Penanggung Jawab |
|---|---|---|---|---|
| `no_member` | Kode ID member kosmetik | `MB-8821` | UNIQUE, Format: MB-XXXX | Kasir |
| `kode_barcode` | Kode batangan unik dari kemasan produk | `8991234567891` | UNIQUE, Standard EAN-13 | Staf Gudang |
| `tgl_kadaluarsa` | Batas tanggal aman penggunaan produk | `2027-11-30` | Date, > tgl_pembelian | Staf Gudang |
| `stok_produk` | Sisa kuantitas gabungan seluruh batch | `42` | Integer, ≥ 0 | Staf Gudang |
| `harga_satuan` | Harga jual per unit saat transaksi | `85000.00` | Decimal, ≥ 0 | Kasir |

## 9. Kebutuhan Non-Fungsional
- **Volume:** Rata-rata 200 transaksi kasir per hari.
- **Retensi Data:** Riwayat transaksi penjualan disimpan sekurang-kurangnya selama 3 tahun.
- **Keamanan Data:** Informasi kontak pribadi member hanya dapat diakses oleh Manajer Toko.

## 10. Isu Kualitas Data yang Diantisipasi
- Penanganan pencatatan ganda untuk varian shade/warna produk kosmetik yang berbeda.
- Mencegah timbulnya kesalahan transaksi akibat penginputan produk yang sudah kadaluarsa.