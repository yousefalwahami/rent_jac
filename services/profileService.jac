node UserProfile {
    has phone_number: str = "";
}

walker get_profile {
    can read with Root entry {
        profiles = [-->[?:UserProfile]];
        if profiles {
            report {"phone_number": profiles[0].phone_number};
        } else {
            here ++> UserProfile();
            report {"phone_number": ""};
        }
    }
}

walker update_profile {
    has phone_number: str;

    can write with Root entry {
        profiles = [-->[?:UserProfile]];
        if profiles {
            profiles[0].phone_number = self.phone_number;
        } else {
            here ++> UserProfile(phone_number=self.phone_number);
        }
        report {"success": True, "phone_number": self.phone_number};
    }
}
