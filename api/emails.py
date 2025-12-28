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
    subject = "Welcome to ISHARE! 🚗"
    # Fallback to username if first_name is missing
    name = user.first_name if user.first_name else user.username
    
    message = f"""
    Hello {name},

    Congratulations! You have successfully registered to ISHARE as a {user.profile.role.upper()}.

    We are excited to have you on board.
    
    - The ISHARE Team
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