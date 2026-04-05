"""Maintenance walker: diagnoses issues, selects vendors, assesses risk, creates tickets."""

import from datetime { datetime }
import from services.graph.models {
    Property, Unit, Ticket, Vendor,
    HasLease, HasTenant, HasTicket, Services
}
import from services.graph.ai {
    diagnose_issue, select_vendor, assess_risk,
    draft_tenant_reply, draft_owner_alert
}


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

        # 4. Traverse up to property, then across to vendor graph
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

        here +>: HasTicket :+> Ticket(
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
