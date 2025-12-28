import uuid
import random

class PaypackPayment:
    """
    A MOCK payment class for development.
    It does NOT connect to the internet.
    It always returns 'success' so you can test your App UI.
    """
    
    def __init__(self):
        pass

    def trigger_momo_pay(self, phone_number, amount):
        print(f"\n💳 [MOCK PAYMENT] Initiating payment for {phone_number}")
        print(f"💰 [MOCK PAYMENT] Amount: {amount} RWF")

        # Simulate a success response
        # We generate a random fake transaction ID like "MOCK-892384"
        fake_ref = f"MOCK-{random.randint(100000, 999999)}"

        print(f"✅ [MOCK PAYMENT] Success! Ref: {fake_ref}\n")

        return {
            "success": True,
            "ref": fake_ref,
            "message": "Payment simulation successful"
        }