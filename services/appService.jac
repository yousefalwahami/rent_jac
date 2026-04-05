import from os { getenv }
import from fastapi { Request }
import from dotenv { load_dotenv }
import from services.graphService { triage }

glob _env: any = load_dotenv();

glob messages: list = [];
glob _alert_number: str = getenv("TWILIO_TARGET_PHONE_NUMBER") or "";


def:pub get_messages() -> dict {
    return {"messages": messages};
}


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
    value = getenv(name);
    if not value {
        raise Exception(name + " is not set");
    }
    return value;
}


def:pub send_test_sms() -> dict {
    account_sid = _require_env("TWILIO_ACCOUNT_SID");
    auth_token = _require_env("TWILIO_AUTH_TOKEN");
    from_number = _require_env("TWILIO_PHONE_NUMBER");
    to_number = _require_env("TWILIO_TARGET_PHONE_NUMBER");

    import from twilio.rest { Client }

    client = Client(account_sid, auth_token);
    message = client.messages.create(
        body="Jac/Twilio webhook test: reply to this message and the sender number + body will print in the server output.",
        from_=from_number,
        to=to_number,
    );

    print("Twilio test SMS sent to " + to_number + " with SID " + str(message.sid));
    return {
        "success": True,
        "to": to_number,
        "sid": str(message.sid),
    };
}


async def:pub twilio_webhook(request: Request) -> dict {
    import from datetime { datetime }
    import from twilio.rest { Client }

    form = await request.form();
    from_number = str(form.get("From") or "unknown");
    body = str(form.get("Body") or "");
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S");

    messages.insert(0, {
        "from": from_number,
        "body": body,
        "time": timestamp,
    });

    print("Incoming Twilio SMS from " + from_number + ": " + body);

    # ── Run the AI triage pipeline ───────────────────────────
    triage_result: any = None;
    try {
        result = root spawn triage(message=body, sender_phone=from_number);
        if result.reports {
            triage_result = result.reports[0];
            print("Triage result: " + str(triage_result));

            # If maintenance was processed, send SMS notifications
            if triage_result.get("event_type") == "maintenance" and triage_result.get("result") {
                maint = triage_result["result"];

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
