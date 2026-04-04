cl import from shared { IncidentRecord, panel_classes }

def:pub demo_mode_view(incidents: list, selected: IncidentRecord, set_selected: any, scenario: str, set_scenario: any, incoming_text: str, set_incoming_text: any, demo_stage: int, set_demo_stage: any) -> JsxElement {
    scenario_message = "The sink in Unit 4B is leaking and water is getting on the floor.";
    progress_width = "w-full";

    return (
        <div className="grid grid-cols-[1fr_1fr] gap-6">
            <div className="space-y-6">
                <div className={panel_classes() + " p-6"}>
                    <p className="text-sm font-semibold text-slate-500">Demo mode</p>
                    <h1 className="mt-1 text-3xl font-semibold tracking-[-0.04em] text-slate-950">Simulate inbound tenant texts</h1>
                </div>
            </div>
            <div className="space-y-6">
                <div className={panel_classes() + " p-6"}>
                    <p className="text-sm font-semibold text-slate-500">Scenario preview</p>
                    <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">{scenario}</h2>
                    <div className="mt-5 rounded-[24px] bg-slate-950 p-5 text-white">
                        <p className="text-xs uppercase tracking-[0.12em] text-white/50">Sample inbound text</p>
                        <p className="mt-3 text-base leading-7">{scenario_message}</p>
                    </div>
                </div>
            </div>
        </div>
    );
}
