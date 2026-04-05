"""Seed walker: populates the demo graph with Palm Court Apartments."""

import from services.graph.models {
    Property, Unit, Lease, Tenant, Ticket, Vendor,
    HasUnit, HasLease, HasTenant, HasTicket, Services
}


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

        # Unit 1A
        lease_1a = Lease(
            start_date="2025-08-01", end_date="2026-07-31",
            rent_amount=1200.0, deposit=1200.0
        );
        unit_1a +>: HasLease :+> lease_1a;
        lease_1a +>: HasTenant :+> Tenant(
            name="Alex Rivera", phone="+17345550101",
            email="alex.r@email.com", payment_status="current",
            move_in_date="2025-08-01"
        );

        # Unit 2A
        lease_2a = Lease(
            start_date="2025-06-01", end_date="2026-05-31",
            rent_amount=1600.0, deposit=1600.0
        );
        unit_2a +>: HasLease :+> lease_2a;
        lease_2a +>: HasTenant :+> Tenant(
            name="Priya Patel", phone="+17345550102",
            email="priya.p@email.com", payment_status="current",
            move_in_date="2025-06-01"
        );

        # Unit 3B (tenant late on rent)
        lease_3b = Lease(
            start_date="2025-01-15", end_date="2026-01-14",
            rent_amount=1800.0, deposit=1800.0
        );
        unit_3b +>: HasLease :+> lease_3b;
        lease_3b +>: HasTenant :+> Tenant(
            name="Marcus Johnson", phone="+17345550103",
            email="marcus.j@email.com", payment_status="late",
            move_in_date="2025-01-15"
        );

        # Unit 4B
        lease_4b = Lease(
            start_date="2025-09-01", end_date="2026-08-31",
            rent_amount=1300.0, deposit=1300.0
        );
        unit_4b +>: HasLease :+> lease_4b;
        lease_4b +>: HasTenant :+> Tenant(
            name="Sarah Chen", phone="+17345550104",
            email="sarah.c@email.com", payment_status="current",
            move_in_date="2025-09-01"
        );

        # Vendors
        prop +>: Services(jobs_completed=5, total_spent=890.0) :+> Vendor(
            name="Mike's HVAC", category="hvac",
            phone="+17345550201", email="mike@mikeshvac.com",
            rating=4.7, avg_cost=180.0
        );
        prop +>: Services(jobs_completed=3, total_spent=520.0) :+> Vendor(
            name="Quick Flow Plumbing", category="plumbing",
            phone="+17345550202", email="info@quickflow.com",
            rating=4.5, avg_cost=150.0
        );
        prop +>: Services(jobs_completed=2, total_spent=340.0) :+> Vendor(
            name="Spark Electric Co", category="electrical",
            phone="+17345550203", email="jobs@sparkelectric.com",
            rating=4.8, avg_cost=200.0
        );

        # Past maintenance history on Unit 2A (shows graph reasoning for repeat HVAC)
        unit_2a +>: HasTicket :+> Ticket(
            ticket_id="TKT-001", category="hvac",
            description="AC not cooling properly", urgency="medium",
            status="resolved", ai_summary="AC unit underperforming, refrigerant low",
            created_at="2025-10-15", resolved_at="2025-10-16",
            vendor_name="Mike's HVAC", estimated_cost=180.0
        );
        unit_2a +>: HasTicket :+> Ticket(
            ticket_id="TKT-002", category="hvac",
            description="Heater making loud noise", urgency="high",
            status="resolved", ai_summary="Blower motor bearing failure",
            created_at="2026-01-20", resolved_at="2026-01-21",
            vendor_name="Mike's HVAC", estimated_cost=220.0
        );

        report {
            "status": "seeded",
            "property": "Palm Court Apartments",
            "units": 4, "tenants": 4, "vendors": 3, "past_tickets": 2
        };
    }
}
