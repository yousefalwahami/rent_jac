cl import from shared { panel_classes }

def:pub settings_view() -> JsxElement {
    return (
        <div className="grid grid-cols-[1fr_1fr] gap-6">
            <div className={panel_classes() + " p-6"}>
                <p className="text-sm font-semibold text-slate-500">Workspace settings</p>
                <h1 className="mt-1 text-3xl font-semibold tracking-[-0.04em] text-slate-950">Operational configuration</h1>
            </div>
            <div className={panel_classes() + " p-6"}>
                <p className="text-sm font-semibold text-slate-500">Integration readiness</p>
                <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">Twilio-ready architecture</h2>
            </div>
        </div>
    );
}
