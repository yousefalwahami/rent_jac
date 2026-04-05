"""CRUD walkers: read-only graph queries for the dashboard."""

import from services.graph.models {
    Property, Unit, Lease, Tenant, Ticket, Vendor,
    HasUnit, HasLease, HasTenant, HasTicket, Services
}


walker list_properties {
    can list_all with Root entry {
        properties = [-->][?:Property];
        result = [];
        for p in properties {
            units = [p ->: HasUnit :->];
            result.append({
                "id": jid(p),
                "name": p.name,
                "address": p.address,
                "city": p.city,
                "state": p.state,
                "unit_count": len(units)
            });
        }
        report result;
    }
}


walker list_units {
    can start with Root entry {
        visit [-->][?:Property];
    }

    can gather with Property entry {
        units = [->: HasUnit :->];
        for u in units {
            leases = [u ->: HasLease :->];
            lease = leases[0] if leases else None;
            tenant = None;
            if lease {
                tenants = [lease ->: HasTenant :->];
                tenant = tenants[0] if tenants else None;
            }
            tickets = [u ->: HasTicket :->];
            open_tickets = [t for t in tickets if t.status != "resolved" and t.status != "closed"];

            report {
                "id": jid(u),
                "unit": u.number,
                "bedrooms": u.bedrooms,
                "bathrooms": u.bathrooms,
                "sq_ft": u.sq_ft,
                "status": u.status,
                "property": here.name,
                "tenant": tenant.name if tenant else None,
                "tenant_phone": tenant.phone if tenant else None,
                "payment_status": tenant.payment_status if tenant else None,
                "rent": lease.rent_amount if lease else None,
                "lease_end": lease.end_date if lease else None,
                "open_tickets": len(open_tickets),
                "total_tickets": len(tickets)
            };
        }
    }
}


walker list_tickets {
    can start with Root entry {
        visit [-->][?:Property];
    }

    can at_property with Property entry {
        visit [->: HasUnit :->];
    }

    can at_unit with Unit entry {
        tickets = [->: HasTicket :->];
        for t in tickets {
            report {
                "id": jid(t),
                "ticket_id": t.ticket_id,
                "unit": here.number,
                "category": t.category,
                "description": t.description,
                "urgency": t.urgency,
                "status": t.status,
                "ai_summary": t.ai_summary,
                "recommended_action": t.recommended_action,
                "vendor_name": t.vendor_name,
                "estimated_cost": t.estimated_cost,
                "tenant_reply": t.tenant_reply,
                "owner_alert": t.owner_alert,
                "created_at": t.created_at,
                "resolved_at": t.resolved_at
            };
        }
    }
}


walker list_vendors {
    can start with Root entry {
        visit [-->][?:Property];
    }

    can at_property with Property entry {
        vendors = [->: Services :->];
        for v in vendors {
            report {
                "id": jid(v),
                "name": v.name,
                "category": v.category,
                "phone": v.phone,
                "rating": v.rating,
                "avg_cost": v.avg_cost,
                "available": v.available,
                "property": here.name
            };
        }
    }
}
