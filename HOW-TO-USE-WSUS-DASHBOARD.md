# How to Use Your WSUS Dashboard
## The "Just Tell Me What It Means" Guide

---

## 🎯 What This Guide Is For

**You already have a WSUS dashboard built.** Now you need to know:
- What do all these numbers mean?
- Which numbers are good?
- Which numbers are bad?
- What should I do about it?
- How do I show this to my boss?

**This guide tells you EXACTLY that!**

---

## 📊 Understanding Your Dashboard (The Numbers Explained)

### The Big Number: Overall Compliance

```
┌─────────────────┐
│                 │
│      92%        │
│   Healthy       │
│                 │
└─────────────────┘
```

**What it means:**
- This shows how many of your computers have all their updates installed
- Think of it like a health score

**What's good:**
- ✅ **95% or higher** = EXCELLENT! Everything is great!
- ✅ **85% to 94%** = GOOD! Most things are okay
- ⚠️ **75% to 84%** = FAIR - Need to improve
- ❌ **Below 75%** = BAD - Need to fix things NOW

**What to tell your boss:**
- If 95%+: "We're in great shape! 95% of our computers are fully updated."
- If 85-94%: "We're doing well. Most computers are updated. Working on the rest."
- If below 85%: "We need to patch some computers. I'm working on it."

---

### The Total Number: How Many Computers

```
┌─────────────────┐
│                 │
│      500        │
│   Computers     │
│                 │
└─────────────────┘
```

**What it means:**
- This is how many computers you have total
- Includes desktops, laptops, and servers

**What's good:**
- This number should match what you expect
- If you think you have 500 computers and it says 500, that's good!

**What's bad:**
- If the number is way different than you expect
- Example: You think you have 500 but it shows 300
- This means 200 computers aren't reporting to WSUS

**What to do if it's wrong:**
- Check if computers are turned off
- Check if computers are connected to the network
- Ask IT to investigate

---

### The Warning Number: Not Reporting

```
┌─────────────────┐
│                 │
│       12        │
│   Sleeping      │
│                 │
└─────────────────┘
```

**What it means:**
- These computers haven't "checked in" with WSUS in 30 days
- They're not getting updates
- Think of them as "missing" or "sleeping"

**What's good:**
- ✅ **0 to 10** computers = Normal (some computers might be off for vacation, etc.)
- ⚠️ **10 to 50** computers = Need to investigate
- ❌ **50+** computers = Big problem!

**What causes this:**
- Computer is turned off for a long time
- Computer was unplugged from network
- Computer was retired/removed but not cleaned up
- Computer has a problem connecting to WSUS

**What to do:**
1. Find out which computers they are (look at the table on your dashboard)
2. Are they just turned off? → Turn them on
3. Are they old/retired? → Remove them from WSUS
4. Are they broken? → Fix them or replace them

**What to tell your boss:**
- "12 computers haven't checked in. I'm investigating which ones they are."
- "Most are probably just laptops that are turned off. I'll verify."

---

### The Critical Number: Updates Needed

```
┌─────────────────┐
│                 │
│       23        │
│   Critical      │
│                 │
└─────────────────┘
```

**What it means:**
- This is how many CRITICAL updates are missing across ALL computers
- Critical = Very important security fixes
- These are the dangerous ones!

**What's good:**
- ✅ **0** = Perfect! No critical updates missing!
- ⚠️ **1 to 10** = Not terrible, but should fix soon
- ❌ **10+** = This is bad! Need to fix ASAP

**Why this matters:**
- Critical updates fix security holes
- Bad guys can use these holes to attack your computers
- The longer they're missing, the more dangerous

**What to do:**
1. Look at your dashboard to see WHICH critical updates
2. Approve those updates in WSUS (or ask IT to do it)
3. Make computers install them
4. Check back in a week to see if the number went down

**What to tell your boss:**
- "We have 23 critical updates that need to be installed. I'm deploying them this week."
- "This is high priority for security."

---

## 📊 Understanding the Bar Chart

```
┌──────────────────────────────────┐
│  Updates We Need                 │
│                                  │
│  Critical:    ▓▓▓▓▓ 23          │
│  Security:    ▓▓▓▓▓▓▓▓ 45       │
│  Other:       ▓▓ 12              │
│                                  │
└──────────────────────────────────┘
```

**What it means:**
Each bar shows a different TYPE of update:

### Critical Updates (Red Bar)
- **Most important!** Fix these first!
- Fix security holes that bad guys can exploit
- Usually small number (5-30)

### Security Updates (Orange/Yellow Bar)
- **Very important!** Fix these second!
- Also fix security problems
- Usually medium number (20-100)

### Other Updates (Blue/Green Bar)
- **Less urgent** but still important
- Bug fixes, performance improvements
- Usually larger number (50-200+)

**How to read it:**
- **Longer bar** = More updates needed = More work to do
- **Shorter bar** = Fewer updates = Less work
- **Goal:** Make all bars as SHORT as possible!

**What to do:**
1. **Fix Critical first** (red bar)
2. **Then fix Security** (orange bar)
3. **Then fix Other** (blue bar)

**Priority order:**
1. Critical updates on servers
2. Critical updates on workstations
3. Security updates on servers
4. Security updates on workstations
5. Everything else

---

## 📋 Understanding the Computer List

```
┌──────────────────────────────────────────────────────┐
│  Top Non-Compliant Computers                         │
├──────────────┬─────────┬──────────┬─────────────────┤
│ Computer     │ Critical│ Security │ Total Missing   │
├──────────────┼─────────┼──────────┼─────────────────┤
│ SERVER-DC01  │    5    │    12    │      28         │
│ WS-FINANCE01 │    3    │     8    │      15         │
│ LAPTOP-CEO   │    2    │     6    │      12         │
│ SERVER-SQL02 │    0    │     4    │       8         │
└──────────────┴─────────┴──────────┴─────────────────┘
```

**What it means:**
- This shows the WORST computers (most updates missing)
- These are the ones you need to fix first!

**How to read each column:**

### Computer Name
- This is the name of the computer
- Usually tells you something about it:
  - "SERVER-" = It's a server (IMPORTANT!)
  - "WS-" or "DESKTOP-" = It's a workstation
  - "LAPTOP-" = It's a laptop
  - Name might include location or person

### Critical Column
- How many critical updates this computer is missing
- **0** = Good! No critical missing
- **1-3** = Not great, but manageable
- **4+** = BAD! This computer is in danger!

### Security Column
- How many security updates missing
- Same idea as Critical column

### Total Missing
- ALL updates missing (critical + security + other)
- This is the total workload for this computer

**What to do:**
1. Start at the TOP of the list (worst offender)
2. Fix that computer first
3. Move down the list

**How to fix a computer:**
1. Find the computer (physically or remotely)
2. Open Windows Update
3. Click "Check for updates"
4. Click "Install updates"
5. Restart the computer
6. Check your dashboard again tomorrow - it should move down or off the list!

**What to tell your boss:**
- "These are our worst computers. I'm patching them in order from top to bottom."
- "SERVER-DC01 is the priority - it has 5 critical updates missing."

---

## 🚦 The Traffic Light System (Color Meanings)

Your dashboard might use colors to show how good or bad things are:

### 🟢 Green = Good!
- Compliance is 95% or higher
- Few or no critical updates missing
- Everything is healthy
- **Action:** Keep doing what you're doing!

### 🟡 Yellow = Warning!
- Compliance is 85-94%
- Some critical updates missing
- Getting worse
- **Action:** Pay attention! Fix things before they get worse!

### 🔴 Red = Bad!
- Compliance below 85%
- Many critical updates missing
- Dangerous situation
- **Action:** Fix this NOW! Drop everything!

---

## 📅 Daily Use Guide (What to Do Each Day)

### Monday Morning Routine (5 minutes)

**Step 1: Open Your Dashboard**
1. Find the file: "My WSUS Dashboard.pbix"
2. Double-click it
3. Wait for Power BI to open

**Step 2: Refresh the Data**
1. Click the **Refresh button** at the top (circular arrow ↻)
2. Wait 30 seconds
3. Now you have the latest numbers!

**Step 3: Check the Big Number**
- Look at Overall Compliance
- Is it **green** (95%+)? Great! Keep monitoring
- Is it **yellow** (85-94%)? Plan some patching this week
- Is it **red** (below 85%)? This is your top priority today!

**Step 4: Check Not Reporting**
- Look at the "Sleeping" or "Not Reporting" number
- If it's **under 10**: Normal, ignore
- If it's **10-50**: Investigate which computers
- If it's **over 50**: Major problem, investigate NOW

**Step 5: Check Critical Updates**
- Look at the Critical number
- If it's **0**: Perfect!
- If it's **1-10**: Approve and deploy this week
- If it's **10+**: Deploy immediately!

**Step 6: Look at the Top 5 Worst Computers**
- Scroll down to the table
- Look at the first 5 computers
- Add them to your "to fix" list for this week

**Done!** That's it for Monday!

### Tuesday-Thursday (2 minutes each day)

1. Open dashboard
2. Click Refresh
3. Quick glance at the main numbers
4. Did anything get worse?
   - **No:** Great! Continue working on your fix list
   - **Yes:** Investigate what changed

### Friday (5 minutes)

1. Open dashboard
2. Click Refresh
3. **Take a screenshot** (Windows + Shift + S)
4. Email it to your boss with a quick note:

**Example email:**
> Subject: Weekly WSUS Update
> 
> Hi [Boss Name],
> 
> This week's patch compliance: 92% (up from 89% last week!)
> 
> - Fixed 15 computers
> - Deployed 8 critical updates
> - Still working on 3 stubborn laptops
> 
> See attached dashboard.
> 
> [Your Name]

---

## 🎯 What Numbers to Track Over Time

### Keep a Simple Log

**In a notebook or spreadsheet, write down every Monday:**

| Date | Compliance % | Not Reporting | Critical Updates |
|------|--------------|---------------|------------------|
| 2/3  | 89%          | 15            | 23               |
| 2/10 | 92%          | 12            | 15               |
| 2/17 | 94%          | 10            | 8                |
| 2/24 | 96%          | 8             | 3                |

**Why track this?**
- Shows you're making progress!
- Your boss can see improvement
- You can see trends (getting better or worse?)

**What you want to see:**
- Compliance % going **UP** (89% → 92% → 94% → 96%)
- Not Reporting going **DOWN** (15 → 12 → 10 → 8)
- Critical Updates going **DOWN** (23 → 15 → 8 → 3)

---

## 🗣️ How to Talk to Different People About Your Dashboard

### Talking to Your Boss (Executive)

**They care about:**
- Are we secure?
- Are we compliant?
- Big picture numbers

**What to say:**
- ✅ "We're at 92% compliance - above our 90% target"
- ✅ "We have 3 critical security updates to deploy this week"
- ✅ "12 computers haven't checked in - I'm investigating"

**What NOT to say:**
- ❌ Don't use technical jargon: "WSUS synchronization issues"
- ❌ Don't go into details: "The vw_OverallCompliance query shows..."
- ❌ Don't make excuses: "Well, it's complicated because..."

**Just show the dashboard and point to the numbers!**

### Talking to IT Team (Technical)

**They care about:**
- Which specific computers
- Which specific updates
- Technical details

**What to say:**
- ✅ "SERVER-DC01 is missing 5 critical updates"
- ✅ "We have 15 computers not reporting in 30+ days"
- ✅ "KB5001234 needs to be approved and deployed"

**What to do:**
- Show them the computer list
- Point out the worst offenders
- Discuss deployment plan

### Talking to Auditors (Compliance)

**They care about:**
- Proof of compliance
- Historical tracking
- Documentation

**What to show:**
- ✅ The dashboard screenshot (current status)
- ✅ Your tracking log (historical data)
- ✅ List of what you've deployed

**What to say:**
- ✅ "We maintain 95%+ compliance"
- ✅ "We track metrics weekly"
- ✅ "Critical updates deployed within 7 days"

---

## 🆘 Common Questions & Answers

### "Why did my compliance go DOWN?"

**Possible reasons:**
1. **New updates were released** → More things to install (normal!)
2. **More computers checked in** → Showed us computers we didn't know about
3. **Servers came back from maintenance** → They haven't updated yet
4. **Laptops came back from travel** → Users been out of office

**What to do:**
- Don't panic! This is often normal
- Check what changed (new updates? new computers?)
- Plan to deploy the new updates

### "Why are some computers always on the list?"

**Possible reasons:**
1. **They're turned off** → Can't update if they're off!
2. **Users decline updates** → They click "Remind me later" forever
3. **Updates fail** → Something's broken on that computer
4. **Special configurations** → Maybe they CAN'T update (legacy software)

**What to do:**
1. Contact the user → Ask them to leave computer on overnight
2. Force updates → Use Group Policy to auto-install
3. Fix the computer → Reinstall Windows if needed
4. Document exceptions → If it CAN'T update, document WHY

### "Is 92% good enough?"

**It depends on your company policy:**

**Most companies:**
- Target: 95% or higher
- Acceptable: 85-95%
- Unacceptable: Below 85%

**High-security companies:**
- Target: 98% or higher
- Acceptable: 95-98%
- Unacceptable: Below 95%

**Small companies:**
- Target: 90% or higher
- Acceptable: 80-90%
- Unacceptable: Below 80%

**Ask your boss:** "What's our target compliance percentage?"

### "How often should I check this?"

**Minimum:**
- Once a week (every Monday morning)

**Recommended:**
- Once a day (quick 2-minute check)

**If you're behind:**
- Twice a day until you catch up

### "What should I do first?"

**Priority order (do these in order!):**

1. **Critical updates on servers** (HIGHEST PRIORITY!)
2. **Critical updates on all computers**
3. **Security updates on servers**
4. **Security updates on all computers**
5. **Everything else**

**Why servers first?**
- Servers are more important
- More users depend on them
- Bigger security risk if compromised

---

## 📱 Quick Reference Card (Print This!)

```
╔══════════════════════════════════════════════════════╗
║         WSUS DASHBOARD QUICK GUIDE                   ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  COMPLIANCE %:                                       ║
║  • 95%+ = Green/Excellent                           ║
║  • 85-94% = Yellow/Good                             ║
║  • Below 85% = Red/Bad                              ║
║                                                      ║
║  NOT REPORTING:                                      ║
║  • 0-10 = Normal                                     ║
║  • 10-50 = Investigate                              ║
║  • 50+ = Problem!                                    ║
║                                                      ║
║  CRITICAL UPDATES:                                   ║
║  • 0 = Perfect                                       ║
║  • 1-10 = Fix this week                             ║
║  • 10+ = Fix NOW!                                    ║
║                                                      ║
║  DAILY ROUTINE:                                      ║
║  1. Open dashboard                                   ║
║  2. Click Refresh (↻)                               ║
║  3. Check main numbers                               ║
║  4. Look at worst computers                          ║
║  5. Fix top 3 on list                               ║
║                                                      ║
║  PRIORITY ORDER:                                     ║
║  1. Critical on servers                             ║
║  2. Critical on workstations                        ║
║  3. Security on servers                             ║
║  4. Security on workstations                        ║
║  5. Everything else                                  ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
```

---

## ✅ Action Plan for Today

**If you just opened your dashboard for the first time:**

1. [ ] Look at Overall Compliance number
2. [ ] Is it green (95%+), yellow (85-94%), or red (below 85%)?
3. [ ] Write it down: _____%
4. [ ] Look at Critical Updates number
5. [ ] Write it down: _____
6. [ ] Look at the top 3 worst computers
7. [ ] Write their names down:
   - _______________________
   - _______________________
   - _______________________
8. [ ] Plan to fix those 3 this week
9. [ ] Take a screenshot for your records
10. [ ] Set a reminder to check again Monday

**Done! You now understand your dashboard!** 🎉

---

## 🎓 Congratulations!

You now know:
- ✅ What each number means
- ✅ What's good and what's bad
- ✅ What to do about it
- ✅ How to track progress
- ✅ How to talk to your boss about it

**Keep this guide handy and refer to it whenever you look at your dashboard!**

**Remember:** 
- Check it weekly (minimum)
- Track your progress
- Fix worst computers first
- Share wins with your boss

**You've got this!** 🚀
