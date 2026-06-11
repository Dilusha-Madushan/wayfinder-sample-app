# Wayfinder — CIBA Upgrade Try-Out Guide

This guide walks you through running the Wayfinder sample end-to-end, focused on the **CIBA flight upgrade** feature. The upgrade flow uses backchannel authentication — a background agent requests approval from the customer via an email or SMS notification, and the customer approves it on their own device without the agent needing to interact with a browser.

> **Demo scripts** are located in the `scripts/` folder at the root of the sample (`scripts/unlock-business-class.sh`, `scripts/reset-db.sh`). Run them from the sample root directory.

---

## Set Your LLM API Key

Before starting, open `ai-agent/.env` and set your LLM API key:

```env
# Anthropic Claude (default)
ANTHROPIC_API_KEY=sk-ant-...

# — OR — Google Gemini
# LLM_PROVIDER=gemini
# GOOGLE_API_KEY=...
```

If the file does not exist yet, copy it from the example first:

```bash
cp ai-agent/.env.example ai-agent/.env
```

---

## Run the Sample

Start each service from the sample root in separate terminals:

```bash
cd backend  && npm install && npm run seed && npm start   # http://localhost:8787
cd ai-agent && npm install && npm start                   # http://localhost:8790
cd frontend && npm install && npm run dev                 # http://localhost:5173
```

> Run `npm run seed` only on first setup — it initialises the database with sample flights.

Once all three services are running, open [http://localhost:5173](http://localhost:5173) in your browser and follow the steps below.

---

## Prerequisites

- **Node.js 20+**
- A real **email address** you can receive messages on (for the CIBA notification)
- An **LLM API key** — Anthropic Claude or Google Gemini

> **SMS in the sample environment:** Instead of a real mobile number, SMS notifications are routed to a webhook. You can view them at [webhook.site](https://webhook.site/#!/view/bc82f64f-49aa-40af-8986-c7b572c87e7f/a1a50a01-9b3b-41ab-8df3-98eae3b56358/1) (If this is already expired then you have to add notification provider into thunder and thunder back-end apis already support this sms provider add/update features. [thunder doc reference](https://thunderid.dev/docs/next/guides/guides/notifications/sms-providers/))

---

## Step 1 — Configure the AI Agent

Copy `ai-agent/.env.example` to `ai-agent/.env` and set your LLM API key:

```env
# Anthropic Claude (default)
ANTHROPIC_API_KEY=sk-ant-...

# — OR — Google Gemini
# LLM_PROVIDER=gemini
# GOOGLE_API_KEY=...
```

Everything else in the example already matches the default ThunderID configuration.

---

## Step 2 — Start the Sample

Run each service from the sample root (three terminals):

```bash
cd backend  && npm install && npm run seed && npm start   # http://localhost:8787
cd ai-agent && npm install && npm start                   # http://localhost:8790
cd frontend && npm install && npm run dev                 # http://localhost:5173
```

`npm run seed` initialises the SQLite database with sample flights and a pre-seeded booking — run it once on first setup.

---

## Step 3 — Sign Up

Open the Wayfinder app in your browser and click **Sign In**. On the sign-in page, click **Sign Up** to create a new account. Fill in your details and complete registration. After a successful sign-up, the app navigates you to the home page.

---

## Step 4 — Sign In

From the home page, click **Sign In** and log in with the credentials you just created.

---

## Step 5 — Book an Economy Flight

Open the **Chat** window and ask the Wayfinder concierge about available flights:

```
Show me flights from Colombo to Dubai
```

The agent returns a list of **Economy class** options. Business class seats are marked unavailable for this demo at this stage.

Pick one of the Economy flights and ask to book it:

```
Book <flight-id> for me
```

The agent needs to act on your behalf and will ask for your permission. A consent dialog opens — approve it to grant the agent access to create bookings. Once you approve, the booking is confirmed and the agent remembers this access for the remainder of the session.

---

## Step 6 — Check Your Booking

Ask the agent to show your bookings:

```
Show me my bookings
```

Confirm the Economy class booking appears in the list.

---

## Step 7 — Request an Upgrade

Ask the agent about upgrading your booking:

```
I'd like to upgrade my Colombo to Dubai booking to Business class. What are my options?
```

The agent shows the available Business class alternatives but notes they are currently **unavailable**. Ask the agent to submit an upgrade request anyway:

```
Please submit an upgrade request for me
```

When the agent asks for confirmation, reply **Yes**. The request is submitted and put into a pending state.

---

## Step 8 — Unlock Business Class

Go to the **Scripts** section in the app and run the **unlock-business-class** script. This marks all Business class seats as available and triggers the upgrade scheduler, which picks up your pending request and initiates a **CIBA backchannel authentication** to get your approval.

Within a few minutes a notification is sent to you:

- **Email** — an approval link is sent to your registered email address.
- **SMS** — a short link is sent to your mobile number. In the test environment, SMS messages are forwarded to a webhook instead of a real number.

---

## Step 9 — Approve the Upgrade

**Recommended: use the email link.**

Open the email from Wayfinder. It contains:
- The app name (**WAYFINDER-UPGRADE-AGENT**)
- A message describing the upgrade request
- An **Approve Authentication** link

Click the link — it opens the approval page. Log in if prompted, then click **Approve** to grant the `upgrade:process` permission. The page confirms **Authentication Successful**.

> The CIBA request expires after **5 minutes**. If the link has expired, go back to the Scripts section and run the unlock-business-class script again to trigger a fresh request.

---

## Step 10 — Verify the Upgrade

Navigate to the **Bookings** page in the app (or refresh it if you are already there). The Economy class booking now shows as **Business class** — the upgrade was applied automatically after your approval.

---

## Resetting the Demo

To run the try-out again from scratch, go to the **Scripts** section in the app and run the **reset-db** script. This deletes the SQLite database and re-seeds it with the original sample data — Economy class booking confirmed, all Business class flights unavailable.

You can also run it directly from the terminal:

```bash
bash scripts/reset-db.sh
```

After resetting, sign out of the app and repeat from Step 3.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| No email received | Verify the email address registered during sign-up is correct and check your spam folder |
| CIBA link says "expired" | Re-run the unlock-business-class script from the Scripts section to trigger a new request |
| Consent screen doesn't appear on second run | Expected — the app remembers the previous consent decision |
| Agent returns an error on booking | The consent dialog was closed without approving — retry the booking message |
| SMS not received | In the test environment, SMS messages go to the webhook; check the webhook dashboard instead |
