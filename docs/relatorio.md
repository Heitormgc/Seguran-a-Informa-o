# Relatório técnico — Firewall Linux em escritório de contabilidade

## 1. Definição do case
Estudo de caso hipotético de escritório contábil com estação interna, portal web e banco de dados, usando somente dados fictícios.

## 2. Diagnóstico e solução
Riscos: acesso direto ao banco, comunicação sem segmentação e regras não documentadas. Solução: duas redes bridge Docker, firewall Linux com NET_ADMIN, ip_forward e iptables FORWARD DROP, liberando HTTP do cliente ao Nginx.

## 3. Matriz de regras
| Origem | Destino | Porta | Ação | Justificativa |
|---|---|---|---|---|
| Cliente LAN | Nginx DMZ | TCP 80 | ACCEPT | Acesso ao portal |
| Cliente LAN | MySQL DMZ | TCP 3306 | DROP padrão | Restringir acesso direto |
| Conexões estabelecidas | Fluxos autorizados | Conforme conexão | ACCEPT | Respostas |
| Outros fluxos encaminhados | DMZ | Demais | DROP padrão | Menor privilégio |

## 4. Testes e validação
Iniciar com `docker compose up -d --build`; executar `curl -i --max-time 5 http://172.28.20.10` no container cliente, tentar `nc -zvw 3 172.28.20.20 3306` e verificar contadores de `iptables -L FORWARD -n -v` no firewall. Anexar evidências reais após testar. O teste negativo isolado não comprova o motivo do bloqueio sem inspeção de tráfego.

## 5. Limitações
Nginx é estático; MySQL não é consumido pela aplicação. Nginx e MySQL estão na mesma bridge DMZ, portanto sua comunicação não passa pelo firewall. O laboratório não representa uma implantação em produção.
