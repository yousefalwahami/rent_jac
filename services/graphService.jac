"""PropOS Graph Service
Core graph model: nodes, edges, enums, AI functions, and walkers.
"""

import from datetime { datetime }


# ── Enums ────────────────────────────────────────────────────

enum EventType {
    MAINTENANCE,
    PAYMENT,
    LEASE,
    COMPLAINT,
    INQUIRY
}

sem EventType.MAINTENANCE = "Repairs, broken items, leaks, no heat or AC, water damage, mold";
sem EventType.PAYMENT = "Rent payments, billing, late fees, payment plans";
sem EventType.LEASE = "Lease terms, renewal, move-in, move-out, lease questions";
sem EventType.COMPLAINT = "Noise, neighbor disputes, common area issues, safety concerns";
sem EventType.INQUIRY = "General questions, information requests, amenity questions";


# ── LLM Return Types ────────────────────────────────────────

obj MaintenanceDiagnosis {
    has category: str;
    has summary: str;
    has urgency: str;
    has recommended_action: str;
}

sem MaintenanceDiagnosis.category = "One of: hvac, plumbing, electrical, appliance, general";
sem MaintenanceDiagnosis.summary = "Brief 1-2 sentence diagnosis of the maintenance issue";
sem MaintenanceDiagnosis.urgency = "One of: low, medium, high, critical";
sem MaintenanceDiagnosis.recommended_action = "Specific recommended next step to resolve the issue";

obj RiskAssessment {
    has level: str;
    has flags: list[str];
    has recommendation: str;
}

sem RiskAssessment.level = "One of: low, moderate, high";
sem RiskAssessment.flags = "List of specific risk factors identified in this situation";
sem RiskAssessment.recommendation = "Brief recommendation considering the risk factors";


# ── LLM Functions ────────────────────────────────────────────

sem classify_event = "Classify a tenant's inbound message into the appropriate event type based on content and intent.";
def classify_event(message: str) -> EventType by llm();

sem diagnose_issue = "Diagnose a maintenance issue from a tenant message. Determine the repair category, severity, and what action to take. Consider safety implications.";
def diagnose_issue(message: str) -> MaintenanceDiagnosis by llm();

sem select_vendor = "Given a maintenance diagnosis and a list of available vendors with their specialties, ratings, and costs, return ONLY the name of the single best vendor for this job.";
def select_vendor(diagnosis: str, available_vendors: str) -> str by llm();

sem assess_risk = "Assess the risk level of a maintenance situation. Consider: repeat incidents on the same unit, tenant payment status, safety hazards, potential property damage.";
def assess_risk(context: str) -> RiskAssessment by llm();

sem draft_tenant_reply = "Draft a brief, professional SMS reply to a tenant who reported a maintenance issue. Acknowledge the problem, give safety advice if needed, and set expectations. Keep under 160 characters.";
def draft_tenant_reply(context: str) -> str by llm();

sem draft_owner_alert = "Draft a concise SMS alert for the property owner about a new maintenance issue. Include unit, issue type, urgency, and recommended vendor with cost. Keep under 200 characters.";
def draft_owner_alert(context: str) -> str by llm();


# ── Nodes ────────────────────────────────────────────────────

node Property {
    has name: str = "";
    has address: str = "";
    has city: str = "";
    has state: str = "";
    has zip_code: str = "";
}

node Unit {
    has number: str = "";
    has bedrooms: int = 1;
    has bathrooms: int = 1;
    has sq_ft: int = 0;
    has status: str = "occupied";
}

node Lease {
    has start_date: str = "";
    has end_date: str = "";
    has rent_amount: float = 0.0;
    has deposit: float = 0.0;
    has status: str = "active";
}

node Tenant {
    has name: str = "";
    has phone: str = "";
    has email: str = "";
    has payment_status: str = "current";
    has move_in_date: str = "";
}

node Ticket {
    has ticket_id: str = "";
    has category: str = "";
    has description: str = "";
    has urgency: str = "medium";
    has status: str = "open";
    has ai_summary: str = "";
    has ai_diagnosis: str = "";
    has recommended_action: str = "";
    has tenant_reply: str = "";
    has owner_alert: str = "";
    has created_at: str = "";
    has resolved_at: str = "";
    has vendor_name: str = "";
    has estimated_cost: float = 0.0;
}

node Vendor {
    has name: str = "";
    has category: str = "";
    has phone: str = "";
    has email: str = "";
    has rating: float = 0.0;
    has avg_cost: float = 0.0;
    has available: bool = True;
}


# ── Edges ────────────────────────────────────────────────────

edge HasUnit {}
edge HasLease {}
edge HasTenant {}
edge HasTicket {}

edge Services {
    has jobs_completed: int = 0;
    has total_spent: float = 0.0;
    has last_service_date: str = "";
}

edge AssignedTo {}


# ══════════════════════════════════════════════════════════════
#  WALKERS
# ══════════════════════════════════════════════════════════════

# ── Seed the demo graph ──────────────────────────────────────

walker seed_graph {
    can create with Root entry {
        existing = [-->][?:Property];
        if existing {
            report {"status": "already_seeded", "properties": len(existing)};
            disengage;
        }

        # Property
        prop = Property(
            name="Palm Court Apartments",
            address="123 University Ave",
            city="Ann Arbor",
            state="MI",
            zip_code="48104"
        );
        here ++> prop;

        # Units
        unit_1a = Unit(number="1A", bedrooms=1, bathrooms=1, sq_ft=650);
        unit_2a = Unit(number="2A", bedrooms=2, bathrooms=1, sq_ft=900);
        unit_3b = Unit(number="3B", bedrooms=2, bathrooms=2, sq_ft=1100);
        unit_4b = Unit(number="4B", bedrooms=1, bathrooms=1, sq_ft=700);
        prop +>: HasUnit :+> unit_1a;
        prop +>: HasUnit :+> unit_2a;
        prop +>: HasUnit :+> unit_3b;
        prop +>: HasUnit :+> unit_4b;

        # Unit 1A — Lease + Tenant
        lease_1a = Lease(
            start_date="2025-08-01", end_date="2026-07-31",
            rent_amount=1200.0, deposit=1200.0
        );
        unit_1a +>: HasLease :+> lease_1a;
        tenant_1a = Tenant(
            name="Alex Rivera", phone="+17345550101",
            email="alex.r@email.com", payment_status="current",
            move_in_date="2025-08-01"
        );
        lease_1a +>: HasTenant :+> tenant_1a;

        # Unit 2A — Lease + Tenant
        lease_2a = Lease(
            start_date="2025-06-01", end_date="2026-05-31",
            rent_amount=1600.0, deposit=1600.0
        );
        unit_2a +>: HasLease :+> lease_2a;
        tenant_2a = Tenant(
            name="Priya Patel", phone="+17345550102",
            email="priya.p@email.com", payment_status="current",
            move_in_date="2025-06-01"
        );
        lease_2a +>: HasTenant :+> tenant_2a;

        # Unit 3B — Lease + Tenant (late on rent)
        lease_3b = Lease(
            start_date="2025-01-15", end_date="2026-01-14",
            rent_amount=1800.0, deposit=1800.0
        );
        unit_3b +>: HasLease :+> lease_3b;
        tenant_3b = Tenant(
            name="Marcus Johnson", phone="+17345550103",
            email="marcus.j@email.com", payment_status="late",
            move_in_date="2025-01-15"
        );
        lease_3b +>: HasTenant :+> tenant_3b;

        # Unit 4B — Lease + Tenant
        lease_4b = Lease(
            start_date="2025-09-01", end_date="2026-08-31",
            rent_amount=1300.0, deposit=1300.0
        );
        unit_4b +>: HasLease :+> lease_4b;
        tenant_4b = Tenant(
            name="Sarah Chen", phone="+17345550104",
            email="sarah.c@email.com", payment_status="current",
            move_in_date="2025-09-01"
        );
        lease_4b +>: HasTenant :+> tenant_4b;

        # Vendors
        vendor_hvac = Vendor(
            name="Mike's HVAC", category="hvac",
            phone="+17345550201", email="mike@mikeshvac.com",
            rating=4.7, avg_cost=180.0
        );
        prop +>: Services(jobs_completed=5, total_spent=890.0) :+> vendor_hvac;

        vendor_plumbing = Vendor(
            name="Quick Flow Plumbing", category="plumbing",
            phone="+17345550202", email="info@quickflow.com",
            rating=4.5, avg_cost=150.0
        );
        prop +>: Services(jobs_completed=3, total_spent=520.0) :+> vendor_plumbing;

        vendor_electrical = Vendor(
            name="Spark Electric Co", category="electrical",
            phone="+17345550203", email="jobs@sparkelectric.com",
            rating=4.8, avg_cost=200.0
        );
        prop +>: Services(jobs_completed=2, total_spent=340.0) :+> vendor_electrical;

        # Past maintenance history on Unit 2A (HVAC repeat issue — shows graph reasoning)
        ticket_1 = Ticket(
            ticket_id="TKT-001", category="hvac",
            description="AC not cooling properly", urgency="medium",
            status="resolved", ai_summary="AC unit underperforming, refrigerant low",
            created_at="2025-10-15", resolved_at="2025-10-16",
            vendor_name="Mike's HVAC", estimated_cost=180.0
        );
        unit_2a +>: HasTicket :+> ticket_1;

        ticket_2 = Ticket(
            ticket_id="TKT-002", category="hvac",
            description="Heater making loud noise", urgency="high",
            status="resolved", ai_summary="Blower motor bearing failure",
            created_at="2026-01-20", resolved_at="2026-01-21",
            vendor_name="Mike's HVAC", estimated_cost=220.0
        );
        unit_2a +>: HasTicket :+> ticket_2;

        report {
            "status": "seeded",
            "property": "Palm Court Apartments",
            "units": 4,
            "tenants": 4,
            "vendors": 3,
            "past_tickets": 2
        };
    }
}


# ── CRUD Walkers ─────────────────────────────────────────────

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


# ── Triage Walker ────────────────────────────────────────────
# Receives an inbound message + phone, finds the tenant in the
# graph, classifies the event, and routes to the correct handler.

walker triage {
    has message: str = "";
    has sender_phone: str = "";
    has property_name: str = "";
    has unit_number: str = "";
    has unit_ref: any = None;
    has found: bool = False;

    can start with Root entry {
        visit : 0 : [-->][?:Property];
    }

    can at_property with Property entry {
        if not self.found {
            self.property_name = here.name;
            visit : 0 : [->: HasUnit :->];
        }
    }

    can at_unit with Unit entry {
        if not self.found {
            self.unit_number = here.number;
            self.unit_ref = here;
            visit : 0 : [->: HasLease :->];
        }
    }

    can at_lease with Lease entry {
        if not self.found {
            visit : 0 : [->: HasTenant :->];
        }
    }

    can at_tenant with Tenant entry {
        if not self.found and here.phone == self.sender_phone {
            self.found = True;

            # Classify the inbound message
            classification = classify_event(self.message);

            if classification == EventType.MAINTENANCE {
                # Spawn maintenance handler on the unit
                result = self.unit_ref spawn handle_maintenance(
                    message=self.message,
                    tenant_name=here.name,
                    tenant_phone=here.phone,
                    property_name=self.property_name
                );
                report {
                    "status": "processed",
                    "event_type": "maintenance",
                    "tenant": here.name,
                    "property": self.property_name,
                    "unit": self.unit_number,
                    "result": result.reports[0] if result.reports else None
                };
            } else {
                report {
                    "status": "classified",
                    "event_type": str(classification).split(".")[-1].lower(),
                    "tenant": here.name,
                    "property": self.property_name,
                    "unit": self.unit_number,
                    "message": self.message
                };
            }

            disengage;
        }
    }

    can finish with Root exit {
        if not self.found {
            report {
                "status": "tenant_not_found",
                "phone": self.sender_phone,
                "message": self.message
            };
        }
    }
}


# ── Maintenance Handler ──────────────────────────────────────
# Spawned on a Unit node. Diagnoses the issue, traverses for
# context, selects a vendor, assesses risk, and creates a Ticket.

walker handle_maintenance {
    has message: str = "";
    has tenant_name: str = "";
    has tenant_phone: str = "";
    has property_name: str = "";

    can process with Unit entry {
        # 1. Diagnose the issue via LLM
        diagnosis = diagnose_issue(self.message);

        # 2. Count past tickets in this category (graph reasoning)
        past_tickets = [->: HasTicket :->];
        same_cat_count = len([
            t for t in past_tickets if t.category == diagnosis.category
        ]);

        # 3. Get tenant payment status via lease traversal
        payment_status = "unknown";
        lease_nodes = [->: HasLease :->];
        if lease_nodes {
            tenant_nodes = [lease_nodes[0] ->: HasTenant :->];
            if tenant_nodes {
                payment_status = tenant_nodes[0].payment_status;
            }
        }

        # 4. Traverse up to property, then to vendor graph
        prop_nodes = [<--][?:Property];
        prop = prop_nodes[0] if prop_nodes else None;
        vendors_info = "";
        vendor_list: list = [];
        if prop {
            vendor_nodes = [prop ->: Services :->];
            for v in vendor_nodes {
                vendor_list.append(v);
                vendors_info += (
                    v.name + " | " + v.category
                    + " | Rating: " + str(v.rating)
                    + " | Avg $" + str(v.avg_cost)
                    + " | Available: " + str(v.available) + "\n"
                );
            }
        }

        # 5. Assess risk via LLM
        risk_ctx = (
            "Unit " + here.number + " at " + self.property_name + "\n"
            + "Category: " + diagnosis.category + "\n"
            + "Same-category incidents on this unit: " + str(same_cat_count) + "\n"
            + "Tenant payment status: " + payment_status + "\n"
            + "Urgency: " + diagnosis.urgency + "\n"
            + "Diagnosis: " + diagnosis.summary
        );
        risk = assess_risk(risk_ctx);

        # 6. Select best vendor via LLM
        best_vendor: any = None;
        if vendors_info {
            selected_name = select_vendor(
                diagnosis.summary + " (Category: " + diagnosis.category + ")",
                vendors_info
            );
            for v in vendor_list {
                if v.name in selected_name or selected_name in v.name {
                    best_vendor = v;
                    break;
                }
            }
            # Fallback to first available vendor
            if not best_vendor and vendor_list {
                best_vendor = vendor_list[0];
            }
        }

        # 7. Draft communications via LLM
        comm_ctx = (
            "Property: " + self.property_name + ", Unit: " + here.number + "\n"
            + "Tenant: " + self.tenant_name + "\n"
            + "Issue: " + diagnosis.summary + "\n"
            + "Urgency: " + diagnosis.urgency + "\n"
            + "Risk: " + risk.level
        );
        if best_vendor {
            comm_ctx += "\nVendor: " + best_vendor.name + ", Est: $" + str(best_vendor.avg_cost);
        }

        tenant_sms = draft_tenant_reply(comm_ctx);
        owner_sms = draft_owner_alert(comm_ctx);

        # 8. Create Ticket node on this unit
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
        tid = "TKT-" + datetime.now().strftime("%y%m%d%H%M");

        new_ticket = Ticket(
            ticket_id=tid,
            category=diagnosis.category,
            description=self.message,
            urgency=diagnosis.urgency,
            status="pending_approval",
            ai_summary=diagnosis.summary,
            ai_diagnosis=diagnosis.recommended_action,
            recommended_action=diagnosis.recommended_action,
            tenant_reply=tenant_sms,
            owner_alert=owner_sms,
            created_at=now,
            vendor_name=best_vendor.name if best_vendor else "",
            estimated_cost=best_vendor.avg_cost if best_vendor else 0.0
        );
        here +>: HasTicket :+> new_ticket;

        # 9. Report full result
        report {
            "ticket_id": tid,
            "property": self.property_name,
            "unit": here.number,
            "tenant": self.tenant_name,
            "tenant_phone": self.tenant_phone,
            "category": diagnosis.category,
            "urgency": diagnosis.urgency,
            "diagnosis": diagnosis.summary,
            "recommended_action": diagnosis.recommended_action,
            "risk_level": risk.level,
            "risk_flags": risk.flags,
            "risk_recommendation": risk.recommendation,
            "vendor": best_vendor.name if best_vendor else "none",
            "estimated_cost": best_vendor.avg_cost if best_vendor else 0.0,
            "tenant_reply": tenant_sms,
            "owner_alert": owner_sms,
            "status": "pending_approval",
            "created_at": now
        };
    }
}


# ── Approve & Dispatch ───────────────────────────────────────
# Landlord approves a ticket — updates status to dispatched.

walker approve_dispatch {
    has ticket_id: str = "";

    can start with Root entry {
        visit [-->][?:Property];
    }

    can at_property with Property entry {
        visit [->: HasUnit :->];
    }

    can at_unit with Unit entry {
        tickets = [->: HasTicket :->];
        for t in tickets {
            if t.ticket_id == self.ticket_id {
                t.status = "dispatched";
                report {
                    "ticket_id": t.ticket_id,
                    "status": "dispatched",
                    "vendor_name": t.vendor_name,
                    "unit": here.number,
                    "tenant_reply": t.tenant_reply,
                    "owner_alert": t.owner_alert,
                    "estimated_cost": t.estimated_cost
                };
                disengage;
            }
        }
    }
}


# ── Resolve Ticket ───────────────────────────────────────────

walker resolve_ticket {
    has ticket_id: str = "";

    can start with Root entry {
        visit [-->][?:Property];
    }

    can at_property with Property entry {
        visit [->: HasUnit :->];
    }

    can at_unit with Unit entry {
        tickets = [->: HasTicket :->];
        for t in tickets {
            if t.ticket_id == self.ticket_id {
                t.status = "resolved";
                t.resolved_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
                report {
                    "ticket_id": t.ticket_id,
                    "status": "resolved",
                    "resolved_at": t.resolved_at
                };
                disengage;
            }
        }
    }
}
