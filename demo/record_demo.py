import os
import sys
import time
import io
import cv2
import numpy as np
from PIL import Image
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

def render_title_slide(w=1920, h=1080, title="EVENTLEDGER AI", subtitle="Intelligent Event Finance & Payments", tag="PayPal AI Hackathon 2026"):
    # Dark high-tech fintech gradient background
    img = np.zeros((h, w, 3), dtype=np.uint8)
    for y in range(h):
        # subtle gradient from dark navy (#0B132B) to deep blue (#1C2541)
        b = int(43 + (y / h) * 20)
        g = int(19 + (y / h) * 15)
        r = int(11 + (y / h) * 10)
        img[y, :] = (b, g, r)
        
    # Draw decorative accent lines
    cv2.line(img, (200, 360), (1720, 360), (0, 200, 255), 3) # golden/amber
    cv2.line(img, (200, 720), (1720, 720), (0, 150, 255), 2)
    
    # Title
    cv2.putText(img, title, (220, 310), cv2.FONT_HERSHEY_DUPLEX, 2.6, (255, 255, 255), 4, cv2.LINE_AA)
    # Subtitle
    cv2.putText(img, subtitle, (225, 450), cv2.FONT_HERSHEY_SIMPLEX, 1.4, (220, 220, 220), 2, cv2.LINE_AA)
    
    # Bullets
    bullets = [
        "- Multi-Provider Payment Orchestration (PayPal Invoicing v2 + UPI)",
        "- Grounded Google Gemini 3.1 AI Copilot (Live Telemetry Q&A)",
        "- Unified Financial Hub & RBI Account Aggregator Framework",
        "- Cryptographic Settlement Verification (SHA-256 & ECDSA secp256k1)",
        "- Executive PDF Audit Reporting & 100% Passing CI/CD Tests"
    ]
    y_start = 520
    for b in bullets:
        cv2.putText(img, b, (230, y_start), cv2.FONT_HERSHEY_SIMPLEX, 0.85, (0, 210, 255), 2, cv2.LINE_AA)
        y_start += 36
        
    cv2.putText(img, tag, (225, 780), cv2.FONT_HERSHEY_SIMPLEX, 1.1, (100, 255, 100), 2, cv2.LINE_AA)
    return img

def render_section_overlay(frame, section_title, duration_text):
    h, w, _ = frame.shape
    # Bottom banner overlay
    overlay = frame.copy()
    cv2.rectangle(overlay, (0, h - 90), (w, h), (15, 23, 42), -1)
    # border line
    cv2.line(overlay, (0, h - 91), (w, h - 91), (0, 200, 255), 2)
    alpha = 0.85
    cv2.addWeighted(overlay, alpha, frame, 1 - alpha, 0, frame)
    cv2.putText(frame, f"EVENTLEDGER AI  |  {section_title}", (40, h - 40), cv2.FONT_HERSHEY_DUPLEX, 1.0, (255, 255, 255), 2, cv2.LINE_AA)
    cv2.putText(frame, duration_text, (w - 220, h - 40), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 210, 255), 2, cv2.LINE_AA)
    return frame

def capture_route_screenshots(driver, base_url="http://localhost:3000/#/"):
    routes = [
        {"route": "", "name": "01. Dashboard & Financial Metrics", "delay": 5, "duration_sec": 14},
        {"route": "events/evt-paypal-001", "name": "02. Event Details & Attendee Roster", "delay": 4, "duration_sec": 12},
        {"route": "checkout", "name": "03. Payment Orchestration & PayPal Sandbox (INV2-H74E-BVRL-78AN-CX8C)", "delay": 4, "duration_sec": 16},
        {"route": "financial-hub", "name": "04. Financial Hub & Categorized Cashflow", "delay": 4, "duration_sec": 16},
        {"route": "financial-hub/consent", "name": "05. RBI Account Aggregator Consent Flow", "delay": 4, "duration_sec": 15},
        {"route": "events/evt-paypal-003", "name": "06. Cryptographic Settlement & Tamper Proof (SHA-256)", "delay": 4, "duration_sec": 15},
        {"route": "", "name": "07. Google Gemini 3.1 AI Copilot Grounded Telemetry", "delay": 4, "duration_sec": 14},
    ]
    
    captured = []
    for r in routes:
        full_url = base_url + r["route"]
        print(f"Navigating to {full_url} ({r['name']})...")
        driver.get(full_url)
        time.sleep(r["delay"])
        
        # Take screenshot
        png_data = driver.get_screenshot_as_png()
        image = Image.open(io.BytesIO(png_data)).convert('RGB')
        img_np = np.array(image)
        # Convert RGB to BGR for OpenCV
        img_bgr = cv2.cvtColor(img_np, cv2.COLOR_RGB2BGR)
        # Ensure 1920x1080
        if img_bgr.shape[0] != 1080 or img_bgr.shape[1] != 1920:
            img_bgr = cv2.resize(img_bgr, (1920, 1080), interpolation=cv2.INTER_AREA)
            
        captured.append({
            "name": r["name"],
            "image": img_bgr,
            "duration_sec": r["duration_sec"]
        })
    return captured

def build_demo_video(output_path, captured_scenes, fps=15, is_full=False):
    h, w = 1080, 1920
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, fps, (w, h))
    
    multiplier = 2.0 if is_full else 1.0
    
    # 1. Intro slide
    intro_img = render_title_slide(w, h, "EVENTLEDGER AI", "Intelligent Event Finance & Payments", "PayPal AI Hackathon 2026")
    intro_frames = int(fps * (10 if is_full else 6))
    for _ in range(intro_frames):
        out.write(intro_img)
        
    # 2. Captured UI Scenes
    total_scenes = len(captured_scenes)
    for idx, sc in enumerate(captured_scenes):
        base_frame = sc["image"]
        frames_count = int(fps * sc["duration_sec"] * multiplier)
        for f in range(frames_count):
            cur_sec = int(f / fps)
            tot_sec = int(frames_count / fps)
            time_str = f"Scene {idx+1}/{total_scenes} [{cur_sec}s/{tot_sec}s]"
            frame_with_overlay = render_section_overlay(base_frame.copy(), sc["name"], time_str)
            out.write(frame_with_overlay)
            
    # 3. Closing slide
    closing_img = render_title_slide(w, h, "EVENTLEDGER AI", "A Verifiable Financial Operating Platform", "GitHub: AP952005/eventledger-ai")
    closing_frames = int(fps * (10 if is_full else 6))
    for _ in range(closing_frames):
        out.write(closing_img)
        
    out.release()
    print(f"Generated video: {output_path} (Size: {os.path.getsize(output_path)} bytes)")

def main():
    print("Starting Headless Chrome...")
    options = Options()
    options.add_argument('--headless=new')
    options.add_argument('--window-size=1920,1080')
    options.add_argument('--force-device-scale-factor=1')
    options.add_argument('--disable-gpu')
    
    driver = webdriver.Chrome(options=options)
    driver.set_window_size(1920, 1080)
    
    try:
        print("Capturing application scenes from Flutter Web...")
        captured_scenes = capture_route_screenshots(driver, "http://localhost:3000/#/")
    finally:
        driver.quit()
        
    os.makedirs("demo", exist_ok=True)
    
    print("Rendering final hackathon demonstration (target ~2m 45s)...")
    build_demo_video("demo/EventLedger_AI_PayPal_Hackathon_Demo.mp4", captured_scenes, fps=15, is_full=False)
    
    print("Rendering full walkthrough demonstration (~6-7 mins)...")
    build_demo_video("demo/EventLedger_AI_Full_Walkthrough.mp4", captured_scenes, fps=15, is_full=True)
    print("All demonstration videos successfully generated!")

if __name__ == "__main__":
    main()

