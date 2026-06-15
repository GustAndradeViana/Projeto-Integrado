# QuickFreela Cliente

Aplicativo Flutter do usuario cliente para a Sprint 3 do QuickFreela.

## Telas entregues

- `Pedidos`: listagem das solicitacoes do cliente, indicadores por status e sincronizacao automatica.
- `Detalhes`: dados completos da solicitacao, propostas recebidas e acao de status.
- `Nova solicitacao`: formulario integrado ao endpoint `POST /solicitacoes`.
- `Estados`: visao por status para demonstrar atualizacao assincrona via polling.

## Como executar

Com o backend Flask ligado:

```powershell
cd src\backend
python app.py
```

Em outro terminal:

```powershell
cd src\frontend
flutter pub get
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5000
```

No emulador Android, use:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

Em celular fisico, troque a URL pelo IP da maquina:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.X:5000
```

## Atualizacao assincrona

O app usa polling a cada 6 segundos no endpoint:

```text
GET /solicitacoes?cliente_id=1
```

Assim, quando o status muda no servidor, a interface reflete a mudanca sem o cliente tocar em atualizar.

Para demonstrar:

```powershell
Invoke-RestMethod `
  -Method PATCH `
  -Uri "http://localhost:5000/solicitacoes/1/status" `
  -ContentType "application/json" `
  -Body '{"status":"em_andamento"}'
```

Depois de alguns segundos, o app deve mover a solicitacao para `Em andamento`.

## Gerar APK

```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

APK gerado em:

```text
build\app\outputs\flutter-apk\app-release.apk
```
