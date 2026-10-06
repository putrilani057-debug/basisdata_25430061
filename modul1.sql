-- 1. Buat basis data untuk Koperasi Mahasiswa
CREATE DATABASE db_kopma;

-- 2. Buat user kerja baru dengan akses terbatas ke db_kopma
CREATE USER 'pengurus_kopma'@'localhost' IDENTIFIED BY 'PasswordKopma123!';
GRANT ALL PRIVILEGES ON db_kopma.* TO 'pengurus_kopma'@'localhost';
FLUSH PRIVILEGES;