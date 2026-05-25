# Documentacao dos Eventos - Sprint 2

MOM utilizado: RabbitMQ com exchange do tipo `topic`.

| Evento | Momento de publicacao | Produtor | Consumidor | Exchange / fila / routing key | Payload JSON de exemplo |
| --- | --- | --- | --- | --- | --- |
| `solicitacao.criada` | Apos `POST /solicitacoes` criar uma nova demanda | `quickfreela-api` | `quickfreela-audit-consumer` | Exchange `quickfreela.events`; fila `quickfreela.events.audit`; routing key `solicitacao.criada` | `{"id":3,"cliente_id":1,"titulo":"Corrigir endpoint Flask","descricao":"Ajustar validacao e retorno JSON.","categoria":"programacao","orcamento":200.0,"prazo_entrega":"2026-05-30","status":"aberta","prestador_id":null,"proposta_aceita_id":null,"cliente_nome":"Ana Cliente","prestador_nome":null}` |
| `solicitacao.status_atualizado` | Apos `PATCH /solicitacoes/<id>/status` alterar o andamento do servico | `quickfreela-api` | `quickfreela-audit-consumer` | Exchange `quickfreela.events`; fila `quickfreela.events.audit`; routing key `solicitacao.status_atualizado` | `{"id":3,"cliente_id":1,"titulo":"Corrigir endpoint Flask","descricao":"Ajustar validacao e retorno JSON.","categoria":"programacao","orcamento":200.0,"prazo_entrega":"2026-05-30","status":"concluida","prestador_id":2,"proposta_aceita_id":2,"cliente_nome":"Ana Cliente","prestador_nome":"Bruno Prestador"}` |
| `proposta.criada` | Apos `POST /propostas` registrar uma proposta de prestador | `quickfreela-api` | `quickfreela-audit-consumer` | Exchange `quickfreela.events`; fila `quickfreela.events.audit`; routing key `proposta.criada` | `{"id":2,"solicitacao_id":3,"prestador_id":2,"valor":180.0,"prazo_dias":2,"mensagem":"Consigo corrigir e testar.","status":"pendente","prestador_nome":"Bruno Prestador","solicitacao_titulo":"Corrigir endpoint Flask"}` |
| `proposta.aceita` | Apos `POST /solicitacoes/<id>/propostas/<proposta_id>/aceitar` aceitar a proposta | `quickfreela-api` | `quickfreela-audit-consumer` | Exchange `quickfreela.events`; fila `quickfreela.events.audit`; routing key `proposta.aceita` | `{"solicitacao":{"id":3,"status":"em_andamento","prestador_id":2,"proposta_aceita_id":2},"proposta":{"id":2,"status":"aceita","prestador_id":2,"valor":180.0}}` |

## Envelope publicado no RabbitMQ

Todos os eventos sao publicados com o mesmo envelope:

```json
{
  "event_id": "uuid-gerado-pelo-backend",
  "event_type": "solicitacao.criada",
  "occurred_at": "2026-05-25T18:00:00.000000+00:00",
  "producer": "quickfreela-api",
  "routing_key": "solicitacao.criada",
  "payload": {
    "id": 3,
    "cliente_id": 1,
    "titulo": "Corrigir endpoint Flask",
    "status": "aberta"
  }
}
```

## Consumidor

O consumidor `consumer_eventos.py` assina a fila `quickfreela.events.audit`, processa as mensagens recebidas e grava evidencias em:

```text
logs/eventos_consumidos.log
```

O backend nao chama esse consumidor por REST. A comunicacao ocorre por mensagem publicada no RabbitMQ e entregue de forma assincrona para a fila.
