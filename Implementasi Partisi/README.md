# Implementasi Partisi
### Daftar isi
1. [Pengecekan Plugin Partition](#1-pengecekan-plugin-partition)
2. [Membuat Partition](#2-membuat-partition)   
2.1 [`RANGE` Partitioning](#21-range-partitioning)   
2.2 [`LIST` Partitioning](#22-list-partitioning)   
2.3 [`HASH` Partitioning](#23-hash-partitioning)   
2.4 [`KEY` Partitioning](#24-key-partitioning)
3. [Testing "A Typical Use Case: Time Series Data"](#3-testing-a-typical-use-case-time-series-data)   
3.1 [Explain Partition](#31-explain-partition)   
3.2 [Select Queries Benchmark](#32-select-queries-benchmark)   
3.3 [The Big Delete Benchmark](#33-the-big-delete-benchmark)
4. [Referensi](#4-referensi)
## 1. Pengecekan Plugin Partition
Untuk mengecek apakah plugin partition telah aktif/tidak, kita menggunakan syntax berikut :
```sql
SELECT plugin_name as name,
plugin_version as version,
plugin_status as status
FROM information_schema.plugins
WHERE plugin_type = 'STORAGE ENGINE';
```
Lalu akan muncul status plugin setiap engine seperti ini :   
![Hasil cek plugin](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/cek_plugin.jpg "Hasil cek plugin")

## 2. Membuat Partition
Pada dasarnya ada 4 jenis partition yang tersedia yaitu : `RANGE`, `LIST`, `HASH`, dan `KEY`.   
### 2.1. `RANGE` Partitioning   
Untuk membuat `RANGE` partitioning bisa menggunakan syntax seperti contoh berikut :
```sql
CREATE TABLE userslogs (
    username VARCHAR(20) NOT NULL,
    logdata BLOB NOT NULL,
    created DATETIME NOT NULL,
    PRIMARY KEY(username, created)
)
PARTITION BY RANGE( YEAR(created) )(
    PARTITION from_2013_or_less VALUES LESS THAN (2014),
    PARTITION from_2014 VALUES LESS THAN (2015),
    PARTITION from_2015 VALUES LESS THAN (2016),
    PARTITION from_2016_and_up VALUES LESS THAN MAXVALUE);
```
![Query userlogs](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/userlogs_range.jpg "Query userlogs")

Penjelasan :   
Tabel userlogs akan di partisi dari nilai kolom `created` dimana ada 4 buah partisi yaitu data yang terbuat pada tahun 2013 ke bawah, data yang terbuat pada tahun 2014, data yang terbuat pada tahun 2015, dan data yang terbuat pada tahun 2016 ke atas.

Alternatif lain `RANGE` adalah `RANGE COLUMNS` yang memungkinkan ekspresi lebih dari satu kolom. Contohnya seperti berikut :
```sql
CREATE TABLE rc1 (
    a INT,
    b INT
)
PARTITION BY RANGE COLUMNS(a, b) (
    PARTITION p0 VALUES LESS THAN (5, 12),
    PARTITION p3 VALUES LESS THAN (MAXVALUE, MAXVALUE)
);

INSERT INTO rc1 (a,b) VALUES (4,11);
INSERT INTO rc1 (a,b) VALUES (5,11);
INSERT INTO rc1 (a,b) VALUES (6,11);
INSERT INTO rc1 (a,b) VALUES (4,12);
INSERT INTO rc1 (a,b) VALUES (5,12);
INSERT INTO rc1 (a,b) VALUES (6,12);
INSERT INTO rc1 (a,b) VALUES (4,13);
INSERT INTO rc1 (a,b) VALUES (5,13);
INSERT INTO rc1 (a,b) VALUES (6,13);
```
Untuk melihat partisi apa saja yang ada pada suatu tabel bisa menggunakan `EXPLAIN` dengan syntax seperti berikut :
```sql
EXPLAIN PARTITIONS SELECT * FROM rc1;
```
![Explain Range Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/explain_range.jpg "Explain Range Partitions")   

Tabel rc1 akan di partisi menjadi 2 bagian yaitu p0 dimana memiliki syarat nilai a kurang dari 5 atau nilai b kurang dari 12, dan p3 dimana memiliki syarat nilai a kurang dari nilai tertinggi kolom a atau nilai b kurang dari nilai tertinggi kolom b. Untuk membuktikannya kita bisa menulis syntax :
```sql
SELECT *,'p0' FROM rc1 PARTITION (p0)
UNION ALL
SELECT *,'p3' FROM rc1 PARTITION (p3)
ORDER BY a,b ASC;
```
![Hasil Range Columns](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/range_columns.jpg "Hasil Range Columns")  

### 2.2 `LIST` Partitioning
`LIST` partition hampir sama dengan `RANGE` namun pada list di partisi sesuai nilai yang di deklarasi. Sama seperti `RANGE` juga `LIST` bisa menggunakan `LIST COLUMNS`. Sebagai contoh seperti berikut :
```sql
CREATE TABLE lc (
    a INT,
    b INT
)
PARTITION BY LIST COLUMNS(a,b) (
    PARTITION p0 VALUES IN( (0,0), (NULL,NULL) ),
    PARTITION p1 VALUES IN( (0,1), (0,2), (0,3), (1,1), (1,2) ),
    PARTITION p2 VALUES IN( (1,0), (2,0), (2,1), (3,0), (3,1) ),
    PARTITION p3 VALUES IN( (1,3), (2,2), (2,3), (3,2), (3,3) )
);

INSERT INTO lc(a,b) VALUES(0,0);
INSERT INTO lc(a,b) VALUES(0,1);
INSERT INTO lc(a,b) VALUES(0,2);
INSERT INTO lc(a,b) VALUES(0,3);
INSERT INTO lc(a,b) VALUES(1,0);
INSERT INTO lc(a,b) VALUES(1,1);
INSERT INTO lc(a,b) VALUES(1,2);
INSERT INTO lc(a,b) VALUES(1,3);
INSERT INTO lc(a,b) VALUES(1,0);
INSERT INTO lc(a,b) VALUES(2,1);
INSERT INTO lc(a,b) VALUES(2,2);
INSERT INTO lc(a,b) VALUES(2,3);
INSERT INTO lc(a,b) VALUES(3,0);
INSERT INTO lc(a,b) VALUES(3,1);
INSERT INTO lc(a,b) VALUES(3,2);
INSERT INTO lc(a,b) VALUES(3,3);
```
![Explain List Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/explain_list.jpg "Explain List Partitions")   
![Hasil List Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/list_columns.jpg "Hasil List Partitions")   

### 2.3 `HASH` Partitioning
Pada `HASH` partitioning, partisi akan dipilih berdasarkan nilai yang dikembalikan. Nilai yang dikembalikan harus berupa integer non-negatif. `HASH` digunakan terutama untuk mendistribusikan data secara merata di antara jumlah partisi. Contoh :
```sql
CREATE TABLE serverlogs (
    server_id INT, 
    logdata BLOB,
    created DATETIME
)
PARTITION BY HASH (server_id)
PARTITIONS 10;

INSERT INTO serverlogs(server_id) VALUES(1);
INSERT INTO serverlogs(server_id) VALUES(2);
INSERT INTO serverlogs(server_id) VALUES(3);
INSERT INTO serverlogs(server_id) VALUES(4);
INSERT INTO serverlogs(server_id) VALUES(5);
INSERT INTO serverlogs(server_id) VALUES(6);
INSERT INTO serverlogs(server_id) VALUES(7);
INSERT INTO serverlogs(server_id) VALUES(8);
INSERT INTO serverlogs(server_id) VALUES(9);
INSERT INTO serverlogs(server_id) VALUES(10);
INSERT INTO serverlogs(server_id) VALUES(11);
INSERT INTO serverlogs(server_id) VALUES(12);
INSERT INTO serverlogs(server_id) VALUES(13);
INSERT INTO serverlogs(server_id) VALUES(14);
INSERT INTO serverlogs(server_id) VALUES(15);
INSERT INTO serverlogs(server_id) VALUES(16);
INSERT INTO serverlogs(server_id) VALUES(17);
INSERT INTO serverlogs(server_id) VALUES(18);
INSERT INTO serverlogs(server_id) VALUES(19);
INSERT INTO serverlogs(server_id) VALUES(20);
```
![Explain Hash Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/explain_hash.jpg "Explain Hash Partitions")   
![Hasil Hash Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/hasil_hash.jpg "Hasil Hash Partitions")   

### 2.4 `KEY` Partitioning
Ini sangat mirip dengan partisi `HASH`, tetapi fungsi hashing disediakan oleh MySQL. Partisi `KEY` dapat menentukan nol atau banyak kolom, yang dapat berisi nilai-nilai non-integer. Hasil integer akan dikembalikan terlepas dari tipe data kolom. Contoh berikut akan menjelaskan hal ini :
```sql
CREATE TABLE serverlogs2 (
    serverid INT, 
    logdata BLOB,
    created DATETIME,
    label VARCHAR(10)
)
PARTITION BY KEY(serverid, label, created)
PARTITIONS 10;

insert into serverlogs2 (serverid, created, label) values (1, '2019-01-03', 'Nissan');
insert into serverlogs2 (serverid, created, label) values (2, '2019-01-29', 'Toyota');
insert into serverlogs2 (serverid, created, label) values (3, '2018-05-15', 'Subaru');
insert into serverlogs2 (serverid, created, label) values (4, '2018-11-07', 'Ford');
insert into serverlogs2 (serverid, created, label) values (5, '2018-05-16', 'Nissan');
insert into serverlogs2 (serverid, created, label) values (6, '2018-04-21', 'Volvo');
insert into serverlogs2 (serverid, created, label) values (7, '2018-10-25', 'Hyundai');
insert into serverlogs2 (serverid, created, label) values (8, '2019-02-01', 'Jaguar');
insert into serverlogs2 (serverid, created, label) values (9, '2019-02-19', 'Ford');
insert into serverlogs2 (serverid, created, label) values (10, '2018-11-21', 'GMC');
insert into serverlogs2 (serverid, created, label) values (11, '2018-07-05', 'Suzuki');
insert into serverlogs2 (serverid, created, label) values (12, '2019-01-17', 'Infiniti');
insert into serverlogs2 (serverid, created, label) values (13, '2019-03-18', 'Land Rover');
insert into serverlogs2 (serverid, created, label) values (14, '2018-04-01', 'GMC');
insert into serverlogs2 (serverid, created, label) values (15, '2018-07-12', 'GMC');
insert into serverlogs2 (serverid, created, label) values (16, '2018-05-15', 'Volvo');
insert into serverlogs2 (serverid, created, label) values (17, '2018-06-20', 'Mitsubishi');
insert into serverlogs2 (serverid, created, label) values (18, '2018-04-18', 'Lexus');
insert into serverlogs2 (serverid, created, label) values (19, '2018-08-12', 'Mitsubishi');
insert into serverlogs2 (serverid, created, label) values (20, '2018-09-30', 'RollsRoyce');
insert into serverlogs2 (serverid, created, label) values (21, '2018-11-11', 'BMW');
insert into serverlogs2 (serverid, created, label) values (22, '2018-08-12', 'Nissan');
insert into serverlogs2 (serverid, created, label) values (23, '2018-06-16', 'Nissan');
insert into serverlogs2 (serverid, created, label) values (24, '2018-11-04', 'Mercedes');
insert into serverlogs2 (serverid, created, label) values (25, '2018-08-02', 'Lincoln');
insert into serverlogs2 (serverid, created, label) values (26, '2018-05-31', 'Volvo');
insert into serverlogs2 (serverid, created, label) values (27, '2018-04-07', 'Chrysler');
insert into serverlogs2 (serverid, created, label) values (28, '2018-10-29', 'BMW');
insert into serverlogs2 (serverid, created, label) values (29, '2018-11-09', 'Mercedes');
```
![Explain Key Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/explain_key.jpg "Explain Key Partitions")   
![Query Select Key Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/q_select_key.jpg "Query Select Key Partitions")   
![Hasil Key Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/hasil_key.jpg "Hasil Key Partitions")   

## 3. Testing "A Typical Use Case: Time Series Data"
Untuk dataset bisa didapatkan [disini](https://drive.google.com/file/d/0B2Ksz9hP3LtXRUppZHdhT1pBaWM/view "Sample data link").
### 3.1 Explain Partition
1. Tabel Measures   
![Explain Tabel Measures](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/explain_measures.jpg "Explain Tabel Measures")   
2. Tabel Partitioned Measures   
![Explain Tabel Partitioned Measures](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/explain_partitioned_measures.jpg "Explain Tabel Partitioned Measures")   
### 3.2 Select Queries Benchmark
Hasil perbandingan query select dari tiap tabel. Lihat waktu eksekusinya.   
![Select Benchmarking](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/select_benchmark.jpg "Select Benchmarking")   
Query select pada tabel yang tidak melakukan partitioning lebih cepat dari pada tabel yang melakukan partitioning.
### 3.3 The Big Delete Benchmark
Sebelum melakukan delete data yang banyak, sebaiknya kita memberi index pada kolom yang akan menjadi kondisi query delete dengan syntax seperti ini :
```sql
ALTER TABLE measures
ADD INDEX index1 (measure_timestamp ASC);
```
```sql
ALTER TABLE partitioned_measures
ADD INDEX index1 (measure_timestamp ASC);
```
Hasil perbandingan query delete dari tiap tabel. Lihat waktu eksekusinya.   
![Delete Benchmarking](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/delete_benchmark.jpg "Delete Benchmarking")   
Untuk menghapus data lebih efektif jika menggunakan partitioning.

## 4. Referensi
- https://www.vertabelo.com/blog/technical-articles/everything-you-need-to-know-about-mysql-partitions
- https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet