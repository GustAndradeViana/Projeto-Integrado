import json
import os
import uuid
from datetime import datetime, timezone
from typing import Any

try:
    import pika
    from pika.exceptions import AMQPError
except ImportError:
    pika = None
    AMQPError = Exception


RABBITMQ_URL = os.environ.get("RABBITMQ_URL", "amqp://guest:guest@localhost:5672/")
EVENTS_ENABLED = os.environ.get("QUICKFREELA_EVENTS_ENABLED", "true").lower() == "true"
EXCHANGE_NAME = os.environ.get("QUICKFREELA_EXCHANGE", "quickfreela.events")
QUEUE_NAME = os.environ.get("QUICKFREELA_QUEUE", "quickfreela.events.audit")
PRODUCER_NAME = os.environ.get("QUICKFREELA_PRODUCER", "quickfreela-api")


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def build_event(event_type: str, payload: dict[str, Any]) -> dict[str, Any]:
    return {
        "event_id": str(uuid.uuid4()),
        "event_type": event_type,
        "occurred_at": now_iso(),
        "producer": PRODUCER_NAME,
        "routing_key": event_type,
        "payload": payload,
    }


def _require_pika() -> None:
    if pika is None:
        raise RuntimeError("Dependencia 'pika' nao instalada. Execute: pip install -r requirements.txt")


def _connection():
    _require_pika()
    params = pika.URLParameters(RABBITMQ_URL)
    return pika.BlockingConnection(params)


def ensure_topology(channel) -> None:
    channel.exchange_declare(exchange=EXCHANGE_NAME, exchange_type="topic", durable=True)
    channel.queue_declare(queue=QUEUE_NAME, durable=True)
    channel.queue_bind(exchange=EXCHANGE_NAME, queue=QUEUE_NAME, routing_key="#")


def publish_event(event_type: str, payload: dict[str, Any]) -> bool:
    if not EVENTS_ENABLED:
        print(f"  -> MOM desabilitado: {event_type}", flush=True)
        return False

    event = build_event(event_type, payload)
    body = json.dumps(event, ensure_ascii=True, default=str).encode("utf-8")

    conn = None
    try:
        conn = _connection()
        channel = conn.channel()
        ensure_topology(channel)
        channel.basic_publish(
            exchange=EXCHANGE_NAME,
            routing_key=event_type,
            body=body,
            properties=pika.BasicProperties(
                content_type="application/json",
                delivery_mode=2,
                app_id=PRODUCER_NAME,
                message_id=event["event_id"],
                timestamp=int(datetime.now(timezone.utc).timestamp()),
            ),
        )
        print(
            f"  -> MOM publicado: exchange={EXCHANGE_NAME} routing_key={event_type} "
            f"event_id={event['event_id']}",
            flush=True,
        )
        return True
    except (AMQPError, OSError, RuntimeError) as exc:
        print(f"  -> MOM indisponivel: {event_type} nao publicado ({exc})", flush=True)
        return False
    finally:
        if conn is not None and not conn.is_closed:
            conn.close()


def check_broker() -> dict[str, Any]:
    if not EVENTS_ENABLED:
        return {
            "status": "disabled",
            "exchange": EXCHANGE_NAME,
            "queue": QUEUE_NAME,
        }

    conn = None
    try:
        conn = _connection()
        channel = conn.channel()
        ensure_topology(channel)
        return {
            "status": "ok",
            "broker": "rabbitmq",
            "url": _safe_url(RABBITMQ_URL),
            "exchange": EXCHANGE_NAME,
            "queue": QUEUE_NAME,
        }
    except (AMQPError, OSError, RuntimeError) as exc:
        return {
            "status": "unavailable",
            "broker": "rabbitmq",
            "url": _safe_url(RABBITMQ_URL),
            "exchange": EXCHANGE_NAME,
            "queue": QUEUE_NAME,
            "erro": str(exc),
        }
    finally:
        if conn is not None and not conn.is_closed:
            conn.close()


def _safe_url(url: str) -> str:
    if "@" not in url or "://" not in url:
        return url
    scheme, rest = url.split("://", 1)
    _, host = rest.rsplit("@", 1)
    return f"{scheme}://***:***@{host}"
