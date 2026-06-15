# QuickFreela API

Backend inicial em Flask + SQLite para o projeto QuickFreela.

## Como executar

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
docker compose -f compose.yml up -d
python src/backend/app.py
```

Servidor local:

- Desktop/web: `http://localhost:5000`
- Emulador Android: `http://10.0.2.2:5000`
- Celular fisico: `http://IP_DA_MAQUINA:5000`

O arquivo SQLite `quickfreela.db` e criado automaticamente na primeira execucao.

## Dados iniciais

O banco ja sobe com estes usuarios para facilitar testes:

| Perfil | Email | Senha |
| --- | --- | --- |
| cliente | `ana.cliente@quickfreela.local` | `123456` |
| prestador | `bruno.dev@quickfreela.local` | `123456` |
| prestador | `carla.design@quickfreela.local` | `123456` |

## Endpoints principais

| Metodo | Rota | Descricao |
| --- | --- | --- |
| GET | `/health` | Verifica status da API |
| GET | `/health/mom` | Verifica conectividade com RabbitMQ |
| POST | `/auth/register` | Cadastra usuario |
| POST | `/auth/login` | Login simples e retorno de token demonstrativo |
| GET | `/usuarios` | Lista usuarios |
| POST | `/usuarios` | Cria usuario |
| GET | `/usuarios/<id>` | Busca usuario |
| PUT | `/usuarios/<id>` | Atualiza usuario |
| DELETE | `/usuarios/<id>` | Remove usuario |
| GET | `/solicitacoes` | Lista solicitacoes |
| POST | `/solicitacoes` | Cria solicitacao |
| GET | `/solicitacoes/<id>` | Busca solicitacao |
| PUT | `/solicitacoes/<id>` | Atualiza solicitacao |
| PATCH | `/solicitacoes/<id>/status` | Atualiza status da solicitacao |
| DELETE | `/solicitacoes/<id>` | Remove solicitacao |
| GET | `/propostas` | Lista propostas |
| POST | `/propostas` | Cria proposta |
| GET | `/propostas/<id>` | Busca proposta |
| PUT | `/propostas/<id>` | Atualiza proposta |
| DELETE | `/propostas/<id>` | Remove proposta |
| POST | `/solicitacoes/<id>/propostas/<proposta_id>/aceitar` | Aceita uma proposta |

## Filtros uteis

```text
GET /usuarios?perfil=cliente
GET /solicitacoes?status=aberta
GET /solicitacoes?cliente_id=1
GET /solicitacoes?prestador_id=2
GET /solicitacoes?categoria=programacao
GET /propostas?solicitacao_id=1
GET /propostas?prestador_id=2
GET /propostas?status=pendente
```

## Exemplos de payload

Criar usuario:

```json
{
  "nome": "Novo Cliente",
  "email": "novo.cliente@email.com",
  "senha": "123456",
  "perfil": "cliente"
}
```

Criar solicitacao:

```json
{
  "cliente_id": 1,
  "titulo": "Ajustar tela Flutter",
  "descricao": "Corrigir overflow em uma tela de perfil.",
  "categoria": "programacao",
  "orcamento": 150.0,
  "prazo_entrega": "2026-05-30"
}
```

Criar proposta:

```json
{
  "solicitacao_id": 1,
  "prestador_id": 2,
  "valor": 140.0,
  "prazo_dias": 2,
  "mensagem": "Consigo corrigir e entregar com um resumo das alteracoes."
}
```

Atualizar status:

```json
{
  "status": "concluida"
}
```

## Sprint 2: MOM com RabbitMQ

O projeto agora usa RabbitMQ como MOM para comunicacao assincrona orientada a eventos.
O Redis tambem sobe pelo `docker-compose.yml`, ficando disponivel para proximas sprints.

Subir os servicos:

```powershell
docker compose up -d
```

Verificar RabbitMQ:

```powershell
Invoke-RestMethod http://localhost:5000/health/mom
```

Iniciar consumidor de eventos:

```powershell
python consumer_eventos.py
```

Eventos principais publicados pelo backend:

- `solicitacao.criada`: apos `POST /solicitacoes`
- `solicitacao.status_atualizado`: apos `PATCH /solicitacoes/<id>/status`
- `proposta.criada`: apos `POST /propostas`
- `proposta.aceita`: apos aceitar uma proposta

Documentacao da sprint:

- `docs/eventos-mom.md`
- `docs/evidencia-mom.md`
- `docs/relatorio-integracao-mom.md`

## Sprint 3: App Flutter do Cliente

O app movel do cliente esta em `src/frontend`.

Entregas implementadas:

- Listagem das solicitacoes do cliente.
- Tela de detalhes com status, dados da demanda e propostas.
- Tela de criacao de solicitacao integrada ao backend.
- Tela de estados para demonstrar mudanca automatica de status.
- Integracao REST com `/solicitacoes` e `/propostas`.
- Atualizacao assincrona equivalente por polling a cada 6 segundos.
- Arquitetura documentada em `docs/arquitetura-flutter-sprint3.md`.

Executar backend:

```powershell
python src/backend/app.py
```

Executar Flutter no Windows:

```powershell
cd src/frontend
flutter pub get
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5000
```

Executar Flutter no emulador Android:

```powershell
cd src/frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

Demonstrar atualizacao automatica:

```powershell
Invoke-RestMethod `
  -Method PATCH `
  -Uri "http://localhost:5000/solicitacoes/1/status" `
  -ContentType "application/json" `
  -Body '{"status":"em_andamento"}'
```

O app atualiza a listagem sozinho em ate 6 segundos.

Gerar APK:

```powershell
cd src/frontend
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:5000
```
