"""MongoDB client — persistent document storage for SMS logs, walker runs, etc."""

import from os { getenv }
import from dotenv { load_dotenv }
import from pymongo { MongoClient }
import from datetime { datetime }

glob _mongo_env: any = load_dotenv();
glob _mongo_uri: str = getenv("MONGODB_URI") or "";
glob _mongo_client: any = None;
glob _mongo_db: any = None;

def _ensure_db() -> any {
    if _mongo_db {
        return _mongo_db;
    }
    if not _mongo_uri {
        print("MONGODB_URI not set — MongoDB features disabled");
        return None;
    }
    _mongo_client = MongoClient(_mongo_uri);
    _mongo_db = _mongo_client["rentora"];
    print("MongoDB connected to rentora database");
    return _mongo_db;
}


# ── SMS Messages ─────────────────────────────────────────────

def:pub log_sms(from_number: str, to_number: str, body: str, direction: str, sid: str = "", unit_id: str = "", tenant_name: str = "") -> dict {
    db = _ensure_db();
    if not db {
        return {"success": False, "error": "MongoDB not connected"};
    }
    doc = {
        "from": from_number,
        "to": to_number,
        "body": body,
        "direction": direction,
        "sid": sid,
        "unit_id": unit_id,
        "tenant_name": tenant_name,
        "timestamp": datetime.now()
    };
    result = db["sms_messages"].insert_one(doc);
    return {"success": True, "id": str(result.inserted_id)};
}

def:pub get_sms_history(phone: str = "", limit_count: int = 50) -> list {
    db = _ensure_db();
    if not db {
        return [];
    }
    query = {};
    if phone {
        query = {"$or": [{"from": phone}, {"to": phone}]};
    }
    cursor = db["sms_messages"].find(query).sort("timestamp", -1).limit(limit_count);
    results = [];
    for doc in cursor {
        doc["_id"] = str(doc["_id"]);
        results.append(doc);
    }
    return results;
}


# ── Walker Logs ──────────────────────────────────────────────

def:pub log_walker_run(walker_name: str, unit_id: str, input_data: dict, output_data: dict, duration_ms: int = 0) -> dict {
    db = _ensure_db();
    if not db {
        return {"success": False, "error": "MongoDB not connected"};
    }
    doc = {
        "walker": walker_name,
        "unit_id": unit_id,
        "input": input_data,
        "output": output_data,
        "duration_ms": duration_ms,
        "timestamp": datetime.now()
    };
    result = db["walker_logs"].insert_one(doc);
    return {"success": True, "id": str(result.inserted_id)};
}


# ── Notifications ────────────────────────────────────────────

def:pub create_notification(notification_type: str, payload: dict, ticket_id: str = "") -> dict {
    db = _ensure_db();
    if not db {
        return {"success": False, "error": "MongoDB not connected"};
    }
    doc = {
        "type": notification_type,
        "payload": payload,
        "ticket_id": ticket_id,
        "read": False,
        "timestamp": datetime.now()
    };
    result = db["notifications"].insert_one(doc);
    return {"success": True, "id": str(result.inserted_id)};
}

def:pub get_notifications(unread_only: bool = True, limit_count: int = 20) -> list {
    db = _ensure_db();
    if not db {
        return [];
    }
    query = {"read": False} if unread_only else {};
    cursor = db["notifications"].find(query).sort("timestamp", -1).limit(limit_count);
    results = [];
    for doc in cursor {
        doc["_id"] = str(doc["_id"]);
        results.append(doc);
    }
    return results;
}


# ── Generic helpers ──────────────────────────────────────────

def:pub db_insert(collection: str, doc: dict) -> dict {
    db = _ensure_db();
    if not db {
        return {"success": False};
    }
    doc["created_at"] = datetime.now();
    result = db[collection].insert_one(doc);
    return {"success": True, "id": str(result.inserted_id)};
}

def:pub db_find(collection: str, query: dict = {}, limit_count: int = 50) -> list {
    db = _ensure_db();
    if not db {
        return [];
    }
    cursor = db[collection].find(query).sort("created_at", -1).limit(limit_count);
    results = [];
    for doc in cursor {
        doc["_id"] = str(doc["_id"]);
        results.append(doc);
    }
    return results;
}
