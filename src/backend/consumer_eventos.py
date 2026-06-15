import json
import os
from datetime import datetime
from pathlib import Path

import pika

try:
    from backend.messaging import EXCHANGE_NAME, QUEUE_NAME, RABBITMQ_URL, ensure_topology
except ModuleNotFoundError:
    from messaging import EXCHANGE_NAME, QUEUE_NAME, RABBITMQ_URL, ensure_topology


CONSUMER_NAME = os.environ.get("QUICKFREELA_CONSUMER", "quickfreela-audit-consumer")
LOG_DIR = Path(os.environ.get("QUICKFREELA_LOG_DIR", "logs"))
LOG_FILE = LOG_DIR / "eventos_consumidos.log"


def log(message: str) -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    line = f"{datetime.now().isoformat(timespec='seconds')} {message}"
    print(line, flush=True)
    with LOG_FILE.open("a", encoding="utf-8") as file:
        file.write(line + "\n")


def process_event(event: dict) -> None:
    event_type = event.get("event_type", "evento.desconhecido")
    event_id = event.get("event_id", "sem-id")
    payload = event.get("payload", {})
    solicitacao_id = payload.get("id") or payload.get("solicitacao", {}).get("id")
    status = payload.get("status") or payload.get("solicitacao", {}).get("status")

    details = {
        "consumer": CONSUMER_NAME,
        "event_id": event_id,
        "event_type": event_type,
        "solicitacao_id": solicitacao_id,
        "status": status,
    }
    log("EVENTO_PROCESSADO " + json.dumps(details, ensure_ascii=True))


def on_message(channel, method, properties, body: bytes) -> None:
    try:
        event = json.loads(body.decode("utf-8"))
        process_event(event)
        channel.basic_ack(delivery_tag=method.delivery_tag)
    except Exception as exc:
        log(f"EVENTO_ERRO delivery_tag={method.delivery_tag} erro={exc}")
        channel.basic_nack(delivery_tag=method.delivery_tag, requeue=False)


def main() -> None:
    params = pika.URLParameters(RABBITMQ_URL)
    connection = pika.BlockingConnection(params)
    channel = connection.channel()
    ensure_topology(channel)
    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue=QUEUE_NAME, on_message_callback=on_message)

    log(
        f"CONSUMER_INICIADO consumer={CONSUMER_NAME} "
        f"exchange={EXCHANGE_NAME} queue={QUEUE_NAME}"
    )
    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        log("CONSUMER_FINALIZADO")
        channel.stop_consuming()
    finally:
        connection.close()


if __name__ == "__main__":
    main()
