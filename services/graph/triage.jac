"""Triage walker: classifies inbound events and routes to handlers."""

import from services.graph.models {
    Property, Unit, Lease, Tenant,
    HasUnit, HasLease, HasTenant
}
import from services.graph.ai { classify_event, EventType }
import from services.graph.maintenance { handle_maintenance }


walker triage {
    has message: str = "";
    has sender_phone: str = "";
    has _property_name: str = "";
    has _unit_number: str = "";
    has _unit_ref: any = None;
    has _found: bool = False;

    can start with Root entry {
        visit : 0 : [-->][?:Property];
    }

    can at_property with Property entry {
        if not self._found {
            self._property_name = here.name;
            visit : 0 : [->: HasUnit :->];
        }
    }

    can at_unit with Unit entry {
        if not self._found {
            self._unit_number = here.number;
            self._unit_ref = here;
            visit : 0 : [->: HasLease :->];
        }
    }

    can at_lease with Lease entry {
        if not self._found {
            visit : 0 : [->: HasTenant :->];
        }
    }

    can at_tenant with Tenant entry {
        if not self._found and here.phone == self.sender_phone {
            self._found = True;

            classification = classify_event(self.message);

            if classification == EventType.MAINTENANCE {
                result = self._unit_ref spawn handle_maintenance(
                    message=self.message,
                    tenant_name=here.name,
                    tenant_phone=here.phone,
                    property_name=self._property_name
                );
                report {
                    "status": "processed",
                    "event_type": "maintenance",
                    "tenant": here.name,
                    "property": self._property_name,
                    "unit": self._unit_number,
                    "result": result.reports[0] if result.reports else None
                };
            } else {
                report {
                    "status": "classified",
                    "event_type": str(classification).split(".")[-1].lower(),
                    "tenant": here.name,
                    "property": self._property_name,
                    "unit": self._unit_number,
                    "message": self.message
                };
            }

            disengage;
        }
    }

    can finish with Root exit {
        if not self._found {
            report {
                "status": "tenant_not_found",
                "phone": self.sender_phone,
                "message": self.message
            };
        }
    }
}
