# How to Set Up a Self‑Hosted Calendar & Contacts Server on iPhone and macOS (Using Baïkal)

## Why Self‑Host?

You want full control over your calendar and contacts—without relying on Google, Apple, or other cloud providers—you can **self‑host** them. This guide shows how to connect an **iPhone** or **macOS** device to a self‑hosted **CalDAV** (calendar) and **CardDAV** (contacts) server using **Baïkal**.

* You own your data
* No ads or tracking
* Works with Apple, Android, Linux, and Windows
* One server, many devices, many accounts

---

## What Are CalDAV and CardDAV?

* **CalDAV**: Syncs calendars (events, reminders, notes)
* **CardDAV**: Syncs contacts (names, phone numbers, emails)

Once set up, your calendars and contacts will automatically sync across your devices.

---

## What You Need Before You Start

Make sure the following are ready:

* A working **Baïkal** server (already installed)
* A domain name, for example:

```yaml
https://baikal.example.org
```

* A **username and password** created in Baïkal
* **SSL enabled** (HTTPS)
* Port **443** open (this is the default HTTPS port)

> If your Baïkal web interface works in a browser using `https://`, you’re good to go.

---

## Important URLs You’ll Need

Replace `<username>` with your actual Baïkal username.

### CardDAV (Contacts)

```
https://baikal.example.org/html/card.php/principals/<username>/
```

### CalDAV (Calendar)

```
https://baikal.example.org/html/cal.php/principals/<username>/
```

---

# Setting Up on iPhone / iPad (iOS)

### Step 1: Open Settings

1. Go to **Settings**
2. Tap **Contacts** (for contacts) or **Calendar** (for calendars)
3. Tap **Accounts**
4. Tap **Add Account**

---

### Step 2: Add CardDAV (Contacts)

1. Tap **Add Account** → **Other**
2. Tap **Add CardDAV Account**

Fill in the fields:

* **Server**:

  ```
  baikal.example.org
  ```
* **User Name**: your Baïkal username
* **Password**: your Baïkal password
* **Description**: e.g. `My Contacts`

Tap **Next**.

✅ Your contacts will now sync automatically.

---

### Step 3: Add CalDAV (Calendar)

1. Go back to **Add Account** → **Other**
2. Tap **Add CalDAV Account**

Fill in:

* **Server**:

  ```
  baikal.example.org
  ```
* **User Name**: your Baïkal username
* **Password**: your Baïkal password
* **Description**: e.g. `My Calendar`

Tap **Next**.

✅ Your calendar is now connected.

---

# Setting Up on macOS

### Step 1: Open Internet Accounts

1. Open **System Settings** (or **System Preferences**)
2. Go to **Internet Accounts**
3. Click **Add Account**
4. Choose **Other Account…**

---

### Step 2: Add CardDAV (Contacts)

1. Click **Add CardDAV Account**
2. Choose **Manual**

Enter the following:

* **User Name**: your Baïkal username
* **Password**: your Baïkal password
* **Server Address**:

  ```
  https://baikal.example.org/html/card.php/principals/<username>/
  ```

Click **Sign In**.

---

### Step 3: Add CalDAV (Calendar)

1. In **Internet Accounts**, click **Add CalDAV Account**
2. Choose **Manual**

Enter:

* **User Name**: your Baïkal username
* **Password**: your Baïkal password
* **Server Address**:

  ```
  https://baikal.example.org/html/cal.php/principals/<username>/
  ```

Click **Sign In**.

---

## How to Check If It Works

* Open the **Contacts** app → your contacts should appear
* Open the **Calendar** app → your calendars should be visible
* Create a test contact or event and check if it syncs to another device

---



Happy self‑hosting 🚀
