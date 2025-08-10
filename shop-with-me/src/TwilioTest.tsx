// src/TwilioTest.tsx
import React, { useState } from "react";
import { Button, Input, Card, CardContent } from "@shopify/shop-minis-react";

export function TwilioTest() {
  const [phoneNumber, setPhoneNumber] = useState("+18885734102");
  const [message, setMessage] = useState("Hello from your Shop Mini app!");
  const [status, setStatus] = useState("");

  const sendTestSMS = async () => {
    setStatus("Sending...");
    
    try {
      // Note: In a real app, you'd make this call to your backend
      // This is just a test structure
      const response = await fetch('/api/send-sms', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          to: phoneNumber,
          message: message
        })
      });

      if (response.ok) {
        setStatus("Message sent successfully!");
      } else {
        setStatus("Failed to send message");
      }
    } catch (error) {
      setStatus("Error: " + error.message);
    }
  };

  return (
    <Card style={{ margin: '20px', maxWidth: '400px' }}>
      <CardContent>
        <h3 style={{ marginBottom: '16px' }}>Twilio SMS Test</h3>
        
        <div style={{ marginBottom: '12px' }}>
          <label style={{ display: 'block', marginBottom: '4px' }}>Phone Number:</label>
          <Input
            value={phoneNumber}
            onChange={(e) => setPhoneNumber(e.target.value)}
            placeholder="+18885734102"
          />
        </div>

        <div style={{ marginBottom: '12px' }}>
          <label style={{ display: 'block', marginBottom: '4px' }}>Message:</label>
          <Input
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Enter your test message"
          />
        </div>

        <Button onClick={sendTestSMS} style={{ marginBottom: '12px' }}>
          Send Test SMS
        </Button>

        {status && (
          <div style={{ 
            padding: '8px', 
            backgroundColor: status.includes('success') ? '#d4edda' : '#f8d7da',
            color: status.includes('success') ? '#155724' : '#721c24',
            borderRadius: '4px',
            fontSize: '14px'
          }}>
            {status}
          </div>
        )}

        <div style={{ marginTop: '16px', fontSize: '12px', color: '#666' }}>
          <strong>Note:</strong> This requires a backend API endpoint at /api/send-sms to work.
          <br />
          Your Twilio number: +18885734102
        </div>
      </CardContent>
    </Card>
  );
} 