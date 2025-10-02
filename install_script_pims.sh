
#!/bin/bash
# Desenvolvido por Alexandre dos Santos (Coxa) - 20-09-2025

# Cria a pasta e baixa os scripts
mkdir -p /volume/CloudAGRO && cd /volume/CloudAGRO/ || exit 1

# Cria arquivos vazios e aplica permissão
touch check_wildfly.sh fix_visudo.sh fonte.sh
chmod +x check_wildfly.sh fix_visudo.sh fonte.sh

# Baixa os scripts atualizados do GitHub
curl -s -o check_wildfly.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/check_wildfly.sh
curl -s -o fix_visudo.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fix_visudo.sh
curl -s -o fonte.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fonte.sh


# Remove bloco antigo do crontab e adiciona novamente
(crontab -l 2>/dev/null | sed '/^#Cloud_sustentação$/,/^#Cloud_sustentação$/d'; cat <<'EOF'
#Cloud_sustentação
* * * * * /bin/bash /volume/CloudAGRO/check_wildfly.sh >> /volume/CloudAGRO/check_wildfly.log 2>&1
#Cloud_sustentação
EOF
) | crontab -
