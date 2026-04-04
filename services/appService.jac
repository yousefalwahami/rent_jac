import from os { getenv }
import from fastapi { Request }


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
    form = await request.form();
    from_number = str(form.get("From") or "unknown");
    body = str(form.get("Body") or "");

    print("Incoming Twilio SMS from " + from_number + ": " + body);

    return {
        "success": True,
        "from": from_number,
        "body": body,
    };
}
