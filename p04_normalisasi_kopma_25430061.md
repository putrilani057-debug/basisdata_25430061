# Dokumen Normalisasi Skema Relasional: Koperasi Mahasiswa (Kopma)
**NIM:** 25430061  
**Parameter P:** 8 ($P = (2 \text{ digit terakhir NIM mod } 9) + 1 = (61 \bmod 9) + 1 = 7 + 1 = 8$)  

---

## 1. Bentuk Tidak Normal (UNF - Unnormalized Form)
Bentuk awal dokumen sumber (berdasarkan struk penjualan dan formulir pendaftaran Kopma) yang masih mengandung grup berulang (*multivalued attributes*) pada rincian item barang dalam satu nota transaksi:

> **NOTA_UNF** (`no_nota`, `tgl_penjualan`, `id_petugas`, `nama_petugas`, `id_anggota`, `nama_anggota`, `{kode_barang, nama_barang, qty_jual, harga_satuan, subtotal_item}`, `jumlah_total`, `diskon_anggota`, `total_bayar`)

---

## 2. Dependensi Fungsional (Functional Dependencies)
Dependensi fungsional diturunkan langsung dari aturan bisnis (`AB-xx`) studi kasus Kopma:
* **FD1:** `no_nota` $\rightarrow$ `tgl_penjualan`, `id_petugas`, `id_anggota`, `jumlah_total`, `diskon_anggota`, `total_bayar` *(AB-01)*
* **FD2:** `id_petugas` $\rightarrow$ `nama_petugas`, `peran_petugas`
* **FD3:** `id_anggota` $\rightarrow$ `npm`, `nama_anggota`, `prodi`, `no_hp`, `total_simpanan`, `tgl_gabung` *(AB-05)*
* **FD4:** `id_produk` $\rightarrow$ `kode_barcode`, `nama_produk`, `kategori_produk`, `harga_jual`, `stok_produk`, `stok_minimum` *(AB-05)*
* **FD5:** (`no_nota`, `id_produk`) $\rightarrow$ `qty_jual`, `harga_satuan`, `diskon_anggota` *(Atribut transaksional, AB-04)*
* **FD6:** `id_pemasok` $\rightarrow$ `nama_pemasok`, `telepon_pemasok`, `alamat_pemasok`
* **FD7:** `no_faktur` $\rightarrow$ `tgl_pembelian`, `id_pemasok`, `status_pembelian` *(AB-06)*

---

## 3. Tahapan Normalisasi

### A. Bentuk Normal Pertama (1NF)
* **Syarat:** Menghilangkan semua kelompok berulang (*multivalued attributes*), memastikan setiap sel bernilai atomik (tunggal), dan mendefinisikan kunci primer komposit.
* **Hasil 1NF:**
  > `NOTA_1NF` (`no_nota`, `tgl_penjualan`, `id_petugas`, `nama_petugas`, `id_anggota`, `nama_anggota`, `kode_barcode`, `nama_barang`, `qty_jual`, `harga_satuan`, `diskon_anggota`, `jumlah_total`, `diskon_total`, `total_bayar`)

---

### B. Bentuk Normal Kedua (2NF)
* **Syarat:** Memenuhi syarat 1NF dan seluruh atribut non-kunci bergantung penuh pada seluruh kunci primer (tidak ada ketergantungan parsial pada kunci komposit).
* **Pemecahan:** Atribut yang hanya bergantung pada sebagian kunci komposit dipisah menjadi entitas mandiri (`anggota`, `pengurus_pegawai`, `produk`, `pemasok`, `penjualan`, dan `detail_penjualan`).
* **Hasil 2NF:**
  1. `anggota` (`id_anggota`, `npm`, `nama_anggota`, `prodi`, `no_hp`, `total_simpanan`, `tgl_gabung`)
  2. `pengurus_pegawai` (`id_pegawai`, `kode_pegawai`, `nama_pegawai`, `jabatan`)
  3. `produk` (`id_produk`, `kode_barcode`, `nama_produk`, `kategori_produk`, `harga_jual`, `stok_produk`, `stok_minimum`)
  4. `pemasok` (`id_pemasok`, `nama_pemasok`, `telepon_pemasok`, `alamat_pemasok`)
  5. `penjualan` (`id_penjualan`, `no_nota`, `tgl_penjualan`, `id_pegawai`, `id_anggota`, `total_bayar`)
  6. `detail_penjualan` (`id_penjualan`, `id_produk`, `qty_jual`, `harga_satuan`, `diskon_anggota`)

---

### C. Bentuk Normal Ketiga (3NF)
* **Syarat:** Memenuhi syarat 2NF dan tidak ada atribut non-kunci yang bergantung secara transitif pada atribut non-kunci lainnya (menghilangkan rantai $A \rightarrow B \rightarrow C$).
* **Pemecahan:** Pada tahap ini seluruh tabel relasional Kopma sudah bersih dari anomali ubah, sisip, dan hapus. Struktur tabel final mencakup tabel master dan tabel operasional transaksional lengkap dengan tabel pengadaan (`pembelian` dan `detail_pembelian`).

---

## 4. Pemeriksaan Boyce-Codd Normal Form (BCNF)
* **Status BCNF:** Tercapai. Seluruh penentu (*determinant*) pada skema relasional di atas sudah merupakan kunci kandidat (*candidate key*). Tidak ditemukan adanya atribut non-kunci yang menentukan atribut kunci utama.

---

## 5. Keputusan Penyimpanan Nilai Turunan
* Atribut `subtotal`, `jumlah_total`, maupun `total_bayar` pada transaksi **tidak disimpan secara permanen** di dalam tabel operasional utama. Nilai ini dihitung secara dinamis (*derived attributes*) menggunakan fungsi agregat (`SUM`) saat kueri laporan dijalankan. Keputusan ini diambil untuk mencegah anomali inkonsistensi data jika terjadi perubahan harga satuan atau kuantitas di kemudian hari.

---

## 6. Skema Relasional Final Kopma (Acuan DDL)
1. **petugas** (`id_petugas` [PK], `kode_petugas` [UQ], `nama_petugas`, `peran_petugas`)
2. **anggota** (`id_anggota` [PK], `no_anggota` [UQ], `npm` [UQ], `nama_anggota`, `prodi`, `no_hp` [Pribadi], `status_anggota`, `tgl_gabung`)
3. **produk** (`id_produk` [PK], `kode_barcode` [UQ], `nama_produk`, `kategori_produk`, `harga_jual`, `stok_produk`, `stok_minimum`)
4. **pemasok** (`id_pemasok` [PK], `nama_pemasok`, `telepon_pemasok`, `alamat_pemasok`)
5. **penjualan** (`id_penjualan` [PK], `no_nota` [UQ], `tgl_penjualan`, `id_petugas` [FK], `id_anggota` [FK, NULL], `bayar_tunai`)
6. **detail_penjualan** (`id_penjualan` [PK, FK], `id_produk` [PK, FK], `qty_jual`, `harga_satuan`)
7. **pembelian** (`id_pembelian` [PK], `no_faktur`, `tgl_pembelian`, `id_pemasok` [FK], `status_pembelian`)
8. **detail_pembelian** (`id_pembelian` [PK, FK], `id_produk` [PK, FK], `qty_beli`, `harga_beli`)