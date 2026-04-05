"""Backboard.io API client for LLM calls."""

import from os { getenv }
import from dotenv { load_dotenv }
import from json { loads }
import from requests { post }

glob _bb_env: any = load_dotenv();
glob _bb_key: str = getenv("BACKBOARD_API_KEY") or "";
glob _bb_base: str = "https://app.backboard.io/api";
glob _bb_assistant_id: str = "";
glob _bb_thread_id: str = "";

def _bb_setup() -> None {
    if _bb_assistant_id {
        return;
    }
    if not _bb_key {
        raise Exception("BACKBOARD_API_KEY not set in .env");
    }
    headers = {"X-API-Key": _bb_key};

    # Create assistant
    resp = post(
        _bb_base + "/assistants",
        json={
            "name": "PropOS AI",
            "system_prompt": "You are an AI for property management. When asked to return JSON, return ONLY valid JSON. No markdown, no code blocks, no extra text."
        },
        headers=headers
    );
    resp.raise_for_status();
    _bb_assistant_id = str(resp.json()["assistant_id"]);

    # Create thread
    resp = post(
        _bb_base + "/assistants/" + _bb_assistant_id + "/threads",
        json={},
        headers=headers
    );
    resp.raise_for_status();
    _bb_thread_id = str(resp.json()["thread_id"]);
    print("Backboard ready: assistant=" + _bb_assistant_id);
}

def:pub bb_call(prompt: str) -> str {
    _bb_setup();
    headers = {"X-API-Key": _bb_key};
    resp = post(
        _bb_base + "/threads/" + _bb_thread_id + "/messages",
        headers=headers,
        json={
            "content": prompt,
            "llm_provider": "openai",
            "model_name": "gpt-4o-mini",
            "stream": False,
            "memory": "off"
        }
    );
    resp.raise_for_status();
    return str(resp.json().get("content") or "");
}
