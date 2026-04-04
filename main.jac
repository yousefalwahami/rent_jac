"""
Rentora entry point.
Imports server-side symbols and mounts the client app.
"""

import from services.appService { greet, send_test_sms, twilio_webhook, get_messages, get_twilio_number, set_alert_number }
import from services.profileService { UserProfile, get_profile, update_profile }
cl import ".styles.global.css";
cl import from .index { ClientApp }

cl {
    def:pub app() -> JsxElement {
        return <ClientApp />;
    }
}
