# Firewall Linux para Escritório de Contabilidade

Projeto acadêmico de infraestrutura segmentada e segura, simulado com Docker Compose, redes Docker bridge, firewall Linux (`iptables`), Nginx e MySQL 8.4.

> **Aviso:** laboratório demonstrativo com dados fictícios. Não representa uma infraestrutura pronta para produção e não deve armazenar informações reais de clientes.

## 1. Cenário de aplicação

Um escritório de contabilidade processa documentos fiscais, informações trabalhistas, registros de funcionários e dados financeiros. Uma rede sem segmentação adequada pode permitir que uma estação de trabalho comprometida alcance diretamente serviços sensíveis. Este projeto demonstra a separação entre a rede de clientes (LAN) e uma zona de serviços (DMZ), com regras de acesso controladas.

## 2. Objetivos

- Segmentar o tráfego entre LAN e DMZ.
- Autorizar HTTP do cliente ao portal Nginx.
- Negar conexões diretas do cliente ao MySQL na porta TCP 3306.
- Registrar evidências com rotas, respostas HTTP e contadores `iptables`.
- Reproduzir o laboratório com Docker Compose.

## 3. Arquitetura

```text
LAN 172.28.10.0/24                      DMZ 172.28.20.0/24
+----------------------+             +------------------------+
| Cliente              |             | Nginx (portal web)     |
| 172.28.10.10         |----+   +--->| 172.28.20.10 :80       |
+----------------------+    |   |    +------------------------+
                            v   |
                    +--------------------+
                    | Firewall Linux     |
                    | LAN 172.28.10.2    |
                    | DMZ 172.28.20.2    |
                    | iptables FORWARD   |
                    +--------------------+
                            |   |
                            |   +--X---> MySQL :3306 (cliente bloqueado)
                            |            172.28.20.20
                            +------ DMZ
```

**Limitação:** Nginx e MySQL compartilham a mesma rede DMZ; o tráfego direto entre eles não é filtrado por este firewall. Para isolamento de produção, separar o banco em uma rede de dados e implementar controles adicionais.

## 4. Matriz de tráfego

| Origem | Destino | Porta | Política |
|---|---|---|---|
| LAN (`172.28.10.0/24`) | Nginx (`172.28.20.10`) | TCP 80 | Permitir (`NEW`) |
| Respostas de conexões estabelecidas | Origem da conexão | Associada | Permitir (`ESTABLISHED,RELATED`) |
| LAN | MySQL (`172.28.20.20`) | TCP 3306 | Negar (política `DROP`) |
| Demais fluxos roteados | DMZ | Outras | Negar (política `DROP`) |

## 5. Estrutura dos arquivos

```text
firewall-contabilidade/
├── docker-compose.yml
├── .env                 # local, não versionar
├── cliente/
│   ├── Dockerfile
│   └── entrypoint.sh
├── firewall/
│   ├── Dockerfile
│   └── entrypoint.sh
├── web/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── index.html
└── db/
    ├── Dockerfile
    └── entrypoint-custom.sh
```

O projeto local usa imagem customizada do MySQL para instalar `iproute`, adicionar `/usr/sbin` ao `PATH` e configurar rota para `172.28.10.0/24` via `172.28.20.2`. A rota do cliente para a DMZ passa por `172.28.10.2`, e a rota de retorno do Nginx para a LAN passa por `172.28.20.2`.

## 6. Execução

Requisitos: Docker Desktop com Compose e terminal PowerShell. Abra o terminal na pasta que contém `docker-compose.yml`. Configure as senhas de teste no `.env` antes da primeira inicialização.

```powershell
docker compose config -q
docker compose up -d --build
docker compose ps
```

Não execute `docker compose down -v` se quiser preservar o volume do MySQL.

## 7. Testes e evidências

**Verificar rota do banco:**

```powershell
docker run --rm --network container:contab-db nicolaka/netshoot ip route
```

Linha observada nos testes: `172.28.10.0/24 via 172.28.20.2 dev eth0`.

**Testar portal:**

```powershell
docker compose exec cliente curl -i --max-time 5 http://172.28.20.10
```

O cliente recebeu o HTML do portal Nginx, demonstrando comunicação HTTP.

**Testar acesso direto ao MySQL e conferir o firewall:**

```powershell
docker compose exec firewall iptables -Z FORWARD
docker compose exec cliente sh -c 'nc -zvw 3 172.28.20.20 3306'
docker compose exec firewall iptables -L FORWARD -n -v
```

Resultado observado: `Operation timed out` na porta 3306; em seguida, `Chain FORWARD (policy DROP 3 packets, 180 bytes)`. Como os contadores foram zerados antes do teste, o resultado é consistente com descarte pelo firewall. Para atribuição inequívoca à porta 3306, é recomendado acrescentar uma regra de contador específica ou capturar os pacotes.

## 8. Segurança e limitações

- Não publicar senhas ou o `.env` no GitHub; usar `.gitignore`.
- Não inserir dados reais de clientes no laboratório.
- A página Nginx é estática e não possui integração com o MySQL.
- O acesso HTTP não é criptografado; em produção, usar HTTPS.
- A DMZ e o banco não estão isolados entre si; a arquitetura é demonstrativa.
- O Docker Desktop e as regras do host podem afetar o roteamento; repetir testes em cada ambiente.
- O firewall demonstrado filtra tráfego encaminhado pelo container; não substitui todos os controles do host e da rede corporativa.

## 9. Próximos aprimoramentos

Separar o banco em uma terceira rede, usar autenticação e TLS, registrar logs, implantar backups e aplicar o princípio do menor privilégio para a aplicação.

## 10. Encerramento

A simulação demonstra segmentação de rede e aplicação de regras para reduzir a exposição de serviços sensíveis de um escritório contábil. Os testes documentados evidenciam acesso autorizado ao portal e ausência de acesso direto ao MySQL pela estação cliente.
