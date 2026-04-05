"""Foursquare Places API client for live vendor discovery."""

import from os { getenv }
import from dotenv { load_dotenv }
import from requests { get as http_get }

# Map maintenance categories → Foursquare search queries
glob _CATEGORY_QUERY: dict = {
    "hvac":       "HVAC air conditioning heating contractor",
    "plumbing":   "plumber plumbing service",
    "electrical": "electrician electrical contractor",
    "appliance":  "appliance repair service",
    "general":    "handyman general contractor"
};

# Foursquare price tier (1–4) → estimated job cost in USD
glob _PRICE_COST: dict = {1: 90.0, 2: 150.0, 3: 250.0, 4: 380.0};

# Fallback city used when the property has no city/state stored
glob _DEFAULT_NEAR: str = "Toronto, ON";


def fetch_vendors_near(category: str, near: str) -> list {
    #*Query Foursquare for contractors near a location.
    Returns a list of dicts: {name, category, phone, rating, avg_cost}.
    Returns [] on any error or if key is missing.
    *#
    load_dotenv();
    api_key = getenv("FOURSQUARE_SERVICE_KEY");
    if not api_key {
        print("[foursquare] FOURSQUARE_SERVICE_KEY not set — skipping live vendor lookup");
        return [];
    }

    query    = _CATEGORY_QUERY.get(category.lower(), category + " contractor");
    location = near if (near and len(near) > 4) else _DEFAULT_NEAR;

    print("[foursquare] querying '" + query + "' near '" + location + "'");

    try {
        resp = http_get(
            "https://api.foursquare.com/v3/places/search",
            headers={"Authorization": api_key, "Accept": "application/json"},
            params={
                "query":  query,
                "near":   location,
                "limit":  5,
                "fields": "name,categories,tel,rating,price"
            },
            timeout=8
        );

        if resp.status_code != 200 {
            print("[foursquare] HTTP " + str(resp.status_code) + ": " + resp.text);
            return [];
        }

        results = resp.json().get("results", []);
        vendors = [];
        for r in results {
            name = r.get("name", "");
            if not name { continue; }
            phone    = r.get("tel", "") or "";
            # Foursquare rating is 0–10
            raw_rating = r.get("rating", 0.0) or 0.0;
            rating   = round(float(raw_rating) / 2.0, 1);   # convert to 0–5 scale
            price_t  = r.get("price", 2) or 2;
            avg_cost = float(_PRICE_COST.get(int(price_t), 150.0));
            vendors.append({
                "name":     name,
                "category": category,
                "phone":    phone,
                "rating":   rating,
                "avg_cost": avg_cost
            });
        }

        print("[foursquare] found " + str(len(vendors)) + " vendor(s) for category '" + category + "'");
        return vendors;

    } except Exception as e {
        print("[foursquare] error: " + str(e));
        return [];
    }
}
