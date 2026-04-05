"""AI functions: LLM return types and Backboard.io-powered implementations."""

import from services.graph.models { EventType }
import from services.graph.backboard { bb_call }
import from json { loads }


# ── LLM Return Types ────────────────────────────────────────

obj MaintenanceDiagnosis {
    has category: str;
    has summary: str;
    has urgency: str;
    has recommended_action: str;
}

obj RiskAssessment {
    has level: str;
    has flags: list[str];
    has recommendation: str;
}


# ── Helpers ─────────────────────────────────────────────────

def _parse_json(raw: str) -> dict {
    clean = raw.strip();
    # Strip markdown code fences if present
    if clean.startswith("```") {
        lines = clean.split("\n");
        clean = "\n".join(lines[1:]);
        if "```" in clean {
            clean = clean.rsplit("```", 1)[0];
        }
    }
    return loads(clean.strip());
}


# ── LLM Functions ────────────────────────────────────────────

def:pub classify_event(message: str) -> EventType {
    prompt = (
        "Classify this tenant message into exactly one category. "
        "Reply with ONLY the category name, nothing else.\n"
        "Categories: MAINTENANCE, RENT_PAYMENT, LEASE_INQUIRY, NOISE_COMPLAINT, EMERGENCY, OTHER\n\n"
        "Message: " + message
    );
    try {
        result = bb_call(prompt).strip().upper();
        if "MAINTENANCE" in result { return EventType.MAINTENANCE; }
        if "RENT" in result { return EventType.RENT_PAYMENT; }
        if "LEASE" in result { return EventType.LEASE_INQUIRY; }
        if "NOISE" in result { return EventType.NOISE_COMPLAINT; }
        if "EMERGENCY" in result { return EventType.EMERGENCY; }
    } except Exception as e {
        print("classify_event error: " + str(e));
    }
    return EventType.OTHER;
}

def:pub diagnose_issue(message: str) -> MaintenanceDiagnosis {
    prompt = (
        "Diagnose this maintenance issue from a tenant. "
        "Return ONLY a JSON object with these exact keys:\n"
        "- \"category\": one of \"hvac\", \"plumbing\", \"electrical\", \"appliance\", \"general\"\n"
        "- \"summary\": brief 1-2 sentence diagnosis\n"
        "- \"urgency\": one of \"low\", \"medium\", \"high\", \"critical\"\n"
        "- \"recommended_action\": specific next step\n\n"
        "Tenant message: " + message
    );
    try {
        data = _parse_json(bb_call(prompt));
        return MaintenanceDiagnosis(
            category=str(data.get("category", "general")),
            summary=str(data.get("summary", "")),
            urgency=str(data.get("urgency", "medium")),
            recommended_action=str(data.get("recommended_action", ""))
        );
    } except Exception as e {
        print("diagnose_issue error: " + str(e));
        return MaintenanceDiagnosis(
            category="general",
            summary="Unable to diagnose — LLM error",
            urgency="medium",
            recommended_action="Manual inspection recommended"
        );
    }
}

def:pub select_vendor(diagnosis: str, available_vendors: str) -> str {
    prompt = (
        "Given this maintenance issue and available vendors, "
        "return ONLY the name of the single best vendor. No explanation.\n\n"
        "Issue: " + diagnosis + "\n\nAvailable vendors:\n" + available_vendors
    );
    try {
        return bb_call(prompt).strip().strip('"');
    } except Exception as e {
        print("select_vendor error: " + str(e));
        return "";
    }
}

def:pub assess_risk(context: str) -> RiskAssessment {
    prompt = (
        "Assess the risk of this maintenance situation. "
        "Return ONLY a JSON object with:\n"
        "- \"level\": one of \"low\", \"moderate\", \"high\"\n"
        "- \"flags\": array of risk factor strings\n"
        "- \"recommendation\": brief recommendation\n\n"
        "Context:\n" + context
    );
    try {
        data = _parse_json(bb_call(prompt));
        flags_raw = data.get("flags", []);
        flags = [str(f) for f in flags_raw];
        return RiskAssessment(
            level=str(data.get("level", "moderate")),
            flags=flags,
            recommendation=str(data.get("recommendation", ""))
        );
    } except Exception as e {
        print("assess_risk error: " + str(e));
        return RiskAssessment(
            level="moderate",
            flags=["LLM error — manual review needed"],
            recommendation="Manual risk assessment recommended"
        );
    }
}

def:pub draft_tenant_reply(context: str) -> str {
    prompt = (
        "Draft a brief professional SMS reply to a tenant who reported a maintenance issue. "
        "Keep under 160 characters. Return ONLY the SMS text, no quotes.\n\n"
        "Context:\n" + context
    );
    try {
        return bb_call(prompt).strip().strip('"');
    } except Exception as e {
        print("draft_tenant_reply error: " + str(e));
        return "We received your maintenance request and are working on it. We'll update you shortly.";
    }
}

def:pub draft_owner_alert(context: str) -> str {
    prompt = (
        "Draft a concise SMS alert for the property owner about a maintenance issue. "
        "Include unit, issue, urgency, vendor recommendation. "
        "Keep under 200 characters. Return ONLY the SMS text, no quotes.\n\n"
        "Context:\n" + context
    );
    try {
        return bb_call(prompt).strip().strip('"');
    } except Exception as e {
        print("draft_owner_alert error: " + str(e));
        return "New maintenance request received. Please review in the dashboard.";
    }
}
