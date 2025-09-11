# Cria a pasta e baixa os scripts
mkdir -p /volume/CloudFluig && cd /volume/CloudFluig/ && \
touch verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh && \
chmod +x verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh && \
curl -o verifica_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_fluig.sh && \
curl -o verifica_certificado.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_certificado.sh && \
curl -o verifica_solr.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_solr.sh
curl -o replicador_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/replicador_fluig.sh

# Adiciona as entradas no crontab do root
(crontab -l 2>/dev/null; cat <<'EOF'
#Cloud_sustentação
*/15 22-23 * * * /bin/bash /volume/CloudFluig/verifica_fluig.sh >> /volume/CloudFluig/verifica_fluig_cron.log 2>&1
*/15 0-6   * * * /bin/bash /volume/CloudFluig/verifica_fluig.sh >> /volume/CloudFluig/verifica_fluig_cron.log 2>&1
0 9 * * * /bin/bash /volume/CloudFluig/verifica_certificado.sh >> /volume/CloudFluig/verifica_certificados_cron.log 2>&1
#* * * * * /bin/bash /volume/CloudFluig/verifica_solr.sh >> /volume/CloudFluig/verifica_solr.log 2>&1
#0 * * * * truncate -s 0 /app/fluig/solr/logs/*.request.log
######PARA O SERVIÇO TCloudDiscovery PARA MITIGAR SOBRECARGA DOS RECURSOS DO SERVIDOR######
0 * * * * systemctl stop tclouddiscovery
######LIMPEZA DE ARQUIVOS ANTIGOS DE UPLOAD######
0 6 * * * find /volume/wdk-data/upload/ -type f -mtime +7 -exec rm -f {} +
EOF
) | crontab -
