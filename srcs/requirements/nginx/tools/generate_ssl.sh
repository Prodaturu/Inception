#!/bin/sh

# Generate SSL certificate for sprodatu.42.fr
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/sprodatu.42.fr.key \
    -out /etc/nginx/ssl/sprodatu.42.fr.crt \
    -subj "/C=DE/ST=Baden-Wurttemberg/L=Heilbronn/O=42School/OU=sprodatu/CN=sprodatu.42.fr"

echo "SSL certificate generated successfully"
