import from os { getcwd, getenv }
import from os.path { join }
import from sqlite3 { connect }

node UserProfile {
    has phone_number: str = "";
    has name: str = "";
}

walker get_profile {
    can read with Root entry {
        email = "";
        try {
            root_uuid = str(here.__jac__.id).replace("-", "");
            db_path = join(getcwd(), ".jac", "data", "main.db");
            conn = connect(db_path);
            row = conn.execute(
                "SELECT username FROM users WHERE root_id = ?", (root_uuid,)
            ).fetchone();
            email = row[0] if row else "";
            conn.close();
        } except Exception {
            email = "";
        }

        profiles = [-->[?:UserProfile]];
        if profiles {
            report {
                "email": email,
                "phone_number": profiles[0].phone_number if profiles[0].phone_number else (getenv("TWILIO_TARGET_PHONE_NUMBER") or ""),
                "name": profiles[0].name if profiles[0].name else (getenv("OWNER_NAME") or "")
            };
        } else {
            here ++> UserProfile();
            report {
                "email": email,
                "phone_number": getenv("TWILIO_TARGET_PHONE_NUMBER") or "",
                "name": getenv("OWNER_NAME") or ""
            };
        }
    }
}

walker update_profile {
    has phone_number: str = "";
    has name: str = "";

    can write with Root entry {
        profiles = [-->[?:UserProfile]];
        if profiles {
            profiles[0].phone_number = self.phone_number;
            profiles[0].name = self.name;
        } else {
            here ++> UserProfile(phone_number=self.phone_number, name=self.name);
        }
        report {"success": True, "phone_number": self.phone_number, "name": self.name};
    }
}
