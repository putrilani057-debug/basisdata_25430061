# Dokumen Normalisasi Skema Relasional: Toko Kosmetik GlowUp Beauty
**NIM:** 25430061  
**Nama Organisasi:** Toko Kosmetik GlowUp Beauty  

---

## 1. Bentuk Tidak Normal (UNF - Unnormalized Form)
Bentuk awal dokumen sumber (berdasarkan struk penjualan dan faktur pengadaan) yang masih mengandung grup berulang (multivalued attributes) pada rincian item produk dalam satu nota/faktur:

> **NOTA_UNF** (`no_nota`, `tgl_penjualan`, `id_pegawai`, `nama_pegawai`, `id_pelanggan`, `nama_pelanggan`, `{kode_barcode, nama_produk, qty_jual, harga_satuan, diskon_item}`, `total_bayar`, `jenis_pembayaran`)

---

## 2. Dependensi Fungsional (Functional Dependencies)
Berdasarkan aturan bisnis (`AB-xx`) dan entitas kandidat dari dokumen kebutuhan data:
* **FD1:** `no_nota` $\rightarrow$ `tgl_penjualan`, `id_pegawai`, `id_pelanggan`, `total_bayar`, `jenis_pembayaran` *(AB-01)*
* **FD2:** `id_pegawai` $\rightarrow$ `nama_pegawai`, `peran_pegawai`
* **FD3:** `id_pelanggan` $\rightarrow$ `no_member`, `nama_pelanggan`, `no_hp_pelanggan`, `tgl_lahir`, `poin_member`, `tgl_daftar` *(AB-05)*
* **FD4:** `id_produk` $\rightarrow$ `kode_barcode`, `nama_produk`, `merek_produk`, `kategori_produk`, `harga_jual`, `stok_produk`, `stok_minimum` *(AB-05)*
* **FD5:** (`no_nota`, `id_produk`) $\rightarrow$ `qty_jual`, `harga_satuan`, `diskon_item` *(Atribut transaksional)*
* **FD6:** `id_distributor` $\rightarrow$ `nama_distributor`, `telepon_distributor`, `alamat_distributor`
* **FD7:** `no_faktur` $\rightarrow$ `tgl_pembelian`, `id_distributor`, `status_pembelian`

---

## 3. Tahapan Normalisasi

### A. Bentuk Normal Pertama (1NF)
* **Syarat:** Menghilangkan semua grup berulang, memastikan setiap sel bernilai atomik (tunggal), dan mendefinisikan kunci primer komposit.
* **Hasil 1NF:**
  > `PENJUALAN_1NF` (`no_nota`, `tgl_penjualan`, `id_pegawai`, `nama_pegawai`, `id_pelanggan`, `nama_pelanggan`, `kode_barcode`, `nama_produk`, `qty_jual`, `harga_satuan`, `diskon_item`, `total_bayar`, `jenis_pembayaran`)

---

### B. Bentuk Normal Kedua (2NF)
* **Syarat:** Memenuhi syarat 1NF dan semua atribut non-kunci bergantung penuh pada seluruh kunci primer (tidak ada ketergantungan parsial).
* **Pemecahan:** Atribut yang hanya bergantung pada sebagian kunci komposit dipisah menjadi tabel mandiri (`pelanggan`, `pegawai`, `produk`, `penjualan`, dan `detail_penjualan`).
* **Hasil 2NF:**
  1. `pelanggan` (`id_pelanggan`, `no_member`, `nama_pelanggan`, ...)
  2. `pegawai` (`id_pegawai`, `nama_pegawai`, `peran_pegawai`)
  3. `produk` (`id_produk`, `kode_barcode`, `nama_produk`, ...)
  4. `penjualan` (`id_penjualan`, `no_nota`, `tgl_penjualan`, `id_pegawai`, `id_pelanggan`)
  5. `detail_penjualan` (`id_penjualan`, `id_produk`, `qty_jual`, `harga_satuan`, `diskon_item`)

---

### C. Bentuk Normal Ketiga (3NF)
* **Syarat:** Memenuhi syarat 2NF dan tidak ada atribut non-kunci yang bergantung secara transitif pada atribut non-kunci lainnya (menghilangkan rantai $A \rightarrow B \rightarrow C$).
* **Pemecahan:** Pada tahap ini seluruh tabel relasional GlowUp Beauty sudah bebas dari anomali ubah, sisip, dan hapus. Struktur tabel final mencakup master data (`pelanggan`, `pegawai`, `produk`, `distributor`, `detail_batch`) serta tabel transaksional (`penjualan`, `detail_penjualan`, `pembelian`, `detail_pembelian`).

---

## 4. Pemeriksaan Boyce-Codd Normal Form (BCNF)
* **Status BCNF:** Tercapai. Seluruh penentu (*determinant*) pada skema relasional di atas sudah merupakan kunci kandidat (*candidate key*). Tidak ada atribut non-kunci yang menentukan atribut kunci.

---

## 5. Keputusan Penyimpanan Nilai Turunan
* Atribut `total_bayar` pada tabel `penjualan` atau `subtotal` pada item transaksi **tidak disimpan secara permanen** di basis data operasional (OLTP). Nilai ini akan dihitung secara dinamis (*computed/derived value*) menggunakan fungsi agregat SQL (`SUM`) dari `qty_jual * harga_satuan` dikurangi diskon. Hal ini diputuskan untuk menghindari inkonsistensi data apabila terjadi perubahan harga atau rincian item di kemudian hari.

---

## 6. Skema Relasional Final (Acuan DDL Modul 5)
1. **pelanggan** (`id_pelanggan` [PK], `no_member` [UQ], `nama_pelanggan`, `no_hp_pelanggan`, `tgl_lahir`, `poin_member`, `tgl_daftar`)
2. **pegawai** (`id_pegawai` [PK], `kode_pegawai` [UQ], `nama_pegawai`, `peran_pegawai`)
3. **produk** (`id_produk` [PK], `kode_barcode` [UQ], `nama_produk`, `merek_produk`, `kategori_produk`, `harga_jual`, `stok_produk`, `stok_minimum`)
4. **detail_batch** (`id_batch` [PK], `id_produk` [FK], `no_lot`, `tgl_kadaluarsa`, `stok_batch`)
5. **distributor** (`id_distributor` [PK], `nama_distributor`, `telepon_distributor`, `alamat_distributor`)
6. **penjualan** (`id_penjualan` [PK], `no_nota` [UQ], `tgl_penjualan`, `id_pegawai` [FK], `id_pelanggan` [FK], `jenis_pembayaran`)
7. **detail_penjualan** (`id_penjualan` [PK, FK], `id_produk` [PK, FK], `qty_jual`, `harga_satuan`, `diskon_item`)
8. **pembelian** (`id_pembelian` [PK], `no_faktur`, `tgl_pembelian`, `id_distributor` [FK], `status_pembelian`)
9. **detail_pembelian** (`id_pembelian` [PK, FK], `id_produk` [PK, FK], `qty_beli`, `harga_beli_satuan`)