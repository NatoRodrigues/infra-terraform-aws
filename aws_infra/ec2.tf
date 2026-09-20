resource "aws_instance" "VM" {
  for_each               = toset(["VM1", "VM2", "VM3", "VM4"])
  ami                    = "ami-011899242bb902164"
  instance_type          = "t2.micro"  
  vpc_security_group_ids = [aws_security_group.webapp_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y wget apt-transport-https software-properties-common nginx

              # 1. Instalação do .NET 8 Runtime/SDK no Ubuntu
              wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
              sudo dpkg -i packages-microsoft-prod.deb
              rm packages-microsoft-prod.deb
              sudo apt-get update
              sudo apt-get install -y aspnetcore-runtime-8.0 dotnet-sdk-8.0

              # 2. Configuração do Nginx como Reverse Proxy (Porta 80 -> 5000)
              cat << 'EON' > /etc/nginx/sites-available/default
              server {
                  listen 80;
                  location / {
                      proxy_pass http://localhost:5000;
                      proxy_http_version 1.1;
                      proxy_set_header Upgrade $http_upgrade;
                      proxy_set_header Connection keep-alive;
                      proxy_set_header Host $host;
                      proxy_cache_bypass $http_upgrade;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;
                  }
              }
              EON
              sudo systemctl restart nginx

              # 3. Criação do diretório base para a aplicação
              sudo mkdir -p /var/www/webapp

              # 4. Configuração do serviço Systemd para gerir a API em background
              cat << 'EOS' > /etc/systemd/system/webapp.service
              [Unit]
              Description=Web App .NET API (${each.key})
              After=network.target

              [Service]
              WorkingDirectory=/var/www/webapp
              ExecStart=/usr/bin/dotnet /var/www/webapp/webapp.dll
              Restart=always
              RestartSec=10
              KillSignal=SIGINT
              SyslogIdentifier=webapp
              User=www-data
              Environment=ASPNETCORE_ENVIRONMENT=Production
              Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
              Environment=AWS_SERVICE_URL=http://host.docker.internal:4566

              [Install]
              WantedBy=multi-user.target
              EOS

              # 5. Permissões e ativação dos serviços de sistema
              sudo chown -R www-data:www-data /var/www/webapp
              sudo systemctl daemon-reload
              sudo systemctl enable webapp
              sudo systemctl enable nginx
              sudo systemctl start nginx

              echo "Instância ${each.key} preparada para deploy." > /var/log/provision.log
              EOF

  tags = {
    Name = "Webapp-${each.key}"
  }
}