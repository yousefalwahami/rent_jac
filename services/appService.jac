import from os { getenv }
import from fastapi { Request, HTTPException }
import from pydantic { BaseModel }
import from dotenv { load_dotenv }
import from twilio.rest { Client }
import from services.graph.models { Property, Unit, Lease, Tenant }
import from datetime { datetime }
import from services.graphService { triage, list_properties, list_tenants, add_property_node, register_tenant, delete_property_node, delete_tenant_node }
import from logging { getLogger }
import from services.graph.localdb { log_sms, log_walker_run, create_notification }

glob _env: any = load_dotenv();
glob _twilio_log: any = getLogger("twilio.http_client").setLevel(40);


glob messages: list = [];
# Map from Twilio SID → triage result, so API-fetched messages can be enriched
glob _triage_by_sid: dict = {};

def:pub get_messages() -> dict {
    try {
        load_dotenv();
        account_sid = getenv("TWILIO_ACCOUNT_SID");
        auth_token = getenv("TWILIO_AUTH_TOKEN");
        twilio_num = getenv("TWILIO_PHONE_NUMBER");

        if account_sid and auth_token {
            client = Client(account_sid, auth_token);
            msgs = client.messages.list(limit=20);

            fmt_msgs = [];
            for m in msgs {
                if "Sent from your Twilio trial account" in str(m.body) {
                    continue;
                }
                fmt_msgs.append({
                    "from": m.from_,
                    "to": m.to,
                    "body": m.body,
                    "time": str(m.date_created) if m.date_created else "",
                    "sid": str(m.sid),
                    "triage": _triage_by_sid.get(str(m.sid), None)
                });
            }
            return {"messages": fmt_msgs, "source": "twilio_api"};
        }
    } except Exception as e {
        print("Failed to fetch from Twilio: " + str(e));
    }

    return {"messages": messages, "source": "memory"};
}

glob _alert_number: str = getenv("TWILIO_TARGET_PHONE_NUMBER") or "";



def:pub get_twilio_number() -> dict {
    number = getenv("TWILIO_PHONE_NUMBER") or "";
    return {"number": number};
}

def:pub set_alert_number(phone_number: str) -> dict {
    _alert_number = phone_number;
    return {"success": True, "alert_number": phone_number};
}


def:pub send_sms(recipient: str, body: str) -> dict {
    account_sid = getenv("TWILIO_ACCOUNT_SID");
    auth_token = getenv("TWILIO_AUTH_TOKEN");
    from_number = getenv("TWILIO_PHONE_NUMBER");
    if not (account_sid and auth_token and from_number) {
        return {"success": False, "error": "Twilio credentials not configured"};
    }
    import from twilio.rest { Client }
    client = Client(account_sid, auth_token);
    msg = client.messages.create(body=body, from_=from_number, to=recipient);
    print("SMS sent to " + recipient + " — SID: " + str(msg.sid));
    return {"success": True, "sid": str(msg.sid)};
}


def:pub greet(name: str = "World") -> dict {
    return {"message": "Hello, " + name + "! Your Jac backend is working."};
}

def _require_env(name: str) -> str {
    import from dotenv { load_dotenv }


    load_dotenv();
    value = getenv(name);
    if not value {
        raise Exception(name + " is not set");
    }
    return value;
}


def:pub send_test_sms(to_number: str = "", message: str = "Jac/Twilio webhook test: reply to this message and the sender number + body will print in the server output.") -> dict {
    try {
        account_sid = _require_env("TWILIO_ACCOUNT_SID");
        auth_token = _require_env("TWILIO_AUTH_TOKEN");
        from_number = _require_env("TWILIO_PHONE_NUMBER");
    } except Exception as e {
        return {"success": False, "error": str(e), "message": "Environment variables missing, check .env"};
    }

    to_num = to_number;
    if not to_num {
        to_num = getenv("TWILIO_TARGET_PHONE_NUMBER");
    }
    if not to_num {
        return {"success": False, "error": "Missing destination number", "message": "Provide to_number in request or set TWILIO_TARGET_PHONE_NUMBER in .env"};
    }

    try {
        
        client = Client(account_sid, auth_token);
        msg = client.messages.create(
            body=message,
            from_=from_number,
            to=to_num,
        );
        print("Twilio test SMS sent to " + to_num + " with SID " + str(msg.sid));
        
        # Log the outbound message to the feed so the UI picks it up
        
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
        messages.insert(0, {
            "from": from_number,
            "body": message,
            "time": timestamp,
        });

        return {
            "success": True,
            "to": to_num,
            "sid": str(msg.sid),
            "status": msg.status
        };
    } except Exception as e {
        print("Twilio error: " + str(e));
        return {"success": False, "error": "Twilio API Error", "message": str(e)};
    }
}

async def:pub twilio_webhook(request: Request) -> dict {
    
    

    form = await request.form();
    from_number = str(form.get("From") or "unknown");
    body = str(form.get("Body") or "");
    msg_sid = str(form.get("MessageSid") or "");
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S");

    msg_entry = {
        "from": from_number,
        "body": body,
        "time": timestamp,
        "triage": None,
    };

    print("Incoming Twilio SMS from " + from_number + ": " + body);

    # Log inbound SMS to MongoDB
    twilio_num = getenv("TWILIO_PHONE_NUMBER") or "";
    log_sms(from_number, twilio_num, body, "inbound", msg_sid);

    # ── Run the AI triage pipeline ───────────────────────────
    triage_result: any = None;
    try {
        result = root spawn triage(message=body, sender_phone=from_number);
        if result.reports {
            triage_result = result.reports[0];
            msg_entry["triage"] = triage_result;
            if msg_sid {
                _triage_by_sid[msg_sid] = triage_result;
            }
            print("Triage result: " + str(triage_result));

            # Log walker run to MongoDB
            log_walker_run("triage", triage_result.get("unit", ""), {"message": body, "phone": from_number}, triage_result);

            # If maintenance was processed, send SMS notifications
            if triage_result.get("event_type") == "maintenance" and triage_result.get("result") {
                maint = triage_result["result"];

                # Log maintenance walker run
                log_walker_run("handle_maintenance", triage_result.get("unit", ""), {"message": body}, maint);

                # Create approval notification
                create_notification("approval_required", maint, maint.get("ticket_id", ""));

                # Send tenant acknowledgment
                if maint.get("tenant_reply") and maint.get("tenant_phone") {
                    send_sms(maint["tenant_phone"], maint["tenant_reply"]);
                }

                # Send owner alert
                if _alert_number and maint.get("owner_alert") {
                    send_sms(_alert_number, maint["owner_alert"]);
                }
            }
        }
    } except Exception as e {
        print("Triage pipeline error: " + str(e));
    }

    messages.insert(0, msg_entry);

    if _alert_number and not triage_result {
        try {
            account_sid = getenv("TWILIO_ACCOUNT_SID");
            auth_token = getenv("TWILIO_AUTH_TOKEN");
            from_twilio = getenv("TWILIO_PHONE_NUMBER");
            if account_sid and auth_token and from_twilio {
                client = Client(account_sid, auth_token);
                client.messages.create(
                    body="New request from " + from_number + ": " + body,
                    from_=from_twilio,
                    to=_alert_number,
                );
                print("Alert forwarded to " + _alert_number);
            }
        } except Exception as e {
            print("Failed to forward alert: " + str(e));
        }
    }

    return {
        "success": True,
        "from": from_number,
        "body": body,
        "triage": triage_result,
    };
}

def:pub run_triage_for_message(body: str, from_number: str, msg_sid: str = "") -> dict {
    try {
        result = root spawn triage(message=body, sender_phone=from_number);
        if result.reports {
            triage_result = result.reports[0];
            # Only cache matched results — unmatched stay uncached so they retry after tenant registration
            if msg_sid and not triage_result.get("unmatched", False) {
                _triage_by_sid[msg_sid] = triage_result;
            }
            return {"success": True, "triage": triage_result};
        }
        return {"success": False, "error": "No triage result"};
    } except Exception as e {
        return {"success": False, "error": str(e)};
    }
}


walker seed_if_empty {
    can run with Root entry {
        check = root spawn list_properties();
        existing = check.reports[0] if (check and check.reports) else [];
        if existing and len(existing) > 0 {
            report {"status": "already_seeded", "count": len(existing)};
            disengage;
        }
        root spawn add_property_node(name="Harbor Point Apts", address="221 Lakeview Dr", unit_numbers=["1A", "2B", "3C"]);
        root spawn add_property_node(name="Maple Street House", address="845 Maple St", unit_numbers=["Unit 1", "Unit 2"]);
        root spawn add_property_node(name="Oak View Complex", address="560 Oak Ave", unit_numbers=["101", "102", "201"]);
        root spawn register_tenant(tenant_name="John Smith", tenant_phone="+15551001001", unit_number="1A", rent_amount=1400.0, lease_start="2025-01-01", lease_end="2026-12-31", property_name="Harbor Point Apts");
        root spawn register_tenant(tenant_name="Sarah Johnson", tenant_phone="+15551001002", unit_number="2B", rent_amount=1600.0, lease_start="2025-01-01", lease_end="2026-12-31", property_name="Harbor Point Apts");
        root spawn register_tenant(tenant_name="Mike Lee", tenant_phone="+15551001003", unit_number="Unit 1", rent_amount=1200.0, lease_start="2025-01-01", lease_end="2026-12-31", property_name="Maple Street House");
        root spawn register_tenant(tenant_name="Emily Chen", tenant_phone="+15551001004", unit_number="101", rent_amount=950.0, lease_start="2025-01-01", lease_end="2026-12-31", property_name="Oak View Complex");
        report {"status": "seeded", "properties": 3, "tenants": 4};
    }
}


walker fetch_properties {
    can list with Root entry {
        result = [];
        for p in [here -->][?:Property] {
            units = [p -->][?:Unit];
            result.append({
                "id": jid(p),
                "name": p.name,
                "address": p.address,
                "city": p.city,
                "state": p.state,
                "unit_count": len(units)
            });
        }
        report result;
    }
}


walker fetch_tenants {
    can list with Root entry {
        result = [];
        for p in [here -->][?:Property] {
            for u in [p -->][?:Unit] {
                for l in [u -->][?:Lease] {
                    for t in [l -->][?:Tenant] {
                        result.append({
                            "id": jid(t),
                            "full_name": t.name,
                            "phone_number": t.phone,
                            "unit_number": u.number,
                            "property_id": jid(p),
                            "property_name": p.name,
                            "rent": str(l.rent_amount),
                            "lease_end": l.end_date
                        });
                    }
                }
            }
        }
        report result;
    }
}


walker save_property_data {
    has name: str = "";
    has address: str = "";

    can create with Root entry {
        if not self.name {
            report {"status": "error", "message": "Property name is required"};
            disengage;
        }
        result = root spawn add_property_node(name=self.name, address=self.address);
        if result and result.reports {
            report result.reports[0];
        } else {
            report {"status": "error", "message": "No result from walker"};
        }
    }
}


walker save_tenant_data {
    has tenant_name: str = "";
    has tenant_phone: str = "";
    has unit_number: str = "";
    has rent_amount: float = 0.0;
    has property_name: str = "";

    can create with Root entry {
        if not (self.tenant_name and self.tenant_phone and self.unit_number and self.property_name) {
            report {"status": "error", "message": "All fields are required"};
            disengage;
        }
        result = root spawn register_tenant(
            tenant_name=self.tenant_name,
            tenant_phone=self.tenant_phone,
            unit_number=self.unit_number,
            rent_amount=self.rent_amount,
            lease_start="2025-01-01",
            lease_end="2026-12-31",
            property_name=self.property_name
        );
        if result and result.reports {
            report result.reports[0];
        } else {
            report {"status": "error", "message": "No result from walker"};
        }
    }
}


def:pub delete_property_data(property_id: str) -> dict {
    try {
        result = root spawn delete_property_node(property_id=property_id);
        if result and result.reports {
            return result.reports[0];
        }
        return {"status": "deleted"};
    } except Exception as e {
        print("delete_property_data error: " + str(e));
        return {"status": "error", "message": str(e)};
    }
}


def:pub delete_tenant_data(tenant_id: str) -> dict {
    try {
        result = root spawn delete_tenant_node(tenant_id=tenant_id);
        if result and result.reports {
            return result.reports[0];
        }
        return {"status": "deleted"};
    } except Exception as e {
        print("delete_tenant_data error: " + str(e));
        return {"status": "error", "message": str(e)};
    }
}

def:pub delete_message(msg_id: str) -> dict {
    try {
        load_dotenv();
        sid = str(msg_id).replace("INC-", "");
        account_sid = getenv("TWILIO_ACCOUNT_SID");
        auth_token = getenv("TWILIO_AUTH_TOKEN");
        if sid.startswith("SM") and account_sid and auth_token {
            client = Client(account_sid, auth_token);
            client.messages(sid).delete();
            print("Deleted Twilio message " + sid);
            return {"success": True};
        } else {
            for i in range(len(messages)) {
                if messages[i].get("sid", "") == sid or str(messages[i].get("id", "")) == sid {
                    messages.pop(i);
                    return {"success": True};
                }
            }
            # Fallback for old memory mock
            for i in range(len(messages)) {
                messages.pop(i);
                return {"success": True};
            }
        }
    } except Exception as e {
        return {"success": False, "error": str(e)};
    }
    return {"success": False, "error": "Not found"};
}
