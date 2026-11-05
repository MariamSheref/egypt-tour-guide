# Payment setup (Paymob — Egypt)

The UI includes **illustrative** Explorer/Family/Premium prices (99/199/299 EGP) and **30-day manual renewal**. This does **not** implement automatic recurring subscriptions. Checkout buttons stay disabled until the backend reports configuration.

1. Create a Paymob merchant account and select **test mode**. Obtain test Secret Key, Public Key, Integration ID, and webhook HMAC Secret; keep keys private.
2. Deploy the FastAPI server behind **public HTTPS** and set `PUBLIC_BACKEND_URL` to that origin. Paymob cannot call a localhost webhook.
3. Populate environment variables described in `backend/.env.example` using your deployment's secret manager (backend does not automatically load `.env`). Do **not** commit `.env`.
4. Install `pip install -r backend/requirements.txt`, run backend with `uvicorn main:app --host 0.0.0.0 --port 8000` from the backend folder, and ensure your payment webhook is publicly reachable.
5. `POST /payments/checkout` creates an intention via Paymob; Flutter opens Hosted Unified Checkout. Only a Paymob HMAC-SHA512-verified **POST /payments/webhook** may mark an order paid. `GET /payments/orders/{id}` shows verified status.
6. Verify Paymob webhook field format and test successful and failed/duplicate callbacks **before** enabling real funds. For production, use managed auth and an account-bound entitlements service, user-visible refunds/cancellation terms and app store policy review. Current order-reference status page is **not** a full history or entitlement check.
7. Android emulator needs `10.0.2.2` in Flutter service instead of `localhost`; real phones and deployed web need a server URL. Configure CORS and HTTPS correctly.
8. For digital features distributed through Google Play / Apple App Store, investigate mandatory in-app billing rules and permitted exceptions before deployment. Hosted checkout may not be an allowed purchase mechanism for your distribution channel.

Official refs: https://developers.paymob.com/paymob-docs/intention-apis/create-intention and https://developers.paymob.com/paymob-docs/developers/transaction-callbacks

Images: 84 **distinct illustrated preview assets** are bundled as offline fallbacks, not real landmark photographs. Where online Wikipedia returns an **exact-title** image, the app uses it; otherwise fallback artwork displays. Before production, curate verified landmark photos and licenses, use exact IDs or locally licensed assets, and provide required attribution.

## Egyptian and international visitors (November 2026)

- The visitor can choose Egyptian or International on the Questionnaire. The planner estimates admission using the corresponding EGP adult columns in `backend/places.csv`. This is **not** the subscription checkout; ticket purchase takes place directly on each venue's official website.
- **Paymob hosted checkout** is a useful option for a merchant operating in Egypt: ask Paymob to enable Visa/Mastercard international transactions and local Egyptian mobile wallets on your merchant account. Method availability depends on the account, payment integration ID, country, and customer card. See https://developers.paymob.com/paymob-docs/payments-and-features/payment-methods .
- The bundled subscription checkout charges in **EGP** and requires merchant credentials, a public HTTPS webhook URL, server-side verification and manual testing. It does **not** automatically renew, and subscription access is **not** enforced in the app yet. Do not charge live users before entitlements, refund policies, terms and authentication are implemented.
- If the monthly plans unlock *digital in-app features* on an App Store / Google Play distributed mobile app, consult platform billing requirements: Apple's in-app purchase rules https://developer.apple.com/app-store/review/guidelines/ and Google's billing policy https://support.google.com/googleplay/android-developer/answer/9858738 . Paymob alone may not be compliant for those purchases. Different rules apply to real-world services consumed outside the app.
- Do not conflate the platform's 30-day subscription payment with official attraction tickets; these are **separate purchases** with potentially different visitor prices.

## Replace a visited stop

The Recommendation page can mark a site visited and regenerate the entire trip from the *same* origin coordinates, budget, period, visitor type and time constraints. The API receives `excluded_places`, which removes those places from the candidate pool. Visited places persist only while the current Recommendation screen is open; sign-in and server persistence are not included yet. If no alternative route fits, the original route is retained with an explanation.

## Verified booking links

The audited per-place official ticket links live in `backend/booking_links.py` and `lib/data/official_booking_links.dart`, with a corresponding `Verified Ticket Booking URL` column in `backend/places.csv`. No booking button appears for free attractions, or where an official online ticket page cannot be confidently matched. A bundled/zone ticket may be shared between several sites; this is not a separate ticket for each part of the complex. The official booking portal is independent of your own subscription checkout.

Known official booking channels: https://www.egymonuments.com/locations and https://tickets.gem.eg/ . Always reconfirm prices, visitor eligibility and ticket types on the destination's page.
