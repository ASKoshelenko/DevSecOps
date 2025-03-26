import smtplib
import subprocess
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


def get_terraform_output(output_name):
    try:
        result = subprocess.run(['terraform', 'output', '-raw', output_name],
                                capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running Terraform command for {output_name}: {e}")
        print(f"Stderr: {e.stderr}")
        return None
    except FileNotFoundError:
        print("Terraform command not found. Make sure Terraform is installed and in your PATH.")
        return None


# Get SMTP password
smtp_password = get_terraform_output('smtp_password')
if not smtp_password:
    raise ValueError("Failed to retrieve SMTP password from Terraform")

# Get SMTP username
smtp_username = get_terraform_output('smtp_username')
if not smtp_username:
    raise ValueError("Failed to retrieve SMTP username from Terraform")

# Get email sender domain
email_domain = get_terraform_output('email_sender_domain')
if not email_domain:
    raise ValueError("Failed to retrieve email sender domain from Terraform")

# SMTP configuration
sender_email = f"DoNotReply@{email_domain}"
print(f"Attempting to send from: {sender_email}")

smtp_server = "smtp.azurecomm.net"
smtp_port = 587

# Replace with the recipient's email
receiver_email = "your_mail@mail.mail"
subject = "Test Email from Azure Communication Services"
body = "This is a test email sent using Azure Communication Services SMTP."

# Create the email message
message = MIMEMultipart()
message["From"] = sender_email
message["To"] = receiver_email
message["Subject"] = subject
message.attach(MIMEText(body, "plain"))

try:
    # Create a secure SSL/TLS connection
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        print(f"Connected to {smtp_server}:{smtp_port}")
        server.set_debuglevel(1)  # Enable debug output
        server.ehlo()  # Can help identify supported features
        server.starttls()
        server.ehlo()  # Some servers need this again after TLS
        print("Attempting login...")
        server.login(smtp_username, smtp_password)
        print("Login successful")
        server.send_message(message)
        print("Test email sent successfully!")
except smtplib.SMTPAuthenticationError as e:
    print(f"Authentication failed: {e}")
    print(f"Username used: {smtp_username}")
    print("Please check your credentials and Azure AD application permissions")
except smtplib.SMTPException as e:
    print(f"SMTP error occurred: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
