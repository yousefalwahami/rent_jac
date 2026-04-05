"""
Rentora entry point.
Imports server-side symbols and mounts the client app.
"""

import from services.appService { greet, send_test_sms, twilio_webhook, get_messages, get_twilio_number, set_alert_number, send_sms, delete_message }
import from services.profileService { get_profile, update_profile }
import from services.dataService { get_properties, get_tenants, add_property, add_tenant, update_property, delete_property, update_tenant, delete_tenant }
import from services.graphService {
    Property, Unit, Lease, Tenant, Ticket, Vendor,
    HasUnit, HasLease, HasTenant, HasTicket, Services, AssignedTo,
    seed_graph, list_properties, list_units, list_tickets, list_vendors,
    triage, handle_maintenance, approve_dispatch, resolve_ticket,
    register_tenant, db_health
}
cl import ".styles.global.css";
cl import from .index { ClientApp }

cl {
    def:pub app() -> JsxElement {
        return <ClientApp />;
    }
}
