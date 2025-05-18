from flask import Flask, jsonify, request
from flask_cors import CORS
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import logging

app = Flask(__name__)
CORS(app)

# ✅ Configure logging
logging.basicConfig(level=logging.INFO)

# ✅ SMTP Configuration
SMTP_SERVER = 'smtp.gmail.com'
SMTP_PORT = 587
EMAIL_ADDRESS = 'enter_email'      # Your admin email
EMAIL_PASSWORD = 'enter_password'      # Your app password

# ✅ Central emergency contact email
EMERGENCY_CONTACT = 'enter_email'  # Replace with your central contact email

@app.route('/send-sos', methods=['POST'])
def send_sos():
    try:
        # ✅ Extract user data from the request
        data = request.get_json()

        # Extract email, location, and optional message
        user_email = data.get('email', 'Unknown User')
        latitude = data.get('latitude', 'N/A')
        longitude = data.get('longitude', 'N/A')
        additional_message = data.get('message', 'No additional message provided')

        # ✅ Google Maps link (to make location clickable)
        maps_link = f"https://www.google.com/maps?q={latitude},{longitude}"

        # ✅ Email content
        message = MIMEMultipart()
        message['From'] = EMAIL_ADDRESS
        message['To'] = EMERGENCY_CONTACT
        message['Subject'] = '🚨 SOS Alert - AidLink'

        # ✅ Dynamic message body with location
        body = f'''
        <h3>🚨 SOS Alert Triggered</h3>
        <p><strong>Sender:</strong> {user_email}</p>
        <p><strong>Location:</strong> 
        <a href="{maps_link}" target="_blank">View on Google Maps</a></p>
        <p><strong>Coordinates:</strong> {latitude}, {longitude}</p>
        <p><strong>Message:</strong> {additional_message}</p>
        <p>An emergency alert has been sent from the AidLink app. Please respond immediately!</p>
        '''
        message.attach(MIMEText(body, 'html'))

        # ✅ Sending the email
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, EMERGENCY_CONTACT, message.as_string())

        logging.info("✅ SOS email sent successfully with location!")
        return jsonify({'success': 'SOS email sent successfully with location!'}), 200

    except smtplib.SMTPAuthenticationError:
        logging.error("❌ SMTP Authentication Error: Invalid email or app password.")
        return jsonify({'error': 'SMTP Authentication failed. Check your credentials.'}), 401

    except smtplib.SMTPException as e:
        logging.error(f"❌ SMTP Error: {str(e)}")
        return jsonify({'error': f'SMTP Error: {str(e)}'}), 500

    except Exception as e:
        logging.error(f"❌ Server Error: {str(e)}")
        return jsonify({'error': f'Server Error: {str(e)}'}), 500


@app.route('/send-disaster-report', methods=['POST'])
def send_disaster_report():
    try:
        data = request.get_json()

        location = data.get('location', 'N/A')
        resources = data.get('resources', [])
        extra_info = data.get('extra_info', '')

        resources_list = ', '.join(resources) if resources else 'No resources selected'

        # Email content
        message = MIMEMultipart()
        message['From'] = EMAIL_ADDRESS
        message['To'] = EMERGENCY_CONTACT
        message['Subject'] = '🆘 Disaster Recovery Report - AidLink'

        body = f'''
        <h3>🆘 Disaster Recovery Report Submitted</h3>
        <p><strong>Location:</strong> {location}</p>
        <p><strong>Resources Needed:</strong> {resources_list}</p>
        <p><strong>Additional Information:</strong> {extra_info if extra_info else 'None'}</p>
        <p>Please respond promptly to this report.</p>
        '''
        message.attach(MIMEText(body, 'html'))

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, EMERGENCY_CONTACT, message.as_string())

        logging.info("✅ Disaster recovery report email sent successfully!")
        return jsonify({'success': 'Disaster recovery report email sent successfully!'}), 200

    except smtplib.SMTPAuthenticationError:
        logging.error("❌ SMTP Authentication Error: Invalid email or app password.")
        return jsonify({'error': 'SMTP Authentication failed. Check your credentials.'}), 401

    except smtplib.SMTPException as e:
        logging.error(f"❌ SMTP Error: {str(e)}")
        return jsonify({'error': f'SMTP Error: {str(e)}'}), 500

    except Exception as e:
        logging.error(f"❌ Server Error: {str(e)}")
        return jsonify({'error': f'Server Error: {str(e)}'}), 500


@app.route('/send-hazard-alert', methods=['POST'])
def send_hazard_alert():
    try:
        data = request.get_json()

        hazard_type = data.get('hazard_type', 'N/A')
        location = data.get('location', 'N/A')
        description = data.get('description', '')

        # Email content
        message = MIMEMultipart()
        message['From'] = EMAIL_ADDRESS
        message['To'] = EMERGENCY_CONTACT
        message['Subject'] = '⚠️ Hazard Alert - AidLink'

        body = f'''
        <h3>⚠️ Hazard Alert Submitted</h3>
        <p><strong>Hazard Type:</strong> {hazard_type}</p>
        <p><strong>Location:</strong> {location}</p>
        <p><strong>Description:</strong> {description if description else 'None'}</p>
        <p>Please respond promptly to this alert.</p>
        '''
        message.attach(MIMEText(body, 'html'))

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, EMERGENCY_CONTACT, message.as_string())

        logging.info("✅ Hazard alert email sent successfully!")
        return jsonify({'success': 'Hazard alert email sent successfully!'}), 200

    except smtplib.SMTPAuthenticationError:
        logging.error("❌ SMTP Authentication Error: Invalid email or app password.")
        return jsonify({'error': 'SMTP Authentication failed. Check your credentials.'}), 401

    except smtplib.SMTPException as e:
        logging.error(f"❌ SMTP Error: {str(e)}")
        return jsonify({'error': f'SMTP Error: {str(e)}'}), 500

    except Exception as e:
        logging.error(f"❌ Server Error: {str(e)}")
        return jsonify({'error': f'Server Error: {str(e)}'}), 500
    
    


@app.route('/send-wildlife-conservation-report', methods=['POST'])
def send_wildlife_conservation_report():
    try:
        data = request.get_json()

        description = data.get('description', '')
        location = data.get('location', 'N/A')

        # Email content
        message = MIMEMultipart()
        message['From'] = EMAIL_ADDRESS
        message['To'] = EMERGENCY_CONTACT
        message['Subject'] = '🦜 Wildlife Conservation Report - AidLink'

        body = f'''
        <h3>🦜 Wildlife Conservation Report Submitted</h3>
        <p><strong>Location:</strong> {location}</p>
        <p><strong>Description:</strong> {description if description else 'None'}</p>
        <p>Please respond promptly to this report.</p>
        '''
        message.attach(MIMEText(body, 'html'))

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, EMERGENCY_CONTACT, message.as_string())

        logging.info("✅ Wildlife conservation report email sent successfully!")
        return jsonify({'success': 'Wildlife conservation report email sent successfully!'}), 200

    except smtplib.SMTPAuthenticationError:
        logging.error("❌ SMTP Authentication Error: Invalid email or app password.")
        return jsonify({'error': 'SMTP Authentication failed. Check your credentials.'}), 401

    except smtplib.SMTPException as e:
        logging.error(f"❌ SMTP Error: {str(e)}")
        return jsonify({'error': f'SMTP Error: {str(e)}'}), 500

    except Exception as e:
        logging.error(f"❌ Server Error: {str(e)}")
        return jsonify({'error': f'Server Error: {str(e)}'}), 500

@app.route('/send-crime-report', methods=['POST'])
def send_crime_report():
    try:
        data = request.get_json()

        crime_types = data.get('crime_types', [])
        description = data.get('description', '')

        crime_list = ', '.join(crime_types) if crime_types else 'No crime types selected'

        # Email content
        message = MIMEMultipart()
        message['From'] = EMAIL_ADDRESS
        message['To'] = EMERGENCY_CONTACT
        message['Subject'] = '🚓 Crime Report - AidLink'

        body = f'''
        <h3>🚓 Crime Report Submitted</h3>
        <p><strong>Crime Types:</strong> {crime_list}</p>
        <p><strong>Description:</strong> {description if description else 'None'}</p>
        <p>Please respond promptly to this report.</p>
        '''
        message.attach(MIMEText(body, 'html'))

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, EMERGENCY_CONTACT, message.as_string())

        logging.info("✅ Crime report email sent successfully!")
        return jsonify({'success': 'Crime report email sent successfully!'}), 200

    except smtplib.SMTPAuthenticationError:
        logging.error("❌ SMTP Authentication Error: Invalid email or app password.")
        return jsonify({'error': 'SMTP Authentication failed. Check your credentials.'}), 401

    except smtplib.SMTPException as e:
        logging.error(f"❌ SMTP Error: {str(e)}")
        return jsonify({'error': f'SMTP Error: {str(e)}'}), 500

    except Exception as e:
        logging.error(f"❌ Server Error: {str(e)}")
        return jsonify({'error': f'Server Error: {str(e)}'}), 500

@app.route('/send-fire-rescue-report', methods=['POST'])
def send_fire_rescue_report():
    try:
        data = request.get_json()

        location = data.get('location', 'N/A')
        report_text = data.get('report_text', '')

        # Email content
        message = MIMEMultipart()
        message['From'] = EMAIL_ADDRESS
        message['To'] = EMERGENCY_CONTACT
        message['Subject'] = '🔥 Fire Rescue Report - AidLink'

        body = f'''
        <h3>🔥 Fire Rescue Report Submitted</h3>
        <p><strong>Location:</strong> {location}</p>
        <p><strong>Report:</strong> {report_text if report_text else 'None'}</p>
        <p>Please respond promptly to this report.</p>
        '''
        message.attach(MIMEText(body, 'html'))

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, EMERGENCY_CONTACT, message.as_string())

        logging.info("✅ Fire rescue report email sent successfully!")
        return jsonify({'success': 'Fire rescue report email sent successfully!'}), 200

    except smtplib.SMTPAuthenticationError:
        logging.error("❌ SMTP Authentication Error: Invalid email or app password.")
        return jsonify({'error': 'SMTP Authentication failed. Check your credentials.'}), 401

    except smtplib.SMTPException as e:
        logging.error(f"❌ SMTP Error: {str(e)}")
        return jsonify({'error': f'SMTP Error: {str(e)}'}), 500

    except Exception as e:
        logging.error(f"❌ Server Error: {str(e)}")
        return jsonify({'error': f'Server Error: {str(e)}'}), 500

@app.route('/send-ambulance-report', methods=['POST'])
def send_ambulance_report():
    try:
        data = request.get_json()

        details = data.get('details', '')
        phone = data.get('phone', '')
        location = data.get('location', '')

        # Email content
        message = MIMEMultipart()
        message['From'] = EMAIL_ADDRESS
        message['To'] = EMERGENCY_CONTACT
        message['Subject'] = '🚑 Ambulance Request - AidLink'

        body = f'''
        <h3>🚑 Ambulance Request Submitted</h3>
        <p><strong>Details:</strong> {details if details else 'None'}</p>
        <p><strong>Phone:</strong> {phone if phone else 'None'}</p>
        <p><strong>Location:</strong> {location if location else 'None'}</p>
        <p>Please respond promptly to this request.</p>
        '''
        message.attach(MIMEText(body, 'html'))

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, EMERGENCY_CONTACT, message.as_string())

        logging.info("✅ Ambulance request email sent successfully!")
        return jsonify({'success': 'Ambulance request email sent successfully!'}), 200

    except smtplib.SMTPAuthenticationError:
        logging.error("❌ SMTP Authentication Error: Invalid email or app password.")
        return jsonify({'error': 'SMTP Authentication failed. Check your credentials.'}), 401

    except smtplib.SMTPException as e:
        logging.error(f"❌ SMTP Error: {str(e)}")
        return jsonify({'error': f'SMTP Error: {str(e)}'}), 500

    except Exception as e:
        logging.error(f"❌ Server Error: {str(e)}")
        return jsonify({'error': f'Server Error: {str(e)}'}), 500

@app.route('/send-hospital-report', methods=['POST'])
def send_hospital_report():
    try:
        data = request.get_json()

        hospital_name = data.get('hospital_name', '')
        problem_description = data.get('problem_description', '')

        # Email content
        message = MIMEMultipart()
        message['From'] = EMAIL_ADDRESS
        message['To'] = EMERGENCY_CONTACT
        message['Subject'] = '🏥 Hospital Report - AidLink'

        body = f'''
        <h3>🏥 Hospital Report Submitted</h3>
        <p><strong>Hospital Name:</strong> {hospital_name if hospital_name else 'None'}</p>
        <p><strong>Problem Description:</strong> {problem_description if problem_description else 'None'}</p>
        <p>Please respond promptly to this report.</p>
        '''
        message.attach(MIMEText(body, 'html'))

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, EMERGENCY_CONTACT, message.as_string())

        logging.info("✅ Hospital report email sent successfully!")
        return jsonify({'success': 'Hospital report email sent successfully!'}), 200

    except smtplib.SMTPAuthenticationError:
        logging.error("❌ SMTP Authentication Error: Invalid email or app password.")
        return jsonify({'error': 'SMTP Authentication failed. Check your credentials.'}), 401

    except smtplib.SMTPException as e:
        logging.error(f"❌ SMTP Error: {str(e)}")
        return jsonify({'error': f'SMTP Error: {str(e)}'}), 500

    except Exception as e:
        logging.error(f"❌ Server Error: {str(e)}")
        return jsonify({'error': f'Server Error: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
