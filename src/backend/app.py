import os
import re
import secrets
import sqlite3
import time
from pathlib import Path
from typing import Any

from flask import Flask, abort, g, jsonify, request
from flask_cors import CORS
from werkzeug.exceptions import HTTPException
from werkzeug.security import check_password_hash, generate_password_hash
try:
    from backend.messaging import check_broker, publish_event
except ModuleNotFoundError:
    from messaging import check_broker, publish_event

BASE_DIR = Path(__file__).resolve().parent
DATABASE = Path(os.environ.get("QUICKFREELA_DB", BASE_DIR / "quickfreela.db"))

PERFIS = {"cliente", "prestador"}
STATUS_SOLICITACAO = {"aberta", "em_andamento", "concluida", "cancelada"}
STATUS_PROPOSTA = {"pendente", "aceita", "recusada", "cancelada"}
EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

app = Flask(__name__)
app.config["JSON_SORT_KEYS"] = False
CORS(app)

def get_db() -> sqlite3.Connection:
    if "db" not in g:
        conn = sqlite3.connect(DATABASE)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON")
        g.db = conn
    return g.db


@app.teardown_appcontext
def close_db(_: Exception | None = None) -> None:
    db = g.pop("db", None)
    if db is not None:
        db.close()


def row_to_dict(row: sqlite3.Row | None) -> dict[str, Any] | None:
    if row is None:
        return None
    return dict(row)


def init_db() -> None:
    db = get_db()
    db.executescript(
        """
        CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            senha_hash TEXT NOT NULL,
            perfil TEXT NOT NULL CHECK (perfil IN ('cliente', 'prestador')),
            criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS solicitacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            titulo TEXT NOT NULL,
            descricao TEXT NOT NULL,
            categoria TEXT NOT NULL DEFAULT 'geral',
            orcamento REAL NOT NULL CHECK (orcamento >= 0),
            prazo_entrega TEXT,
            status TEXT NOT NULL DEFAULT 'aberta'
                CHECK (status IN ('aberta', 'em_andamento', 'concluida', 'cancelada')),
            prestador_id INTEGER,
            proposta_aceita_id INTEGER,
            criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (cliente_id) REFERENCES usuarios(id) ON DELETE CASCADE,
            FOREIGN KEY (prestador_id) REFERENCES usuarios(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS propostas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            solicitacao_id INTEGER NOT NULL,
            prestador_id INTEGER NOT NULL,
            valor REAL NOT NULL CHECK (valor >= 0),
            prazo_dias INTEGER NOT NULL CHECK (prazo_dias > 0),
            mensagem TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'pendente'
                CHECK (status IN ('pendente', 'aceita', 'recusada', 'cancelada')),
            criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (solicitacao_id) REFERENCES solicitacoes(id) ON DELETE CASCADE,
            FOREIGN KEY (prestador_id) REFERENCES usuarios(id) ON DELETE CASCADE,
            UNIQUE (solicitacao_id, prestador_id)
        );
        """
    )
    db.commit()
    seed_db()


def seed_db() -> None:
    db = get_db()
    total = db.execute("SELECT COUNT(*) AS total FROM usuarios").fetchone()["total"]
    if total > 0:
        return

    senha = generate_password_hash("123456")
    usuarios = [
        ("Ana Cliente", "ana.cliente@quickfreela.local", senha, "cliente"),
        ("Bruno Prestador", "bruno.dev@quickfreela.local", senha, "prestador"),
        ("Carla Designer", "carla.design@quickfreela.local", senha, "prestador"),
    ]
    db.executemany(
        "INSERT INTO usuarios (nome, email, senha_hash, perfil) VALUES (?, ?, ?, ?)",
        usuarios,
    )

    db.execute(
        """
        INSERT INTO solicitacoes
            (cliente_id, titulo, descricao, categoria, orcamento, prazo_entrega)
        VALUES
            (1, 'Corrigir bug em tela Flutter',
             'App fecha ao abrir a tela de detalhes. Preciso de uma correcao rapida.',
             'programacao', 180.00, '2026-05-30')
        """
    )
    db.execute(
        """
        INSERT INTO solicitacoes
            (cliente_id, titulo, descricao, categoria, orcamento, prazo_entrega)
        VALUES
            (1, 'Criar banner simples para rede social',
             'Arte quadrada com logo, frase curta e chamada para promocao.',
             'design', 90.00, '2026-05-28')
        """
    )
    db.execute(
        """
        INSERT INTO propostas
            (solicitacao_id, prestador_id, valor, prazo_dias, mensagem)
        VALUES
            (1, 2, 160.00, 2, 'Consigo analisar o crash e entregar a correcao com testes.')
        """
    )
    db.commit()

def json_body() -> dict[str, Any]:
    data = request.get_json(silent=True)
    if not isinstance(data, dict) or not data:
        abort(400, description="Body JSON invalido ou ausente.")
    return data


def required_str(data: dict[str, Any], field: str) -> str:
    value = data.get(field)
    if not isinstance(value, str) or not value.strip():
        abort(400, description=f"Campo '{field}' e obrigatorio.")
    return value.strip()


def optional_str(data: dict[str, Any], field: str, default: str | None = None) -> str | None:
    value = data.get(field, default)
    if value is None:
        return None
    if not isinstance(value, str):
        abort(400, description=f"Campo '{field}' deve ser texto.")
    return value.strip()


def required_float(data: dict[str, Any], field: str) -> float:
    if field not in data:
        abort(400, description=f"Campo '{field}' e obrigatorio.")
    try:
        value = float(data[field])
    except (TypeError, ValueError):
        abort(400, description=f"Campo '{field}' deve ser numerico.")
    if value < 0:
        abort(400, description=f"Campo '{field}' nao pode ser negativo.")
    return value


def required_int(data: dict[str, Any], field: str, positive: bool = False) -> int:
    if field not in data:
        abort(400, description=f"Campo '{field}' e obrigatorio.")
    try:
        value = int(data[field])
    except (TypeError, ValueError):
        abort(400, description=f"Campo '{field}' deve ser inteiro.")
    if positive and value <= 0:
        abort(400, description=f"Campo '{field}' deve ser maior que zero.")
    return value


def validate_email(email: str) -> str:
    email = email.strip().lower()
    if not EMAIL_RE.match(email):
        abort(400, description="Campo 'email' deve ser um email valido.")
    return email


def validate_choice(value: str, field: str, allowed: set[str]) -> str:
    if value not in allowed:
        allowed_values = ", ".join(sorted(allowed))
        abort(400, description=f"Campo '{field}' deve ser um destes valores: {allowed_values}.")
    return value


def get_usuario_or_404(usuario_id: int, perfil: str | None = None) -> dict[str, Any]:
    row = get_db().execute(
        "SELECT id, nome, email, perfil, criado_em FROM usuarios WHERE id = ?",
        (usuario_id,),
    ).fetchone()
    usuario = row_to_dict(row)
    if usuario is None:
        abort(404, description=f"Usuario com id={usuario_id} nao encontrado.")
    if perfil is not None and usuario["perfil"] != perfil:
        abort(400, description=f"Usuario id={usuario_id} precisa ter perfil '{perfil}'.")
    return usuario


def get_solicitacao_or_404(solicitacao_id: int) -> dict[str, Any]:
    row = get_db().execute(
        """
        SELECT s.*, uc.nome AS cliente_nome, up.nome AS prestador_nome
        FROM solicitacoes s
        JOIN usuarios uc ON uc.id = s.cliente_id
        LEFT JOIN usuarios up ON up.id = s.prestador_id
        WHERE s.id = ?
        """,
        (solicitacao_id,),
    ).fetchone()
    solicitacao = row_to_dict(row)
    if solicitacao is None:
        abort(404, description=f"Solicitacao com id={solicitacao_id} nao encontrada.")
    return solicitacao


def get_proposta_or_404(proposta_id: int) -> dict[str, Any]:
    row = get_db().execute(
        """
        SELECT p.*, u.nome AS prestador_nome, s.titulo AS solicitacao_titulo
        FROM propostas p
        JOIN usuarios u ON u.id = p.prestador_id
        JOIN solicitacoes s ON s.id = p.solicitacao_id
        WHERE p.id = ?
        """,
        (proposta_id,),
    ).fetchone()
    proposta = row_to_dict(row)
    if proposta is None:
        abort(404, description=f"Proposta com id={proposta_id} nao encontrada.")
    return proposta


def publicar_evento(tipo: str, dados: dict[str, Any]) -> None:
    """Publica evento de dominio no RabbitMQ sem bloquear o fluxo REST."""
    evento = {"tipo": tipo, "dados": dados}
    print(f"  -> Evento: {evento}", flush=True)
    publish_event(tipo, dados)

@app.before_request
def log_request() -> None:
    ts = time.strftime("%H:%M:%S")
    print(f"[{ts}] {request.method:7s} {request.path}", flush=True)

@app.route("/", methods=["GET"])
def index():
    return jsonify(
        {
            "nome": "QuickFreela API",
            "versao": "1.0.0",
            "endpoints": {
                "health": "/health",
                "usuarios": "/usuarios",
                "solicitacoes": "/solicitacoes",
                "propostas": "/propostas",
                "login": "/auth/login",
            },
        }
    )

@app.route("/health", methods=["GET"])
def health():
    db = get_db()
    return jsonify(
        {
            "status": "ok",
            "usuarios": db.execute("SELECT COUNT(*) AS total FROM usuarios").fetchone()["total"],
            "solicitacoes": db.execute("SELECT COUNT(*) AS total FROM solicitacoes").fetchone()[
                "total"
            ],
            "propostas": db.execute("SELECT COUNT(*) AS total FROM propostas").fetchone()["total"],
            "timestamp": time.time(),
        }
    )


@app.route("/health/mom", methods=["GET"])
def health_mom():
    mom = check_broker()
    status_code = 200 if mom["status"] in {"ok", "disabled"} else 503
    return jsonify(mom), status_code

@app.route("/auth/register", methods=["POST"])
def registrar_usuario():
    return criar_usuario()

@app.route("/auth/login", methods=["POST"])
def login():
    data = json_body()
    email = validate_email(required_str(data, "email"))
    senha = required_str(data, "senha")

    row = get_db().execute("SELECT * FROM usuarios WHERE email = ?", (email,)).fetchone()
    if row is None or not check_password_hash(row["senha_hash"], senha):
        abort(401, description="Email ou senha invalidos.")

    usuario = {
        "id": row["id"],
        "nome": row["nome"],
        "email": row["email"],
        "perfil": row["perfil"],
        "criado_em": row["criado_em"],
    }
    return jsonify({"token": secrets.token_urlsafe(24), "usuario": usuario}), 200

@app.route("/usuarios", methods=["GET"])
def listar_usuarios():
    perfil = request.args.get("perfil")
    params: list[Any] = []
    sql = "SELECT id, nome, email, perfil, criado_em FROM usuarios"
    if perfil:
        validate_choice(perfil, "perfil", PERFIS)
        sql += " WHERE perfil = ?"
        params.append(perfil)
    sql += " ORDER BY id"

    rows = get_db().execute(sql, params).fetchall()
    return jsonify([row_to_dict(row) for row in rows]), 200


@app.route("/usuarios/<int:usuario_id>", methods=["GET"])
def buscar_usuario(usuario_id: int):
    return jsonify(get_usuario_or_404(usuario_id)), 200

@app.route("/usuarios", methods=["POST"])
def criar_usuario():
    data = json_body()
    nome = required_str(data, "nome")
    email = validate_email(required_str(data, "email"))
    senha = required_str(data, "senha")
    perfil = validate_choice(required_str(data, "perfil"), "perfil", PERFIS)

    try:
        cursor = get_db().execute(
            "INSERT INTO usuarios (nome, email, senha_hash, perfil) VALUES (?, ?, ?, ?)",
            (nome, email, generate_password_hash(senha), perfil),
        )
        get_db().commit()
    except sqlite3.IntegrityError:
        abort(409, description="Ja existe um usuario com este email.")

    usuario = get_usuario_or_404(cursor.lastrowid)
    publicar_evento("usuario.criado", usuario)
    return jsonify(usuario), 201

@app.route("/usuarios/<int:usuario_id>", methods=["PUT"])
def atualizar_usuario(usuario_id: int):
    get_usuario_or_404(usuario_id)
    data = json_body()
    nome = required_str(data, "nome")
    email = validate_email(required_str(data, "email"))
    perfil = validate_choice(required_str(data, "perfil"), "perfil", PERFIS)

    senha = optional_str(data, "senha")
    try:
        if senha:
            get_db().execute(
                """
                UPDATE usuarios
                SET nome = ?, email = ?, perfil = ?, senha_hash = ?
                WHERE id = ?
                """,
                (nome, email, perfil, generate_password_hash(senha), usuario_id),
            )
        else:
            get_db().execute(
                "UPDATE usuarios SET nome = ?, email = ?, perfil = ? WHERE id = ?",
                (nome, email, perfil, usuario_id),
            )
        get_db().commit()
    except sqlite3.IntegrityError:
        abort(409, description="Ja existe um usuario com este email.")

    usuario = get_usuario_or_404(usuario_id)
    publicar_evento("usuario.atualizado", usuario)
    return jsonify(usuario), 200


@app.route("/usuarios/<int:usuario_id>", methods=["DELETE"])
def remover_usuario(usuario_id: int):
    get_usuario_or_404(usuario_id)
    get_db().execute("DELETE FROM usuarios WHERE id = ?", (usuario_id,))
    get_db().commit()
    publicar_evento("usuario.removido", {"id": usuario_id})
    return "", 204

@app.route("/solicitacoes", methods=["GET"])
def listar_solicitacoes():
    filtros = []
    params: list[Any] = []

    for campo in ("status", "cliente_id", "prestador_id", "categoria"):
        valor = request.args.get(campo)
        if valor is None:
            continue
        if campo == "status":
            validate_choice(valor, "status", STATUS_SOLICITACAO)
        filtros.append(f"s.{campo} = ?")
        params.append(valor)

    sql = """
        SELECT s.*, uc.nome AS cliente_nome, up.nome AS prestador_nome
        FROM solicitacoes s
        JOIN usuarios uc ON uc.id = s.cliente_id
        LEFT JOIN usuarios up ON up.id = s.prestador_id
    """
    if filtros:
        sql += " WHERE " + " AND ".join(filtros)
    sql += " ORDER BY s.id"

    rows = get_db().execute(sql, params).fetchall()
    return jsonify([row_to_dict(row) for row in rows]), 200

@app.route("/solicitacoes/<int:solicitacao_id>", methods=["GET"])
def buscar_solicitacao(solicitacao_id: int):
    return jsonify(get_solicitacao_or_404(solicitacao_id)), 200

@app.route("/solicitacoes", methods=["POST"])
def criar_solicitacao():
    data = json_body()
    cliente_id = required_int(data, "cliente_id", positive=True)
    get_usuario_or_404(cliente_id, perfil="cliente")

    titulo = required_str(data, "titulo")
    descricao = required_str(data, "descricao")
    categoria = optional_str(data, "categoria", "geral") or "geral"
    orcamento = required_float(data, "orcamento")
    prazo_entrega = optional_str(data, "prazo_entrega")

    cursor = get_db().execute(
        """
        INSERT INTO solicitacoes
            (cliente_id, titulo, descricao, categoria, orcamento, prazo_entrega)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (cliente_id, titulo, descricao, categoria, orcamento, prazo_entrega),
    )
    get_db().commit()

    solicitacao = get_solicitacao_or_404(cursor.lastrowid)
    publicar_evento("solicitacao.criada", solicitacao)
    return jsonify(solicitacao), 201

@app.route("/solicitacoes/<int:solicitacao_id>", methods=["PUT"])
def atualizar_solicitacao(solicitacao_id: int):
    solicitacao_atual = get_solicitacao_or_404(solicitacao_id)
    data = json_body()

    cliente_id = required_int(data, "cliente_id", positive=True)
    get_usuario_or_404(cliente_id, perfil="cliente")
    titulo = required_str(data, "titulo")
    descricao = required_str(data, "descricao")
    categoria = optional_str(data, "categoria", "geral") or "geral"
    orcamento = required_float(data, "orcamento")
    prazo_entrega = optional_str(data, "prazo_entrega")
    status = validate_choice(
        optional_str(data, "status", solicitacao_atual["status"]) or solicitacao_atual["status"],
        "status",
        STATUS_SOLICITACAO,
    )

    get_db().execute(
        """
        UPDATE solicitacoes
        SET cliente_id = ?, titulo = ?, descricao = ?, categoria = ?, orcamento = ?,
            prazo_entrega = ?, status = ?, atualizado_em = CURRENT_TIMESTAMP
        WHERE id = ?
        """,
        (cliente_id, titulo, descricao, categoria, orcamento, prazo_entrega, status, solicitacao_id),
    )
    get_db().commit()

    solicitacao = get_solicitacao_or_404(solicitacao_id)
    publicar_evento("solicitacao.atualizada", solicitacao)
    return jsonify(solicitacao), 200


@app.route("/solicitacoes/<int:solicitacao_id>/status", methods=["PATCH"])
def atualizar_status_solicitacao(solicitacao_id: int):
    get_solicitacao_or_404(solicitacao_id)
    data = json_body()
    status = validate_choice(required_str(data, "status"), "status", STATUS_SOLICITACAO)

    get_db().execute(
        """
        UPDATE solicitacoes
        SET status = ?, atualizado_em = CURRENT_TIMESTAMP
        WHERE id = ?
        """,
        (status, solicitacao_id),
    )
    get_db().commit()

    solicitacao = get_solicitacao_or_404(solicitacao_id)
    publicar_evento("solicitacao.status_atualizado", solicitacao)
    return jsonify(solicitacao), 200


@app.route("/solicitacoes/<int:solicitacao_id>", methods=["DELETE"])
def remover_solicitacao(solicitacao_id: int):
    get_solicitacao_or_404(solicitacao_id)
    get_db().execute("DELETE FROM solicitacoes WHERE id = ?", (solicitacao_id,))
    get_db().commit()
    publicar_evento("solicitacao.removida", {"id": solicitacao_id})
    return "", 204

@app.route("/propostas", methods=["GET"])
def listar_propostas():
    filtros = []
    params: list[Any] = []

    for campo in ("status", "solicitacao_id", "prestador_id"):
        valor = request.args.get(campo)
        if valor is None:
            continue
        if campo == "status":
            validate_choice(valor, "status", STATUS_PROPOSTA)
        filtros.append(f"p.{campo} = ?")
        params.append(valor)

    sql = """
        SELECT p.*, u.nome AS prestador_nome, s.titulo AS solicitacao_titulo
        FROM propostas p
        JOIN usuarios u ON u.id = p.prestador_id
        JOIN solicitacoes s ON s.id = p.solicitacao_id
    """
    if filtros:
        sql += " WHERE " + " AND ".join(filtros)
    sql += " ORDER BY p.id"

    rows = get_db().execute(sql, params).fetchall()
    return jsonify([row_to_dict(row) for row in rows]), 200

@app.route("/propostas/<int:proposta_id>", methods=["GET"])
def buscar_proposta(proposta_id: int):
    return jsonify(get_proposta_or_404(proposta_id)), 200

@app.route("/propostas", methods=["POST"])
def criar_proposta():
    data = json_body()
    solicitacao_id = required_int(data, "solicitacao_id", positive=True)
    prestador_id = required_int(data, "prestador_id", positive=True)

    solicitacao = get_solicitacao_or_404(solicitacao_id)
    if solicitacao["status"] != "aberta":
        abort(409, description="So e possivel enviar proposta para solicitacao aberta.")
    if solicitacao["cliente_id"] == prestador_id:
        abort(400, description="Cliente da solicitacao nao pode enviar proposta para ela.")

    get_usuario_or_404(prestador_id, perfil="prestador")
    valor = required_float(data, "valor")
    prazo_dias = required_int(data, "prazo_dias", positive=True)
    mensagem = required_str(data, "mensagem")

    try:
        cursor = get_db().execute(
            """
            INSERT INTO propostas
                (solicitacao_id, prestador_id, valor, prazo_dias, mensagem)
            VALUES (?, ?, ?, ?, ?)
            """,
            (solicitacao_id, prestador_id, valor, prazo_dias, mensagem),
        )
        get_db().commit()
    except sqlite3.IntegrityError:
        abort(409, description="Este prestador ja enviou proposta para esta solicitacao.")

    proposta = get_proposta_or_404(cursor.lastrowid)
    publicar_evento("proposta.criada", proposta)
    return jsonify(proposta), 201

@app.route("/propostas/<int:proposta_id>", methods=["PUT"])
def atualizar_proposta(proposta_id: int):
    proposta_atual = get_proposta_or_404(proposta_id)
    data = json_body()

    valor = required_float(data, "valor")
    prazo_dias = required_int(data, "prazo_dias", positive=True)
    mensagem = required_str(data, "mensagem")
    status = validate_choice(
        optional_str(data, "status", proposta_atual["status"]) or proposta_atual["status"],
        "status",
        STATUS_PROPOSTA,
    )

    get_db().execute(
        """
        UPDATE propostas
        SET valor = ?, prazo_dias = ?, mensagem = ?, status = ?,
            atualizado_em = CURRENT_TIMESTAMP
        WHERE id = ?
        """,
        (valor, prazo_dias, mensagem, status, proposta_id),
    )
    get_db().commit()

    proposta = get_proposta_or_404(proposta_id)
    publicar_evento("proposta.atualizada", proposta)
    return jsonify(proposta), 200

@app.route("/solicitacoes/<int:solicitacao_id>/propostas/<int:proposta_id>/aceitar", methods=["POST"])
def aceitar_proposta(solicitacao_id: int, proposta_id: int):
    solicitacao = get_solicitacao_or_404(solicitacao_id)
    proposta = get_proposta_or_404(proposta_id)

    if proposta["solicitacao_id"] != solicitacao_id:
        abort(400, description="Proposta nao pertence a solicitacao informada.")
    if solicitacao["status"] != "aberta":
        abort(409, description="Solicitacao precisa estar aberta para aceitar proposta.")
    if proposta["status"] != "pendente":
        abort(409, description="Proposta precisa estar pendente para ser aceita.")

    data = request.get_json(silent=True) or {}
    cliente_id = data.get("cliente_id")
    if cliente_id is not None:
        try:
            cliente_id = int(cliente_id)
        except (TypeError, ValueError):
            abort(400, description="Campo 'cliente_id' deve ser inteiro.")
        if cliente_id != solicitacao["cliente_id"]:
            abort(403, description="Somente o cliente dono da solicitacao pode aceitar proposta.")

    db = get_db()
    db.execute(
        """
        UPDATE propostas
        SET status = 'recusada', atualizado_em = CURRENT_TIMESTAMP
        WHERE solicitacao_id = ? AND id <> ? AND status = 'pendente'
        """,
        (solicitacao_id, proposta_id),
    )
    db.execute(
        """
        UPDATE propostas
        SET status = 'aceita', atualizado_em = CURRENT_TIMESTAMP
        WHERE id = ?
        """,
        (proposta_id,),
    )
    db.execute(
        """
        UPDATE solicitacoes
        SET status = 'em_andamento', prestador_id = ?, proposta_aceita_id = ?,
            atualizado_em = CURRENT_TIMESTAMP
        WHERE id = ?
        """,
        (proposta["prestador_id"], proposta_id, solicitacao_id),
    )
    db.commit()

    resultado = {
        "solicitacao": get_solicitacao_or_404(solicitacao_id),
        "proposta": get_proposta_or_404(proposta_id),
    }
    publicar_evento("proposta.aceita", resultado)
    return jsonify(resultado), 200

@app.route("/propostas/<int:proposta_id>", methods=["DELETE"])
def remover_proposta(proposta_id: int):
    proposta = get_proposta_or_404(proposta_id)
    if proposta["status"] == "aceita":
        abort(409, description="Nao e possivel remover uma proposta aceita.")
    get_db().execute("DELETE FROM propostas WHERE id = ?", (proposta_id,))
    get_db().commit()
    publicar_evento("proposta.removida", {"id": proposta_id})
    return "", 204

@app.errorhandler(HTTPException)
def handle_http_error(error: HTTPException):
    return jsonify({"erro": error.description}), error.code

@app.errorhandler(500)
def internal_error(_: Exception):
    return jsonify({"erro": "Erro interno no servidor."}), 500

with app.app_context():
    init_db()

if __name__ == "__main__":
    print("=" * 60)
    print("  QuickFreela API")
    print("  Servidor iniciado em http://0.0.0.0:5000")
    print("  Emulador Android: http://10.0.2.2:5000")
    print(f"  Banco SQLite: {DATABASE}")
    print("=" * 60)
    app.run(host="0.0.0.0", port=5000, debug=True)
