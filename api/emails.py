# api/emails.py
import threading
from django.core.mail import send_mail
from django.conf import settings

class EmailThread(threading.Thread):
    def __init__(self, subject, message, recipient_list):
        self.subject = subject
        self.message = message
        self.recipient_list = recipient_list
        threading.Thread.__init__(self)

    def run(self):
        send_mail(
            self.subject,
            self.message,
            settings.DEFAULT_FROM_EMAIL,
            self.recipient_list,
            fail_silently=False,
        )

# =====================================================
#  AUTH EMAILS
# =====================================================

def send_welcome_email(user):
    subject = "Welcome to iShare! 🚗✨"
    # Fallback to username if first_name is missing
    name = user.first_name if user.first_name else user.username
    role = user.profile.role if hasattr(user, 'profile') and user.profile.role else 'passenger'
    role_display = 'Driver' if role == 'driver' else 'Passenger'
    
    message = f"""
🎉 Congratulations, {name}!

Welcome to iShare - Rwanda's Smart Carpooling Platform! 🚗

We're thrilled to have you join our community! You have successfully created your account as a {role_display}.

📱 Your Account Details:
   • Username: {user.username}
   • Email: {user.email}
   • Account Type: {role_display}
   
🎁 Special Welcome Offer:
   You're now on a 1-month FREE TRIAL! Enjoy unlimited access to:
   • Post rides (for drivers)
   • Book seats (for passengers)
   • Connect with verified users
   • Save money on every trip

💡 What's Next?
   • Complete your profile to get verified
   • Start posting or booking rides
   • Build your rating and trust score
   • Enjoy safe, affordable travel!

🔐 Security First:
   All our drivers and passengers are verified for your safety and peace of mind.

💰 After Your Trial:
   Subscription costs:
   • Passengers: 5,000 RWF/month
   • Drivers: 10,000 RWF/month

We're here to make your travel experience better, cheaper, and more eco-friendly.

Have questions? Reach out to us anytime - we'd love to help!

Safe travels,
The iShare Team 🌍

---
iShare Rwanda
Share the ride, share the cost 💙
    """
    EmailThread(subject, message, [user.email]).start()

def send_otp_email(email, otp_code):
    subject = "Reset Your Password - ISHARE 🔒"
    message = f"""
    Hello,

    You requested to reset your password. 
    
    Your Reset Code is: {otp_code}

    Enter this code in the app to set a new password.
    """
    EmailThread(subject, message, [email]).start()

# =====================================================
#  TRIP EMAILS
# =====================================================

def send_booking_confirmation(user, trip_details):
    subject = "Booking Confirmed! ✅"
    name = user.first_name if user.first_name else user.username

    message = f"""
    Hello {name},

    Your seat has been successfully booked!

    🚗 Trip: {trip_details['start']} to {trip_details['end']}
    📅 Date: {trip_details['date']}
    💰 Price: {trip_details['price']} RWF
    
    Your driver will be notified. Safe travels!
    """
    EmailThread(subject, message, [user.email]).start()

def send_trip_reminder(user, minutes_left):
    subject = f"Your Ride Arrives in {minutes_left} Mins! 🚖"
    name = user.first_name if user.first_name else user.username
    
    message = f"""
    Hello {name},

    Just a heads up! Your driver will reach your pickup location in approximately {minutes_left} minutes.
    
    Please be ready to avoid delays.
    """
    EmailThread(subject, message, [user.email]).start()