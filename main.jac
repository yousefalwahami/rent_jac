"""
Imports server-side symbols and mounts the client app.
"""

import from services.appService { greet, send_test_sms, twilio_webhook }

cl import from .index { ClientApp }

cl {
    def:pub app() -> JsxElement {
        return <ClientApp />;
    }
}
