# Implementasi Partisi

### 1. Pengecekan Plugin Partition
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

### 2. Create Partition
Pada dasarnya ada 4 jenis partition yang tersedia yaitu : `RANGE`, `LIST`, `HASH`, dan `KEY`.   
#### 2.1. `RANGE` Partitioning   
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

#### 2.2 `LIST` Partitioning
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
```
![Explain List Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/explain_list.jpg "Explain List Partitions")   
![Hasil List Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/list_columns.jpg "Hasil List Partitions")   

#### 2.3 `HASH` Partitioning
Pada `HASH` partitioning, partisi akan dipilih berdasarkan nilai yang dikembalikan. Nilai yang dikembalikan harus berupa integer non-negatif. `HASH` digunakan terutama untuk mendistribusikan data secara merata di antara jumlah partisi. Contoh :
```sql
CREATE TABLE serverlogs (
    server_id INT, 
    logdata BLOB,
    created DATETIME
)
PARTITION BY HASH (server_id)
PARTITIONS 10;
```
![Explain Hash Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/explain_hash.jpg "Explain Hash Partitions")   
![Hasil Hash Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/hasil_hash.jpg "Hasil Hash Partitions")   

#### 2.4 `KEY` Partitioning
Ini sangat mirip dengan partisi `HASH`, tetapi fungsi hashing disediakan oleh MySQL. Partisi `KEY` dapat menentukan nol atau banyak kolom, yang dapat berisi nilai-nilai non-integer. Hasil integer akan dikembalikan terlepas dari tipe data kolom. Contoh berikut akan menjelaskan hal ini :
```sql
CREATE TABLE serverlogs5 (
    serverid INT, 
    logdata BLOB,
    created DATETIME,
    label VARCHAR(10)
)
PARTITION BY KEY(serverid, label, created)
PARTITIONS 10;
```
![Explain Key Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/explain_key.jpg "Explain Key Partitions")   
![Query Select Key Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/q_select_key.jpg "Query Select Key Partitions")   
![Hasil Key Partitions](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Implementasi%20Partisi/gambar/hasil_key.jpg "Hasil Key Partitions")   

### 3. Testing "A Typical Use Case: Time Series Data"

#### 3.1 Explain Partition
#### 3.2 Select Queries Benchmark
#### 3.3 The Big Delete Benchmark