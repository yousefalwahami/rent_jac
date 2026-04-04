"""
<<<<<<< HEAD
Imports server-side symbols and mounts the client app.
"""

import from services.appService { greet, send_test_sms, twilio_webhook }

=======
Rentora entry point.
"""

cl import ".styles.global.css";
>>>>>>> 9e70e4e (Polish Rentora frontend experience)
cl import from .index { ClientApp }

cl {
    def:pub app() -> JsxElement {
        return <ClientApp />;
    }
}
