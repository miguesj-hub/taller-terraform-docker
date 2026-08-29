-- Este script se monta en /docker-entrypoint-initdb.d/, la carpeta que la
-- imagen oficial de MySQL ejecuta automáticamente la PRIMERA vez que se
-- inicializa el volumen de datos (ver terraform/mysql.tf).
CREATE TABLE IF NOT EXISTS visits (
  id INT AUTO_INCREMENT PRIMARY KEY,
  served_by VARCHAR(100) NOT NULL,
  visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
