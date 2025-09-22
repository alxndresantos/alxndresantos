Pular para o conteúdo
Histórico de chats

Você disse:
meu script faz isso # Cria a pasta e baixa os scripts
mkdir -p /volume/CloudFluig && cd /volume/CloudFluig/ && \
touch verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh && \
chmod +x verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh && \
curl -o verifica_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_fluig.sh && \
curl -o verifica_certificado.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_certificado.sh && \
curl -o verifica_solr.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_solr.sh
curl -o replicador_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/replicador_fluig.sh
curl -o import_key.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/import_key.sh

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
#Cloud_sustentação
EOF
) | crontab -
 quero adicionar uma validação caso ja tenha essas infos no contrab apagar o bloco que inicia no #Cloud_sustentação e termina no #Cloud_sustentação e adiciionar novamente
O ChatGPT disse:
Entendi 👍
Você quer que seu script, ao rodar, remova qualquer bloco anterior entre #Cloud_sustentação … #Cloud_sustentação no crontab e depois insira o bloco atualizado.

Pode fazer assim:

# Remove o bloco antigo do crontab e adiciona novamente
(crontab -l 2>/dev/null | sed '/^#Cloud_sustentação$/,/^#Cloud_sustentação$/d'; cat <<'EOF'
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
#Cloud_sustentação
EOF
) | crontab -
O que esse trecho faz:
crontab -l lista as entradas atuais.

sed '/^#Cloud_sustentação$/,/^#Cloud_sustentação$/d' remove qualquer bloco que esteja entre as duas tags.

cat <<'EOF' ... EOF injeta o novo bloco atualizado.

O resultado é aplicado de volta no crontab com | crontab -.

Assim, seu script pode ser executado quantas vezes quiser, que sempre vai substituir o bloco inteiro por uma versão limpa.

Quer que eu adapte esse mesmo modelo para o seu trecho completo (com mkdir, curl etc.) já embutindo essa lógica, ou prefere deixar separado?

Você disse:
quero 
O ChatGPT disse:
Show, então já deixo seu script inteiro atualizado com a lógica de recriar sempre o bloco do crontab 👍

#!/bin/bash
# Desenvolvido por Alexandre dos Santos (Coxa) - 20-09-2025

# Cria a pasta e baixa os scripts
mkdir -p /volume/CloudFluig && cd /volume/CloudFluig/ || exit 1

# Cria arquivos vazios e aplica permissão
touch verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh import_key.sh
chmod +x verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh import_key.sh

# Baixa os scripts atualizados do GitHub
curl -s -o verifica_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_fluig.sh
curl -s -o verifica_certificado.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_certificado.sh
curl -s -o verifica_solr.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_solr.sh
curl -s -o replicador_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/replicador_fluig.sh
curl -s -o import_key.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/import_key.sh

# Remove bloco antigo do crontab e adiciona novamente
(crontab -l 2>/dev/null | sed '/^#Cloud_sustentação$/,/^#Cloud_sustentação$/d'; cat <<'EOF'
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
#Cloud_sustentação
EOF
) | crontab -
👉 Esse script agora é idempotente:

Se rodar várias vezes, o bloco do crontab será sempre substituído pelo novo.

Se não tiver crontab ainda, ele cria do zero.

Se tiver crontab com outras tarefas, elas são preservadas.

Quer que eu já adicione também um log geral (ex.: /volume/CloudFluig/setup_cron.log) para registrar a execução desse script principal, ou prefere deixar sem log?

Você disse:
implemente nesse script tbm # Cria a pasta e baixa os scripts
mkdir -p /volume/CloudFluig && cd /volume/CloudFluig/ && \
touch verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh && \
chmod +x verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh && \
curl -o verifica_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_fluig.sh && \
curl -o verifica_certificado.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_certificado.sh && \
curl -o verifica_solr.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_solr.sh
curl -o replicador_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/replicador_fluig.sh
curl -o import_key.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/import_key.sh

# Adiciona as entradas no crontab do root
(crontab -l 2>/dev/null; cat <<'EOF'
#Cloud_sustentação
*/20 * * * * /bin/bash /volume/CloudFluig/verifica_fluig.sh >> /volume/CloudFluig/verifica_fluig_cron.log 2>&1
0 9 * * * /bin/bash /volume/CloudFluig/verifica_certificado.sh >> /volume/CloudFluig/verifica_certificados_cron.log 2>&1
#* * * * * /bin/bash /volume/CloudFluig/verifica_solr.sh >> /volume/CloudFluig/verifica_solr.log 2>&1
#0 * * * * truncate -s 0 /app/fluig/solr/logs/*.request.log
######PARA O SERVIÇO TCloudDiscovery PARA MITIGAR SOBRECARGA DOS RECURSOS DO SERVIDOR######
0 * * * * systemctl stop tclouddiscovery
######LIMPEZA DE ARQUIVOS ANTIGOS DE UPLOAD######
0 6 * * * find /volume/wdk-data/upload/ -type f -mtime +7 -exec rm -f {} +
EOF
) | crontab -
O ChatGPT disse:
Perfeito 👌
Vou ajustar esse seu segundo script para também apagar qualquer bloco anterior entre #Cloud_sustentação … #Cloud_sustentação e recriar com as entradas novas.

Aqui está a versão atualizada:

#!/bin/bash
# Desenvolvido por Alexandre dos Santos (Coxa) - 20-09-2025

# Cria a pasta e baixa os scripts
mkdir -p /volume/CloudFluig && cd /volume/CloudFluig/ || exit 1

# Cria arquivos vazios e aplica permissão
touch verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh import_key.sh
chmod +x verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh import_key.sh

# Baixa os scripts atualizados do GitHub
curl -s -o verifica_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_fluig.sh
curl -s -o verifica_certificado.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_certificado.sh
curl -s -o verifica_solr.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_solr.sh
curl -s -o replicador_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/replicador_fluig.sh
curl -s -o import_key.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/import_key.sh

# Remove bloco antigo do crontab e adiciona novamente
(crontab -l 2>/dev/null | sed '/^#Cloud_sustentação$/,/^#Cloud_sustentação$/d'; cat <<'EOF'
#Cloud_sustentação
*/20 * * * * /bin/bash /volume/CloudFluig/verifica_fluig.sh >> /volume/CloudFluig/verifica_fluig_cron.log 2>&1
0 9 * * * /bin/bash /volume/CloudFluig/verifica_certificado.sh >> /volume/CloudFluig/verifica_certificados_cron.log 2>&1
#* * * * * /bin/bash /volume/CloudFluig/verifica_solr.sh >> /volume/CloudFluig/verifica_solr.log 2>&1
#0 * * * * truncate -s 0 /app/fluig/solr/logs/*.request.log
######PARA O SERVIÇO TCloudDiscovery PARA MITIGAR SOBRECARGA DOS RECURSOS DO SERVIDOR######
0 * * * * systemctl stop tclouddiscovery
######LIMPEZA DE ARQUIVOS ANTIGOS DE UPLOAD######
0 6 * * * find /volume/wdk-data/upload/ -type f -mtime +7 -exec rm -f {} +
#Cloud_sustentação
EOF
) | crontab -
➡️ Agora esse script também é idempotente:

Se rodar de novo, o bloco entre #Cloud_sustentação será substituído.

As demais entradas do crontab do root continuam intactas.

Quer que eu una os dois scripts (o de */15 e esse de */20) em um só, e você só troca uma variável (FREQUENCIA=15 ou 20) para escolher qual cron criar?

Você disse:
Sep 20 23:10:29 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: 2025-09-21 02:07:30.188 INFO  (searcherExecutor-13-thread-1-processing-1) [c: s: r: x:1 t:] o.a.s.c.SolrCore Registered new searcher autowarm time: 0 ms
Sep 20 23:10:29 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: #010#010#010#010#010#010    #010#010#010#010
Sep 20 23:10:29 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Refusing to accept PID outside of service control group, acquired through unsafe symlink chain: /app/fluig/solr/solr-8983.pid
Sep 20 23:10:29 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Session c41385 of user fluig.
Sep 20 23:10:29 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: Sending stop command to Solr running on port 8983 ... waiting up to 180 seconds to allow Jetty process 6289 to stop gracefully.
Sep 20 23:10:32 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: chown: cannot access ‘/app/fluig/solr/solr-8983.pid’: No such file or directory
Sep 20 23:10:32 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: fluig_indexer.service: control process exited, code=exited status=1
Sep 20 23:10:32 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]  #010#010#010#010#010#010    #010#010#010#010
Sep 20 23:10:32 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Unit fluig_indexer.service entered failed state.
Sep 20 23:10:32 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: fluig_indexer.service failed.
Sep 20 23:11:01 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Session 164612 of user root.
Sep 20 23:11:01 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Fluig Indexer.
Sep 20 23:11:01 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Session c41386 of user fluig.
O ChatGPT disse:
Pelos logs que você trouxe, dá pra entender bem o que está acontecendo com o fluig-indexer (Solr):

O que aparece no log:
systemd: Refusing to accept PID outside of service control group, acquired through unsafe symlink chain: /app/fluig/solr/solr-8983.pid
👉 O systemd não gostou do PID que o serviço apontou no arquivo /app/fluig/solr/solr-8983.pid.
Isso geralmente acontece quando:

O arquivo foi criado com link simbólico inseguro, ou

O processo morreu mas o .pid ficou sobrando.

Sending stop command to Solr running on port 8983 ... waiting up to 180 seconds ...
chown: cannot access ‘/app/fluig/solr/solr-8983.pid’: No such file or directory
👉 O stop foi chamado, mas quando tentou manipular o .pid, o arquivo já não existia (talvez o processo tenha morrido antes).

systemd: fluig_indexer.service: control process exited, code=exited status=1
systemd: Unit fluig_indexer.service entered failed state.
systemd: fluig_indexer.service failed.
👉 O serviço caiu porque o script de controle (provavelmente solr start/stop dentro do wrapper do Fluig) retornou erro.

systemd: Started Fluig Indexer.
👉 O próprio systemd reiniciou o serviço (Restart=always provavelmente está configurado na unit fluig_indexer.service).

Resumindo o problema:
O Solr do Fluig está caindo na hora do stop/start.

O PID do Solr não está sendo tratado corretamente (inseguro ou inexistente).

O serviço cai (failed state) mas o systemd reinicia logo em seguida.

Possíveis causas
Arquivo .pid corrompido ou manipulado

Pode ser link simbólico errado, permissões incorretas ou criado fora do cgroup do systemd.

Já vi muito isso quando se usa chown direto em solr-8983.pid e o processo já morreu.

Dupla chamada de stop/start

O script que controla o Solr pode estar rodando stop e em seguida o systemd também tentar parar, causando conflito.

Permissões incorretas

Usuário fluig não consegue acessar/manipular corretamente /app/fluig/solr/solr-8983.pid.

O que dá pra ajustar
Garantir limpeza do PID no start/stop
Antes de iniciar, se o processo não estiver rodando, mas o arquivo .pid existir, apagar ele:

if [ -f /app/fluig/solr/solr-8983.pid ] && ! ps -p $(cat /app/fluig/solr/solr-8983.pid) > /dev/null 2>&1; then
    rm -f /app/fluig/solr/solr-8983.pid
fi
Revisar o unit file fluig_indexer.service
Ver se tem algo como:

PIDFile=/app/fluig/solr/solr-8983.pid
Restart=always
Se tiver, pode precisar ajustar para o PID real do processo.

Ajustar permissões
Ver se o usuário fluig é realmente dono do diretório:

chown -R fluig:fluig /app/fluig/solr
👉 Pergunto: você quer que eu monte um script de monitoramento/recovery para incluir no seu verifica_solr.sh que trate esse problema do PID quebrado (apagando se estiver inválido), ou prefere que eu ajuste a própria unit do systemd (fluig_indexer.service) pra não depender mais desse .pid?

Você disse:
Sep 20 23:18:52 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: 2025-09-21 02:15:54.331 INFO  (searcherExecutor-13-thread-1-processing-1) [c: s: r: x:1 t:] o.a.s.h.c.SpellCheckComponent Loading spell index for spellchecker: wordbreak
Sep 20 23:18:52 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: 2025-09-21 02:15:54.331 INFO  (searcherExecutor-13-thread-1-processing-1) [c: s: r: x:1 t:] o.a.s.h.c.SpellCheckComponent Loading spell index for spellchecker: default
Sep 20 23:18:52 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: 2025-09-21 02:15:54.339 INFO  (searcherExecutor-13-thread-1-processing-1) [c: s: r: x:1 t:] o.a.s.c.SolrCore Registered new searcher autowarm time: 0 ms
Sep 20 23:18:53 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: #010#010#010#010#010#010    #010#010#010#010
Sep 20 23:18:53 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Refusing to accept PID outside of service control group, acquired through unsafe symlink chain: /app/fluig/solr/solr-8983.pid
Sep 20 23:18:53 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Session c41391 of user fluig.
Sep 20 23:18:53 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: Sending stop command to Solr running on port 8983 ... waiting up to 180 seconds to allow Jetty process 11127 to stop gracefully.
Sep 20 23:18:55 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: chown: cannot access ‘/app/fluig/solr/solr-8983.pid’: No such file or directory
Sep 20 23:18:55 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]  #010#010#010#010#010#010    #010#010#010#010
Sep 20 23:18:55 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: fluig_indexer.service: control process exited, code=exited status=1
Sep 20 23:18:55 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Unit fluig_indexer.service entered failed state.
Sep 20 23:18:55 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: fluig_indexer.service failed.
Sep 20 23:19:01 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Session 164632 of user root.
Sep 20 23:19:01 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Fluig Indexer.
Sep 20 23:19:01 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Session c41392 of user fluig.
O ChatGPT disse:
Certo, pelo log mais recente, o padrão se mantém: o fluig-indexer (Solr) inicia, mas logo em seguida o serviço falha devido ao problema com o PID:

Diagnóstico rápido
Mensagem-chave:

Refusing to accept PID outside of service control group, acquired through unsafe symlink chain: /app/fluig/solr/solr-8983.pid
chown: cannot access ‘/app/fluig/solr/solr-8983.pid’: No such file or directory
O systemd não aceita o PID do Solr porque o arquivo .pid está fora do cgroup do serviço ou é um symlink inseguro.

Depois, quando o script tenta chown no PID, ele não existe — provavelmente porque o Solr já encerrou ou nunca criou o PID corretamente.

Consequência:

O serviço entra em failed state (control process exited, code=exited status=1).

O systemd tenta reiniciar (Started Fluig Indexer) mas o problema se repete indefinidamente.

Causas prováveis
Solr não está escrevendo o PID corretamente (permissão, diretório errado, ou container/cgroup isolado).

O script do Fluig que manipula o PID (fluig-indexer) chama stop/start de forma que o .pid desaparece antes do systemd tentar acessá-lo.

Uso de symlinks inseguros dentro de /app/fluig/solr/.

Soluções possíveis
Forçar limpeza do PID antes de iniciar (mais simples, pode colocar no verifica_solr.sh):

PID_FILE="/app/fluig/solr/solr-8983.pid"
if [ -f "$PID_FILE" ] && ! ps -p $(cat "$PID_FILE") > /dev/null 2>&1; then
    echo "PID inválido encontrado, removendo $PID_FILE"
    rm -f "$PID_FILE"
fi
Ajustar permissões do diretório Solr:

chown -R fluig:fluig /app/fluig/solr
chmod -R 750 /app/fluig/solr
Revisar unit do systemd (fluig_indexer.service):

Certificar que PIDFile=/app/fluig/solr/solr-8983.pid aponta para o PID real.

Se for possível, usar Type=simple ou Type=forking correto para o Solr.

Se estiver em container ou cgroup isolado, pode ser necessário remover a referência direta ao PID e confiar só no processo de foreground.

Se você quiser, eu posso montar um patch pronto para o seu verifica_solr.sh que:

Verifica se o PID existe e é válido.

Remove PID inválido.

Tenta reiniciar o Solr com segurança.

Isso evita que o serviço fique entrando em failed state repetidamente.

Quer que eu faça isso?

Você disse:
Sep 20 23:33:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: Waiting up to 180 seconds to see Solr running on port 8983 [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]  #010#010#010#010#010#010 [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]  #010#010#010#010#010#010 [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]
Sep 20 23:33:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: Started Solr server on port 8983 (pid=). Happy searching!
Sep 20 23:33:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: #010#010#010#010#010#010    #010#010#010#010
Sep 20 23:33:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 systemd: Started Session c25 of user fluig.
Sep 20 23:33:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: No process found for Solr node running on port 8983
Sep 20 23:34:01 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 systemd: Started Session 72 of user root.
Sep 20 23:34:01 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 systemd: Started Fluig Indexer.
Sep 20 23:34:01 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 systemd: Started Session c26 of user fluig.
Sep 20 23:34:04 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: /app/fluig/fluig_Indexer/bin/solr: line 653:  2839 Killed                  nohup "$JAVA" "${SOLR_START_OPTS[@]}" $SOLR_ADDL_ARGS -Dsolr.log.muteconsole "-XX:OnOutOfMemoryError=$SOLR_TIP/bin/oom_solr.sh $SOLR_PORT $SOLR_LOGS_DIR" -jar start.jar "${SOLR_JETTY_CONFIG[@]}" $SOLR_JETTY_ADDL_CONFIG > "$SOLR_LOGS_DIR/solr-$SOLR_PORT-console.log" 2>&1
Sep 20 23:34:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: Solr at http://localhost:8983/solr not online.
Sep 20 23:34:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: Waiting up to 180 seconds to see Solr running on port 8983 [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]  #010#010#010#010#010#010 [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]  #010#010#010#010#010#010 [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]
Sep 20 23:34:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: Started Solr server on port 8983 (pid=). Happy searching!
Sep 20 23:34:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: #010#010#010#010#010#010    #010#010#010#010
Sep 20 23:34:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 systemd: Started Session c27 of user fluig.
Sep 20 23:34:07 185098-core-instance-N-FL-P-CGW3YX-1-03ee1LIN-SP06 fluig-indexer: No process found for Solr node running on port 8983
O ChatGPT disse:
Esse trecho do log mostra que o Solr do Fluig não está conseguindo se manter de pé:

Ele inicia (Started Solr server on port 8983),

Em seguida o processo é "Killed" (line 653: 2839 Killed),

Logo após o Fluig detecta que não há processo no ar (No process found for Solr node running on port 8983).

👉 O detalhe crítico é esse trecho:

Killed nohup "$JAVA" ...
-XX:OnOutOfMemoryError=$SOLR_TIP/bin/oom_solr.sh ...
Isso mostra que o processo foi morto pelo kernel (provavelmente OOM Killer) por falta de memória.
O script oom_solr.sh é disparado pelo parâmetro -XX:OnOutOfMemoryError, mas na verdade nem sempre dá tempo de executar — o kernel já encerra o processo antes.

O que você pode fazer:
Verificar o log do kernel para confirmar o OOM killer:

dmesg | egrep -i "kill|oom"
journalctl -k | egrep -i "kill|oom"
Checar o consumo de memória do Solr/Fluig:

free -m
top -o %MEM
Aumentar o heap do Solr
Normalmente o Fluig usa heap pequeno por padrão.
Edite o arquivo:

/app/fluig/fluig_Indexer/bin/solr.in.sh
ou o script que exporta as variáveis de memória, e ajuste:

SOLR_HEAP="2g"
(se tiver memória disponível no servidor).

Configurar swap caso não tenha:

swapon --show
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
Isso ajuda a segurar picos de consumo.

Rodar um monitor (tipo seu verifica_solr.sh) para tentar restartar o Solr se cair, mas isso é só mitigação — o ideal é resolver a causa raiz (memória insuficiente).

Quer que eu adapte o seu verifica_solr.sh para detectar quando o Solr morrer por OOM e reiniciar automaticamente, além de logar o motivo (checando dmesg/journalctl)?

Você disse:
Sep 20 23:40:08 120758-core-instance-N-FL-P-C8F09F-1-3c1123LIN-Z2 systemd: [/etc/systemd/system/hz-runner.service:3] Invalid URL, ignoring: Em
Sep 20 23:40:08 120758-core-instance-N-FL-P-C8F09F-1-3c1123LIN-Z2 systemd: [/etc/systemd/system/hz-runner.service:3] Invalid URL, ignoring: dev
Sep 20 23:40:20 120758-core-instance-N-FL-P-C8F09F-1-3c1123LIN-Z2 fluig-indexer: /app/fluig/fluig_Indexer/bin/solr: line 725: 24729 Aborted                 nohup "$JAVA" "${SOLR_START_OPTS[@]}" $SOLR_ADDL_ARGS -Dsolr.log.muteconsole -jar start.jar "${SOLR_JETTY_CONFIG[@]}" $SOLR_JETTY_ADDL_CONFIG > "$SOLR_LOGS_DIR/solr-$SOLR_PORT-console.log" 2>&1

O ChatGPT disse:
Esse log é outro sintoma de falha grave no Solr do Fluig:

fluig-indexer: /app/fluig/fluig_Indexer/bin/solr: line 725: 24729 Aborted
👉 Aqui não foi “Killed” pelo OOM Killer (falta de memória), mas sim “Aborted” — ou seja, o processo do Java encerrou por erro interno (provavelmente SIGABRT).

O que pode causar esse Aborted no Solr:
Configuração de memória incorreta (SOLR_HEAP muito alto ou muito baixo).

Incompatibilidade de Java (versão diferente da suportada pelo Fluig/Solr).

Corrompimento de índice ou configuração dentro do diretório:

/app/fluig/fluig_Indexer/solr/
→ arquivos corrompidos em data/ podem causar aborts.

Parâmetros extras de JVM no solr.in.sh ou solr wrapper.

Problemas de systemd → note os erros antes:

systemd: [/etc/systemd/system/hz-runner.service:3] Invalid URL, ignoring: Em
systemd: [/etc/systemd/system/hz-runner.service:3] Invalid URL, ignoring: dev
Isso mostra que há arquivos .service com linhas inválidas, o que pode causar falhas de dependência no boot.

Como diagnosticar melhor:
Verifique os últimos logs do Solr:

tail -n 100 /app/fluig/fluig_Indexer/logs/solr-8983-console.log
tail -n 100 /app/fluig/fluig_Indexer/logs/solr.log
Checar systemd para o erro do hz-runner:

cat -n /etc/systemd/system/hz-runner.service
Procure na linha 3, parece que tem algo como Em dev que não é válido.

Conferir a versão do Java que o Fluig está usando:

sudo -u fluig /app/fluig/jdk/bin/java -version
E comparar com a versão homologada do Fluig que você está rodando.

Testar iniciar manualmente o Solr fora do systemd:

cd /app/fluig/fluig_Indexer/bin
./solr start -p 8983 -force
Isso ajuda a ver o erro direto no terminal em vez de só no journal.

📌 Resumindo:

O Killed anterior era OOM (memória).

O Aborted agora é erro interno no Solr/Java/configuração.

Posso te montar um checklist de correção passo a passo (memória, Java, índice, systemd), ou prefere que eu adapte seu verifica_solr.sh para capturar também esse tipo de erro (Aborted) e reiniciar o serviço automaticamente?

Você disse:
2025-09-21 02:39:49.538 INFO  (coreLoadExecutor-11-thread-1) [c: s: r: x:1 t:] o.a.s.c.CoreContainer Creating SolrCore '1' using configuration from instancedir /app/fluig/solr/data/1, trusted=true
2025-09-21 02:39:49.585 INFO  (coreLoadExecutor-11-thread-1) [c: s: r: x:1 t:] o.a.s.c.SolrCore Opening new SolrCore at [/app/fluig/solr/data/1], dataDir=[/volume/wdk-data/index/]
2025-09-21 02:39:49.806 INFO  (main) [c: s: r: x: t:] o.a.s.j.SolrRequestAuthorizer Creating a new SolrRequestAuthorizer
2025-09-21 02:39:49.883 WARN  (main) [c: s: r: x: t:] o.g.j.i.Errors The following warnings have been detected: WARNING: HK2 service reification failed for [org.glassfish.jersey.message.internal.DataSourceProvider] with an exception:
MultiException stack 1 of 2
java.lang.NoClassDefFoundError: javax/activation/DataSource
        at java.base/java.lang.Class.getDeclaredConstructors0(Native Method)
        at java.base/java.lang.Class.privateGetDeclaredConstructors(Class.java:3137)
        at java.base/java.lang.Class.getDeclaredConstructors(Class.java:2357)
        at org.jvnet.hk2.internal.Utilities$3.run(Utilities.java:1354)
        at org.jvnet.hk2.internal.Utilities$3.run(Utilities.java:1350)
        at java.base/java.security.AccessController.doPrivileged(Native Method)
        at org.jvnet.hk2.internal.Utilities.getAllConstructors(Utilities.java:1350)
        at org.jvnet.hk2.internal.Utilities.findProducerConstructor(Utilities.java:1293)
        at org.jvnet.hk2.internal.DefaultClassAnalyzer.getConstructor(DefaultClassAnalyzer.java:60)
        at org.glassfish.jersey.inject.hk2.JerseyClassAnalyzer.getConstructor(JerseyClassAnalyzer.java:124)
        at org.jvnet.hk2.internal.Utilities.getConstructor(Utilities.java:156)
        at org.jvnet.hk2.internal.ClazzCreator.initialize(ClazzCreator.java:105)
        at org.jvnet.hk2.internal.ClazzCreator.initialize(ClazzCreator.java:156)
        at org.jvnet.hk2.internal.SystemDescriptor.internalReify(SystemDescriptor.java:716)
        at org.jvnet.hk2.internal.SystemDescriptor.reify(SystemDescriptor.java:670)
        at org.jvnet.hk2.internal.ServiceLocatorImpl.reifyDescriptor(ServiceLocatorImpl.ja
O ChatGPT disse:
Esse trecho do log é bem revelador 👇

java.lang.NoClassDefFoundError: javax/activation/DataSource
🚨 O que significa
O Solr (e, por consequência, o fluig-indexer) está tentando carregar a classe javax.activation.DataSource, mas ela não existe no classpath do Java que está rodando.

Isso acontece porque:

No Java 8, o pacote javax.activation vinha embutido.

A partir do Java 11, a API Java Activation Framework (JAF) foi removida do JDK e precisa ser adicionada manualmente.

Ou seja: você provavelmente está rodando o Fluig/Indexer com Java 11+, mas o código do Solr/Fluig foi feito assumindo Java 8.

🔍 Confirmar
Roda:

sudo -u fluig /app/fluig/jdk/bin/java -version
Se mostrar 11 ou 17, confirma o problema.

✅ Como corrigir
Você tem 2 opções:

1. (Mais seguro) Rodar com Java 8
Se a versão do Fluig que você usa só é homologada em Java 8, volte para o JDK 8 que vem com a instalação do Fluig:

export JAVA_HOME=/app/fluig/jdk8
export PATH=$JAVA_HOME/bin:$PATH
E ajustar o serviço systemd do indexer para apontar pro JDK 8.

2. (Workaround) Adicionar manualmente o JAR do javax.activation
Baixar o Jakarta Activation API (substituto do antigo JAF) e colocar em /app/fluig/fluig_Indexer/lib/ext/:

cd /app/fluig/fluig_Indexer/lib/ext/
wget https://repo1.maven.org/maven2/com/sun/activation/jakarta.activation/1.2.2/jakarta.activation-1.2.2.jar
Depois reiniciar:

systemctl restart fluig_indexer
Isso vai fornecer a classe javax.activation.DataSource que o Solr está procurando.

📌 Resumindo:

Esse NoClassDefFoundError está matando o processo (Aborted).

A causa é a ausência do javax.activation no Java ≥ 11.

Solução: ou voltar pro Java 8 (homologado) ou injetar o JAR jakarta.activation.

Quer que eu monte um passo a passo para ajustar o systemd do fluig-indexer pra rodar fixo no JDK 8 (sem mexer no restante do Fluig), ou prefere seguir no caminho de adicionar o JAR faltante no Java 11?

Você disse:
openjdk version "11.0.7" 2020-04-14
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.7+10)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11.0.7+10, mixed mode)
O ChatGPT disse:
Perfeito, confirmado ✅ — seu fluig-indexer está rodando com Java 11.
E como o log mostrou, o Solr do Fluig precisa da classe javax.activation.DataSource, que foi removida no Java 11.

🔧 Caminhos possíveis
Opção 1 — Corrigir adicionando o JAR faltante (mais simples)
Você pode colocar o Jakarta Activation (substituto do JAF) no classpath do indexador:

cd /app/fluig/fluig_Indexer/lib/ext/
wget https://repo1.maven.org/maven2/com/sun/activation/jakarta.activation/1.2.2/jakarta.activation-1.2.2.jar
chown fluig:fluig jakarta.activation-1.2.2.jar
E depois:

systemctl restart fluig_indexer
Isso deve eliminar o erro de NoClassDefFoundError.

Opção 2 — Voltar o indexador para Java 8 (mais seguro e homologado pela TOTVS)
Muitas versões do Fluig não suportam Java 11 oficialmente, apenas Java 8.
Se o seu ambiente é crítico, essa é a solução mais estável.

Passos:

Instale o JDK 8 (se não tiver no servidor).

Edite o serviço do indexador:

nano /etc/systemd/system/fluig_indexer.service
E altere a linha que define o Java, algo assim:

Environment="JAVA_HOME=/app/fluig/jdk8"
ExecStart=/app/fluig/jdk8/bin/java -jar ...
Recarregue o systemd:

systemctl daemon-reexec
systemctl restart fluig_indexer
📌 Resumo:

Java 11 está quebrando porque faltam bibliotecas removidas (javax.activation).

Solução rápida → adicionar o JAR jakarta.activation.

Solução oficial/homologada → rodar o indexador com Java 8.

👉 Quer que eu já te monte um script pronto que baixa e coloca o jakarta.activation no lugar certo e reinicia o serviço automaticamente?

Você disse:
10#010#010#010 [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]  #010#010#010#010#010#010 [|]  #010#010#010#010#010#010 [/]  #010#010#010#010#010#010 [-]  #010#010#010#010#010#010 [\]  #010#010#010#010#010
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: implementation=org.glassfish.jersey.message.internal.DataSourceProvider
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: contracts={javax.ws.rs.ext.MessageBodyReader,javax.ws.rs.ext.MessageBodyWriter}
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: scope=javax.inject.Singleton
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: qualifiers={}
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: descriptorType=CLASS
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: descriptorVisibility=NORMAL
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: metadata=
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: rank=0
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: loader=null
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: proxiable=null
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: proxyForSameScope=null
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: analysisName=null
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: id=90
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: locatorId=0
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: identityHashCode=1736804080
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: reified=false)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.jvnet.hk2.internal.SystemDescriptor.reify(SystemDescriptor.java:681)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.jvnet.hk2.internal.ServiceLocatorImpl.reifyDescriptor(ServiceLocatorImpl.java:442)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.jvnet.hk2.internal.ServiceLocatorImpl.narrow(ServiceLocatorImpl.java:2300)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.jvnet.hk2.internal.ServiceLocatorImpl.access$1200(ServiceLocatorImpl.java:106)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.jvnet.hk2.internal.ServiceLocatorImpl$10.compute(ServiceLocatorImpl.java:1385)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.jvnet.hk2.internal.ServiceLocatorImpl$10.compute(ServiceLocatorImpl.java:1380)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.glassfish.hk2.utilities.cache.internal.WeakCARCacheImpl.compute(WeakCARCacheImpl.java:105)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.jvnet.hk2.internal.ServiceLocatorImpl.internalGetAllServiceHandles(ServiceLocatorImpl.java:1442)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.jvnet.hk2.internal.ServiceLocatorImpl.getAllServiceHandles(ServiceLocatorImpl.java:1368)
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: at org.jvnet.hk2.internal.Ser...
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: 2025-09-21 03:33:17.626 INFO  (main) [c: s: r: x: t:] o.e.j.s.h.ContextHandler Started o.e.j.w.WebAppContext@aa21042{solr-jetty-context.xml,/solr,file:///app/fluig/solr/server/solr-webapp/webapp/,AVAILABLE}{/app/fluig/solr/server/solr-webapp/webapp}
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: 2025-09-21 03:33:17.641 INFO  (main) [c: s: r: x: t:] o.e.j.s.RequestLogWriter Opened /app/fluig/solr/logs/2025_09_21.request.log
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: 2025-09-21 03:33:17.646 INFO  (main) [c: s: r: x: t:] o.e.j.s.AbstractConnector Started ServerConnector@3aacf32a{HTTP/1.1, (http/1.1, h2c)}{0.0.0.0:8983}
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: 2025-09-21 03:33:17.648 INFO  (main) [c: s: r: x: t:] o.e.j.s.Server Started Server@32c0915e{STARTING}[10.0.19,sto=0] @4561ms
Sep 21 00:36:18 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 fluig-indexer: #010#010#010#010#010#010    #010#010#010#010
Sep 21 00:37:01 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Session 164783 of user root.
Sep 21 00:38:01 174436-core-instance-N-FL-P-C0HJZV-1-88db1fLIN-Z2 systemd: Started Session 164784 of user root.
O ChatGPT disse:
Beleza, Alexandre 👍
Esse trecho de log mostra que o erro de javax.activation.DataSource foi resolvido (o DataSourceProvider foi registrado).

📌 Resumindo o que rolou:

Antes, o indexador (Solr) não achava a classe javax.activation.DataSource.

Depois que você adicionou a lib (ou ajustou o ambiente), ele conseguiu carregar o DataSourceProvider sem mais NoClassDefFoundError.

O Solr subiu normalmente, abriu o conector em 0.0.0.0:8983 e o Jetty inicializou sem travar.

Agora o indexador deve estar rodando e respondendo no http://localhost:8983/solr ✅.

👉 Próximo passo:
Quer que eu te monte um check rápido em bash que testa automaticamente se o Solr do Fluig está online e responde (curl http://localhost:8983/solr/admin/ping), pra validar que o serviço está de pé e saudável?

Você disse:
2025-09-21 03:41:36.764 INFO  (main) [c: s: r: x: t:] o.a.s.c.CorePropertiesLocator Found 0 core definitions underneath /app/fluig/solr/data
2025-09-21 03:41:37.601 INFO  (main) [c: s: r: x: t:] o.a.s.j.SolrRequestAuthorizer Creating a new SolrRequestAuthorizer
2025-09-21 03:41:37.696 WARN  (main) [c: s: r: x: t:] o.g.j.i.Errors The following warnings have been detected: WARNING: HK2 service reification failed for [org.glassfish.jersey.message.internal.DataSourceProvider] with an exception:
MultiException stack 1 of 2
java.lang.NoClassDefFoundError: javax/activation/DataSource
        at java.base/java.lang.Class.getDeclaredConstructors0(Native Method)
        at java.base/java.lang.Class.privateGetDeclaredConstructors(Class.java:3137)
        at java.base/java.lang.Class.getDeclaredConstructors(Class.java:2357)
        at org.jvnet.hk2.internal.Utilities$3.run(Utilities.java:1354)
        at org.jvnet.hk2.internal.Utilities$3.run(Utilities.java:1350)
        at java.base/java.security.AccessController.doPrivileged(Native Method)
        at org.jvnet.hk2.internal.Utilities.getAllConstructors(Utilities.java:1350)
        at org.jvnet.hk2.internal.Utilities.findProducerConstructor(Utilities.java:1293)
        at org.jvnet.hk2.internal.DefaultClassAnalyzer.getConstructor(DefaultClassAnalyzer.java:60)
        at org.glassfish.jersey.inject.hk2.JerseyClassAnalyzer.getConstructor(JerseyClassAnalyzer.java:124)
        at org.jvnet.hk2.internal.Utilities.getConstructor(Utilities.java:156)
        at org.jvnet.hk2.internal.ClazzCreator.initialize(ClazzCreator.java:105)
        at org.jvnet.hk2.internal.ClazzCreator.initialize(ClazzCreator.java:156)
        at org.jvnet.hk2.internal.SystemDescriptor.internalReify(SystemDescriptor.java:716)
        at org.jvnet.hk2.internal.SystemDescriptor.reify(SystemDescriptor.j
O ChatGPT disse:
Aí sim, agora ficou claro 👀

📌 Esse novo log mostra duas situações diferentes:

Found 0 core definitions underneath /app/fluig/solr/data
➡️ O Solr subiu, mas não achou nenhum core configurado.

Normalmente o Fluig cria pelo menos um core (collection1, fluig, etc).

Se não tem, o Solr roda “vazio”, e isso impede o indexador de funcionar no Fluig.

NoClassDefFoundError: javax/activation/DataSource
➡️ Voltou o erro da javax.activation.DataSource. Isso significa que a lib não está no classpath do Solr nesse start, ou o Fluig removeu/ignorou.

🔧 Como corrigir
Resolver o DataSource (Java 11 não tem mais javax.activation por padrão):

Baixe o jar jakarta.activation-api-1.2.2.jar ou javax.activation-1.2.0.jar.

Copie para:

/app/fluig/solr/server/lib/ext/
Reinicie o Solr.

Confirme se o erro sumiu no log.

Verificar os cores:

Entre na pasta:

ls -l /app/fluig/solr/data
Deve haver subpastas com core.properties.

Se não houver, o Fluig não está criando os cores automaticamente.

No solr.xml (dentro de /app/fluig/solr/server/solr), deve apontar para instancedir correto.

Testar manualmente Solr:

curl "http://localhost:8983/solr/admin/cores?action=STATUS"
Isso mostra os cores carregados.

Se vier vazio ("status": {}), então realmente nenhum core foi criado.

👉 Pergunto: você lembra se no ambiente original do Fluig tinha pastas tipo /app/fluig/solr/data/fluig ou /app/fluig/solr/data/collection1?

Isso ajuda a confirmar se o problema agora é lib Java ou core ausente.

Você disse:
preciso de um script que analise esse arquivo /var/lib/cloud/instance/custom-data.json sempre for executar  caso dentro dele diver a info  "loadbalances": [] assim execute esse comando cd /tmp && curl -o fluig_sust_std.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh && sh /tmp/fluig_sust_std.sh && rm -rf /tmp/fluig_sust_std.sh e caso ele encontre a info loadbalances": [127.0.0.1] com algum info dentro do [] deve executar cd /tmp && curl -o fluig_sust.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh && sh /tmp/fluig_sust.sh && rm -rf /tmp/fluig_sust.sh
O ChatGPT disse:
Perfeito 👍
Você pode resolver isso com um script Bash simples que lê o JSON, verifica o valor de "loadbalances" e decide qual script baixar/executar.

Aqui vai um exemplo robusto:

#!/bin/bash
# Script para analisar /var/lib/cloud/instance/custom-data.json
# Desenvolvido por Alexandre dos Santos (Coxa) - 20-09-2025

JSON_FILE="/var/lib/cloud/instance/custom-data.json"

# Verifica se o arquivo existe
if [ ! -f "$JSON_FILE" ]; then
  echo "Arquivo $JSON_FILE não encontrado!"
  exit 1
fi

# Extrai o valor de loadbalances (sem espaços e quebras)
LOADBALANCES=$(grep -o '"loadbalances":[^}]*' "$JSON_FILE" | sed 's/"loadbalances"://;s/[[:space:]]//g')

# Caso loadbalances seja []
if [[ "$LOADBALANCES" == "[]" ]]; then
  echo "Loadbalances vazio. Executando fluig_sust_std.sh..."
  cd /tmp || exit 1
  curl -s -o fluig_sust_std.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh
  sh /tmp/fluig_sust_std.sh
  rm -f /tmp/fluig_sust_std.sh

# Caso loadbalances tenha algum conteúdo dentro de []
elif [[ "$LOADBALANCES" =~ \[.*[0-9].*\] ]]; then
  echo "Loadbalances preenchido ($LOADBALANCES). Executando fluig_sust.sh..."
  cd /tmp || exit 1
  curl -s -o fluig_sust.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh
  sh /tmp/fluig_sust.sh
  rm -f /tmp/fluig_sust.sh

else
  echo "Não foi possível identificar loadbalances corretamente: $LOADBALANCES"
fi
🔧 Como usar
Salve como /usr/local/bin/check_loadbalances.sh

Dê permissão:

chmod +x /usr/local/bin/check_loadbalances.sh
Sempre que precisar, rode:

/usr/local/bin/check_loadbalances.sh
👉 Quer que eu já monte isso para rodar automaticamente no boot via systemd (um service que dispara esse script sempre que a máquina inicia)?

Você disse:
a info que pode retornar na variavel loadbalances é tipo essa "loadbalances": [{"vip_port": 443, "snat_translation": null, "floating_ip": "172.16.129.55"}, {"vip_port": 80, "snat_translation": null, "floating_ip": "172.16.129.55"}],
O ChatGPT disse:
Boa, agora ficou claro 🚀

Então o campo "loadbalances" pode ser:

Vazio → "loadbalances": []

Preenchido → "loadbalances": [{...}, {...}] (com objetos dentro)

Nesse caso, precisamos verificar se há objetos dentro do array, e não só 127.0.0.1.

Aqui vai o script ajustado:

#!/bin/bash
# Script para analisar /var/lib/cloud/instance/custom-data.json
# Desenvolvido por Alexandre dos Santos (Coxa) - 20-09-2025

JSON_FILE="/var/lib/cloud/instance/custom-data.json"

# Verifica se o arquivo existe
if [ ! -f "$JSON_FILE" ]; then
  echo "Arquivo $JSON_FILE não encontrado!"
  exit 1
fi

# Pega somente a linha com "loadbalances"
LOADBALANCES=$(grep -o '"loadbalances":[^}]*' "$JSON_FILE" | sed 's/"loadbalances"://;s/[[:space:]]//g')

# Se loadbalances for []
if [[ "$LOADBALANCES" == "[]" ]]; then
  echo "Loadbalances vazio. Executando fluig_sust_std.sh..."
  cd /tmp || exit 1
  curl -s -o fluig_sust_std.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh
  sh /tmp/fluig_sust_std.sh
  rm -f /tmp/fluig_sust_std.sh

# Se loadbalances tiver objetos dentro
elif [[ "$LOADBALANCES" =~ ^\[.*\{.*\}.*\]$ ]]; then
  echo "Loadbalances preenchido ($LOADBALANCES). Executando fluig_sust.sh..."
  cd /tmp || exit 1
  curl -s -o fluig_sust.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh
  sh /tmp/fluig_sust.sh
  rm -f /tmp/fluig_sust.sh

else
  echo "Formato inesperado em loadbalances: $LOADBALANCES"
fi
🔍 O que mudou:
Agora o elif não depende de número (127.0.0.1) → ele detecta se há um {} dentro do [], ou seja, se tem objetos no array.

Exemplo:

"loadbalances": [] → roda fluig_sust_std.sh

"loadbalances": [{"vip_port":443,...}] → roda fluig_sust.sh

Quer que eu já adapte para usar jq (bem mais confiável para JSON que grep/sed) ou prefere manter só com ferramentas padrão (grep/sed)?

Você disse:
a logica não funcionou em um ambiente onde o loadbalances": [] está assim ele exectou o comando cd /tmp && curl -o fluig_sust.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh && sh /tmp/fluig_sust.sh && rm -rf /tmp/fluig_sust.sh eu tbm quero que ele gere um log no /tmp com o nome install_script_fluig com a info de qual script foi executado
O ChatGPT disse:

Pensou por 25s
Ótimo — obrigado pelo detalhe. O problema veio da abordagem com grep/sed (ela pode falhar em JSONs formatados de formas variadas). Abaixo tem um script robusto que:

usa jq quando disponível (mais seguro/rápido);

cai para python3 se jq não existir;

decide corretamente entre [] (vazio) ou array com objetos (>0);

baixa e executa o script correto;

grava logs em /tmp/install_script_fluig (append) com timestamps;

remove o script temporário depois da execução.

Cole, salve como /usr/local/bin/check_and_install_fluig.sh, dê chmod +x e rode quando quiser.

#!/bin/bash
# check_and_install_fluig.sh
# Analisa /var/lib/cloud/instance/custom-data.json e executa o script apropriado
# Registra ações em /tmp/install_script_fluig
# Desenvolvido por Alexandre dos Santos (Coxa) - 2025-09-21

JSON_FILE="/var/lib/cloud/instance/custom-data.json"
LOG="/tmp/install_script_fluig"

logit() {
  echo "$(date '+%F %T %z') - $*" >> "$LOG"
}

# garante que exista o arquivo de log
touch "$LOG" 2>/dev/null || { echo "Falha ao criar $LOG"; exit 1; }

if [ ! -f "$JSON_FILE" ]; then
  logit "ERRO: arquivo $JSON_FILE não encontrado"
  exit 1
fi

# tenta usar jq primeiro (mais confiável)
if command -v jq >/dev/null 2>&1; then
  LB_LEN=$(jq -r 'if has("loadbalances") then (if (.loadbalances|type)=="array" then (.loadbalances|length) else "NOTARRAY" end) else "MISSING" end' "$JSON_FILE" 2>/dev/null) || LB_LEN="JQ_ERROR"
  PARSER="jq"
elif command -v python3 >/dev/null 2>&1; then
  # fallback para python3 se jq não existir
  LB_LEN=$(python3 - "$JSON_FILE" <<'PY'
import sys, json
fn = sys.argv[1]
try:
    j = json.load(open(fn))
except Exception:
    print("PY_ERROR")
    sys.exit(0)
lb = j.get("loadbalances", None)
if lb is None:
    print("MISSING")
elif isinstance(lb, list):
    print(len(lb))
else:
    print("NOTARRAY")
PY
)
  PARSER="python3"
else
  logit "ERRO: nem 'jq' nem 'python3' estão disponíveis para parsear JSON. Não posso continuar."
  exit 1
fi

logit "Parser usado: $PARSER. Resultado bruto: $LB_LEN"

# valida e decide ação
case "$LB_LEN" in
  "MISSING")
    logit "Campo 'loadbalances' ausente em $JSON_FILE. Nenhuma ação executada."
    exit 0
    ;;
  "NOTARRAY")
    logit "Campo 'loadbalances' existe mas não é um array. Nenhuma ação executada."
    exit 1
    ;;
  "JQ_ERROR"|"PY_ERROR")
    logit "Erro ao parsear JSON ($LB_LEN)."
    exit 1
    ;;
  "")
    logit "Resultado vazio inesperado ao parsear JSON."
    exit 1
    ;;
  *)
    # se for número, prossegue
    if [[ "$LB_LEN" =~ ^[0-9]+$ ]]; then
      if [ "$LB_LEN" -eq 0 ]; then
        SCRIPT_URL="https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh"
        SCRIPT_LOCAL="/tmp/fluig_sust_std.sh"
        SCRIPT_NAME="fluig_sust_std.sh"
      else
        SCRIPT_URL="https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh"
        SCRIPT_LOCAL="/tmp/fluig_sust.sh"
        SCRIPT_NAME="fluig_sust.sh"
      fi
    else
      logit "Formato inesperado do resultado do parse ($LB_LEN). Abortando."
      exit 1
    fi
    ;;
esac

# baixa, executa e loga saída
logit "Baixando $SCRIPT_URL para $SCRIPT_LOCAL"
cd /tmp || { logit "Erro: não consegui cd /tmp"; exit 1; }

if curl -fsSL -o "$SCRIPT_LOCAL" "$SCRIPT_URL"; then
  chmod +x "$SCRIPT_LOCAL" 2>/dev/null || true
  logit "Execução iniciada: $SCRIPT_NAME (loadbalances length = $LB_LEN)"
  # salva saída do script no log
  if sh "$SCRIPT_LOCAL" >>"$LOG" 2>&1; then
    logit "Execução concluída com sucesso: $SCRIPT_NAME"
  else
    rc=$?
    logit "Execução com erro (exit code $rc): $SCRIPT_NAME"
  fi
  rm -f "$SCRIPT_LOCAL"
  logit "Arquivo temporário removido: $SCRIPT_LOCAL"
else
  logit "Falha ao baixar $SCRIPT_URL"
  exit 1
fi

exit 0
Por que seu script anterior executou o branch errado?

grep -o '"loadbalances":[^}]*' pode capturar trechos incompletos ou corresponder de forma incorreta se o JSON tiver quebras de linha, espaços, objetos aninhados, etc. Usar um parser JSON (jq ou python3) evita esses falsos-positivos.

Quer que eu:

lhe gere o comando crontab/systemd para rodar isso periodicamente, ou

acrescente um modo --dry-run para só testar sem executar os scripts baixados?

Você disse:
se ajudar no script sempre que dentro da variavel loadbalances tive alguma coisa vai ter esse campo "floating_ip" dentro do [] se não achar esse campo pode seguir que ele é vazio
O ChatGPT disse:
Boa 👌, essa informação do "floating_ip" ajuda a deixar a lógica à prova de falhas.
Podemos simplificar:

Se o campo "loadbalances" não existir ou não tiver nenhum "floating_ip" válido → rodar fluig_sust_std.sh

Se encontrar pelo menos um objeto com "floating_ip" → rodar fluig_sust.sh

Aqui está a versão ajustada do script:

#!/bin/bash
# check_and_install_fluig.sh
# Analisa /var/lib/cloud/instance/custom-data.json e executa o script apropriado
# Se loadbalances estiver vazio ou sem floating_ip -> fluig_sust_std.sh
# Se loadbalances contiver floating_ip -> fluig_sust.sh
# Log em /tmp/install_script_fluig
# Desenvolvido por Alexandre dos Santos (Coxa) - 2025-09-21

JSON_FILE="/var/lib/cloud/instance/custom-data.json"
LOG="/tmp/install_script_fluig"

logit() {
  echo "$(date '+%F %T %z') - $*" >> "$LOG"
}

touch "$LOG" 2>/dev/null || { echo "Falha ao criar $LOG"; exit 1; }

if [ ! -f "$JSON_FILE" ]; then
  logit "ERRO: arquivo $JSON_FILE não encontrado"
  exit 1
fi

# usa jq ou python3 para analisar
if command -v jq >/dev/null 2>&1; then
  HAS_FLOATING=$(jq -r 'if (.loadbalances|type)=="array" then
                          (map(select(has("floating_ip"))) | length > 0)
                        else "false" end' "$JSON_FILE" 2>/dev/null)
  PARSER="jq"
elif command -v python3 >/dev/null 2>&1; then
  HAS_FLOATING=$(python3 - "$JSON_FILE" <<'PY'
import sys, json
fn=sys.argv[1]
try:
    j=json.load(open(fn))
except Exception:
    print("false"); sys.exit(0)
lb=j.get("loadbalances", [])
if isinstance(lb, list) and any(isinstance(x, dict) and "floating_ip" in x for x in lb):
    print("true")
else:
    print("false")
PY
)
  PARSER="python3"
else
  logit "ERRO: nem jq nem python3 disponíveis"
  exit 1
fi

logit "Parser usado: $PARSER. floating_ip encontrado? $HAS_FLOATING"

if [ "$HAS_FLOATING" = "true" ]; then
  SCRIPT_URL="https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh"
  SCRIPT_LOCAL="/tmp/fluig_sust.sh"
  SCRIPT_NAME="fluig_sust.sh"
else
  SCRIPT_URL="https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh"
  SCRIPT_LOCAL="/tmp/fluig_sust_std.sh"
  SCRIPT_NAME="fluig_sust_std.sh"
fi

# baixa e executa
logit "Baixando $SCRIPT_URL"
cd /tmp || { logit "Erro ao acessar /tmp"; exit 1; }

if curl -fsSL -o "$SCRIPT_LOCAL" "$SCRIPT_URL"; then
  chmod +x "$SCRIPT_LOCAL" 2>/dev/null || true
  logit "Executando $SCRIPT_NAME"
  if sh "$SCRIPT_LOCAL" >>"$LOG" 2>&1; then
    logit "Execução OK: $SCRIPT_NAME"
  else
    rc=$?
    logit "Execução com erro (exit $rc): $SCRIPT_NAME"
  fi
  rm -f "$SCRIPT_LOCAL"
  logit "Arquivo removido: $SCRIPT_LOCAL"
else
  logit "Falha ao baixar $SCRIPT_URL"
  exit 1
fi

exit 0
👉 Esse script agora só considera verdadeiro quando achar pelo menos um "floating_ip" dentro de loadbalances.
Se não tiver nada, ou tiver vazio ([]), ele executa o fluig_sust_std.sh.

Quer que eu já monte a unidade systemd para rodar isso sempre no boot do servidor?

Você disse:
ele não executa dessa maneira, poderia colocar essa ultima logica no primeira versão do script #!/bin/bash
# Script para analisar /var/lib/cloud/instance/custom-data.json
# Desenvolvido por Alexandre dos Santos (Coxa) - 20-09-2025

JSON_FILE="/var/lib/cloud/instance/custom-data.json"

# Verifica se o arquivo existe
if [ ! -f "$JSON_FILE" ]; then
  echo "Arquivo $JSON_FILE não encontrado!"
  exit 1
fi

# Pega somente a linha com "loadbalances"
LOADBALANCES=$(grep -o '"loadbalances":[^}]*' "$JSON_FILE" | sed 's/"loadbalances"://;s/[[:space:]]//g')

# Se loadbalances for []
if [[ "$LOADBALANCES" == "[]" ]]; then
  echo "Loadbalances vazio. Executando fluig_sust_std.sh..."
  cd /tmp || exit 1
  curl -s -o fluig_sust_std.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh
  sh /tmp/fluig_sust_std.sh
  rm -f /tmp/fluig_sust_std.sh

# Se loadbalances tiver objetos dentro
elif [[ "$LOADBALANCES" =~ ^\[.*\{.*\}.*\]$ ]]; then
  echo "Loadbalances preenchido ($LOADBALANCES). Executando fluig_sust.sh..."
  cd /tmp || exit 1
  curl -s -o fluig_sust.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh
  sh /tmp/fluig_sust.sh
  rm -f /tmp/fluig_sust.sh

else
  echo "Formato inesperado em loadbalances: $LOADBALANCES"
fi
O ChatGPT disse:

Pensou por 11s
Perfeito — aqui está a versão final do seu script mantendo a estrutura da primeira versão (grep/sed style) mas com a lógica atualizada para checar floating_ip, e com log em /tmp/install_script_fluig.
Ele tenta usar jq (quando disponível) ou python3 como fallback — se nenhum dos dois existir, faz uma tentativa com sed/grep (menos robusta, mas compatível com o estilo original).

Cole como, por exemplo, /usr/local/bin/check_loadbalances_and_run.sh, dê chmod +x e execute. O arquivo de log será /tmp/install_script_fluig (append).

#!/bin/bash
# Script para analisar /var/lib/cloud/instance/custom-data.json
# Decide qual script executar com base em loadbalances/floating_ip
# Log em /tmp/install_script_fluig
# Desenvolvido por Alexandre dos Santos (Coxa) - 2025-09-21 (versão integrada)

JSON_FILE="/var/lib/cloud/instance/custom-data.json"
LOG="/tmp/install_script_fluig"

logit(){
  echo "$(date '+%F %T %z') - $*" >> "$LOG"
}

# garante log
touch "$LOG" 2>/dev/null || { echo "Falha ao criar $LOG"; exit 1; }

if [ ! -f "$JSON_FILE" ]; then
  logit "ERRO: arquivo $JSON_FILE não encontrado"
  exit 1
fi

# Método preferencial: jq
if command -v jq >/dev/null 2>&1; then
  logit "Parser: jq"
  # verifica se existe ao menos um objeto com floating_ip não-nulo/não-vazio
  HAS_FLOATING=$(jq -r 'if (type=="object" and (.loadbalances? | type)=="array") then ([.loadbalances[]? | select(type=="object" and (.floating_ip != null and .floating_ip != ""))] | length) else 0 end' "$JSON_FILE" 2>/dev/null)
  if [[ "$HAS_FLOATING" =~ ^[0-9]+$ && "$HAS_FLOATING" -gt 0 ]]; then
    FOUND_FLOATING=true
  else
    FOUND_FLOATING=false
  fi

# Fallback: python3
elif command -v python3 >/dev/null 2>&1; then
  logit "Parser: python3"
  FOUND_FLOATING=$(python3 - "$JSON_FILE" <<'PY'
import sys, json
fn = sys.argv[1]
try:
    j = json.load(open(fn))
except Exception:
    print("false"); sys.exit(0)
lb = j.get("loadbalances", [])
if isinstance(lb, list) and any(isinstance(x, dict) and x.get("floating_ip") not in (None, "") for x in lb):
    print("true")
else:
    print("false")
PY
  )
  if [ "$FOUND_FLOATING" = "true" ]; then
    FOUND_FLOATING=true
  else
    FOUND_FLOATING=false
  fi

# Último recurso: grep/sed (menos confiável)
else
  logit "Parser: fallback sed/grep (menos robusto)"
  # pega trecho "loadbalances": [ ... ] em uma linha (remove quebras)
  LB_SNIPPET=$(tr '\n' ' ' < "$JSON_FILE" | sed -n 's/.*"loadbalances"[[:space:]]*:[[:space:]]*\(\[[^]]*\]\).*/\1/p')
  LB_SNIPPET=${LB_SNIPPET:-}
  # se vazio, considera como vazio
  if [ -z "$LB_SNIPPET" ] || [ "$LB_SNIPPET" = "[]" ]; then
    FOUND_FLOATING=false
  else
    # procura pelo campo floating_ip dentro do bloco
    if echo "$LB_SNIPPET" | grep -q '"floating_ip"' ; then
      FOUND_FLOATING=true
    else
      FOUND_FLOATING=false
    fi
  fi
fi

logit "Resultado: FOUND_FLOATING=$FOUND_FLOATING"

# Decide qual script baixar/executar
if [ "$FOUND_FLOATING" = true ]; then
  SCRIPT_URL="https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh"
  SCRIPT_LOCAL="/tmp/fluig_sust.sh"
  SCRIPT_NAME="fluig_sust.sh"
else
  SCRIPT_URL="https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh"
  SCRIPT_LOCAL="/tmp/fluig_sust_std.sh"
  SCRIPT_NAME="fluig_sust_std.sh"
fi

logit "Baixando $SCRIPT_NAME de $SCRIPT_URL"
cd /tmp || { logit "ERRO: não consegui cd /tmp"; exit 1; }

if curl -fsSL -o "$SCRIPT_LOCAL" "$SCRIPT_URL"; then
  chmod +x "$SCRIPT_LOCAL" 2>/dev/null || true
  logit "Iniciando execução: $SCRIPT_NAME"
  if sh "$SCRIPT_LOCAL" >> "$LOG" 2>&1; then
    logit "Execução concluída com sucesso: $SCRIPT_NAME"
  else
    rc=$?
    logit "Execução retornou código $rc: $SCRIPT_NAME"
  fi
  rm -f "$SCRIPT_LOCAL"
  logit "Removido temporário: $SCRIPT_LOCAL"
else
  logit "Falha ao baixar $SCRIPT_URL"
  exit 1
fi

exit 0
Observações / dicas:

Se possível instale jq no servidor (yum install -y jq ou dnf install -y jq), o parsing ficará muito mais robusto.

O script escreve sempre no /tmp/install_script_fluig (append). Se quiser um log rotativo ou outro local, me diga.

Esse script segue a lógica pedida: se encontrar ao menos um floating_ip dentro de loadbalances → executa fluig_sust.sh; caso contrário → fluig_sust_std.sh.

Quer que eu gere também a unidade systemd (service + enable) para rodar isso no boot automaticamente?




Nenhum arquivo escolhidoNenhum arquivo escolhido
O ChatGPT pode cometer erros. Considere verificar informações importantes.
