# WSUS Power BI Dashboard - Step-by-Step Guide
## All 6 SQL Views Are Working - Let's Build Your Dashboard!

---

## 🎉 You're Ready!

You have all 6 SQL views working in SUSDB. Now let's build your dashboard in 30 minutes!

---

## PART 1: Connect Power BI to Your Data (5 minutes)

### Step 1: Open Power BI Desktop

**What to do:**
1. Find Power BI Desktop on your computer
   - Look for the yellow square icon
   - Or search "Power BI" in Windows Start menu
2. **Double-click** to open it
3. Wait for it to load (10-20 seconds)

**What you'll see:**
- A big white screen
- Some buttons at the top
- Maybe a "Welcome" screen (close it if you see it)

---

### Step 2: Click "Get Data"

**What to do:**
1. Look at the **top left** of Power BI
2. Find the button that says **"Get data"** (might be yellow)
3. **Click it once**

**What you'll see:**
- A window pops up with lots of data source options

---

### Step 3: Choose SQL Server

**What to do:**
1. In the search box at the top, **type:** `SQL Server`
2. You'll see **"SQL Server"** appear in the list
3. **Click on it** (single click to highlight it)
4. **Click the "Connect" button** at the bottom

**What you'll see:**
- The window changes to "SQL Server database"

---

### Step 4: Enter Your Server Information

**What to do:**

**Box 1 - Server:**
1. Click in the box labeled **"Server"**
2. Type your SQL Server name
   - Example: `WSUSSQL01`
   - (Use whatever server name you used when creating the views)
3. Don't press Enter yet!

**Box 2 - Database:**
1. Click in the box labeled **"Database (optional)"**
2. Type: `SUSDB` (all capital letters)

**Radio Buttons - Data Connectivity mode:**
1. Look for two circles below
2. One says **"Import"**
3. One says **"DirectQuery"**
4. **Click the "Import" circle**
   - The circle will fill in when selected

5. **Click "OK"** at the bottom

**What you'll see:**
- A loading spinner
- Then a new window asking for credentials

---

### Step 5: Enter Your Login

**What to do:**

**If you use Windows login:**
1. Click the **"Windows"** tab at the top
2. Click **"Connect"**

**If you use SQL username/password:**
1. Click the **"Database"** tab at the top
2. In the **"User name"** box, type your SQL username
3. In the **"Password"** box, type your SQL password
   - You won't see the letters - they show as dots ●●●●
   - This is normal for security
4. Click **"Connect"**

**What you'll see:**
- Another loading spinner (5-10 seconds)
- Then a window called "Navigator"

---

### Step 6: Select Your 6 Views

**What to do:**

**You'll see the Navigator window with:**
- A list on the left side
- A preview area on the right

**Finding your views:**
1. On the left, find **"SUSDB"** in the list
2. See the little arrow (►) next to it?
3. **Click that arrow**
4. The list expands to show everything in SUSDB

**Quick way to find your views:**
1. See the search box at the top of the Navigator?
2. **Type:** `vw_`
3. Now you only see your 6 views!

**Check all 6 boxes:**

Click the **checkbox** ☐ next to each view:
- ☐ **vw_OverallCompliance** ← Click to check ☑
- ☐ **vw_ComplianceByClassification** ← Click to check ☑
- ☐ **vw_MissingSecurityUpdates** ← Click to check ☑
- ☐ **vw_NonReportingSystems** ← Click to check ☑
- ☐ **vw_ComplianceBySystemType** ← Click to check ☑
- ☐ **vw_TopNonCompliantSystems** ← Click to check ☑

**When you check a box:**
- A checkmark ✓ appears
- The right side shows a preview of the data

**All 6 checked?** Great!

7. Look at the **bottom right** of the window
8. **Click the "Load" button**

**What you'll see:**
- Navigator closes
- A blue loading bar appears!
- Text says "Loading data..."
- This takes **30 seconds to 2 minutes**

**WAIT for it to finish!** Don't click anything.

**When it's done:**
- Loading bar disappears
- You're back to the main Power BI window
- On the **right side**, you see your 6 views listed!

**🎉 YOU'RE CONNECTED! Data is loaded!**

---

## PART 2: Build Your First Dashboard (20 minutes)

### Understanding Your Screen

```
┌─────────────────────────────────────────────────────┐
│ Home  Insert  Modeling  View    (Top Menu)          │
├─────────────────────────────────────────────────────┤
│                                                      │
│         (White Canvas - Your Work Area)              │
│         Charts will go here                          │
│                                                      │
├──────────┬─────────────────┬────────────────────────┤
│ Filters  │ Visualizations  │      Data (Fields)     │
│          │                 │                        │
│ (Left)   │ (Middle)        │ (Right)                │
│          │ ■ □ ═ ☷         │ 📊 vw_Overall...       │
│          │                 │ 📊 vw_Compliance...    │
└──────────┴─────────────────┴────────────────────────┘
```

**Important areas:**
- **White canvas** (middle) = Where you build your dashboard
- **Visualizations** (bottom middle) = Different chart types
- **Fields** (right side) = Your data (the 6 views)

---

### CHART 1: Overall Compliance Card

**This shows your main compliance percentage - like 92%**

#### Step 1: Add a Card

1. Look at **Visualizations** (bottom middle area)
2. Find the icons showing different chart types
3. Look for the one that looks like a **card with "123"**
4. When you hover over it, it says **"Card"**
5. **Click it once**

**What happens:**
- A blank box appears on your white canvas
- It has a gray border (means it's selected)

#### Step 2: Add the Compliance %

1. Look at **Fields** (far right side)
2. Find **"vw_OverallCompliance"**
3. See the little arrow (►) next to it?
4. **Click that arrow** to expand it
5. You'll see field names:
   - TotalComputers
   - CompliancePercentage ← **This one!**
   - ReportingLast30Days
   - etc.

6. Find **"CompliancePercentage"**
7. **Click the checkbox** ☐ next to it

**What happens:**
- The number appears in your card!
- Might say "85.50" or "92.00"
- This is your compliance %!

#### Step 3: Make It Big and Pretty

**The number is tiny. Let's make it HUGE!**

1. Make sure your card is selected (has gray border)
   - If not, click on the card once

2. Look **below the Visualizations area**
3. See two icons: **paintbrush 🎨** and **magnifying glass 🔍**
4. **Click the paintbrush** 🎨

**A panel opens with formatting options!**

**Make the number bigger:**
5. Look for **"Callout value"** in the list
6. Click the arrow (►) next to it to expand
7. Find **"Font size"** or **"Text size"**
8. See the number next to it? (Maybe 12 or 24)
9. **Click on that number**
10. **Type:** `80`
11. **Press Enter**

**BOOM! The number is HUGE!**

**Add a title:**
12. Scroll down in the format panel
13. Find **"Category label"** or **"Title"**
14. See the toggle switch (OFF/ON)?
15. **Click it** to turn it **ON** (turns blue)
16. A text box appears
17. **Click in the text box**
18. **Type:** `Overall Compliance`
19. **Press Enter**

**Optional - Change background color:**
20. Find **"Background"** in the list
21. Turn it **ON**
22. Click the **colored square** next to "Color"
23. Pick a color:
   - **Green** if your compliance is good (95%+)
   - **Yellow** if it's okay (85-95%)
   - **Red** if it's bad (below 85%)
24. Click the color you want

**✅ YOUR FIRST CHART IS DONE!**

---

### CHART 2: Total Computers Card

**This shows how many computers you have total**

**Quick steps (you already know how!):**

1. **Click empty white space** (deselects current card)
2. Click **Card icon** (the 123 one)
3. From **Fields**, expand **"vw_OverallCompliance"**
4. Check the box: **"TotalComputers"**
5. **Format it:**
   - Click paintbrush 🎨
   - Callout value → Font size → **60**
   - Category label → ON → Type: `Total Computers`

**✅ CARD 2 DONE!**

---

### CHART 3: Not Reporting Card

**This shows computers that haven't checked in**

**Quick steps:**

1. Click **empty space**
2. Click **Card icon**
3. Check: **"NotReportingLast30Days"** from vw_OverallCompliance
4. **Format it:**
   - Font size → **60**
   - Label → `Not Reporting (30 days)`
   - Background → **Red** (this is a warning!)

**✅ CARD 3 DONE!**

---

### CHART 4: Bar Chart (Update Types)

**This shows a chart with bars for different update types**

#### Step 1: Create the Chart

1. **Click empty white space**
2. Look at **Visualizations**
3. Find the icon that looks like **bars**: ▅▃▆
4. Hover over it - says "Stacked bar chart" or "Clustered column chart"
5. **Click it**

**What happens:**
- A blank chart appears

#### Step 2: Add Categories (What to show)

1. Look at **Fields** (right side)
2. Find **"vw_ComplianceByClassification"**
3. **Click the arrow** (►) to expand it
4. You'll see:
   - Classification ← **This one!**
   - TotalComputers
   - UpdatesNeeded
   - etc.

5. Find **"Classification"**
6. **Click and HOLD** your mouse on "Classification"
7. **Drag** it over to the chart
8. You'll see a box on the chart that says **"Axis"** or **"X-axis"**
9. **Drop it there** (release mouse button)

**OR easier way:**
- Just **check the box** next to "Classification"
- Power BI adds it automatically!

**What happens:**
- The chart now shows categories!
- You might see "All Updates" (since we simplified)

#### Step 3: Add Numbers (Height of bars)

1. Still in **"vw_ComplianceByClassification"**
2. Find **"UpdatesNeeded"**
3. **Drag it** to the **"Values"** or **"Y-axis"** box
   - OR just **check the box** next to it

**What happens:**
- BARS APPEAR!
- Shows how many updates are needed!

#### Step 4: Make It Pretty

1. **Click paintbrush** 🎨
2. Find **"Title"**
3. Turn it **ON**
4. Type: `Updates Needed`
5. Find **"Data labels"**
6. Turn it **ON**
7. Now numbers appear on the bars!

**✅ BAR CHART DONE!**

---

### CHART 5: Top Non-Compliant Computers Table

**This shows which computers need the most updates**

#### Step 1: Create a Table

1. Click **empty space**
2. In **Visualizations**, find the **table icon** (looks like a grid ⊞)
3. **Click it**

**What happens:**
- A blank table appears

#### Step 2: Add Columns

**From "vw_TopNonCompliantSystems", add these:**

1. Expand **"vw_TopNonCompliantSystems"**
2. **Check these boxes** (one by one):
   - ☑ **ComputerName**
   - ☑ **TotalMissingUpdates**
   - ☑ **OperatingSystem**
   - ☑ **ComputerGroup**

**What happens:**
- Columns appear in the table!
- You see your worst computers listed!

#### Step 3: Format It

1. Click **paintbrush** 🎨
2. Find **"Title"**
3. Turn ON
4. Type: `Top Non-Compliant Computers`

**✅ TABLE DONE!**

---

### ARRANGE EVERYTHING

**Your charts are probably all over the place. Let's organize!**

#### Moving Charts

1. **Click on a chart** to select it
2. **Click and hold** in the middle of it
3. **Drag** to where you want it
4. **Release**

#### Resizing Charts

1. **Click on a chart**
2. See the little **squares on the corners**?
3. **Click and hold** on a corner square
4. **Drag** to make bigger or smaller
5. **Release**

#### Suggested Layout

**Arrange them like this:**

```
┌──────────────────────────────────────────────┐
│                                              │
│ [92% Card]  [500 Card]  [12 Card]           │
│ Compliance   Total     Not Report            │
│                                              │
├──────────────────────────────────────────────┤
│                                              │
│ [      Bar Chart: Updates Needed      ]     │
│                                              │
├──────────────────────────────────────────────┤
│                                              │
│ [  Table: Top Non-Compliant Computers ]     │
│                                              │
└──────────────────────────────────────────────┘
```

**Tips:**
- Put the 3 cards at the TOP in a row
- Put bar chart in the MIDDLE (make it wide)
- Put table at the BOTTOM (make it wide)
- Leave some space between things

---

## PART 3: Save Your Work! (2 minutes)

### Step 1: Save the File

**SUPER IMPORTANT - Save now!**

1. Look at the **very top left**
2. Find the word **"File"**
3. **Click "File"**
4. **Click "Save As"**

**A save dialog appears:**

5. Choose **where** to save:
   - Click **"Desktop"** (easiest to find)
   - Or choose another location

6. **Name your file:**
   - In the "File name" box
   - Type: `WSUS Dashboard`

7. **Click "Save"**

**What happens:**
- File is saved!
- At the top of Power BI, you now see "WSUS Dashboard"

**The file is saved as:** `WSUS Dashboard.pbix`

**✅ YOUR WORK IS SAVED!**

---

### Step 2: Quick Save Shortcut

**From now on, save often using:**
- Press **Ctrl + S** on your keyboard
- (Hold Ctrl, press S, release both)
- This saves quickly without menus

**Save every 5-10 minutes!**

---

## PART 4: Refresh Your Data (1 minute)

### When to Refresh

**Do this:**
- Every time you open the dashboard
- Before showing to your boss
- Once a day

### How to Refresh

**Super easy:**

1. Look at the **top of Power BI**
2. Find the **"Home"** tab
3. Find the **circular arrow button** ↻
4. It says **"Refresh"** when you hover over it
5. **Click it**

**What happens:**
- Loading happens (10-30 seconds)
- All your numbers update with latest data!
- That's it!

**✅ DATA REFRESHED!**

---

## PART 5: Share with Your Boss (2 minutes)

### Method 1: Take a Screenshot (Easiest!)

1. Press **Windows + Shift + S** on your keyboard
   - (Hold Windows key, hold Shift, press S)
2. Your screen goes dim
3. A crosshair appears
4. **Click and drag** around your dashboard
5. **Release**
6. The screenshot is copied!

7. **Open your email**
8. Click in the message area
9. Press **Ctrl + V** to paste
10. Your dashboard appears in the email!
11. **Send it!**

### Method 2: Export to PDF

1. Click **"File"** at top
2. Click **"Export"**
3. Click **"Export to PDF"**
4. Choose where to save
5. Click **"Export"**
6. Wait...
7. PDF is created!
8. Attach to email and send

### Method 3: Share the .pbix File

1. Find your file: **"WSUS Dashboard.pbix"** on Desktop
2. **Right-click** on it
3. **Send to** → **Compressed (zipped) folder**
4. Email the ZIP file
5. They can open it in Power BI Desktop

---

## 🎉 YOU'RE DONE!

### What You Built

✅ **A working WSUS dashboard with:**
- Overall compliance %
- Total computers count
- Non-reporting systems alert
- Updates needed chart
- Top worst computers table

✅ **You can:**
- See compliance at a glance
- Identify problem computers
- Share with your boss
- Refresh data anytime
- Track progress over time

---

## 📅 Daily Usage

### Monday Morning (2 minutes)

1. **Open** WSUS Dashboard.pbix
2. **Click Refresh** ↻
3. **Check** the big compliance number
   - Is it green (95%+)? Great!
   - Is it yellow (85-95%)? Plan some patching
   - Is it red (<85%)? Priority today!
4. **Look** at the table
5. **Note** the top 3 worst computers
6. **Plan** to fix them this week

### Friday Afternoon (3 minutes)

1. **Open** dashboard
2. **Refresh** ↻
3. **Take screenshot** (Windows + Shift + S)
4. **Email** to boss with note:
   ```
   Subject: Weekly WSUS Update
   
   This week's compliance: 92%
   - Fixed 5 computers
   - 3 stubborn ones remaining
   - Deployed 8 critical updates
   
   See attached dashboard.
   ```

### Anytime Someone Asks

1. **Open** dashboard
2. **Refresh** ↻
3. **Show them!**

---

## 🆘 Quick Troubleshooting

### Problem: Can't connect to SQL Server

**Try this:**
1. Check server name is correct
2. Check you can ping the server
3. Ask IT if SQL Server is running

### Problem: No data in charts

**Try this:**
1. Click the **Refresh button** ↻
2. Check that WSUS has computers reporting
3. Run this in SQL: `SELECT * FROM vw_OverallCompliance`

### Problem: Numbers look wrong

**Try this:**
1. Click **Refresh** ↻
2. Wait for it to finish completely
3. Check the date/time in WSUS

### Problem: Chart disappeared

**Try this:**
1. Press **Ctrl + Z** to undo
2. If that doesn't work, rebuild it (you know how now!)

### Problem: Forgot how to do something

**Try this:**
1. Re-read this guide!
2. It has all the steps
3. Do it again step-by-step

---

## 🎯 Next Steps (Optional)

### Want to add more charts?

**You can add:**
- More cards (failed updates, reporting rate)
- Pie chart (server vs workstation)
- Line chart (if you track over time)
- More tables (all non-reporting systems)

**How to add:**
- Just follow the same steps!
- Pick a chart type
- Add fields
- Format it
- Done!

### Want to learn more?

**Resources:**
- YouTube: "Power BI tutorial for beginners"
- Microsoft Learn: https://docs.microsoft.com/learn/powerbi/
- Practice with your dashboard!

---

## ✅ Final Checklist

Before you finish, make sure you:

- [ ] Connected Power BI to SUSDB
- [ ] Loaded all 6 views
- [ ] Created at least 3 cards
- [ ] Created at least 1 chart
- [ ] Arranged everything nicely
- [ ] Saved the file (WSUS Dashboard.pbix)
- [ ] Know how to refresh data
- [ ] Know how to share it
- [ ] Tested it at least once

**All checked? YOU DID IT!** 🎊

---

## 🚀 You're Now a Dashboard Pro!

**You can:**
- ✅ Build Power BI dashboards
- ✅ Connect to SQL databases
- ✅ Create charts and cards
- ✅ Share reports with others
- ✅ Track WSUS compliance
- ✅ Impress your boss!

**Congratulations!** 🌟

---

**Keep this guide handy - you'll refer to it often!**

**Good luck with your WSUS reporting!**
