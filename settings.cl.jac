import from "@jac/runtime" { __doFuncFetch }
cl import from shared { panel_classes }

def:pub SettingsView() -> JsxElement {
    has twilio_number: str = "";
    has alert_number: str = "";
    has alert_input: str = "";
    has loading: bool = False;
    has initialized: bool = False;
    has saving: bool = False;
    has save_success: bool = False;

    async def load_settings() -> None {
        loading = True;
        t = await __doFuncFetch("get_twilio_number", {});
        twilio_number = t["number"] if (t and t["number"]) else "Not configured";
        try {
            p = root spawn get_profile();
            reports = p.reports if p else [];
            data = reports[0] if reports else {};
            alert_number = data["phone_number"] if (data and data["phone_number"]) else "";
            alert_input = alert_number;
        } except Exception {
            alert_number = "";
            alert_input = "";
        }
        loading = False;
        initialized = True;
    }

    if not initialized and not loading {
        load_settings();
    }

    async def handle_save(e: any) -> None {
        e.preventDefault();
        saving = True;
        save_success = False;
        root spawn update_profile(phone_number=alert_input);
        await __doFuncFetch("set_alert_number", {"phone_number": alert_input});
        alert_number = alert_input;
        saving = False;
        save_success = True;
    }

    return (
        <div className="space-y-6 p-6">
            <div className={panel_classes() + " p-6"}>
                <p className="text-sm font-semibold text-slate-500">Workspace</p>
                <h1 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">Settings</h1>
            </div>

            <div className={panel_classes() + " p-6"}>
                <h2 className="text-base font-semibold text-slate-900 mb-1">Phone Numbers</h2>
                <p className="text-sm text-slate-500 mb-6">Configure the numbers used for inbound tenant texts and outbound owner alerts.</p>

                {loading and (
                    <div className="flex items-center gap-2 text-sm text-slate-500">
                        <div className="h-4 w-4 rounded-full border-2 border-slate-300 border-t-slate-700 animate-spin"></div>
                        Loading...
                    </div>
                )}

                {not loading and (
                    <div className="space-y-6">
                        <div>
                            <label className="block text-xs font-semibold text-slate-600 mb-1.5">Inbound Number</label>
                            <p className="text-xs text-slate-400 mb-2">The Twilio number tenants send maintenance requests to. Set via <span className="font-mono bg-slate-100 px-1 rounded">TWILIO_PHONE_NUMBER</span> in your .env file.</p>
                            <input
                                type="text"
                                value={twilio_number}
                                disabled={True}
                                className="w-full max-w-xs rounded-xl border border-slate-200 bg-slate-100 px-3.5 py-2.5 text-sm text-slate-500 cursor-not-allowed font-mono"
                            />
                        </div>

                        <div className="border-t border-slate-100 pt-6">
                            <form onSubmit={handle_save}>
                                <label className="block text-xs font-semibold text-slate-600 mb-1.5">Alert Number</label>
                                <p className="text-xs text-slate-400 mb-2">Your number. Receives notifications when a maintenance issue is flagged.</p>
                                <div className="flex items-center gap-3">
                                    <input
                                        type="tel"
                                        value={alert_input}
                                        onChange={lambda e: any { alert_input = e.target.value; save_success = False; }}
                                        placeholder="+1 555 000 0000"
                                        className="w-full max-w-xs rounded-xl border border-slate-200 bg-slate-50 px-3.5 py-2.5 text-sm text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-slate-900 focus:border-transparent transition font-mono"
                                        disabled={saving}
                                    />
                                    <button
                                        type="submit"
                                        disabled={saving or alert_input == alert_number}
                                        className="rounded-xl bg-slate-950 px-4 py-2.5 text-sm font-semibold text-white hover:opacity-90 disabled:opacity-40 transition shrink-0"
                                    >
                                        {("Saving..." if saving else "Save")}
                                    </button>
                                </div>
                                {save_success and (
                                    <p className="mt-2 text-xs font-medium text-emerald-600">Alert number updated.</p>
                                )}
                            </form>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
