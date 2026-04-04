import from "@jac/runtime" { __doFuncFetch }
cl import from shared { panel_classes }

def:pub SmsInboxView() -> JsxElement {
    has messages: list = [];
    has loading: bool = False;
    has error: str = "";

    async def load_messages() -> None {
        loading = True;
        error = "";
        try {
            result = await __doFuncFetch("get_messages", {});
            if result and result["messages"] {
                messages = result["messages"];
            } else {
                messages = [];
            }
        } except Exception as ex {
            error = "Failed to load messages: " + str(ex);
        }
        loading = False;
    }

    def message_card(msg: any) -> JsxElement {
        return (
            <div className={panel_classes() + " p-5"}>
                <div className="flex items-center justify-between gap-4 mb-3">
                    <div className="flex items-center gap-3">
                        <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-100 text-base font-semibold text-slate-600">
                            {str(msg["from"])[0:2]}
                        </div>
                        <div>
                            <p className="text-sm font-semibold text-slate-900">{msg["from"]}</p>
                            <p className="text-xs text-slate-400">{msg["time"]}</p>
                        </div>
                    </div>
                    <div className="rounded-full border border-slate-200 bg-slate-50 px-3 py-1 text-xs font-semibold text-slate-500">SMS</div>
                </div>
                <div className="rounded-[18px] bg-slate-950 px-4 py-3">
                    <p className="text-sm leading-relaxed text-white">{msg["body"]}</p>
                </div>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <div className={panel_classes() + " p-6"}>
                <div className="flex items-center justify-between gap-4">
                    <div>
                        <p className="text-sm font-semibold text-slate-500">Twilio SMS</p>
                        <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">Incoming Messages</h2>
                    </div>
                    <div className="flex items-center gap-3">
                        <div className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-600">
                            {str(len(messages)) + " message" + ("s" if len(messages) != 1 else "")}
                        </div>
                        <button
                            onClick={load_messages}
                            disabled={loading}
                            className="rounded-2xl bg-slate-950 px-4 py-3 text-sm font-semibold text-white transition hover:opacity-90 disabled:opacity-50"
                        >
                            {("Loading..." if loading else "Refresh")}
                        </button>
                    </div>
                </div>
            </div>

            {error and (
                <div className={panel_classes() + " p-5"}>
                    <p className="text-sm text-red-600">{error}</p>
                </div>
            )}

            {not loading and not error and len(messages) == 0 and (
                <div className={panel_classes() + " p-12 text-center"}>
                    <p className="text-4xl mb-4">📭</p>
                    <p className="text-lg font-semibold tracking-[-0.02em] text-slate-950 mb-1">No messages yet</p>
                    <p className="text-sm text-slate-500 mb-5">Texts sent to your Twilio number will appear here.</p>
                    <button
                        onClick={load_messages}
                        disabled={loading}
                        className="rounded-xl border border-slate-200 bg-slate-50 px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 disabled:opacity-50"
                    >
                        {("Loading..." if loading else "Load messages")}
                    </button>
                </div>
            )}

            {len(messages) > 0 and (
                <div className="space-y-3">
                    {[message_card(msg) for msg in messages]}
                </div>
            )}
        </div>
    );
}
