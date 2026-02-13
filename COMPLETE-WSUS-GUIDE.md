# Complete WSUS Dashboard Guide
## From Zero to Hero - Everything You Need

---

## 🎯 What This Guide Covers

**PART 1:** Installing the SQL Views (one-time setup)
**PART 2:** Connecting Power BI to the Views
**PART 3:** Building Your First Dashboard
**PART 4:** Using Your Dashboard Every Day

**Time needed:** 
- Part 1: 10 minutes
- Part 2: 5 minutes  
- Part 3: 20 minutes
- Part 4: Ongoing

---

# PART 1: Installing the SQL Views
## (One-Time Setup - Do This First!)

### What Are SQL Views?

Think of SQL views like **pre-made recipes**. Instead of gathering all the ingredients every time (which is slow), we make the recipe once and just use it whenever we want. This makes Power BI super fast!

### Who Should Do This?

**Option A:** Your IT person or database administrator
**Option B:** You (if you're comfortable with SQL Server Management Studio)

### What You Need

1. **SQL Server Management Studio (SSMS)** - Download from: https://aka.ms/ssmsfullsetup
2. **Access to your SQL Server** - The computer that has WSUS database
3. **The 6 SQL view files** - These should be in your WSUS-Reporting folder

### Step-by-Step Instructions

#### STEP 1: Find Your SQL View Files

The files are named:
- `01_vw_OverallCompliance.sql`
- `02_vw_ComplianceByClassification.sql`
- `03_vw_MissingSecurityUpdates.sql`
- `04_vw_NonReportingSystems.sql`
- `05_vw_ComplianceBySystemType.sql`
- `06_vw_TopNonCompliantSystems.sql`

**Where to find them:**
- They should be in the ZIP file you downloaded
- Look in the folder called "WSUS-Reporting" or "wsus-reporting-flat"
- All 6 files should be together

**Don't have them?** Ask the person who set this up for you.

#### STEP 2: Open SQL Server Management Studio (SSMS)

1. Click the **Start button** (Windows logo)
2. Type: `SQL Server Management Studio`
3. Click on it when it appears
4. Wait for it to open (takes 10-20 seconds)

**What you see:**
A window that says "Connect to Server" at the top

#### STEP 3: Connect to Your SQL Server

In the "Connect to Server" window:

1. **Server type:** Should say "Database Engine" (leave it)

2. **Server name:** Type your SQL Server name
   - Example: `WSUSSQL01`
   - Or: `192.168.1.50`
   - Or: `SERVERNAME\INSTANCENAME`
   - (This is the same name you'll use in Power BI later)

3. **Authentication:** 
   - If you see "Windows Authentication" selected - good! Click Connect
   - If you need to choose, select "SQL Server Authentication"
     - Then type username
     - Then type password

4. Click **"Connect"**

**What happens:**
- A loading circle spins
- Then you see the main SSMS window with a tree on the left

**Troubleshooting:**
- Can't connect? Ask IT for the correct server name
- Login failed? Ask IT to give you permission

#### STEP 4: Open the First SQL File

1. In SSMS, click **"File"** at the very top left
2. Click **"Open"**
3. Click **"File..."**
4. A file browser window opens
5. **Navigate to** where you saved the SQL files
6. **Click on** `01_vw_OverallCompliance.sql`
7. Click **"Open"**

**What happens:**
- A new tab opens in SSMS
- You see SQL code (lots of text)
- Don't worry about understanding it!

#### STEP 5: Select SUSDB Database

**This is CRITICAL - don't skip!**

1. Look at the **toolbar** (row of buttons below the menu)
2. Find the **dropdown box** that shows database names
3. It might say "master" or something else
4. **Click on that dropdown**
5. **Select "SUSDB"** from the list
6. The dropdown now shows "SUSDB"

**Why this matters:**
If you don't select SUSDB, the view will be created in the wrong place!

#### STEP 6: Run the SQL Script

1. Look for the **Execute button** (green triangle/arrow or says "Execute")
2. **Click it** (or press F5 on keyboard)

**What happens:**
- The script runs (takes 1-2 seconds)
- At the bottom, you see "Command(s) completed successfully"
- The first view is now created!

**If you see an error:**
- Check that "SUSDB" is selected in the dropdown
- Check that you're connected to the right server
- Ask IT for help

#### STEP 7: Repeat for Remaining 5 Files

**Do the same thing for each file:**

1. File → Open → File
2. Select `02_vw_ComplianceByClassification.sql`
3. Make sure SUSDB is selected
4. Click Execute
5. See "Command completed successfully"

**Repeat for:**
- ✅ `02_vw_ComplianceByClassification.sql`
- ✅ `03_vw_MissingSecurityUpdates.sql`
- ✅ `04_vw_NonReportingSystems.sql`
- ✅ `05_vw_ComplianceBySystemType.sql`
- ✅ `06_vw_TopNonCompliantSystems.sql`

**Total: 6 files executed = 6 views created!**

#### STEP 8: Verify Views Were Created

**Let's double-check everything worked:**

1. In SSMS, look at the **left side** (Object Explorer)
2. Find your server name and expand it (click the ►)
3. Expand **"Databases"** (click ►)
4. Expand **"SUSDB"** (click ►)
5. Expand **"Views"** (click ►)
6. Look for items starting with **"vw_"**

**You should see:**
- dbo.vw_OverallCompliance
- dbo.vw_ComplianceByClassification
- dbo.vw_MissingSecurityUpdates
- dbo.vw_NonReportingSystems
- dbo.vw_ComplianceBySystemType
- dbo.vw_TopNonCompliantSystems

**See all 6?** ✅ Perfect! Part 1 is DONE!

**Don't see them?** Go back and make sure you:
- Selected SUSDB before running
- Saw "Command completed successfully" for each
- Connected to the right server

---

# PART 2: Connecting Power BI to the Views
## (Link Your Dashboard to the Data)

### Prerequisites

Before starting Part 2, make sure:
- ✅ Part 1 is complete (6 views created)
- ✅ Power BI Desktop is installed
- ✅ You have your SQL Server name written down
- ✅ You have your username/password (if needed)

### Step-by-Step Instructions

#### STEP 1: Open Power BI Desktop

1. Look at your desktop (main screen)
2. Find the **yellow square icon** "Power BI Desktop"
3. **Double-click it**
4. Wait 10-30 seconds for it to load

**What you see:**
- A big window with "Power BI Desktop" at the top
- A white canvas in the middle
- Buttons at the top

**First time opening?**
- You might see a "Get Started" splash screen
- Just **close it** (click X or "Close")

#### STEP 2: Click "Get Data"

1. Look at the **top left** of the screen
2. See the **"Home"** tab (should be selected/highlighted)
3. Find the **"Get data"** button (might have a yellow icon)
4. **Click "Get data"**

**What happens:**
A window pops up with lots of data source options

#### STEP 3: Choose SQL Server

1. In the window, look at the **search box** at the top
2. **Click in it**
3. **Type:** `SQL Server`
4. Press Enter or wait a second

**What happens:**
- The list filters to show only SQL Server options
- You see "SQL Server" with a database icon

5. **Click on "SQL Server"** (single click to select it)
6. **Click the "Connect" button** at the bottom right

**What happens:**
A new window appears: "SQL Server database"

#### STEP 4: Enter Server and Database

**In the new window, you'll see two boxes:**

**Box 1 - Server:**
1. **Click in the "Server" box**
2. **Type your SQL Server name** EXACTLY
   - Example: `WSUSSQL01`
   - Or: `192.168.1.50`
   - Or: `SERVERNAME\INSTANCENAME`
   - (Same name you used in SSMS)

**Box 2 - Database (optional):**
1. **Click in the "Database" box**
2. **Type:** `SUSDB` (all capital letters)

**Box 3 - Data Connectivity mode:**
- You'll see two circles (radio buttons)
- One says **"Import"**
- One says **"DirectQuery"**
- **Click the "Import" circle** ← IMPORTANT!
  - (The circle fills in when selected)

**Why Import?**
Import is faster! It downloads the data once, then you work with it offline.

3. **Click "OK"** button at the bottom

**What happens:**
Power BI tries to connect... loading circle spins...

#### STEP 5: Enter Credentials

**A new window appears: "SQL Server database"**

At the top you'll see tabs:
- **Windows**
- **Database**

**Which to choose?**

**If you normally log in with your Windows account:**
1. Click the **"Windows"** tab
2. Click **"Connect"** button

**If you have a SQL username and password:**
1. Click the **"Database"** tab
2. In **"User name"** box: Type your SQL username
3. In **"Password"** box: Type your SQL password
   - (You won't see the letters - they show as ●●●●)
4. Click **"Connect"** button

**What happens:**
- Loading spinner appears
- Power BI connects to SQL Server (takes 5-15 seconds)
- A new window appears: "Navigator"

**If connection fails:**
- ❌ Check server name is exactly right
- ❌ Check username/password are correct
- ❌ Make sure SQL Server is turned on
- ❌ Ask IT for help

#### STEP 6: Select the 6 Views

**You now see the "Navigator" window with:**
- A list on the left side
- A preview area on the right side

**On the left side:**
1. Find **"SUSDB"** in the list
2. You might see a little arrow (►) next to it
3. **Click that arrow** to expand SUSDB
4. Now you see lots of items under SUSDB

**Finding the Views:**

**Option A: Use search (EASIEST)**
1. Look for the **search box** at the top
2. Click in it
3. Type: `vw_`
4. Press Enter
5. Now you ONLY see the views we want!

**Option B: Scroll and find them**
1. Scroll through the list
2. Look for items starting with "vw_"

**Check All 6 Boxes:**

Click the **checkbox** next to each of these:

- ☐ **vw_OverallCompliance** ← Click the box
- ☐ **vw_ComplianceByClassification** ← Click the box
- ☐ **vw_MissingSecurityUpdates** ← Click the box
- ☐ **vw_NonReportingSystems** ← Click the box
- ☐ **vw_ComplianceBySystemType** ← Click the box
- ☐ **vw_TopNonCompliantSystems** ← Click the box

**When you check a box:**
- A checkmark ✓ appears
- The preview on the right shows some data

**All 6 checked?** Great!

#### STEP 7: Load the Data

1. Look at the **bottom right** of the Navigator window
2. You'll see two buttons: "Load" and "Transform Data"
3. **Click "Load"** button

**What happens:**
- The Navigator window closes
- A loading screen appears!
- Blue progress bar shows
- Text says "Loading data..." or "Preparing data..."
- This takes **30 seconds to 2 minutes** depending on how much data

**Be patient!** Don't click anything. Let it finish.

**When done:**
- Loading screen disappears
- You're back to the main Power BI window
- On the **right side** you now see your 6 views listed!

**✅ CONGRATULATIONS! YOU'RE CONNECTED!** 🎉

#### STEP 8: Verify Connection

**Look at the far right panel (Fields panel):**

You should see:
- 📊 vw_OverallCompliance
- 📊 vw_ComplianceByClassification
- 📊 vw_MissingSecurityUpdates
- 📊 vw_NonReportingSystems
- 📊 vw_ComplianceBySystemType
- 📊 vw_TopNonCompliantSystems

**See all 6?** Perfect! Part 2 is DONE!

---

# PART 3: Building Your First Dashboard
## (Making Pretty Charts)

### What We'll Build

A simple dashboard with:
1. **Card 1:** Overall Compliance % (the big health score)
2. **Card 2:** Total Computers (how many total)
3. **Card 3:** Not Reporting (sleeping computers)
4. **Chart:** Bar chart showing update types

### Understanding the Screen

```
Power BI Layout:
┌─────────────────────────────────────────────────────┐
│ Home  Insert  Modeling  View    (Top Menu)         │
├─────────────────────────────────────────────────────┤
│                                                      │
│                                                      │
│         (White Canvas - Your Work Area)              │
│         This is where charts go                      │
│                                                      │
├──────────┬─────────────────┬────────────────────────┤
│ Filters  │ Visualizations  │      Fields            │
│          │                 │                        │
│ (Left)   │ (Middle)        │ (Right - Your Data)    │
│          │ ■ □ ═           │ 📊 vw_Overall...       │
│          │                 │ 📊 vw_Compliance...    │
└──────────┴─────────────────┴────────────────────────┘
```

### CHART 1: Overall Compliance Card

#### Step 1: Click the Card Icon

1. Look at **Visualizations panel** (middle bottom, has icons)
2. Find the icon that looks like a **card with "123"**
3. When you hover over it, it says "Card"
4. **Click it once**

**What happens:**
- A blank rectangular box appears on your canvas
- It has a gray border (means it's selected)

#### Step 2: Add Data to Card

1. Look at **Fields panel** (far right)
2. Find **"vw_OverallCompliance"**
3. See the little arrow (►) next to it?
4. **Click that arrow** - it expands to show fields inside

**You'll see:**
- TotalComputers
- ReportingLast30Days
- NotReportingLast30Days
- TotalUpdatesNeeded
- TotalUpdatesInstalled
- CompliancePercentage ← **This one!**

5. Find **"CompliancePercentage"**
6. See the checkbox ☐ next to it?
7. **Click that checkbox** ☑

**What happens:**
- The number appears in your card!
- Might say "92" or "85.5" or similar

#### Step 3: Make It BIG and Pretty

**Right now the number is tiny. Let's fix it:**

1. Make sure your card is **selected** (has gray border)
2. Look **below the Visualizations icons**
3. See two icons: paintbrush 🎨 and magnifying glass 🔍
4. **Click the paintbrush** 🎨 (Format visual)

**A list of options appears:**

**Make the number bigger:**
5. Find **"Callout value"** in the list
6. Click it to expand (► becomes ▼)
7. Find **"Text size"**
8. Click on the number next to it
9. Type: **80**
10. Press Enter

**The number gets HUGE!**

**Add a title:**
11. Find **"Category label"** in the list
12. See the toggle switch next to it? (OFF/ON)
13. **Click the switch** to turn it ON (turns blue)
14. Find the **text box** that appears
15. Click in it
16. Type: `Overall Compliance`
17. Press Enter

**Change background color (optional):**
18. Find **"Background"** in the list
19. Turn it ON (click the switch)
20. Click the **color box** next to "Color"
21. Pick green if number is good, red if bad
22. Click the color you want

**✅ YOUR FIRST CARD IS DONE!** 🎉

### CHART 2: Total Computers Card

**This is the same process, just faster!**

#### Step 1: New Card
1. **Click on empty white space** (deselects current card)
2. Click the **Card icon** again (the 123 one)

#### Step 2: Add Data
1. From **"vw_OverallCompliance"** (expand if needed)
2. Check the box: **"TotalComputers"** ☑

#### Step 3: Make Pretty
1. Click paintbrush 🎨
2. Callout value → Text size → **60**
3. Category label → Turn ON → Type: `Total Computers`

**✅ CARD 2 DONE!**

### CHART 3: Not Reporting Card

#### Quick Steps:
1. Click empty space
2. Click Card icon
3. Check: **"NotReportingLast30Days"** from vw_OverallCompliance
4. Paintbrush 🎨 → Text size **60**
5. Label: `Not Reporting`
6. Background: **Red** (because this is a warning)

**✅ CARD 3 DONE!**

### CHART 4: Bar Chart (Update Types)

#### Step 1: Create Bar Chart
1. Click **empty white space**
2. Look at Visualizations icons
3. Find the **bar chart icon**: ▆▅▃
4. Hover to see "Stacked bar chart" or "Clustered bar chart"
5. **Click it**

**What happens:**
A blank chart appears

#### Step 2: Add Categories (X-Axis)

**The X-axis is the categories (Critical, Security, etc.)**

1. Look at Fields panel (right side)
2. Find **"vw_ComplianceByClassification"**
3. Expand it (click ►)

**You'll see:**
- Classification ← **This one!**
- TotalComputers
- ComputersNeedingUpdates
- UpdatesNeeded
- UpdatesInstalled
- CompliancePercentage

4. Find **"Classification"**
5. **Click and HOLD** the mouse button on "Classification"
6. **Drag** it over to the chart
7. Look for a box that says **"X-axis"** or **"Axis"**
8. **Drop it there** (release mouse button)

**Alternative (easier) method:**
- Just **check the box** next to "Classification"
- Power BI will add it automatically!

**What happens:**
The chart now shows categories: Critical Updates, Security Updates, etc.

#### Step 3: Add Numbers (Y-Axis)

**The Y-axis is the actual numbers (heights of bars)**

1. Still in **"vw_ComplianceByClassification"**
2. Find **"UpdatesNeeded"**
3. **Drag it** to the **"Y-axis"** box
   - Or just **check the box** next to it

**What happens:**
- BARS APPEAR!
- Different heights showing how many updates needed

**✅ YOUR BAR CHART IS DONE!** 🎊

#### Step 4: Make Chart Pretty

1. Click paintbrush 🎨
2. Find **"Title"**
3. Turn it ON
4. In text box type: `Updates Needed by Type`
5. Find **"Data labels"**
6. Turn it ON
7. Now numbers appear on each bar!

### FINAL STEP: Arrange Everything

**Your charts are probably all over the place. Let's organize!**

#### Moving Charts:
1. **Click on a chart** to select it
2. **Click and hold** on it
3. **Drag** to where you want it
4. **Release** mouse button

#### Resizing Charts:
1. **Click on a chart** to select it
2. See the little **squares** on corners and edges?
3. **Click and hold** on a corner square
4. **Drag** to make bigger or smaller
5. **Release**

#### Suggested Layout:

**Arrange them like this:**

```
┌────────────────────────────────────────────┐
│                                            │
│  [92% Card]  [500 Card]  [12 Card]        │
│   Compliance   Total     Not Report        │
│                                            │
│  [        Bar Chart          ]             │
│  [    Updates by Type        ]             │
│  [                           ]             │
│                                            │
└────────────────────────────────────────────┘
```

**Tips:**
- Put the 3 cards at the top in a row
- Put the bar chart below, make it wide
- Leave space between charts (looks better!)

### SAVE YOUR WORK!

**SUPER IMPORTANT - Do this now!**

1. Click **"File"** at the very top left
2. Click **"Save As"**
3. Choose where to save (Desktop is good)
4. **Name it:** `WSUS Dashboard`
5. Click **"Save"**

**The file is saved as:** `WSUS Dashboard.pbix`

**Remember where you saved it!**

**Quick save shortcut:**
- Press **Ctrl + S** (hold Ctrl, press S)
- This saves quickly without the menu

**✅ PART 3 DONE! YOUR DASHBOARD IS BUILT!** 🎉🎉🎉

---

# PART 4: Using Your Dashboard
## (Daily Operations)

### Opening Your Dashboard

**Every time you want to use it:**

1. Find the file: `WSUS Dashboard.pbix`
2. **Double-click it**
3. Power BI opens with your dashboard

**Or:**
1. Open Power BI Desktop
2. File → Open
3. Find `WSUS Dashboard.pbix`
4. Click Open

### Refreshing Data (Getting New Numbers)

**Do this EVERY TIME you open the dashboard:**

1. Look at the **top** of Power BI
2. Find the **"Home"** tab
3. Find the **circular arrow button** ↻ (says "Refresh")
4. **Click it**

**What happens:**
- Loading happens (10-30 seconds)
- All numbers update with latest data!

**How often to refresh:**
- Every time you open it
- Before showing to your boss
- Once a day if you keep it open

### Reading the Numbers

#### Compliance % (Main Health Score)

**What it means:**
- Shows what % of computers have all updates
- Higher is better!

**What's good:**
- 🟢 **95% or higher:** EXCELLENT! Keep it up!
- 🟡 **85-94%:** GOOD! Most things okay
- 🔴 **Below 85%:** BAD! Need to fix things

**What to do:**
- Above 95%: Keep doing what you're doing
- 85-94%: Plan some patching this week
- Below 85%: This is urgent! Fix ASAP!

#### Total Computers

**What it means:**
- How many computers total in WSUS

**What's good:**
- Should match what you expect
- If you have 500 computers, it should say ~500

**What's bad:**
- Way different than expected
- Example: You think 500 but it shows 300
- Means 200 aren't reporting!

#### Not Reporting

**What it means:**
- Computers that haven't checked in for 30+ days
- They're "sleeping" or missing

**What's good:**
- 🟢 **0-10 computers:** Normal
- 🟡 **10-50 computers:** Needs investigation
- 🔴 **50+ computers:** Big problem!

**What to do:**
1. Find which computers (look at table on dashboard)
2. Are they turned off? → Turn them on
3. Are they old/retired? → Remove from WSUS
4. Are they broken? → Fix or replace

### Daily Routine

#### Monday Morning (5 minutes)

**Full check:**
1. Open dashboard
2. Click Refresh ↻
3. Look at Compliance %
   - Green (95%+)? → Good!
   - Yellow (85-94%)? → Plan patching
   - Red (below 85%)? → Priority today!
4. Look at Not Reporting
   - Under 10? → OK
   - 10-50? → Investigate which ones
   - Over 50? → Major issue!
5. Look at bar chart
   - How many Critical updates?
   - How many Security updates?
6. Make note of numbers

#### Tuesday-Thursday (2 minutes)

**Quick check:**
1. Open dashboard
2. Refresh ↻
3. Quick glance - anything worse?
   - No? → Good, keep working
   - Yes? → Investigate why

#### Friday (5 minutes)

**Weekly report:**
1. Open dashboard
2. Refresh ↻
3. Take screenshot:
   - Press **Windows + Shift + S**
   - Drag around dashboard
   - It copies to clipboard
4. Open email
5. Press **Ctrl + V** to paste
6. Write quick summary:

**Example email:**
```
Subject: Weekly WSUS Update

Hi Boss,

This week's compliance: 92%
- Up from 89% last week
- Deployed 8 critical updates
- 12 computers not reporting (investigating)

Dashboard attached.
```

### Talking to Your Boss

**What they care about:**
- Are we secure? ✓ or ✗
- One big number (compliance %)
- Getting better or worse?

**What to say:**
✅ "We're at 92% - above our 90% target"
✅ "Up from 89% last week"
✅ "Deployed critical updates this week"

**What NOT to say:**
❌ "The vw_OverallCompliance query shows..."
❌ "WSUS synchronization issues..."
❌ Technical jargon

**Just show the dashboard and point at numbers!**

### Tracking Progress

**Keep a simple log:**

| Date | Compliance % | Not Reporting | Notes |
|------|--------------|---------------|-------|
| 2/3  | 89%          | 15            | Started patching |
| 2/10 | 92%          | 12            | Deployed critical updates |
| 2/17 | 94%          | 10            | Good progress! |

**Why track:**
- Shows improvement
- Boss likes seeing progress
- Helps you see trends

### Common Problems

#### Problem: "Compliance went DOWN!"

**Don't panic! This is usually normal:**
- New updates were released (most common!)
- More computers checked in
- Laptops came back from travel

**What to do:**
1. Check if new updates appeared
2. Plan to deploy them
3. It will go back up soon

#### Problem: "Same computers always worst"

**Reasons:**
- Turned off all the time
- Users keep clicking "Remind later"
- Something broken on computer

**What to do:**
1. Contact the users
2. Ask them to leave computer on overnight
3. Or force updates with Group Policy

#### Problem: "Numbers look weird"

**What to check:**
1. Did you click Refresh? (Do this first!)
2. Is WSUS working? (Ask IT)
3. Are computers online? (Check network)

### Your Action Priority

**Fix things in this order:**

1. **Critical updates on SERVERS** ← Most important!
2. Critical updates on workstations
3. Security updates on servers
4. Security updates on workstations
5. Everything else

**Why servers first?**
- More important than desktop PCs
- More users depend on them
- Bigger security risk if hacked

---

## ✅ Complete Checklist

**Have you done everything?**

### Part 1: SQL Views
- [ ] Downloaded the 6 SQL view files
- [ ] Opened SQL Server Management Studio
- [ ] Connected to SQL Server
- [ ] Selected SUSDB database
- [ ] Ran all 6 SQL scripts
- [ ] Verified 6 views were created

### Part 2: Power BI Connection
- [ ] Opened Power BI Desktop
- [ ] Clicked Get Data → SQL Server
- [ ] Entered server name and SUSDB
- [ ] Connected with credentials
- [ ] Selected all 6 vw_ views
- [ ] Clicked Load
- [ ] Verified 6 views in Fields panel

### Part 3: Dashboard Building
- [ ] Created Card 1 (Compliance %)
- [ ] Created Card 2 (Total Computers)
- [ ] Created Card 3 (Not Reporting)
- [ ] Created Bar Chart
- [ ] Arranged everything nicely
- [ ] Saved the file

### Part 4: Using It
- [ ] Know how to open dashboard
- [ ] Know how to refresh data
- [ ] Understand what numbers mean
- [ ] Know what's good vs bad
- [ ] Have daily routine planned
- [ ] Know how to talk to boss

**Check all boxes = YOU'RE DONE!** 🎉🎉🎉

---

## 🎯 Quick Reference

**Keep this handy:**

```
═══════════════════════════════════════════
        WSUS DASHBOARD QUICK GUIDE
═══════════════════════════════════════════

OPENING:
1. Double-click "WSUS Dashboard.pbix"
2. Click Refresh button ↻
3. Wait 30 seconds

READING NUMBERS:
• Compliance 95%+ = Green/Good
• Compliance 85-94% = Yellow/OK
• Compliance below 85% = Red/Bad

• Not Reporting 0-10 = Normal
• Not Reporting 10-50 = Investigate
• Not Reporting 50+ = Problem

DAILY ROUTINE:
1. Open dashboard
2. Refresh
3. Check main numbers
4. Fix worst computers first

TALKING TO BOSS:
"We're at [X]% compliance - [up/down] 
from last week. [X] critical updates 
being deployed this week."

HELP:
• Can't connect? Check server name
• No data? Click Refresh
• Looks wrong? Ask IT

═══════════════════════════════════════════
```

---

## 🎊 CONGRATULATIONS!

**You now have:**
- ✅ SQL views installed
- ✅ Power BI connected
- ✅ Dashboard built
- ✅ Knowledge to use it daily

**You're officially a WSUS Dashboard expert!** 🚀

**Keep this guide saved somewhere - you'll refer to it often!**

**Good luck!** 🌟
