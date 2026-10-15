# Firewall Linux para escritório de contabilidade

Projeto acadêmico Docker Compose com cliente, firewall iptables, Nginx e MySQL. Use somente dados fictícios.

## Iniciar no PowerShell

Abra a pasta do projeto no VS Code. Se ainda não existir `.env`, execute:

```powershell
Copy-Item .env.example .env
```

Edite as senhas em `.env`. Se já tiver `.env` com senhas configuradas, mantenha esse arquivo.

```powershell
docker compose down
docker compose up -d --build
docker compose ps
```

## Testes

```powershell
docker compose exec cliente ip route
docker compose exec web ip route
docker compose exec firewall sysctl net.ipv4.ip_forward
docker compose exec firewall iptables -L FORWARD -n -v
docker compose exec cliente curl -i --max-time 5 http://172.28.20.10
docker compose exec cliente sh -c 'nc -zvw 3 172.28.20.20 3306'
docker compose exec firewall iptables -L FORWARD -n -v
```

HTTP deve responder `200 OK`. O acesso do cliente ao banco não é autorizado. Confira os contadores da cadeia FORWARD para avaliar o bloqueio; uma conexão malsucedida isoladamente não prova que o firewall foi responsável, pois o MySQL não tem rota específica de retorno à LAN nesta versão.

## Observações

- Cliente e web têm rotas para enviar o tráfego entre LAN e DMZ via firewall.
- A cadeia FORWARD tem política DROP e libera somente HTTP cliente→web e respostas estabelecidas.
- Nginx e MySQL compartilham a DMZ: o tráfego entre eles não atravessa o firewall.
- O Nginx exibe página estática, sem integração ao banco.
- `docker compose down` preserva o volume MySQL; **não use `down -v`** se quiser preservar dados.
- `.env` está no `.gitignore` e não deve ser enviado ao GitHub.
