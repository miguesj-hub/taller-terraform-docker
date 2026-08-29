# Esta NO es una plantilla estática: Terraform la procesa con la función
# templatefile() antes de subirla al contenedor (ver terraform/nginx.tf).
# $${ ... } interpola valores; %%{ for ... } / %%{ endfor } es un bucle de HCL.
# El resultado final es un nginx.conf normal, generado dinámicamente según
# cuántas réplicas de backend existan en ese momento.

events {}

http {
  upstream backend_upstream {
%{ for host in backend_hosts ~}
    server ${host}:3000;
%{ endfor ~}
  }

  server {
    listen 80;

    # Todo lo que empiece por /api/ se reparte (round-robin, por defecto
    # de Nginx) entre las réplicas del backend Node.js.
    location /api/ {
      proxy_pass http://backend_upstream/api/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
    }

    # Todo lo demás se sirve desde el contenedor del frontend (React
    # compilado, servido por su propio Nginx interno).
    location / {
      proxy_pass http://frontend:80/;
      proxy_set_header Host $host;
    }
  }
}
