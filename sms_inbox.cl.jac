import from "@jac/runtime" { __doFuncFetch }
cl import from shared { panel_classes }

def:pub SmsInboxView(props: dict) -> JsxElement {
    raw_msgs = props["messages"] if props and props["messages"] else [];
    messages = raw_msgs if raw_msgs else [];
    
    has loading: bool = False;
    has error: str = "";

    def message_card(msg: any) -> JsxElement {
        if not msg { return <div></div>; }
        
        # safely handle property access since msg might be a raw JS object from API
        m_matched = msg["matched"] if "matched" in msg else False;
        m_tenant = msg["tenant_name"] if "tenant_name" in msg else "";
        m_from = msg["from"] if "from" in msg else "";
        m_prop = msg["property_name"] if "property_name" in msg else "";
        m_unit = msg["unit"] if "unit" in msg else "";
        m_time = msg["time"] if "time" in msg else "";
        m_body = msg["body"] if "body" in msg else "";

        is_matched = True if m_matched else False;
        sender_name = str(m_tenant) if is_matched else str(m_from);
        property_info = str(m_prop) + " — Unit " + str(m_unit) if is_matched else "Unknown contact";
        
        return (
            <div className={panel_classes() + " p-5"}>
                <div className="flex items-center justify-between gap-4 mb-3">
                    <div className="flex items-center gap-3">
                        <div className={"flex h-9 w-9 items-center justify-center rounded-xl text-base font-semibold " + (is_matched and "bg-indigo-100 text-indigo-700" or "bg-slate-100 text-slate-600")}>
                            {sender_name[0:2].upper() if len(sender_name) >= 2 else "?"}
                        </div>
                        <div>
                            <p className="text-sm font-semibold text-slate-900">{sender_name}</p>
                            <p className="text-xs text-slate-500">{m_time} • {property_info}</p>
                        </div>
                    </div>
                    <div className="rounded-full border border-slate-200 bg-slate-50 px-3 py-1 text-xs font-semibold text-slate-500">SMS</div>
                </div>
                <div className="rounded-[18px] bg-slate-950 px-4 py-3">
                    <p className="text-sm leading-relaxed text-white">{str(m_body)}</p>
                </div>
            </div>
        );
    }

    return (
        <div className="space-y-6 flex flex-col h-full bg-slate-50 p-6 font-sans">
            <div className={panel_classes() + " p-6 shrink-0"}>
                <div className="flex items-center justify-between gap-4">
                    <div>
                        <p className="text-sm font-semibold text-slate-500">Twilio SMS</p>
                        <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">Live Inbox</h2>
                    </div>
                    <div className="flex items-center gap-3">
                        <div className="flex items-center gap-2 rounded-full border border-green-200 bg-green-50 px-3 py-1.5 text-xs font-medium text-green-700 shadow-sm">
                            <span className="relative flex h-2 w-2">
                                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                                <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                            </span>
                            Live Sync Active
                        </div>
                    </div>
                </div>
            </div>
            
            <div className="flex flex-col flex-1 overflow-y-auto gap-4 pb-12 pr-2">
                {len(messages) == 0 and (
                    <div className={panel_classes() + " p-12 text-center text-slate-500 flex flex-col items-center justify-center min-h-[300px] border-dashed"}>
                        <svg className="w-8 h-8 mb-3 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path></svg>
                        <p className="font-medium mb-1 shadow-sm">No Messages Yet</p>
                        <p className="text-sm opacity-80 max-w-sm text-center">Text your Twilio number to see live updates stream into this inbox immediately.</p>
                    </div>
                )}
                {messages.map(lambda msg: any -> JsxElement {
                    return message_card(msg);
                })}
            </div>
        </div>
    );
}
